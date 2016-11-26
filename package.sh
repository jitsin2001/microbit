#!/bin/sh
BASEFILE=MBexposed2_NRF51_MICROBIT.hex

{
	sed '$d' ${BASEFILE};
	cat UBIT.hex;
} > mb.hex 


