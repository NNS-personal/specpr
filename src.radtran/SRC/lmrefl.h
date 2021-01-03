# Whenever this header file is used, source should also include defs.h

#
#
# parameter (NBND = 3)        # in defs.h
# parameter (NMINL = 9)       # in defs.h
# parameter (MAXCHNS = 4852)  # in defs.h
# parameter (MAXTEXT = 19408) # in defs.h
# parameter (NAREF = 2)       # in defs.h
# parameter (NMMIX = 2)       # in defs.h


	common /lmrefl/ wav, d, ddflt, weight, dens, scoef
	common /lmrefl/ xn, xk, xi, r, rfirst
	common /lmrefl/ irecxn, irecxk, irecxi
	common /lmrefl/ xiangl, xeangl, wsmean, g
	common /lmrefl/ idxn,idxk,idxi
	common /lmrefl/ mu, mu0, nminer, imask
	common /lmrefl/ npeaka,ipeaka 
	common /lmrefl/ dlowlm, duplm, wlowlm
	common /lmrefl/ wuplm, wpf, dpf, df, w0, inrmlc

	real*4    wav(MAXCHNS)   # wavelengths
	real*4    d(NMINL)       # grain diameter
	real*4    ddflt(NMINL)
	real*4    weight(NMINL)  # material weight fraction
	real*4    dens(NMINL)    # material density
	real*4    scoef(NMINL)
	real*4    xn(NMINL,MAXCHNS) # index of refraction for intimate mix component NMINL
	real*4    xk(NMINL,MAXCHNS) # absorption coefficient for intimate mix component NMINL
	real*4    xi(MAXCHNS)
	real*4    r(MAXCHNS)        # final computed intimate mix reflectance spectrum
	real*4    rfirst(MAXCHNS)   # first surface reflection from intimate mix calculation
	integer*4 irecxn(NMINL)     # record number for index of refractions in intimate mix
	integer*4 irecxk(NMINL)     # record number for absorption coefficients
	integer*4 irecxi
	real*4    xiangl            # angle of incidence
	real*4    xeangl            # angle of emission
	real*4    wsmean(MAXCHNS)
	real*4    g
	integer*4 idxn(NMINL)       # device letter for index of refraction spectra
	integer*4 idxk(NMINL)       # device letter for absorption coefficients spectra
	integer*4 idxi              #
	real*4    mu
	real*4    mu0
	integer*4 nminer
	integer*4 imask(MAXCHNS)    # mask =0 ignore that channel
	integer*4 npeaka(NMINL)     # absorption coeff peaks
	integer*4 ipeaka(NMINL,10)  # absorption coeff peaks
	real*4    dlowlm(NMINL)
	real*4    duplm(NMINL)
	real*4    wlowlm(NMINL)
	real*4    wuplm(NMINL)
	real*4    wpf(NMINL)
	real*4    dpf(NMINL)
	real*4    df
	real*4    w0
	integer*4 inrmlc



######   areal fractions and molecular mixes

        common /lblref/ xaref, xafrac,  numaref, xatspec
        common /lblref/ xmindx, xmabsc, xmolfra, nmolmix  

        real*4    xaref(NAREF,MAXCHNS)   # areal mix spectra
	real*4    xafrac(NAREF)          # areal fractions to each areal mix spectrum
	integer*4 numaref                # number of areal mix spectra in use
	real*4    xatspec(MAXCHNS)       # total of areal mix spectra, areal mix fractions only
	real*4    xmindx(NMMIX,MAXCHNS)  # index of refraction working array for molecular mix
	real*4    xmabsc(NMMIX,MAXCHNS)  # absorption coefficient working array for molecular mix
	real*4    xmolfra(NMMIX,NMINL)   # molecular fractions in each intimate mix component (NMINL)
	integer*4 nmolmix(NMINL)         # number of components used in molecular mix for
					 #    each compound (NMINL) in the intimate mix
