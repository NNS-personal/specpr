	subroutine mrefl3 (nminer,w,xn,xk,d,weight,dens,mu0,mu,r,
			wsmean,r1,g,wband,currch,sd,inrmlc,flag)
#	implicit integer*4 (i-n)
	implicit none
#
#     this program computes the reflectance of a particulate surface
#     given the wavelength, the material index of refraction,
#     the absorption coefficient, and a grain size.
#
#     input :
#                   nminer = number of mineral components.
#                       w  = wavelength in microns
#                       xn = index of refraction
#                       xk = absorption coefficient in inverse cm.
#                        d = grain size in cm.
#                   weight = weight fraction of each component
#                     dens = density of each component
#                      mu0 = cosine of angle of incidence
#                       mu = cosine of angle of emission
#		      flag = flag set to do only one mineral computation
#
#     question:      wband = is it ever used????  RNC 11/11/2010
#
#     output:
#               r      = reflectance
#               wsmean = single scattering albedo
#               r1     = first surface reflection component
#
#**************************************************************************
#
#
	include "defs.h"
	include "../../src.specpr/common/lundefs"

	real*4 phi, phinum, phiden, absord, phase, bphase
	real*4 rhosqd, sdenom, snumer 
	real*4 d(NMINL), weight(NMINL)
	integer*4 currch,aflag,flag
	real*4 xn(NMINL), xk(NMINL)
	real*4 dens(NMINL)

	real*4 r1, rm, r

	real*4 ws1(NMINL), ws(NMINL), s(NMINL)
	real*4 wband(MAXCHNS,NMINL), se2(NMINL)

	real*4 ws1st(NMINL)   # first surface reflection (normal)
                              # assumes bidirectional reflectance
                              # is not at too large of a phase angle
                              # need to fix for more general case

	real*4 ws1stmean      #mean first surface normal reflection
#
	real*4 mu,mu0,mu4

	real*4 xkd, w, wsmean, g, sd, b, bg, cg, dd, denom
	real*4 dp, hmu, p, pg, pga, phiarg, pi, qa, qe, qs
	real*4 rnrml, se, si, wsw, wxmean, x, xxk
	real*4 hmu0, wd, xnumer

	integer*4 nminer, inrmlc, ip, i

	pi =3.1415926

#
	if (flag==0) {   
		aflag=1     # do mix from 1 ti nminer components
	} else {
		aflag=nminer  # generally, nminer=1 here
	}

      do i = aflag, nminer {

# DEBUG:
	if (w > 0.39 && w < 0.401) {  # debug over narrow wave range to limit output
         write(ttyout, 777) w, i, xn(i), xk(i),d(i), dens(i)
777	 format(' DEBUG: w=',f12.6,' iminer=',i4,' xn=',f12.3,
		' xk=',f12.3,' d=',f12.4,' den=',f9.4)
	}

		if ((xn(i).le.0.1e-30).or.(xk(i).le.0.1e-30)) go to 50
#
		x= xk(i)*(w/10000.)/(4.0*pi*xn(i))
# Compute scattering from single particle surface modelled as a
# thin film alla Born and Wolf

		if ( d(i) <= (w/(1.0e+5*xn(i))) ) {

			rhosqd=( (1.0-xn(i))**2 + 
				(xn(i)*x)**2 )/ ( (1.0+xn(i))**2 +
				(xn(i)*x)**2 )

			phiarg=2*x*xn(i)/(xn(i)**2 + (x*xn(i))**2 -1.0) 
	



			phi=atan(phiarg) 
			absord=xk(i)*d(i)*(2.0/3.0)

			phase=absord/x	
			snumer=rhosqd*( exp(absord)+
				exp(-absord)+2*cos(phase) )


			sdenom=exp(absord)+(rhosqd)**2*exp(-absord)+
			      	2*rhosqd*cos(2*phi+phase)

# Debug statement


			s(i)=snumer/sdenom

#write(6,110) snumer, sdenom
#110 format("snumer = ", f10.4, " sdenom = ", f10.4)	
#write(6,111) w, rhosqd, phase , absord, s(i)
#111 format ( "w=", f7.3,"rhosqd=", f5.3, "phase=", f5.3, "absord=",
#f5.3, " s(i) = ", f7.4)

		} else {

		s(i) = ((xn(i)-1.0)**2 +
			(xn(i)*x)**2)/((xn(i)+1)**2 +
			(xn(i)*x)**2)
		}

#
		call Ssube (xn(i),xk(i),s(i),Se)
		call Ssubi (xn(i),xk(i),s(i),Si)
		xkd = xk(i) * d(i)
# old way:		call Qsubs (Se,Si,xkd,sd,ws1(i),ws(i))
# new way, 2009:
                # imaginary part of the index of refraction:

		pi  = 3.14159265
		xxk = xk(i)*w /(40000.0* pi)  # future: compute elsewhere so not repeat

                p=0.5 # p=packing density: future: add as a user variable

		dp= (1.0/(12.0* weight(i) *p/(pi* d(i)**3)))**(1/3.0)

		call singscat (Se, Si, xkd, sd, d(i), w, dp, xn(i), xxk, weight(i),
                           ws1(i), Qs, Qa, Qe,  ws(i), ws1st(i))

		se2(i) = Se

# More debug
#		write(6,222) ws(i),Se,Si
#222		format ("ws = ",f6.4 ," Se = ",f6.4," Si = ",f6.4) 

		if (ws(i).gt.1.0) ws(i)=1.0
		if (ws1(i).gt.1.0) ws1(i)=1.0
#
	}
#
# compute mean single scattering albedo
#
	call Qsmnh (nminer,ws,d,dens,weight,wsmean,wband,currch,aflag)

#       write(*,"(' w=',f8.4,'   wsmean=',f9.6)") w, wsmean

#
# compute mean first surface reflection from grain surfaces
#

	denom = 0.0
	ws1stmean =0.0
	do ip = aflag, nminer {
		dd = dens(ip)*d(ip)
		denom = denom + weight(ip)/dd

		ws1stmean = ws1stmean + weight(ip)*ws1st(ip)/dd
	}
	ws1stmean = ws1stmean/denom
#	write (*,*) ' ws1stmean=', ws1stmean, '  denom=',denom
#
# reflectance computed using hapke eqn 16
#        subroutine hr = Chandrasekhar H function.
#
	wxmean = (1.0 - wsmean) **0.5

#**write(6,113) wsmean,wxmean
#**113 format( "wsmean = ", f12.4, " wxmean =",f6.4)

	call hr (mu,wsmean,wxmean,Hmu)

#**write(6,114) mu0
#**114 format( " mu0 = ", f6.4)

	call hr (mu0,wsmean,wxmean,Hmu0)
#
# Bg not yet included in analysis (need to add someday)
#
	Bg = 0.0
#
# compute mean Pg (Nelson and Clark, BAAS, 198?)
#
# notes 11/03/2009:  Hapke 1993 book:
#
#  Rayleigh partile phase function: p. 74  eqn 5.15
#  p(g) = (3/4)*(1+cos(g)*cos(g))  
#
#  Lambert sphere: eq 6.14 p 112:
#  p(g) = (8/3)*(sin(g)+(pi - g)*cos(g))/pi
#
#  Lommel-Seeliger sphere: eq 6.15 p 113:
#  p(g) = (3/4)*(1/(1-ln(2)))*(1-sin(g/2)*tan(g/2)*ln(cotan(g/2))
#
#  Henyey-Greenstein function: eq 6.7 p 108:
#  p(g) = (1-gamma^2)/((1+2*gamma*cos(g)+gamma^2)^(3/2))
#  gamma = cosine asymmetry factor, = -<cos(g)>
#
#  See also double Henyey-Greenstein function p 121.
#
	Pg= 0.0
	denom = 0.0
	xnumer= 0.0
	cg = cos(g)
	do ip = aflag, nminer {
		b=se2(ip)/ws(ip)
		if (b > 1.0) b = 1.0   # needed? RNC 10/15/2009
		Pga = 1.0 + b*cg  # Pg for mineral ip # CODE PRE 11/2009

		Pga = 0.5        # RNC 11/03/2009 to fit lab ice data

		dd = dens(ip)*d(ip)
		wsw = weight(ip)*ws(ip)
		wd = wsw/dd

		denom = denom + wd
		xnumer = xnumer + wd*Pga
	}
	Pg = xnumer / denom               # mean P(g)
#
	mu4 = 4.0 * (mu+mu0)
#
# OLD:	r1 = wsmean*mu0*(1.0+Bg)*Pg/mu4       # singly scattered component
# above pre 10/16/2009

	r1 = ws1stmean*mu0*(1.0+Bg)*Pg/mu4       # singly scattered component
	rm = wsmean*mu0*(Hmu*Hmu0-1.0)/mu4    # multiply scattered component
#
#
	r = r1 + rm                           # radiance coefficient
	                                      # (Hapke eqn 16)

# debug write

#	write (6,35) w, wsmean, Se, b, aflag
#35	format (' wav=',f7.4,'  wsmean=',f8.5,'   Se=',f7.4,'  b=',f12.5,'  aflag=',i4)
#	write (6,34) w, r1, rm, r
#34      format (' wav=',f7.4,'  r1=',f8.5,'   rm=',f8.5,'   r=',f8.5)
#
# if requested, normalize reflectance to standard at same viewing geometry
#
# debug write
#	write (6,40) r
#40	format('Reflt before normalization = ',f9.6)
	if (inrmlc == 1) {
		call stdref (mu0, mu, rnrml)
		r = r / rnrml
	}
#
#**debug write statement
#**      write (6,10)  r, r1, rm, rw1, rw1m, wsmean, 
#**     c               Hmu, Hmu0
#**10    format (' r=', 8(f7.4))

	go to 100
#
50	r = -1.23e34
#


100	return
	end
