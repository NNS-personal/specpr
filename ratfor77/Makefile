 
# pd ratfor77 (oz)
#
# if F77 is defined, the output
# of ratfor is Fortran 77.
#
#	On sun4,		use S_CHAR="char"
#	On RS6000,		use S_CHAR="signed char"
#	On DEC3100,	maybe	use S_CHAR="signed char"
#	On CRAY,		use S_CHAR="char"
#	On GNU,		        use S_CHAR="char"
#

EXTRA_DISTR_FILES = getopt.c  lookup.c  lookup.h  rat4.c ratcom.h   ratdef.h

INSTALLDIR=/usr/local/bin
SIGNED_CHAR=char
CC=cc
# DGNU=-DGNU
DGNU=
OCDEFINES=-c -DF77 -DS_CHAR=$(SIGNED_CHAR) $(HAVE_GNU)

#
ratfor77:	rat4.o lookup.o getopt.o 
	cc $(CFLAGS) rat4.o lookup.o getopt.o  -o ratfor77

.c.o:
	$(CC) $(CFLAGS) $(OCDEFINES) $<

install:	ratfor77
	mv ratfor77 $(INSTALLDIR)/ratfor77
	chmod 755 $(INSTALLDIR)/ratfor77
	
