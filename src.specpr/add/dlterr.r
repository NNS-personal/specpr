	subroutine dlterr (iji,nchans,idltz,is,inume,data)
	implicit integer*4 (i-n)
#cc  name: dlterr
#cc  version date: 06/01/83
#cc  author(s): Rodney Kam, Roger Clark & Jeff Hoover
#cc  language:  RATFOR
#cc
#cc  short description:
#cc the purpose of the routine is to delete points in the spectra and
#cc errors  and calculate the errors associated with each file if requested
#cc
#cc  algorithm description: none
#cc  system requirements:   none
#cc  subroutines called:
#cc                    dltpts
#cc  argument list description:
#cc     arguments: iji,nchans,idltz,is,inume,data
#cc  parameter description:
#cc  common description:
#cc  message files referenced:
#cc  internal variables:
#cc  file description:
#cc  user command lines:
#cc  update information:
#cc  NOTES:


    include "../common/alphabet"
	real*4 data(4864)
	integer*4 inume(4864),idelet(4864)


	call dltpts (iji,jdch,idelet,4864,ic)
	if (ic==ihe || ic==ihx) id = ihx
	if (jdch==0) return
	do i = 1,jdch
		data(idelet(i)) = -1.23e34

	return
	end
