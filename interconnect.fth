\ 

udata 
create ICROOT cell allot 
create SAVEDRSP cell allot 
cdata

struct ic.table
 	int ic.ubit
	int ic.serial
	int ic.display
end-struct 


struct mbed.table
	int ubit.reset
	int ubit.sleep
	int ubit.ticks
end-struct

struct ser.table
	int ser.baud
	int ser.emit
	int ser.type
	int ser.cr
	int ser.keyq
	int ser.key
end-struct


