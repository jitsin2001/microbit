(( App Startup ))

: serkeytest 
  begin
   key . 
  again
;

: serkeytest2
  begin
   begin 
    key?
   until 
   ." ." key . 
  again

;

: linetest
  ." Tib@" tib . ." Len:" #tib @ . cr
  ." next-user " next-user @ . cr
  ." Waiting for input " 
  query 'tib @ 20 dump
;



\ -------------------------------------------
\ The word that sets everything up
\ -------------------------------------------
: StartApp
	hex
	cr
	." DP: " sp@ . cr
	." RP: " rp@ . cr 
	." SYS:" control sys@ . cr
	s0 $40 ldump
	icroot 10 ldump
	\ serkeytest
	\ linetest
	\ $20002800 $400 ldump
;

