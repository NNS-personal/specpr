# @(#) makefile 2.18@(#)
SHELL=/bin/sh

OBJ=spblockdata.o

HDR= \
alphabet \
blank \
cmd \
cmdarg \
delete \
dscrch \
f13com \
filenames \
hptrm \
info \
interp \
iocontrol \
ioftyp \
key1 \
label1 \
label3 \
labelf \
labl2 \
lbl3 \
lbl4 \
lbl5 \
lbl6 \
lbl7 \
lbl8 \
lblg \
lblprt \
lblvol \
lblwav \
lundefs \
overlys \
pipes \
plot01 \
plot02 \
plotspool \
pltcnt \
sitelogo \
spcolors \
spfeat \
spool \
subvar \
tablet \
therml \
times \
xtnct \
xf

BLOCK=spblockdata.r alphabet filenames lblvol lbl4 cmd delete ioftyp

$(SP_OBJ)/common.o:	$(HDR) $(OBJ)  
	$(LD) $(SP_LFLAGS) -r -o $@ $(OBJ) 

spblockdata.o:	spblockdata.r
	$(RF) $(SP_RFLAGS) spblockdata.r >  spblockdata.f 
	$(F77) $(SP_FFLAGS) -c spblockdata.f 
	rm -f spblockdata.f
clean:
	-rm -f $(OBJ) 
