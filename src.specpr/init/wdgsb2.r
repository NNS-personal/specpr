subroutine wdgsb2(iwdflg)
implicit integer*4(i-n)

#ccc  version date: 06/01/83
#ccc  author(s):  roger clark & jeff hoover
#ccc  language:   fortran
#ccc
#ccc  short description:
#ccc                   this subroutine initializes different parameters
#ccc  algorithm description: none
#ccc  system requirements:   none
#ccc  subroutines called:
#ccc                    crtin,wjfren
#ccc  argument list description:
#ccc      argument: iwdflg
#ccc  parameter description:
#ccc  common description:
#ccc  message files referenced:
#ccc  internal variables:
#ccc  file description:
#ccc  user command lines:
#ccc  update information:
#ccc  notes:
#ccc

	include "../common/blank"
	include "../common/lbl7"
	include "../common/lbl6"
	include "../common/lbl4"
	include "../common/label1"
	include "../common/lbl3"
	include "../common/label3"
	include "../common/labelf"
	include "../common/lblg"
	include "../common/lblprt"
	include "../common/alphabet"
	include "../common/lundefs"

logical iwdflg
iwdflg = .false.

repeat {
	call whedr
	write(ttyout,10)
#
#     free format input of ifilex
#
	call crtin
	i = 1
	repeat {
		call wjfren(i,x,il)
		repeat {
			call wjfren(i,x,im)
			if (i>=80 || il==ihx || il==ihe) go to 910
			if (il==0 || x<-maxrec || x>maxrec) go to 900
			if (il!=ihv&&il!=ihw&&il!=ihd&&il!=ihu&&il!=ihy&&il!=ihs)
				go to 900
			if (il==ihv) iprtv = x
			if (il==ihw) iprtw = x
			if (il==ihd) iprtd = x
			if (il==ihu) iprtu = x
			if (il==ihy) iprty = x
			if (il==ihs) iprts = x
			if (il==ihv) ifilex = x
			if (i>=80) go to 910
			if (im!=0) il = im
		} until(im==0)
	}
900 continue
}
910   continue
if (ititle(1:2)=="zx") iwdflg = .true.
else {
	bbnd = 0
	ubnd = 2
	nchans = 256
	ira(1) = 0
	ira(2) = 0
	ira(3) = 0
	idec(1) = 0
	idec(2) = 0
	idec(3) = 0
	irmas = 0
	iwch = 0
	ra = 0
	dec = 0
	ha = 0
	airmas = 0
}
return

10  format(1x,
	'FILE PROTECTION: type in the file id and',
	' protection (e.g. v237 w-1)',/,
	' protection number:',//,
	' PROTECTED, WRITE AT END OF DATA: protection',
	' number 0 or greater',/,
	' READ ONLY: protection number less than -1',
	' (you canot have',/,
	'            a read only file of 1 record)',/,
	' UNPROTECTED: protection number = -1',/)

end
