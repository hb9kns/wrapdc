#!/bin/sh
# wrapper for dc
info="wrapper for dc // 2018-5-1 Y.Bonetti // see https://github.com/hb9kns/wrapdc"
# global status file
statf=$HOME/.wdcrc
# output file (last stack top)
outf=${TMPDIR:-/tmp}/wdc-$USER
# clear state: precision 2, clear stack and reg.0..9
clstat='2k 0 0 0 0 0 0s00s10s20s30s40s50s60s70s80s9'
if test ! -r $statf
then echo $clstat >$statf
fi

if test "$1" = "-v"
then verbose='echo' ; shift
else verbose=':'
fi

# macros defined as sed patterns
# (kill all '!' not part of comparison commands, and also comments)
mcrs='
s,%t,S.dL.100*S.S:L.L:/,g;# percent part: X:=100*X/Y, Y kept
s,%d,S.ddL.-_100*S.S:L.L:/,g;# percent delta: X:=100*(X-Y)/Y, Y kept
s,%f,S.dl.*100L.-/,g;# percent future: X:=Y*X/(100-X), Y kept
s,%,S.dL.*100/,g;# percentage: X:=X*Y/100, Y kept
s,hm,r60*+,g;# hoursminutes: X:=X+Y*60
s,rem,\%,g;# remainder: X:=Y%X (instead of normal '%' command)
s,sto\(.\),s\1l\1,g;# sto.: store with copying (i.e keep value on stack)
s,fact,[S.l.*L.1-d0<:]S:S.1L.l:x0*s:L:+,g;# factorial: X:=X!
s,neg,_1*,g;# negate: X:=-X
s,inv,S.1L./,g;# inverse: X:=1/X
s,\$m,[l4l1/l2l1/]S.l10!=.s.L.,g;# mean value: X:=reg.2/reg.1, Y:=reg.4/reg.1
s,\$-,dL2r-s2dd*L3r-s3rdL4r-s4dd*L5r-s5*L6r-s6L11-s1,g;# remove statistic entry
s,\$+*,dL2+s2dd*L3+s3rdL4+s4dd*L5+s5*L6+s6L11+s1,g;# add statistic entry
s, , ,;# statistic registers:1=n 2=sumX 3=sumX^2 4=sumY 5=sumY^2 6=sumXY
s,[eE]\(_*[0-9][0-9]*\), 10 \1^*,g;# infix exponential: X:=X*10^N
s,drop,0*+,g;# stack drop
s,r,S.S:L.L:,g;# revert: X:=Y, Y:=X ('r' is a GNU extension)
 s,![ 	]*[^<=>].*,,
 s,#.*,,
'
# get stored stack from statf, process input, and finish with
# storing current precision (like "2k"), memories, and top 5 of stack,
# and print stack top ("X register")
cycl(){
# get status, ignore error lines from unknown commands, clear arguments
 stat=`grep -v unimplemented $statf`
 args=''
# process direct commands
 case $1 in
 help*) cat <<EOH >&2

$info

top 5 stack positions, registers 0-9 ("memories") and precision are saved
 in '$statf'
direct commands:
 list (defined macros)
 verb (verbose display: status and arguments) | noverb (normal display)
 clear (clear state: standard precision, clear stack and memories)

stack top value is displayed after each processed line:
EOH
 ;;
 verb*) verbose='echo' ;;
 noverb*) verbose=':' ;;
 list) echo "$mcrs"|grep '^s,'|sed -e 's/s,/: /;s/,.*#/ #/' >&2 ;;
 clear) args="$clstat" ;;
# if no command, get args, convert macros
 *) args=`echo "$@"|sed -e "$mcrs"` ;;
 esac
$verbose :status: "$stat"
$verbose :arguments: "$args" >&2
$verbose >&2
# read old status, actual input, and status preparation commands, pass to dc,
# recreate dc specific minus signs, and join continuation lines
 cat <<ENDOFDCINPUT | dc 2>/dev/null | sed -e 's/^-/_/' -e :a -e '/\\$/N; s/\\\n//; ta'>$statf
$stat
$args
# save stack in registers A-E
SASBSCSDSE
# print '#' (ASCII value 35) and info strings
35P[ config file generated on `date` by
]n
35P[ $info
]n
# print precision and 'k' and 'c' to clear stack when loading
Kn[kc
]n
# print contents of registers 0-9 (memories) and storage command
l0n[s0
]nl1n[s1
]nl2n[s2
]nl3n[s3
]nl4n[s4
]nl5n[s5
]nl6n[s6
]nl7n[s7
]nl8n[s8
]nl9n[s9
]n
# clear stack, store 0 in reg.'.' and macro in reg.':', which compares stack
# depth with 1 (in case of empty stack generated by this '1') and if equal,
# prints 0 (from reg.'.'), else former top of stack, and clears stack
c 0s. [1z=.nc]s:
# apply macro in reg.':' to all saved stack values, and separate with NL
LEl:x[
]nLDl:x[
]nLCl:x[
]nLBl:x[
]nlAl:x[ # ]n
# print exponentialized version of stack top as comment:
# A=(number of digits - number of fraction digits - 1) of stack top,
# divide stack top by 10^A and print, print A
lA10lAZLAX-1-sAlA^/n[E]nLAp
ENDOFDCINPUT
# save stack top in output file for further direct processing
 tail -n 1 $statf | sed -e 's/ *#.*//' >$outf
# print stack top
 tail -n 1 $statf
}

if test "$1" = ""
# process STDIN ..
then while read line
 do case $line in
  q*) exit ;;
  esac
  cycl "$line"
 done
# .. or arguments
else cycl "$@"
fi
