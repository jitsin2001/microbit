\ Minimalist forth for brining up the NXP 11u37


((
Change history
==============
))


\ ================
\ *! tiva
\ ================

only forth definitions  decimal


\ ******************************
\ Define the default directories
\ ******************************

\ MPE macros
c" ./Common" setmacro CommonDir	\ where the common code lives
c" ./Cortex" setmacro CpuDir		\ where the CPU specific code lives
c" ."		setmacro HWDir		\ where board specific code lives
c" ."    	setmacro AppDir		\ where application code lives

c" ./Drivers" setmacro DriverDir \ Driver Code

c" ../embedded/cm3forthtools/"    setmacro LocalCM3	\ Cortex-M common forth 


\ ***************************************
\ Load compiler extensions such as macros
\ ***************************************

include %CpuDir%/Macros

\ *********************************************************
\ Turn on the cross compiler and define CPU and log options
\ *********************************************************

\ file: nxp11uxx.log                \ uncomment to send log to a file

CROSS-COMPILE

only forth definitions          \ default search order

  Cortex-M0                     \ Thumb-2 processor type and register usage

  \ no-log                        \ uncomment to suppress output log
  rommed                        \ split ROM/RAM target
  interactive                   \ enter interactive mode at end
Stamp? 0= [if] +xrefs [then]	\ enable cross references
  align-long                    \ code is 32bit aligned
  +LongCalls			\ permit standalone Forth to handle
  				\ calls outside 25 bit range.
 hex-i32   

0 equ false
-1 equ true

\ *******************
\ *S Configure target
\ *******************

\ =====================
\ *N 11Uxx Definitions.
\ =====================

#16 cells equ /ExcVecs	\ -- len
\ *G Size of the exception/interrupt vector table. There are
\ ** 16 reserved by ARM

\ =============
\ *N Memory map
\ =============


\ *P The Flash memory starts at $0000:0000. 

  $0003:0000 $0003:FFFF cdata section uBit	\ code section in boot Flash

  $2000:2700 $2000:287f idata section PROGd	\  IDATA
  $2000:2880 $2000:2BFF udata section PROGu	\  UDATA

interpreter
: prog uBit ;			\ synonym
target

PROG PROGd PROGu  CDATA                 \ use Code for HERE , and so on


\ ============================
\ *N Stack and user area sizes
\ ============================

$100 equ UP-SIZE		\ size of each task's user area
$080 equ SP-SIZE		\ size of each task's data stack
$080 equ RP-SIZE		\ size of each task's return stack
up-size rp-size + sp-size +
  equ task-size			\ size of TASK data area
\ define the number of cells of guard space at the top of the data stack
#4 equ sp-guard			\ can underflow the data stack by this amount

#128 equ TIB-LEN		\ terminal i/p buffer length

\ define nesting levels for interrupts and SWIs.
0 equ #IRQs			\ number of IRQ stacks,
				\ shared by all IRQs (1 min)
0 equ #SVCs			\ number of SVC nestings permitted
				\ 0 is ok if SVCs are unused

#0 equ console-port	\ -- n ; Designate serial port for terminal (0..n).
 1 equ useUART0? 
\ *G Ports 1..5 are the on-chip UARTs. The internal USB device
\ ** is port 10, and bit-banged ports are defined from 20 onwards.

#10 equ tick-ms		\ -- ms
\ *G Timebase tick in ms.

\ ***************************************
\ Load compiler extensions such as macros
\ ***************************************


\ =====================
\ *N Software selection
\ =====================

\ Kernel components
 1 equ ColdChain?		\ nz to use cold chain mechanism
 0 equ tasking?			\ true if multitasker needed
   #16 cells equ tcb-size		\   for internal consistency check
   0 equ event-handler?		\   true to include event handler
   0 equ message-handler?	\   true to include message handler
   0 equ semaphores?		\ true to include semaphores
 0 equ timebase?		\ true for TIMEBASE code
 0 equ softfp?			\ true for software floating point
 0 equ FullCase?		\ true to include ?OF END-CASE NEXTCASE extensions
 0 equ target-locals?		\ true if target local variable sources needed
 0 equ romforth?		\ true for ROMForth handler
 0 equ blocks?			\ true if BLOCK needed
 $0000 equ sizeofheap		\ 0=no heap, nz=size of heap
   1 equ heap-diags?		\   true to include diagnostic code
 0 equ paged?			\ true if ROM or RAM is paged/banked
 0 equ ENVIRONMENT?		\ true if ANS ENVIRONMENT system required

\ *****************
\ default constants
\ *****************

cell equ cell				\ size of a cell (16 bits)


\ ************
\ *S Kernel files
\ ************
  include %CpuDir%/CM0Def		\ Cortex generic equates and SFRs
  include %CpuDir%/StackDef		\ Reserve default task and stacks
  PROGd  sec-top 1+ equ UNUSED-TOP  PROG	\ top of memory for UNUSED
  
  include %AppDir%/StartCM0		\ basic Cortex-M3 startup code
  include %CpuDir%/CodeM0M1		\ low level kernel definitions

  include %AppDir%/interconnect 
  include %LocalCM3%/aapcs	        \ ARM procedure calling standards wrappers.

  include %CommonDir%/kernel62          \ high level kernel definitions
  include %AppDir%/kernel-quit          \ customized QUIT.
  include %CommonDir%/Devtools		\ DUMP .S etc development tools
  \ include %CommonDir%/Voctools		\ ORDER VOCS etc
  include %CommonDir%/methods		\ target support for methods
  \ include %CpuDir%/LocalCM3		\ local variables
 

  \ include %SPDir%/SAPI-Core     	\ Core SAPI functions.
  \ include %SPDir%/dylink     		\ Runtime Linking

  \ include %LocalCM3%/bitband
  \ include %CpuDir%/MultiCortex		\ multi-tasker, MUST be before TIMEBASE

timebase? [if]
  include %CommonDir%/timebase		\ time base common code, MUST be before SysTickxxx
  include %CommonDir%/Delays		\ time delays
  ' start-timers AtCold
[else]
  \ include %CommonDir%/Delays
[then]

environment? [if]
  include %CommonDir%/environ		\ ENVIRONMENT?
[then]

SIZEOFHEAP [if]
  include %CommonDir%/heap32		\ memory allocation set
[then]

\ *************
\ *S End of kernel
\ *************

buildfile ubit-basic.no
l: version$
  build$,
l: BuildDate$
  DateTime$,

internal
: .banner	\ --
  cr ." ********************************"
;

: .CPU		\ -- ; display CPU type
  ." MPE ROM PowerForth for Cortex-M0" cr
  BuildDate$ $. space  [char] v emit version$ $. 
;
external

: ANS-FORTH	\ -- ; marker
;


\ *******************
\ *S Application code
\ *******************

include %DriverDir%/serLE_p \ polling serial driver

include %AppDir%/startup
\ ' hex AtCold

' startapp AtCold

\ ***************
\ *S Finishing up
\ ***************

libraries	\ to resolve common forward references
  include %CpuDir%/LibCortex
  include %CommonDir%/LIBRARY
end-libs

\ Force binary file to 512 byte unit.
cdata
  flush-idata                           \ force IDATA sections to be laid
  					\ NOW, rather than by FINIS
  here $1FF +  $-0200 and org		\ force to 512 byte boundary for ISP loader

decimal

\ XREF DUP                              \ where is DUP used?
\ XREF-ALL                              \ full cross reference
\ XREF-UNUSED                           \ find unused words

update-build
FINIS

\ ======
\ *> ###
\ ======

