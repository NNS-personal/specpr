/******************************************************************************
Modifications:
  - Raymond F. kokaly  23 Feb 2004
    Altered code to include byteswapping switch for linux.
  - Raymond F. Kokaly  02 May 1997
    Additions made to the information that is printed to the specpr manual
     history (instr_num,cal_num,splice1,splice2,nsamples).
    Additional fields in the specpr record are also filled in (revs,nruns,
     iwtrns,itimch,xnrm,scatim,timint).    
******************************************************************************/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stddef.h>
#include <fcntl.h>
#include <time.h>
#include "specio.h"
#include "io_specpr.h"


void 
noswap2(void *s1, void *t1)
{
    char *s = s1;
    char *t = t1;
    t[0] = s[0];
    t[1] = s[1];
}

void 
noswap4(void *s1, void *t1)
{
    char *s = s1;
    char *t = t1;
    t[0] = s[0];
    t[1] = s[1];
    t[2] = s[2];
    t[3] = s[3];
}

void 
swap2(void *s1, void *t1)
{
    char *s = s1;
    char *t = t1;
    t[0] = s[1];
    t[1] = s[0];
}

void 
swap4(void *s1, void *t1)
{
    char *s = s1;
    char *t = t1;
    t[0] = s[3];
    t[1] = s[2];
    t[2] = s[1];
    t[3] = s[0];
}

static char *usage  = "\
usage: %s infile outfile [-na] [-w]\n\
Options:\n\
	-na: no average (default is to average every 3 pixels)\n\
	-w: output wavelengths only.\n\
	-linux: run code on linux machine (changes byte swapping).\n\
";

main(ac, av)
int ac;
char **av;
{
    char buf[484];
    int ifd, ofd;
    float scan_time = 0.1;
    float f1, f2, splice1, splice2;
    short g1, g2, o1, o2, instr_num, cal_num, nsamples;
    int itime;
    int average = 3;
    char *prog = av[0];
    struct _label label;
    float f;
    int count;
    char *infile, *outfile;
    int i, j;
    float *fdata;
    struct tm t2;
    struct tm_s t;
    int tval;
    int waves = 0;
    int do_linux = 0;
    char *ptr;

    while (--ac) {
        av++;
        if (*av[0] == '-') {
            if (!strcmp(*av, "-na"))
                average = 1;
            else if (!strcmp(*av, "-w"))
                waves = 1;
            else {
                fprintf(stderr, "%s: unrecognized argument: %s\n", prog, *av);
            }
        } else {
            if (infile == NULL)
                infile = *av;
            else if (outfile == NULL)
                outfile = *av;
            else {
                fprintf(stderr, "unrecognized argument: %s\n", prog, *av);
            }
        }
    }

    if (infile == NULL || outfile == NULL) {
		fprintf(stderr, usage, prog);
        exit(1);
    }
    if ((ifd = open(infile, O_RDONLY)) < 0) {
        fprintf(stderr, "%s: Unable to open input file: %s\n", prog, infile);
        exit(1);
    }
    if ((ofd = open(outfile, O_RDWR | O_CREAT, 0777)) < 0) {
        fprintf(stderr, "%s: Unable to open output file: %s\n", prog, outfile);
        exit(1);
    }
    read(ifd, buf, 484);

    if (!waves) fprintf(stderr, "%s\n", buf + COMMENTS);

    if (do_linux == 0) {
      swap2(buf + WHEN + 0, &t.tm_sec);
      swap2(buf + WHEN + 2, &t.tm_min);
      swap2(buf + WHEN + 4, &t.tm_hour);
      swap2(buf + WHEN + 6, &t.tm_mday);
      swap2(buf + WHEN + 8, &t.tm_mon);
      swap2(buf + WHEN + 10, &t.tm_year);
      swap4(buf + CH1_WAVEL, &f1);
      swap4(buf + WAVEL_STEP, &f2);
      f1 /= 1000;
      f2 /= 1000;
      swap2(buf + CALIBRATION, &cal_num);
      swap2(buf + INSTRUMENT_NUM, &instr_num);
      swap4(buf + IT, &itime);
      swap2(buf + SWIR1_GAIN, &g1);
      swap2(buf + SWIR2_GAIN, &g2);
      swap2(buf + SWIR1_OFFSET, &o1);
      swap2(buf + SWIR2_OFFSET, &o2);
      swap4(buf + SPLICE1_WAVELENGTH, &splice1);
      swap4(buf + SPLICE2_WAVELENGTH, &splice2);
      splice1 /= 1000;
      splice2 /= 1000;
      swap2(buf + SAMPLE_COUNT, &nsamples);
    } else {
      noswap2(buf + WHEN + 0, &t.tm_sec);
      noswap2(buf + WHEN + 2, &t.tm_min);
      noswap2(buf + WHEN + 4, &t.tm_hour);
      noswap2(buf + WHEN + 6, &t.tm_mday);
      noswap2(buf + WHEN + 8, &t.tm_mon);
      noswap2(buf + WHEN + 10, &t.tm_year);
      noswap4(buf + CH1_WAVEL, &f1);
      noswap4(buf + WAVEL_STEP, &f2);
      f1 /= 1000;
      f2 /= 1000;
      noswap2(buf + CALIBRATION, &cal_num);
      noswap2(buf + INSTRUMENT_NUM, &instr_num);
      noswap4(buf + IT, &itime);
      noswap2(buf + SWIR1_GAIN, &g1);
      noswap2(buf + SWIR2_GAIN, &g2);
      noswap2(buf + SWIR1_OFFSET, &o1);
      noswap2(buf + SWIR2_OFFSET, &o2);
      noswap4(buf + SPLICE1_WAVELENGTH, &splice1);
      noswap4(buf + SPLICE2_WAVELENGTH, &splice2);
      splice1 /= 1000;
      splice2 /= 1000;
      noswap2(buf + SAMPLE_COUNT, &nsamples);
    }

    if (!waves) {
        fprintf(stderr, "%d:%d:%d %d/%d/%d\n",
                t.tm_hour,
                t.tm_min,
                t.tm_sec,
                t.tm_mon + 1,
                t.tm_mday,
                t.tm_year + 1900);
    }

    if (!waves) {
        fprintf(stderr,"ASD FR Field Spectrometer, Instrument: %d, Calibration: %d\n", instr_num, cal_num);
        fprintf(stderr, "Start wavelength: %f, step: %f, Integration time: %d ms\n", f1, f2, itime);
        fprintf(stderr, "Detector 1, gain: %d, offset: %d, Detector 2, gain: %d, offset: %d\n", g1, o1, g2, o2);
        fprintf(stderr, "Splice 1: %f,  Splice 2: %f, Samples in Avg: %d\n", splice1, splice2, nsamples);
    }

    if (waves) {
        strncpy(label.ititl, "Wavelengths", 40);
    } else {
        strncpy(label.ititl, buf + COMMENTS, 40);
    }
    for (i = 0; i < 40; i++) {
        if (label.ititl[i] == '\n')
            label.ititl[i] = ' ';
        if (label.ititl[i] == '\0')
            label.ititl[i] = ' ';
    }

    strncpy(label.usernm, getenv("USER"), 8);

    label.itchan = 2151 / average;
    label.revs   = nsamples;
    label.nruns  = nsamples;
    label.iwtrns = nsamples;
    label.itimch = itime;
    label.xnrm   = 1.;
    label.scatin = scan_time;
    label.timint = nsamples*scan_time;

    if (waves) {
        strcpy(label.ihist, "Wavelengths");
    } else {
        strcpy(label.ihist, ((ptr = strrchr(infile, '/')) ? ptr : infile));
    }
    for (i = 0; i < 60; i++) {
        if (label.ihist[i] == '\n')
            label.ihist[i] = ' ';
        if (label.ihist[i] == '\0')
            label.ihist[i] = ' ';
    }
    sprintf(label.mhist, "ASD FR Field Spectrometer, Instrument: %d, Calibration: %d\n",instr_num,cal_num);
    sprintf(label.mhist + 74, "Start wavelength: %f, step: %f, Integration time: %d ms\n", f1, f2, itime);
    sprintf(label.mhist + 148, "Detector 1, gain: %d, offset: %d, Detector 2, gain: %d, offset: %d\n", g1, o1, g2, o2);
    sprintf(label.mhist + 222, "Splice 1: %f,  Splice 2: %f, Samples in Avg: %d\n", splice1, splice2, nsamples);

    for (i = 0; i < 296; i++) {
        if (label.mhist[i] == '\0')
            label.mhist[i] = ' ';
    }

    fdata = (float *) calloc(sizeof(float), 2151);
    read(ifd, fdata, 2151 * sizeof(float));
    for (i = 0; i < 2151; i++) {
        f = fdata[i];
        // if(do_linux eq 0) {
        if(do_linux == 0) {
          swap4(fdata + i, &f);
        } else {
          noswap4(fdata + i, &f);
        } 
        fdata[i] = f;
    }
    if (average > 1) {
        count = 0;
        for (i = 0; i < 2151; i += average) {
            f = 0;
            for (j = 0; j < average; j++) {
                if (waves == 1) {
                    f += (f1 + (i + j) * f2);
                } else {
                    f += fdata[i + j];
                }
            }
            f = f / average;
            fdata[count++] = f;
        }
    }
        /**
         ** put in time values.
         **/
    t2.tm_sec = t.tm_sec;
    t2.tm_min = t.tm_min;
    t2.tm_hour = t.tm_hour;
    t2.tm_mday = t.tm_mday;
    t2.tm_mon = t.tm_mon;
    t2.tm_year = t.tm_year;
    t2.tm_isdst = t.tm_isdst;

    tval = mktime(&t2);
    set_julian_date(tval, &label.iscta, &label.jdatea);
    set_julian_date(tval, &label.isctb, &label.jdateb);

    i = write_specpr(ofd, -1, &label, fdata);
    fprintf(stderr, "Wrote record of %d pixels to %s\n", label.itchan, outfile, i);

    close(ifd);
    close(ofd);
}
