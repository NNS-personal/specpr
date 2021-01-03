        subroutine getnst2(il)

#	gets the number of optical constant sets
#
        implicit integer*4 (i-n)
	include "../../src.specpr/common/lundefs"
	include "../../src.specpr/common/alphabet"
	include "defs.h"
	include "lmrefl.h"



10	write (ttyout, 15) NMINL, NMMIX
15	format (' Type in the number of input optical index sets in ',
                ' the intimate mixture (max sets =',i3,')',/,
                ' Note each set can be a molecular mix of',i3,
                     ' components.',/)

	call crtin
	i = 1
	call wjfren (i,x,il)
	#write (ttyout,'("x=",f9.5)') x
	if (il == ihe || il == ihx) go to 10000
	if (il != 0 || x < 1 || x > NMINL) {
		call what(i)
		write (ttyout, 20)
20		format (' input error, reenter')
		go to 10
	}
	nminer = nint(x)
	write (ttyout, 30) nminer
30	format (1x, i6, ' optical index sets allowed',
		' in this computation',/)

10000	return
	end 
