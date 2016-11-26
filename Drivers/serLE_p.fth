\ serLE_p.fth - Polled Driver for microbit.
\ requires interconnect.fth
\

\ ********************
\ *S Serial primitives
\ ********************

internal

: +FaultConsole	( -- )  ;
\ *G Because this is a polled driver, *\fo{+FaultConsole} for
\ ** fault handling is a *\fo{NOOP}. See *\i{Cortex/FaultCortex.fth}
\ ** for more details.

: (seremit)	\ char --
\ *G Transmit a character on the given UART.
  icroot @ ic.serial @ ser.emit @ \ Double-indirect lookup.
  swap call1--
;

: (sertype)	\ caddr len --
\ *G Transmit a string on the given UART.
  bounds
  do i c@ (seremit)  loop
;

: (sercr)	\ --
\ *G Transmit a CR/LF pair on the given UART.
  icroot @ ic.serial @ ser.cr @ \ Double-indirect lookup.
  call0--
;

-1 value PENDKEY

: (serkey?)	\ -- t/f
\ *G Return true if the given UART has a character avilable to read.
  icroot @ ic.serial @ ser.keyq @ \ Double-indirect lookup.
  call0--n
  dup #-1012 = if  \ Check for the magic value that means nothing
     drop -1 to pendkey false 
    else 
     to pendkey true
    then 
;

: (serkey)	\ -- char
\ *G Wait for a character to come available on the given UART and
\ ** return the character.
  pendkey -1 = if 
    begin
    [ tasking? ] [if]  pause  [then]
    (serkey?) 
    until
  then 
  pendkey -1 to pendkey  
;

: initUART	\ divisor22 base --
  drop drop
;

external

\ ********
\ *S UART0
\ ********

useUART0? [if]

: init-ser0	; 

: seremit0	\ char --
\ *G Transmit a character on UART0.
  (seremit)  ;
  
: sertype0	\ c-addr len --
\ *G Transmit a string on UART0.
  (sertype)  ;

: sercr0	\ --
\ *G Issue a CR/LF pair to UART0.
  (sercr)  ;

: serkey?0	\ -- flag
\ *G Return true if UART0 has a character available.
  (serkey?)  ;

: serkey0	\ -- char
\ *G Wait for a character on UART0.
  (serkey)  ;

create Console0	\ -- addr ; OUT managed by upper driver
\ *G Generic I/O device for UART0.
  ' serkey0 ,		\ -- char ; receive char
  ' serkey?0 ,		\ -- flag ; check receive char
  ' seremit0 ,		\ -- char ; display char
  ' sertype0 ,		\ caddr len -- ; display string
  ' sercr0 ,		\ -- ; display new line
console-port 0 = [if]
  console0 constant console
\ *G *\fo{CONSOLE} is the device used by the Forth system for interaction.
\ ** It may be changed by one of the phrases of the form:
\ *C   <device>  dup opvec !  ipvec !
\ *C   <device>  SetConsole
[then]

[then]


\ ************************
\ *S System initialisation
\ ************************

: init-ser	\ --
\ *G Initialise all serial ports
  [ useUART0? ] [if]  init-ser0  [then]
;


\ ======
\ *> ###
\ ======

decimal
