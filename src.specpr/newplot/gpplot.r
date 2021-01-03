	subroutine gpplot
	implicit integer*4(i-n)
	
	include "../common/pltcnt"
	include "../common/lundefs"

	integer*4 idummy

	logical getplt

	close(pltlun,iostat=idummy)
	open (pltlun,status='scratch',access='direct',form='unformatted',
		recl=58916)
# note 59136 would be the next higher multiple of 256 (256*231)
	pltcnt = 0
	nplots = 0

	while (getplt(ii)) {
		call bldplt
		nplots = 0
	}
	
	close(pltlun,iostat=idummy)
	end
