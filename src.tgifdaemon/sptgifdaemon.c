#include <stdio.h>
#include <math.h>
#include <signal.h>
#include <sgtty.h>
#include <errno.h>
#include <string.h>

/*  02/14/2003 RED                                           */
/*    Modified to output 37 obj format vs the old 32 format. */

/* #include "hpdaemon.h" */

FILE           *text;
FILE           *vector;
FILE		*debugout;
int             max_down;
int             max_across;
int             drawn;

#define NORMAL      '@'
#define SUBSCRIPT   '{'
#define SUPSCRIPT   '}'
#define GREEK       '!'
#define MATH        '|'

#define BREAK_CHARS "{}@!|"
#define WHITE       " \t"


#define NullS   (char*)0

int copies;

struct vector {
    short           df;    /* down  coordinate of from point */
    short           af;    /* across coordinate of from point */
    short           dt;    /* down  coordinate of  to  point */
    short           at;    /* across coordinate of  to  point */
    short           w;    /* width of vector              */
};

main(ac, av)
    char          **av;
{
    int             i;
    while (openargs()) {
        while (copies--) {
            initplotter(stdout);
            plot_vectors(stdout);
	    /* debugout=fopen("debugout","w"); */	
	    plot_text(stdout);
	    /* fclose(debugout); */
        }
    }
}


openargs()
{
    char            line[128];
    int             error;

    while (gets(line) != NULL) {
        switch (line[0]) {
        case 'T':
            errno = 0;
            text = fopen(&line[1], "r");
            break;
        case 'V':
            errno = 0;
            vector = fopen(&line[1], "r");
            break;
        case 'C':
            copies = atoi(&line[1]);
            if (copies < 1 || copies > 9)
                copies = 1;
            if (vector == (FILE *) NULL || text == (FILE *) NULL) {
                exit(1);
            }
            return (1);
        default:
            break;
        }
    }
    if (vector != NULL) fclose(vector);
    if (text != NULL) fclose(text);
    return (0);
}

static char     line[256];

initplotter(FILE *fp)
{
    int             error;

#if 0
    INITIALIZE;
    /* SCPTS(300, -270, 8300, 10530); */
    SCPTS(650, -320, 8650, 10480);
    SCALE(0, 2000, 0, 2048);
    LINETYPE(-1);
    TEXTSIZE(8);
    PEN(3);
    VS(10);
#endif

	/* state(                                                    */
	/*             0, page_style      PORTRAIT=0 LANDSCAPE=1     */
	/*            37, fileVersion     (cur max is 37)            */
	/*            50, printMag        (vs 100.0)                 */
        /*             0, drawOrigX,      "X Draw Origin"            */
        /*             0, drawOrigY,      "Y Draw Origin"            */
        /*             0, zoomScale,      "Zoom scale"               */
        /*             8, xyEnglishGrid,  "English Grid"             */
        /*             1, snapOn,         "Grid"                     */
        /*             0, colorIndex,     "Color"                    */
        /*             1, horiAlign,      "Horizontal Align"         */
        /*             1, vertAlign,      "Vertical Align"           */
        /*             0, lineWidth,      "Line Width"               */
        /*             0, curSpline,      "Spline"                   */
        /*             1, lineStyle,      "Line Style"               */
        /*             0, objFill,        "Fill Pattern"             */
        /*             1, penPat,         "Pen Pattern"              */
        /*             0, textJust,       "Text Justify"             */
        /* 'Courier-Bold', font_str,      "Font Name String"         */
        /*             1, curStyle,       "Font Style"               */
        /*        115200, font_sz,        "Cur Size Unit"(fontsize?) */
        /*             0,                 "Static 0"                 */
        /*             0, curDash,        "Dash Style"               */
        /*             0, gridSystem,     "Grid System"              */
        /*            10, xyMetricGrid,   "Metric Grid"              */
        /*             0, textVSpace,     "Text Vertical Spacing"    */
        /*             0, zoomedIn,       "Zoomed In"                */
        /*             1, gridShown,      "Grid Shown"               */
        /*             1, moveMode,       "Move Mode")               */
        /*             0, rotate,         "Text Rotation"            */
        /*            16, rcbRadius,      "RCBox Radius"             */
        /*             0, useGray,        "Use Gray Scale"           */
        /*             0, pageLayoutMode, "Page Layout Mode"         */
        /*             1, page_arg1,      "Page Layout Subarg 1"     */
        /*             1, page_arg2,      "Page Layout Subarg 2"     */
        /*             1, pageLineShownInTileMode,"Page Lines Shown" */
        /*             0, colorDump,      "Print In Color"           */
        /*          2000, one_page_width, "One Page Width"           */
        /*          2400, one_page_height,"One Page Height"          */
        /* v37         1, StretchableText,                           */
        /*             0, textRotation,                              */
        /*          2880, rotationIncrement                          */
        /*             0, transPAt                                   */

/* Notes for below
       printMag of 100 vs 50 did not seem to make any diff in display via tgif
*/  
char            init_str[] =
	"%TGIF 4.1.41\n"
	"state(0,37,50.000,0,0,0,8,1,0,1,1,0,0,1,0,1,0,"
	"'Courier-Bold',1,115200,0,0,0,10,0,0,1,1,0,16,0,0,1,1,1,0,"
	"2000,2400,1,0,2880,0).\n"
	"%\n"
	"% @(#)$Header$\n"
	"% %W%\n"
	"%\n"
	"unit(\"1 pixel/pixel\").\n"
	"color_info(19,65535,0,[\n"
	"\t\"red\", 63222, 8738, 5911, 63222, 8738, 5911, 1,\n"
	"\t\"green\", 24415, 64507, 5911, 24415, 64507, 5911, 1,\n"
	"\t\"blue\", 5397, 13621, 65535, 5397, 13621, 65535, 1,\n"
	"\t\"cyan\", 22359, 65278, 65535, 22359, 65278, 65535, 1,\n"
	"\t\"magenta\", 62708, 15934, 65535, 62708, 15934, 65535, 1,\n"
	"\t\"yellow\", 65535, 64764, 5911, 65535, 64764, 5911, 1,\n"
	"\t\"#008080\", 0, 32896, 32896, 0, 32768, 32768, 1,\n"
	"\t\"#0000f0\", 0, 0, 61680, 0, 0, 61440, 1,\n"
	"\t\"white\", 65535, 65535, 65535, 65535, 65535, 65535, 1,\n"
	"\t\"black\", 0, 0, 0, 0, 0, 0, 1,\n"
	"\t\"gray10\", 5397, 1285, 5911, 5397, 1285, 5911, 1,\n"
	"\t\"gray20\", 9509, 1285, 5911, 9509, 1285, 5911, 1,\n"
	"\t\"gray30\", 16705, 14392, 14649, 16705, 14392, 14649, 1,\n"
	"\t\"gray40\", 22873, 21588, 21588, 22873, 21588, 21588, 1,\n"
	"\t\"gray50\", 29812, 29041, 28784, 29812, 29041, 28784, 1,\n"
	"\t\"gray60\", 36751, 36494, 36237, 36751, 36494, 36237, 1,\n"
	"\t\"gray70\", 44204, 43947, 43433, 44204, 43947, 43433, 1,\n"
	"\t\"gray80\", 51143, 51143, 50629, 51143, 51143, 50629, 1,\n"
	"\t\"gray90\", 58082, 58339, 57825, 58082, 58339, 57825, 1\n"
	"]).\n"
	"script_frac(\"0.6\").\n"
	"fg_bg_colors('red','White').\n"
	"page(1,\"\",1,'').\n";

	fprintf(fp, "%s", init_str);
}

typedef struct {
	int x;
	int y;
} LIST;

/**
 ** Draw a line of N points, using PEN.
 **/

char *line_start = "poly('black','',%d,[";

char *line_end1 = "],0,%d,1,1,0,0,%d,0,0,0,0,'4',0,0,\n    \"";
char *line_end2 = "\",\"\",[\n"
		  "    0,0,0,0,'0','0','0'],[0,0,0,0,'0','0','0'],[\n"
		  "]).\n";

/* The following comments are pre 02/14/2003 */
/* RED Changed divsor to 4 from 2 in if SCALE - didn't seem to work */
/*     Changed to divide by 2 in the else portion - worked by y positioning for text is off */
/*     Changed y+100 to y+50 in relation to above change */

#ifdef SCALE
	int scale_x(int x)	{ return((x*1.375)/2); };
	int scale_y(int y)	{ return((y+150)/2); };
#else 
	int scale_x(int x)	{ return(x/2); }
	int scale_y(int y)	{ return((y+50)/2); }
#endif


draw_line(FILE *fp, int n, int pen, LIST *list)
{
	int i;

	fprintf(fp, line_start, n);
	for (i = 0 ; i < n  ; i++) {
		if (i%8 == 0) {
			fprintf(fp,"\n\t");
		}
		if (i != n-1) {
			fprintf(fp, "%d,%d,",
				scale_x(list[i].x), scale_y(list[i].y));
		} else  {
			fprintf(fp, "%d,%d",
				scale_x(list[i].x), scale_y(list[i].y));
		}
	}
	fprintf(fp, line_end1, pen%10, pen/10);

/* RED This is where a 0 is put for each 4 points */
/*     Trying 0 every 8 points                    */
/*	for (i = 0 ; i < n ; i+= 4) {             */
/* RED 02/14/2003 put back to 4 points and corrected if mod statement below */
	for (i = 0 ; i < n ; i+= 4) {
/*		if (i > 1 && i % 64 == 1) {       */
		if (i > 1 && i % 256 == 0) {
			fputc('\n',fp);
			fprintf(fp,"     ");
		}
		fputc('0',fp);
	}
	fprintf(fp, line_end2);
}

plot_vectors(FILE *fp)
{
	/* Increase initial list lize to 512 from 256 */
	LIST *list = (LIST *)calloc(512, sizeof(LIST));
	int ns = 512;
	int nv = 0;
    struct vector v;
	int c_pen = 0;;

    while (fread((char *) &v, sizeof(v), 1, vector) != 0) {
        if (v.af > v.at) {		/* put points in ascending order */
			int across, down;
            across = v.af;
            down = v.df;
            v.af = v.at;
            v.df = v.dt;
            v.at = across;
            v.dt = down;
	}

/* RED Set width of line accordingly */

	switch (v.w) {
	case 1:
		v.w = 4;
		break;
        case 2:
		v.w = 2;
                break;
        case 3:
		v.w = 4;
                break;
        case 4: 
		v.w = 5;
                break;
        case 5: 
		v.w = 6;
                break;
        case 6: 
		v.w = 3;
                break;
	}
        if (v.w != c_pen || !nv || v.af != list[nv-1].x || v.df != list[nv-1].y) {
			/**
			 ** output previous line segment, and start a new one.
			 **/
			if (nv > 1) {
				draw_line(fp, nv, c_pen, list);
			}
			list[0].x = v.af;
			list[0].y = v.df;
			nv=1;
        }

		if (nv == ns) {			/* make list bigger if necessary */
			ns *= 2;
			list = (LIST *)realloc(list, ns*sizeof(list[0]));
		}

		list[nv].x = v.at;
		list[nv].y = v.dt;
		nv++;
		c_pen = v.w;
    }
	/**
	 ** Draw last segment, if necessary.
	 **/
	if (nv > 1) {
		draw_line(fp, nv, c_pen, list);
	}
	return;
	free(list);
}

int
TEXT(FILE *fp, int x, int y, int font, int angle, int symbol, char *str)
{
	char *set;
	int scaledx;
	int scaledy;
	int th;
	int tw;
	int v1;
	int v2;
	int vert;
	int passedx;
	int passedy;
	int initfont;
	
	if (symbol == NORMAL) set = "Courier-Bold";
	else if (symbol == GREEK) set = "Symbol";


	/**
	 ** Tgif measures from top of character.  specpr uses bottom.
	 **/

/* RED if angle true, scale back x even if negative */
	passedx = x;
	passedy = y;
/*	if (angle) {                                      */
/*		x -= font;                                */
/*		tempx -= (font/1.8)*strlen(str)/2 + font; */
               /* Adjust if possibly off screen to left  */ 
/*		if (tempx < -80-scale_x(x)) {             */
/*			tempx = -80-scale_x(x);           */
/*		}                                         */
/*	} else {                                          */
/*		y -= font;                                */
/*		tempx = -12;                              */
/*	}                                                 */

	if (strcmp(str,"m") == 0) {
		x = x + 270;
	}
	if (strcmp(str,"m)") ==0) {
		x = x + 296;
	}
	th=font;
	initfont=(font-2)/2;
	th=font;
	tw=strlen(str)*font*0.59;
	initfont=(font-2)/2;
	if (angle) {
		/* scaledx=passedx-tw; */
		if (strlen(str) > 40) {
			tw=strlen(str)*24*0.59;
			th=24;
			scaledx=2*(passedx-tw+(strlen(str)-12)*9)-40;
			scaledy=220;
		} else {
			scaledx=passedx-tw+(strlen(str)-12)*9;
			/* scaledy=passedy-(tw*2)+initfont; */
			scaledy=400;
		}
		v1=th;
		v2=tw;
		vert=1;
	} else {
		scaledx=scale_x(x)-12;
		scaledy=scale_y(y)+5-font;
		v1=tw;
		v2=th;
		vert=0;
	}
/*	fprintf(debugout,"str      %s\n"
			 "initfont %d\t th(font) %d\t tw       %d\n"
			 "passedx  %d\t passedy  %d\n"
			 "scaledx  %d\t scaledy  %d\n",
	str,initfont,th,tw,passedx,passedy,scaledx,scaledy);
	fprintf(debugout,"============================\n"); */


/* RED 02/14/2003 output new "text" line(s) */

	fprintf(fp,"text('black',%d,%d,1,0,1,%d,%d,0,26,7,0,0,0,0,2,"
		  "%d,%d,0,0,\"\",0,%d,0,0,%d,'',[\n",
		scaledx, scaledy, v1, v2, tw,th,vert,scaledy+26);
	if (angle) {
		fprintf(fp,"\t%d,%d,%d,%d,%d,%d,-1.83697e-13,-1000,1000,-1.83697e-13,"
			 "%d,%d,%d,%d,%d,%d],[\n",
		scaledx,scaledy,scaledx,scaledy,scaledx+tw,scaledy+th,
		strlen(str)*10,strlen(str)*10,scaledx-1,scaledy-1,
		scaledx+tw+1,scaledy+th+1);
	}

	fprintf(fp,"minilines(%d,%d,0,0,0,0,0,[\n",tw,th);
	fprintf(fp,"mini_line(%d,26,7,0,0,0,[\n",tw);
	fprintf(fp,"str_block(0,%d,26,7,0,-4,0,0,0,[\n",tw);
	fprintf(fp,"str_seg('black','%s',1,%d,%d,"
		  "26,7,0,-4,0,0,0,0,0,\n",set,th*5760,tw);
	fprintf(fp,"\t\"%s\")])\n",str);
	fprintf(fp,"])\n");
	fprintf(fp,"])]).\n");


/* RED Divide by 10 rather than 5 */
/*     Didn't seem to make any difference in the simple test graph - setting by to 5 */
/*     Still doesn't seem to make any diferrence for multiple text defs on same line */
/*	return(font*3/5*strlen(str)); */
	return(font/1.8*strlen(str));
}

plot_text(FILE *fp)
{
    char            type;
    char            line[256];
    char            tbuf[256];
    char           *start_p, *next_p;
    char            brk_c;
    int             down, across, font, angle;
    int             pen, x, y;
    int             c_pen, c_down, c_across;
    int             delaycnt;
    float           txt_scale;
    char            mode = NORMAL;
    char            symbol_set = NORMAL;
    int             i;
	char *p, *q;
	int offset, script;
	float font_scale;


    while (fgets(line, 256, text) != NULL) {
        sscanf(line, "%c%d%d%d%d%[^\n]\n",
               &type,
               &down,
               &across,
               &font,
               &angle,
               tbuf);

        switch (type) {
        case 'T':   /*** text ***/ 
	
	{
            for (i = strlen(tbuf) - 1; i >= 0; i--) {
                if (tbuf[i] != ' ') {
                    tbuf[i + 1] = '\0';
                    break;
                }
            }
  	    offset = script = 0;
/* RED Set font size to 2 time passed value plus 2 instead of 3 times */ 
	    font = (font*2)+2;
 	    font_scale = 1.0;
	    symbol_set = NORMAL;
            p = tbuf;
	   
   	    while(p && *p) {
		if ((q = strpbrk(p, BREAK_CHARS)) != NULL) {
			mode = *q;
			*q = '\0';
		}

		offset += TEXT(fp, across+offset, down+script, 
			 (int)font*font_scale, angle, symbol_set, p);

		if (q != NULL) {
			switch(mode) {
				case NORMAL:
					fprintf(stderr, "Switching to normal\n");
					symbol_set = NORMAL;
					script = 0;
					font_scale = 1.0;
					break;
				case GREEK:
					symbol_set = (symbol_set == GREEK ? NORMAL : GREEK);
					break;
				case MATH:
					symbol_set = (symbol_set == MATH ? NORMAL : MATH);
					break;
				case SUBSCRIPT:
					fprintf(stderr, "Switching to sub\n");
					script = font/2;
					font_scale = 0.6;
					break;
				case SUPSCRIPT:
					fprintf(stderr, "Switching to sup\n");
					script = -font/2;
					font_scale = 0.6;
					break;
			}
			q++;
		}
		p = q;
	   } /* end while*/
	}
	break;

        case 'S':   /*** symbol ***/
            sscanf(tbuf, "%d", &pen);
			x = across;
			y = down;

            switch (angle) {
            case 0: /* square */
                UC(fp, x, y,  font,  pen, "-99 10 20 +99 -20 0 0 -40 20 0 0 40;");
                break;
            case 1: /* plus sign */
                UC(fp, x, y,  font,  pen, "-99 0 28 +99 0 -56 -99 14 28 +99 -28 0;");
                break;
            case 2: /* cross */
                UC(fp, x, y,  font,  pen, "-99 5 20 +99 0 5 -10 0 0 -10 -5 0 0 -20 5 0 0 -10 10 0 0 10 5 0 0 20 -5 0 0 5;");
                break;
            case 3: /* diamond */
                UC(fp, x, y,  font,  pen, "-99 0 28 +99 -14 -28 14 -28 14 28 -14 28;");
                break;
            case 4: /* filled square */
                UC(fp, x, y,  font,  pen, "-99 -10 -20 +99 20 0 0 3 -20 0 0 3 20 0 0 3 -20 0 0 3 20 0 0 3 -20 0 0 3 20 0 0 3 -20 0 0 3 20 0 0 3 -20 0 0 3 20 0 0 3 -20 0 0 3 20 0 0 2 -20 0 0 2 20 0 0 -40 -20 0 0 40;");
                break;
            case 5: /* point */
				/*
                DRAWTO(down, across);
                MOVETO(down, across);
				*/
                break;
            case 6: /* triangle down */
                UC(fp, x, y,  font,  pen, "-99 0 -26 +99 14 43 -28 0 14 -43;");
                break;
            case 7: /* triangle up */
                UC(fp, x, y,  font,  pen, "-99 0 28 +99 -14 -43 28 0 -14 43;");
                break;
            case 8: /* circle */
                UC(fp, x, y,  font,  pen, "-99 3 -20 +99 -6 0 -3 3 -2 5 -2 7 0 10 2 7 2 5 3 3 6 0 3 -3 2 -5 2 -7 0 -10 -2 -7 -2 -5 -3 -3;");
                break;
            case 9: /* filled cross */
                UC(fp, x, y,  font,  pen, "-99 -5 -20 +99 10 0 0 2 -10 0 0 2 10 0 0 3 -10 0 0 3 10 0 -99 5 1 +99 -20 0 0 3 20 0 0 3 -20 0 0 3 20 0 0 3 -20 0 0 3 20 0 0 3 -20 0 -99 5 1 +99 10 0 0 3 -10 0 0 3 10 0 0 2 -10 0 0 2 10 0 -10 0 0 -10 -5 0 0 -20 5 0 0 -10 10 0 0 10 5 0 0 20 -5 0 0 5;");
                break;
            case 10:    /* filled diamond */
                UC(fp, x, y,  font,  pen, "-99 0 28 +99 -14 -28 1 -2 14 28 1 -2 -14 -28 1 -2 14 28 1 -2 -14 -28 1 -2 14 28 1 -2 -14 -28 1 -2 14 28 1 -2 -14 -28 1 -2 14 28 1 -2 -14 -28 1 -2 14 28 1 -2 -14 -28 1 -2 14 28 1 -2 -14 -28 -14 28 14 28 14 -28;");
                break;
            case 11:    /* X */
                UC(fp, x, y,  font,  pen, "-99 -10 20 +99 20 -40 -99 0 40 +99 -20 -40;");
                break;
            case 12:    /* filled triangle up */
                UC(fp, x, y,  font,  pen, "-99 -14 -14 +99 28 0 0 3 -26 0 0 3 24 0 0 3 -22 0 0 3 20 0 0 3 -18 0 0 3 16 0 0 3 -14 0 0 3 12 0 0 3 -10 0 0 3 8 0 0 3 -6 0 0 3 4 0 0 3 -2 0 0 3 -14 -43 29 0 -14 43;");
                break;
            case 13:    /* filled triangle down */
                UC(fp, x, y,  font,  pen, "-99 -14 17 +99 28 0 0 -3 -26 0 0 -3 24 0 0 -3 -22 0 0 -3 20 0 0 -3 -18 0 0 -3 16 0 0 -3 -14 0 0 -3 12 0 0 -3 -10 0 0 -3 8 0 0 -3 -6 0 0 -3 4 0 0 -3 -2 0 0 -3 1 0 14 43 -29 0 14 -43;");
                break;
            case 14:    /* filled circle */
                UC(fp, x, y,  font,  pen, "-99 -3 -20 +99 6 0 3 3 -12 0 -1 2 14 0 1 3 -16 0 -1 3 18 0 1 3 -20 0 0 1 20 0 0 3 -20 0 0 2 20 0 0 2 -20 0 0 3 20 0 0 1 -20 0 1 3 18 0 -1 3 -16 0 1 3 14 0 -1 2 -12 0 3 3 6 0 3 -3 2 -5 2 -7 0 -10 -2 -7 -2 -5 -3 -3 -6 0 -3 3 -2 5 -2 7 0 10 2 7 2 5 3 3 6 0;");
                break;
            case 15:    /* sample of number (not used) */
				/*
                TEXTSIZE(11 * font);
                CP(-0.333, -0.25);
				*/
                /* TEXT(PI2, "1"); */
                break;
            default:    /* plus sign */
                UC(fp, x, y,  font,  pen, "-99 0 28 +99 0 -56 -99 14 28 +99 -28 0;");
                break;
            }
			break;
		}
    }
    fseek(text, 0L, 0);
}


UC(FILE *fp, int x, int y, int font, int pen, char *str)
{
	LIST list[64];
	int count = 0;
	int nv = 0, a, b;
	int ns = 63, v;
	char *p, *q;

/* RED ??? f = font*0.5 */

	float f = font*0.5;
	float xp = x, yp = y;

	p = str;
	while(p && *p) {
		v = strtol(p, &q, 10);
		if (p == q) break;
		p = q;
		if (v == +99) continue;
		if (v == -99) {
			if (nv > 1) {
				draw_line(fp, nv, pen, list);
			}
			count = nv = 0;
			continue;
		}
		
		if (count % 2 == 0) a = v;
		if (count % 2 == 1) b = v;

		if (count % 2 == 1) {
			list[nv].x = xp = xp + (float)a*f;
			list[nv].y = yp = yp + (float)b*f;
			nv++;
		}
		count++;
	}
	if (nv) {
		draw_line(fp, nv, pen, list);
	}
}
