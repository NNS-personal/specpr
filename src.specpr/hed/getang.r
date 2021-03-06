	subroutine getang (d,m,s,er)
	implicit integer*4 (i-n)

#ccc  version date: 5/6/85
#ccc  author(s): Roger Clark
#ccc  language:  Ratfor
#ccc
#ccc  short description:
#ccc                   This subroutine retrieves angle from iopcon and
#ccc                   checks for validity. if valid er=0. if not er=1.
#ccc                   if r ( return ) is entered as first character,
#ccc                   er=2
#ccc  algorithm description: none
#ccc  system requirements:   none
#ccc  subroutines called:
#ccc                    wjfren
#ccc  argument list description:
#ccc       arguments: h,m,s,er
#ccc  parameter description:
#ccc  common description:
#ccc  message files referenced:
#ccc  internal variables:
#ccc  file description:
#ccc  user command lines:
#ccc  update information:
#ccc  NOTES:
#ccc
########################################################################
#                                                                      #
# subroutine retrieves time from iopcon and checks                     #
# that d is between 0 and 359, m is between 0 and 59,                  #
# and s is between 0 and 59.99999.  if data valid, er=0.  if not, er=1.#
# if r (return) is entered as 1st character, er=2.                     #
#                                                                      #
########################################################################

	integer*4 d,m,er
	real*4 s
	include "../common/lundefs"
	include "../common/alphabet"

	i=1
	call wjfren (i,x,im)
	if (im.ne.0) {
		if (im.eq.ihr) {
			er=2
			return
		}
110     write(ttyout,104)
		er=1
		return
	}
	if (x<0.0 || x>359.0) go to 110
	d = x
	call wjfren (i,x,im)
	if (im!=0 || x<0 || x>59.0) go to 110
	m=x
	call wjfren (i,x,im)
	if (im!=0 || x<0.0 || x>60.0) go to 110
	s=x
	er=0
	return

104	format (' *** angle error ***',/)
	end
