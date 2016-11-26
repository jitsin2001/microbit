
: QUIT		\ -- ; R: i*x --
\ *G Empty the return stack, store 0 in *\fo{SOURCE-ID}, and enter
\ ** interpretation state. *\fo{QUIT} repeatedly *\fo{ACCEPT}s a
\ ** line of input and *\fo{INTERPRET}s it, with a prompt if
\ ** interpreting and *\fo{ECHOING} is on. Note that any task that
\ ** uses *\fo{QUIT} must initialise *\fo{'TIB}, *\fo{BASE},
\ ** *\fo{IPVEC}, and *\fo{OPVEC}.
[ blocks? ] [if]
  blk off
[then]
  xon/xoff off  echoing on              \ No Xon/Xoff, do Echo
  0 to source-id  [compile] [		\ set up
  begin
    \ r0 @ rp!                            \   reset return stack
    echoing @ if  cr  then              \   if echoing enabled issue new line
    query				\   get user input
    ['] interpret catch ?dup 0= if	\   interpret line
      state @ 0=  echoing @ 0<>  and if	\   if interpreting & echoing
        ."  ok"  depth ?dup		\     prompt user
        if  ." -" .  then
      then
    else
      .throw  s0 @ sp!  [compile] [	\    display error, clean up
      cr source type			\    display input line
      cr >in @ 1- spaces ." ^"		\    display pointer to error
    then
  again                                 \   do next line
;

