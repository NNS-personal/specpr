# @(#) makefile 2.9@(#)

SHELL=/bin/sh

OBJ=	\
regex.o


$(SP_OBJ)/mingw-regex.o:	$(OBJ)
	$(LD) $(SP_LFLAGS) -r -o $@ $(OBJ)

.SUFFIXES:
.SUFFIXES: .o .c
	
regex.o:		regex.c
	check_env SP_CFLAGS
	$(CC) $(SP_CFLAGS) -c regex.c
