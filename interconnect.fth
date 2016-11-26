\ Interconnection/Run Time Linking layer.
\ This stuff is pretty fundamental.  Include it early
\ Its organized along the general lines of the uBit library.

udata 
create ICROOT cell allot 
create SAVEDRSP cell allot 
cdata

\ The table of tables.
struct ic.table
 	int ic.ubit
	int ic.serial
	int ic.display
end-struct 

\ ------------------------------------
\ Microbit functions
\ ------------------------------------
struct mbed.table
	int ubit.reset
	int ubit.sleep
	int ubit.random
	int ubit.ticks
end-struct

: TICKS ( -- n ) icroot @ ic.ubit @ ubit.ticks @ call0--n ; 
: UBSLEEP ( n -- ) icroot @ ic.ubit @ ubit.sleep @ swap call1-- ; 

\ ------------------------------------
\ Serial functions.   
\ ------------------------------------
struct ser.table
	int ser.baud
	int ser.emit
	int ser.type
	int ser.cr
	int ser.keyq
	int ser.key
end-struct





