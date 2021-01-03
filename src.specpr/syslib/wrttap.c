/* 02/29/2002 Randall Dailey
 *         Changed ../tape.h to tape.h
 */
/* fortran interface to write specpr tapes */

#include "tape.h"

/*  machine dependency for HPUX added 3/27/85. Roger Clark */


wrttap(idev,str,strln)
short *idev;
char *str;
long strln;
{
	return;
}

/* below is identical to above except _ added */

wrttap_(idev,str,strln)
short *idev;
char *str;
long strln;
{
        return;
}

