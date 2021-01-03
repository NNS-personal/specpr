# CFLAGS=-g -Aa -D_HPUX_SOURCE
CC=cc
SP_CFLAGS='-O -m64'
OBJ=specio.o io_specpr.o
PROG=fstospecpr

${PROG}:	${OBJ}
	${CC} ${SP_CFLAGS} ${OBJ} -o $@ -lm

clean:
	-rm -f ${OBJ} ${PROG}

install:
	mv ${PROG} $(SP_LOCAL)/bin/${PROG}
	chmod 755 $(SP_LOCAL)/bin/${PROG}
