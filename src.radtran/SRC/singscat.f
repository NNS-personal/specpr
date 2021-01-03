      subroutine singscat (Se, Si, aD, sD, D, wav, dp, n, k, mx,
     c                     Qs1, Qs, Qa, Qe, wsingl, ws1st)

            implicit none

            real*4 Se, Si, aD, sD, D, wav, dp, n, k, mx
c### not used             complex*4 mc

            real*4 Qs1, Qs, Qa, Qe, wsingl, ws1st

c local variables:

            real*4 nnkk, nnkk2, nnmkk, Qstop, Qsbot, bot, xtop
	    real*4 xfact, dpw
	    real*4 df, XX, Qd, x, r1, xe, xexp, xq

c was: subroutine Qsubs (Se,Si,aD,sD,Qs1,Qs)

c WAS:  this subroutine computes equation 24 of Hapke (1981) JGR vol 16
c          pages 3039-3054.
c
c     input variables:
c           Se = external reflection
c           Si = internal reflection
c           aD = absoprtion coefficient * grain diameter
c           sD = grain internal scattering coeff * grain diameter
c            D = grain diameter in cm
c          wav = wavelength in microns
c           dp = interparticle distance (cm)
c not used  mc = complex index of refraction mc = n + ik  (complex)
c           n  = real part of index of refraction
c           k  = imaginary part of index of refraction
c          mx  = mass fraction
c    
c     computed:
c           Qs = scattering efficiency
c           Qa = absorption efficiency
c           Qe = extinction efficiency
c       wsingl = singlescattering albedo
c        ws1st = first surface reflection (normal)
c
c                note: Se,Si,r1 are >= 0.0 and <= 1.0.
c
c          Qs1 = Qs - Se which is the single scattering
c                             albedo for first order scattering
c                             but not including first surface
c                             reflection from grain surfaces.
c           Qs = the single scattering albedo in Hapke 1981
c                    and assumed Qe = 1.0
c
c     note: absorption coefficient = 4 pi k/wav
c

      df = dp/D 

      XX = 3.14159265 * D / (wav / 10000.)
      xfact = 3.0*(n-1.0)*XX

c
c     Qs = Qd + Qs'  after Hapke 1993, p94 last line and eq 5.25 p87 '
c
c
c According to Hapke (1981 and 1993), for particles touching, Qe=1 and
c there is no diffraction component.
c
c remember dp is in centimeters, wav in microns, so the 10,000 factor
c

	Qa = 0.0
	Qd = 0.0
	Qe = 1.0

c Qe = Qs + Qa = 1.0  thus Qa = 1 - Qs
	

c              this is the Hapke formulation (Hapke, 1981) using geometric
c              optics
c
               x = (aD/(aD+sD))**0.5
               r1 = (1.0-x)/(1.0+x)
c
c     compute argument to exponent, if overrange set to max value
c
               xe = -0.6666667*(aD*(aD+sD))**0.5

c		write(*,23) aD, sD
c23		format(' aD=',e12.6,'    sD=',e12.6)

               if (xe .lt. -80.0) then
	  		xe = -80.0
			xexp = 0.0
      		else
			xexp = exp(xe)
      		endif
c
c   debug write
c
c	write(6,25) xe, xexp
c 25	format(' xe= ',e10.4,'   xexp= ',e10.4)
c
c debug write
c
c	write(6,35) Se, Si, r1
c 35	format(' Se= ',f7.4,'  Si= ',f7.4,'  R1 = ',e10.4)
c	utest = (r1-Si)*xexp
c	write(6,45) utest
c 45	format('Test for underflow',e10.4)

                xq = ((1.0-Se)*(1.0-Si)*(r1+xexp))
     1               /(1.0 - r1*Si + (r1-Si)*xexp)

                Qs = Se + xq

		Qa = 1.0 - Qs

      		Qs1 = Qs - Se
c
c      		write (6,*) 'Qs =', Qs,'  xq=',xq 

		wsingl = (Qs + Qd)/(1.0 + Qd)

c    ws1st is the first surface reflection from grains plus the grain internal
c          scattering.  RNC 10/16/2009

		ws1st = Qs1 + ((n-1.0)**2 + k*k)/((n+1.0)**2 + k*k)

c		write (6,66) wav, n, k, ws1st
c66     format (' wav=',f8.3,'  n=',f9.5,'  =k',f9.5,'  ws1st=',f9.5)


c      write (6,222) wav, Qs, Qd, Qa, Qs1, wsingl, mx
c222   format (' wav=',f8.3, ' Qs=',f9.5 ,'  Qd=',f9.5 ,'  Qa=',f9.5 ,
c     6        '   Qs1=',f9.6,'  wsingl=',f9.6,'   wfract=',f8.6)

      return
      end
