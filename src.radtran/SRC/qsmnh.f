      subroutine Qsmnh (nminer,ws,d,dens,weight, 
     c                   wsmean,wband,currch,aflag)
C	implicit integer*4 (i-n)
        implicit none
c
c     this subroutine computes the mean single scattering albedo
c     for nimner components.  see subroutine mrefl for definitions.
c
	integer*4 currch,aflag
	real*4 d(nminer), weight(nminer)
      real*4 ws(nminer),dens(nminer),wband(4852,nminer)
      real*4 wsmean, dd, denom

      integer*4 i, nminer
c
      wsmean = 0.0
      denom = 0.0
c
      do 10 i = aflag, nminer
c
      dd = dens(i)*d(i)
      denom = denom + weight(i)/dd
c
      wsmean = wsmean + weight(i)*ws(i)/dd
c
	if (currch .ne. 0) then
		wband(currch,i) = ws(i)
	endif
10    continue
c
      wsmean = wsmean/denom
c
      return 
      end
