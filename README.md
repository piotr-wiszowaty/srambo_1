srambo\_1
========

srambo\_1 is a yet another 320 kB Atari XE memory expansion. It designed for
Atari 130 XEs and 65 XEs with ECI connector.

Description
-----------

The device has two modes of operation (selected with a jumper):

1. 'Rambo' - extended memory banks are selected with PORTB bits 2, 3, 5, 6.
   Access to extended memory by both CPU and ANTIC is controlled with PORTB
   bit 4.
   To turn on this mode one needs to connect pins AUX3 and AUX4.
2. 'Compy' - extended memory banks are selected with PORTB bits 2, 3, 6, 7.
   Access to extended memory by CPU is controlled with PORTB bit 4. Access to
   extended memory by ANTIC is controlled with PORTB bit 5.
   To select this mode one needs to connect pins AUX3 and AUX2.

Sources
-------

`cpld/` - CPLD design files (ISE WebPack 14.7)

`pcb/`  - PCB design files (Kicad 4.0.3)

Installation
------------

All Atari modifications are easily reversible (provided one does not - for
example - destroy any tracks during desoldering process).
To install the expansion one needs to:

0. Assemble the memory expansion (obviously)
1. Desolder all DRAM chips (U9..U16, U26..U33)
2. Desolder MMU chip (U34)
3. Desolder EMMU chip U3 (130 XE) or three wire jumpers (65 XE)
4. Solder a wire between U23 PIA pin 16 and U3 EMMU pin 12
5. Solder appropriate pin-header sockets into the motherboard (see PCB design
   files for reference)
6. Plug the assembled device into the sockets

References
----------

Various parts of control logic are based on [576 kB memory expansion](http://atarionline.pl/v01/index.php?subaction=showfull&id=1235583828&archive=&start_from=0&ucat=6&ct=wynalazki&amp%253Bamp%253Bucat=1%253Bamp%253Bsubaction%253Dshowfull%252Ftrackback) by ASAL.
