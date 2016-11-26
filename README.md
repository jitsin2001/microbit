# microbit
MPE Forth for the BBC Microbit

The MicroBit is well-managed environment.   This port works in conjunction
with a launcher thats built in the the mBed environment.  

The microbit mBed web build environment doesn't give us access to the linker 
map or the source code for the microbit executive.   

This port needs an mBed-supplied hex file that allocates the forth memory
and then launches forth.

Forth makes direct calls to the microbit libary functions.

