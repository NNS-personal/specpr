   subroutine getn2(iminr,il,mmixflag)

#  	gets index of refraction from specpr file

	implicit integer*4 (i-n)
	include "../../src.specpr/common/lundefs"
	include "../../src.specpr/common/alphabet"
	include "../../src.specpr/common/label1"
	include "../../src.specpr/common/lblg"
	include "defs.h"
	include "lmrefl.h"

	integer*4 mmixflag, jloop

	character*40 xntitl(9)

10	write (ttyout, 20) iminr, NMMIX
20      format (/,'************** Mixture Component',i3,' ************',/,
                  ' Type  s  to enter a single set of n and k or',/,
                  '       m  and the number of components for a ',
				'multi-component molecular mix',/,
		  '           (max =',i5,') (linear mix abs coefs)',
		  '       f  for a 2-component',
                                ' effective medium molecular mix',/,
		  '          Make the 2nd component the small fraction',/,
		  ' WAVELENGTHS MUST BE IN MICRONS')

	mmixflag=0  	# default: no molecular mixture
			# mmixflag=1 = molecular mix of abs coefs
			# mmixflag=2 = effective medium mix

	call crtin
	i = 1
	call wjfren (i,x,il)
	if (il == ihe || il == ihx) {
		il = id
		go to 10000
	}

	if (il == ihs) {   # enter single set of optical constants

100	  write (ttyout, 105) iminr
105	  format (' type in the file ids and record numbers of the ',
		' real index of refraction,',/,
		' for element ',i2)

	  call crtin
	  i = 1
	  call wjfren (i,x,id)
	  call wjfren (i,x,il)
	  if (id == ihe || id == ihx) {
		il = id
		go to 10000
	  }
	  if (il == ihe || il == ihx) go to 10000
	  if (il != 0) {
		call what(i)
		go to 100
	  }
	  if (x < 1 || x > maxrec) {
		write (ttyout, 50) 
50	        format (' ERROR record number out of range, reenter',/)
		go to 100
	  }
	  irecxn(iminr) = x    #record number for xn set iminr
	  idxn(iminr) = id
	  call devok(4,id,irecxn(iminr),lun, ier)
	  if (ier != 0) go to 100
	  itmp = irecxn(iminr)
	  call redfil (itmp,lun,ier)
	  if (ier != 0) go to 100
	  write (ttyout,110) iminr, ititl, itchan
110	  format (/, ' Index of Refraction set',i3,/, 5x,
		a, 5x, 'channels=',i6,/)
	  do j = 1, nchans {
		xn(iminr,j) = data(j)
	  }
	  xntitl(iminr) = ititl

	} else if (il == ihm || il == ihf) {  # molecular mix oe effective medium mix

	    if (il == ihm) mmixflag=1  # # linear absorption coefficient mix
	    if (il == ihf) mmixflag=2  # effective medium mix

	    itmp=0
	    if (mmixflag == 1) {      # linear absorption coefficient mix
	    	call wjfren (i,x,il)  # get the nimner in the molecular mix
	    	if (il == ihe || il == ihx) go to 10000
            	if (il != 0) {
                  call what(i)
                  go to 10
            	}
	    	itmp = x
	    }
	    if (mmixflag == 2) { # effective medium of 2 components
		itmp=2
	    }
	    if (itmp < 1 || itmp > NMMIX ) {

		write (ttyout, 40) itmp
40		format (' ERROR: number of molecular mixtures',i4,
				' out of range, reenter',/)
		go to 10
	    }
	    nmolmix(iminr) = itmp   # number of molecular mixtures in component iminr


	    do jloop = 1, nmolmix(iminr) {

500		write (ttyout, 505) iminr, jloop
505		format (' type in the file ids and record numbers of the ',
			' real Index of Refraction,',/,
			' for element ',i2,/,
			' for component ',i3,' of the molecular mix')

		call crtin
		i = 1
		call wjfren (i,x,id)
		call wjfren (i,x,il)
		if (id == ihe || id == ihx) {
			il = id
			go to 10000
		}
		if (il == ihe || il == ihx) go to 10000
		if (il != 0) {
			call what(i)
			go to 500
		}
		if (x < 1 || x > maxrec) {
			write (ttyout, 50) 
			go to 500
		}
		#if (jloop == 1 ) {           # keep info on first entry
			irecxn(iminr) = x    #record number for xn set iminr
			idxn(iminr) = id
		#}
		call devok(4,id,irecxn(iminr),lun, ier)
		if (ier != 0) go to 500
		itmp = irecxn(iminr)
		call redfil (itmp,lun,ier)
		if (ier != 0) go to 500
		write (ttyout,111) iminr, jloop, ititl, itchan
111	  	format (/, ' Index of Refraction set',i3,
			' mol mox',i3,/, 5x,a, 5x, 'channels=',i6,/)
		do j = 1, nchans {
			xmindx(jloop,j) = data(j)
		}
		if (jloop == 1 ) {    # keep info on first entry
			xntitl(iminr) = ititl
		}
	    }

	} else {

		write (ttyout,200)
200		format (' Input not recognized (subroutine getn2).  Re-enter',//)
		go to 10
	}


10000	return
	end 
