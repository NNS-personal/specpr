#HPUX program radtran (ach1, ach2, ach3)
#
#     RATFOR
#
#     this program is an interface to radiative transfer models:
#          mreflectv3: do reflectance computations
#          optconst: compute optical constants from reflectance spectra
#
#**************************************************************************

	implicit integer*4 (i-n)

	include "defs.h"
	include "lmrefl.h"
	include "convh.h"

	include "../../src.specpr/common/label1"
	include "../../src.specpr/common/lbl4"
	include "../../src.specpr/common/lundefs"
	include "../../src.specpr/common/alphabet"
	include "../../src.specpr/common/cmd"
	include "../../src.specpr/common/lblg"
	include "../../src.specpr/common/lblwav"
	include "../../src.specpr/common/cmdarg"
	include "../../src.specpr/common/overlys"
	include "../../src.specpr/common/inputhistory"
#
	character*1536 dummy
 	equivalence (dummy,ititl)

#HPUX	character*80 ach1, ach2, ach3

	integer*4 fsize
	integer*4 recnum
	integer*4 idummy, filsiz, icrst
	integer*2 chkbit,ibit,bitnum
	real*4 xxn(NMINL),xxk(NMINL)   # temporary holding arrays for
				#   passing info to mrefl sub.

	real*4 param(18),pturb,fitcri,stndev,min,num
	character*40 xntitl(NMINL), xktitl(NMINL), xititl
	character*8 file1,namwav
	character*1 iform
	integer*4 iargc, nn, ilen, idlt(MAXCHNS)

        character*7     ovcolor
	integer*4 iov

#
#
#HPUX	charg1 = ach1
#HPUX	charg2 = ach2
#HPUX	charg3 = ach3

#
#	ttyout = screen output
#	ttyin = keyboard input

#
#       set  common variables in spblockdata  KEL  06/09
#
        call spblockdata


	maxrec = 999999
	maxchn = MAXCHNS
	maxtxt = maxtext   # was 19860
	iline=0

	ihistch=0

	call getcmdargs

#############################################################
#       set command counter to beginning of file            #
#############################################################
	icoman = 1
	redire = .false.
	cndx = 0
	icopy = 0

        for (i=1; i<=6; i=i+1) {

                ovrflg(i) = -1   # overlays not defined
                ovrflgb(i) = -1   # overlays not defined
                ovrchn(i) = 0    # number of channels in overlay
        }


##########################################################
#       call initialization routine                      #
##########################################################
        if ((ncmdarg >= 1) & (charg1(1:2) == '-g')) {
                write (ttyout,101)
101             format ('You must specify a restart file before a ',
                       'graphics mode',/)
                stop
        }
	icrst=2
	call rstart(icrst)
#############################################################
#       set command counter to beginning of file            #
#############################################################
	icoman = 1
	redire = .true.
	cndx = 0
	icopy = 0

# initialize imask array

	do i=1, MAXCHNS {
		imask(i) =0
	}

# more specpr initialization

	call taprw
	call prochk

# check for graphics settings

if ((ncmdarg >= 2) & (charg2(1:2) == '-g')) {
	igrmod = 0

	write (ttyout,*)"DEBUG: ", charg2(3:8)
	if (charg2(3:5) == 'xhp') {
		igrmod = 50
		call initt(igrmod)

						# added graphics window size 8/15/2011 - RNC
	} else if (charg2(3:8) == 'xterm3') {   # triple size xterm graphics window
		igrmod = 53
		write (ttyout,*)"DEBUG: igrmod=", igrmod
		call initt(igrmod)

	} else if (charg2(3:8) == 'xterm2') {   # double size xterm graphics window
		igrmod = 52
		write (ttyout,*)"DEBUG: igrmod=", igrmod
		call initt(igrmod)

	} else if (charg2(3:8) == 'xterm1') {   # standard size xterm graphics window
		igrmod = 51
		call initt(igrmod)

	} else if (charg2(3:7) == 'xterm' ) {
		igrmod = 51
		call initt(igrmod)

	} else if (charg2(3:5) == 'xdt') {
# dt for dtterm vs hpterm - result in no io via eralph to clear memory
		igrmod = 60
		call initt(igrmod)

	} else if (charg2(3:3) >= '0' & charg2(3:3) <= '9') {
		iopcon = charg2
		i = 3
		call wjfren(i,x,il)
		if (il != 0) {
			write (ttyout,*) iopcon
			call what(i)
			write (ttyout,*) 'Graphics mode', x, ' unknown'
			write (ttyout,*) 'Graphics mode ignored'
		} else {
			igrmod = x
			call initt(igrmod)
		}
	}
}

399	call eralph
	call whedr

      write (ttyout,5)
5     format (/, 20x, 'PROGRAM RADTRAN:', /,
       ' This routine interfaces to radiative transfer routines',/)

6	write (ttyout,7)
7	format (/,' Enter  r  to compute reflectance ',
			'spectra of intimate mixtures',
                /,' Enter  R  to compute reflectance spectra of ',/,
                  '            intimate + molecular + areal mixtures',
                /,' Enter  a  to derive absorption ',
			'coefficients from reflectance spectra',
                /,' Enter  u  to unmix (derive absorption ',
			'coefficients for an unknown in a ',/,
                  '                     ',/,
			'reflectance spectrum containing ',
				'one or more knowns)',
/,' Enter  EX  to exit',/)

#### these will be added in the future
#/,' Enter  i  to compute the reflectance of intimate-areal mixtures',
#/,' Enter  n  to derive k and n from reflectance spectra',//,

# show defined overlays
        for (iov=1; iov<=6; iov=iov+1) {
                if (ovrflg(iov) > 0) {

                        if (iov == 1) ovcolor='red    '
                        if (iov == 2) ovcolor='blue   '
                        if (iov == 3) ovcolor='green  '
                        if (iov == 4) ovcolor='orange '
                        if (iov == 5) ovcolor='cyan   '
                        if (iov == 6) ovcolor='magenta'
                        write (ttyout,1234) iov,
                                ovfil(iov), ovrec(iov),
                                ovwfil(iov), ovwrec(iov),
                                ovops(iov), ovcolor,
                                ovtitle(iov), ovrchn(iov)
                }
        }
1234    format(1x,'ov', i1,'=',a1,i6,' ',a1,i6,' ',a,' ',a,' ',a,i7)

	call crtin
	i = 1
	call wjfren (i,x,il)
#RED
# Unable to locate varialbe id defined anywhere.  Given the statement
# that immediately follows, assume that this statement should have been
# either deleted or commented out at some point - now commented out
#	if (id == ihe || id == ihx) go to 399
	if (il == ihe || il == ihx) go to 399

	if (il ==  ihce) {                  # look for capital E
		call wjfren (i,x,il)
                if (il == ihcx) {  # now if capital X , exit
                        #            # if graphics = X windows,
                        #                #       reset to HP mode
                        #if (igrmod >= 50 & igrmod <= 59) igrmod = 4

			go to 10000
                }
	}


#       check if overlay defined, form= ov1= v23 V22 color
#       added 12/22/2009

        #write (*,*) "DEBUG: overlay point 1"
        if (i < 83 && il == iho && iopcon(i:i)=='v') {
                iero = 0
                if(iopcon(i-1:i+2) == "ov1=" ) {
                        #write (*,*) "DEBUG: overlay point 2 ov1="
                        i=i+3
                        itmpo=1
                        call getoverly(i,itmpo,iero)
                        #call crtin   # DEBUG
                        go to 399   # go to beginning
                }
                if(iopcon(i-1:i+2) == "ov2=" ) {
                        #write (*,*) "DEBUG: overlay point 2 ov2="
                        i=i+3
                        itmpo=2
                        call getoverly(i,itmpo,iero)
                        go to 399   # go to beginning
                }
                if(iopcon(i-1:i+2) == "ov3=" ) {
                        i=i+3
                        itmpo=3
                        call getoverly(i,itmpo,iero)
                        go to 399   # go to beginning
                }
                if (iero > 0) {
                        go to 399
                }

        }


	if (il == ihr)  call refcom(idummy)
	if (il == ihcr) {

		# begin recording input lines to the history array for later output.
		# Note: once set up here, crtin does the rest.

		inhsenbl = 1              # enable history recording
		tinphist(1:1) = 'R'
		tinphist(2:2) = char(10)  # line feed
		inhistch=3                # next position in the history

		call refmix(idummy)

		inhsenbl = 0  # disable input history recording
	}
	if (il == iha)  call abscf(idummy)
#######	if (il == ihn)  call optic(idummy) # will be in the future
	if (il == ihu)  call unmix(idummy)
#######	if (il == ihi)  call intarl(idummy) # will be in the future
	go to 399

10000	icrst=1
	call rstart(icrst)
	call closef
	stop
	end
