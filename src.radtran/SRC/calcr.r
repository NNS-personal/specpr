   subroutine calcr(j, rfx, r1, xxn, xxk, gmalb, astep, sd)
#
# 	calculate the reflectance value
#

#	implicit integer*4 (i-n)
	implicit none
	include "../../src.specpr/common/lundefs"
	include "../../src.specpr/common/alphabet"

	include "defs.h"
	include "lmrefl.h"
	include "convh.h"

	real*4 xxn(NMINL), xxk(NMINL)	#temp arrays for passing to
					# mrefl subroutine
	real*4 rfx, r1

	real*4 gmalb, astep, sd, sum, xangle, xastep

	integer*4 j, jangle, iastep, iastep2, ifl

	currch = 0		#turn off albedo calculation

	do ifl = 1, nminer {
		call dwcomp (ddflt(ifl),df,w0,wav(j),d(ifl))
	}
	if (gmalb == 1.) {
		sum = 0.
		xastep = astep/57.29578

		iastep2=astep/2.
		iastep=astep

		do jangle = iastep2, 90, iastep {
			xangle = float(jangle)/57.29578
			mu = cos(xangle)
			mu0 = mu
			call mrefl3 (nminer,wav(j),xxn,xxk,
				d,weight,dens,mu0,mu,rfx,
				wsmean(j),r1,g,wband,currch,sd,inrmlc,0)
			sum = sum + 2*mu*mu0*rfx*sin(xangle)*xastep
		}
		rfx = sum
	} else {
		call mrefl3 (nminer,wav(j),xxn,xxk,
			d,weight,dens,mu0,mu,rfx,
			wsmean(j),r1,g,wband,currch,sd,inrmlc,0)
	}
#
# debug write
#
#	write (ttyout,100) rfx
#100	format(' reflectance = ',e12.4)

500	return
	end
