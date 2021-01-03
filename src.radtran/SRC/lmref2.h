# Whenever this header file is used, source should also include defs.h

	common /lmrefl/ wav(MAXCHNS), d(NMINL), ddflt(NMINL), weight(NMINL)
	common /lmrefl/ dens(NMINL), scoef(NMINL)
	common /lmrefl/ xn(MAXCHNS), xk(MAXCHNS), xi(MAXCHNS)
	common /lmrefl/ r(MAXCHNS,NMINL),rtmp(NMINL)
	common /lmrefl/ irecxn(NMINL), irecxk(NMINL), irecxi
	common /lmrefl/ xiangl,xeangl, wsmean(MAXCHNS), g, wsi
	common /lmrefl/ idxn(NMINL),idxk(NMINL),idxi
	common /lmrefl/ mu, mu0,nminer,imask(MAXCHNS)
	common /lmrefl/ npeaka(NMINL),ipeaka(NMINL,10) # absorption coeff peaks
	common /lmrefl/ dlowlm(NMINL),duplm(NMINL),wlowlm(NMINL)
	common /lmrefl/ wuplm(NMINL),wpf(NMINL),dpf(NMINL),df,w0,inrmlc,w

	real*4 weight, d, ddflt, df, w0, w
	integer*4 nminer,imask
	real*4 mu0, mu, g, r, xi, dlowlm, duplm, wlowlm, wuplm, rtmp
	real*4 xn, xk, dens, wsmean, wpf, dpf, wsi
	integer*4 idxn,idxk,idxi,irecxn,irecxk,irecxi,inrmlc
