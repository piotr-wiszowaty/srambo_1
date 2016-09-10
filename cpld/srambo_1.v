//    srambo_1
//    Copyright (C) 2016  Piotr Wiszowaty
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see http://www.gnu.org/licenses/.

`timescale 1ns / 1ps
module srambo_1 (
	input o2,			// clock input
	input n_we,			// RAM write enable
	input n_ras,		// RAM row address strobe
	input a15,			// RAM address A15
	input a14,			// RAM address A14
	input a13,			// RAM address A13
	input a12,			// RAM address A12
	input a11,			// RAM address A11
	input a7,			// RAM address A7
	input a6,			// RAM address A6
	input a5,			// RAM address A5
	input a4,			// RAM address A4
	input a3,			// RAM address A3
	input a2,			// RAM address A2
	input a1,			// RAM address A1
	input a0,			// RAM address A0
	input pb2,			// bank select bit
	input pb3,			// bank select bit
	input pb4,			// 0: CPU extended RAM in $4000-$7FFF, 1: main RAM
	input pb5,			// 0: ANTIC extended RAM in $4000-$7FFF, 1: main RAM
	input pb6,			// bank select bit
	input casin, 		// RAM column address strobe (from Freddie)
	output fa14, 		// main RAM access: copy of A14, ext. RAM access: copy of PB2
	output fa15, 		// main RAM access: copy of A15, ext. RAM access: copy of PB3
	output n_s4,		// access cardridge in $8000-$9FFF
	output n_s5,		// access cartridge in $A000-$BFFF
	input n_be,			// 0: Basic in $A000-$BFFF, 1: RAM
	output n_io,		// 0: I/O access ($D000-$D7FF)
	output n_ci,		// 0: non-RAM access, 1: RAM access
	input n_map,		// 0: SelfTest $5000-$57FF, 1: RAM
	output n_os,		// 0: OS ROM active
	input rd4,			// 0: no cartridge in $8000-$9FFF, 1: cartridge
	input rd5,			// 0: no cartridge in $A000-$BFFF, 1: cartridge
	input n_mpd,		// 0: disable ROM in $D800-$DFFF, 1: enable ROM
	output n_basic,		// 0: Basic ROM access, 1: no Basic ROM access
	input ren,			// 0: RAM enable in $C000-$CFFF and $D800-$FFFF, 1: ROM
	input n_ref,		// 0: RAM refresh, 1: address valid
	output casman,		// /CASMAN
	output casbnk,		// /CASBNK
	output emmu_11,
	input halt,
	output [18:0] ram_addr,
	output ram_n_we,
	output ram_n_oe,
	output aux0,
	output aux1,
	output aux2,	// 0
	input aux3,		// mode select: 0=rambo, 1=compy shop
	output aux4,	// 1
	output aux5,
	output aux6);

reg n_map_r = 1;
reg n_be_r = 1;
reg halt_r = 1;
reg [7:0] a7_0_r;

wire a_4000_7fff = ~a15 &  a14;
wire a_5000_57ff = ~a15 &  a14 & ~a13 &  a12 & ~a11;
wire a_8000_9fff =  a15 & ~a14 & ~a13;
wire a_a000_bfff =  a15 & ~a14 &  a13;
wire a_c000_cfff =  a15 &  a14 & ~a13 & ~a12;
wire a_d000_d7ff =  a15 &  a14 & ~a13 &  a12 & ~a11;
wire a_d800_dfff =  a15 &  a14 & ~a13 &  a12 &  a11;
wire a_e000_ffff =  a15 &  a14 &  a13;

wire select_rambo = ~aux3;
wire select_compy = aux3;
wire bank_enable = a_4000_7fff &
			       ((select_rambo & ~pb4)
				   | (select_compy & ~pb4 & halt_r)		// CPU
				   | (select_compy & ~pb5 & ~halt_r));	// ANTIC

wire ram_a18 = bank_enable;
wire ram_a17 = (bank_enable & select_compy) ? n_map :
			   (bank_enable & select_rambo) ? pb6 : 0;
wire ram_a16 = (bank_enable & select_compy) ? pb6 :
			   (bank_enable & select_rambo) ? pb5 : 0;
wire ram_a15 = (bank_enable & select_compy) ? pb3 :
			   (bank_enable & select_rambo) ? pb3 : a15;
wire ram_a14 = (bank_enable & select_compy) ? pb2 :
			   (bank_enable & select_rambo) ? pb2 : a14;

wire n_cart = n_s4 | n_s5;

assign fa14 = a14;
assign fa15 = a15;

assign n_s4 = ~(rd4 & a_8000_9fff);
assign n_s5 = ~(rd5 & a_a000_bfff);

assign n_io = ~(n_ref & a_d000_d7ff);
assign n_os = ~(n_ref & ren & (a_c000_cfff | (n_mpd & a_d800_dfff) | a_e000_ffff | (~n_map_r & a_5000_57ff)));
assign n_basic = ~(n_ref & ~n_be_r & ~rd5 & a_a000_bfff);
assign n_ci = ~(~n_ref | ~n_io | ~n_os | ~n_basic | ~n_cart);

assign ram_n_oe = ~(~casin & o2);
assign ram_n_we = ~(~n_we & ~casin & o2);
assign ram_addr = {ram_a18,	// 18
	               ram_a17,	// 17
				   ram_a16,	// 16
				   ram_a15,	// 15
				   ram_a14,	// 14
				   a6,		// 13
				   a5,		// 12
				   a4,		// 11
				   a3,		// 10
				   a2,		// 9
				   a1,		// 8
				   a7_0_r};	// 7..0

always @(negedge n_ras) begin
	a7_0_r <= {a7, a6, a5, a4, a3, a2, a1, a0};
end

always @(posedge n_ras) begin
	halt_r <= halt;
end

always @(negedge o2) begin
	if (pb4 & (pb5 | select_rambo)) begin
		n_map_r <= n_map;
		n_be_r <= n_be;
	end
end

assign aux0 = n_cart;
assign aux1 = n_ci;
assign aux2 = 0;
assign aux4 = 1;
assign aux5 = ram_n_we;
assign aux6 = ram_n_oe;

assign casman = 0;
assign casbnk = 0;
assign emmu_11 = 0;

endmodule
