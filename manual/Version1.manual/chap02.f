



     SPECPR User's Manual                      Page 2.1


_2.  _P_R_O_G_R_A_M _S_T_R_U_C_T_U_R_E

_2._1.  _B_l_o_c_k _D_i_a_g_r_a_m _o_f _P_r_o_g_r_a_m _S_t_r_u_c_t_u_r_e

     Figure 2.1-1 shows the basic user control structure and
the commands used by the user to access each section.

_2._2.  _F_i_l_e _S_t_r_u_c_t_u_r_e

     The file structure of SPECPR is  the  most  complicated
portion  of  the  program.  As far as the user is concerned,
there are 6  "Devices"  each  labeled  by  a  single  letter
(called "file ID letters").  These are:


    v= saVefile (Vfile)
    w= raWfile (Wfile)
    d= workfile (formerly Diskfile at MIT) (Dfile)
    s= Starpack file
    u= Ufile
    y= Yfile


     Normally the user assigns, via the file assignment rou-
tine  (section 5), all of the "devices" to disc files.  How-
ever, processed data is stored on  magnetic  tape  and  thus
needs  to be transferred to the disc.  Originally, devices u
and y were intended to be used only for transfer and display
and  were  not  used in any math operation.  However, due to
increased needs, they have been  made  full  working  files.
Each  of  the 5 main data files (v, w, d, u, and y) may con-
tain up  to  2000  spectra  (with  their  associated  header
information),and may be assigned in the program to the named
disc files or to magnetic tape drives.   The  starpack  file
contains 50 extinction correction "starpacks" on disc.

     Errors (1 sigma standard deviations) are stored in  the
next  record after the data when generated.  This saves room
since many files do not contain error values.

     Each I/O operation is analyzed for errors by  the  pro-
gram.   If  an  I/O  error  occurs, the error encountered is
listed on the CRT so the user can try and  figure  out  what
happened.

     All data values for "data"  or  "wavelength"  (y  or  x
data)  points are valid except -1.23x108+349 which is taken to
be a deleted points.

     The user accesses a spectrum by typing in the  File  ID
letter  and  the  record number in the file (this is techni-
cally erroneously called a file number not record number  by
the program messages).


                      January 26, 1984







     SPECPR User's Manual                      Page 2.2


     In addition, transfers between all combinations  of  v,
w, d, u, y, and s are allowed if the user selected file pro-
tection permits such transfers (see File Protection, section
2.3).

_T_r_a_n_s_f_e_r _R_e_s_t_r_i_c_t_i_o_n_s

     If the device names are equal, two special restrictions
are  applied.   For  instance, if the name of "Vfile" is the
same as the name of the "Ufile" (e.g. a data tape is on  MT0
as "Ufile" and is to be transferred to the "Vfile" on disc),
the restriction applies to tape to disc, disc to tape,  disc
to disc, and tape to tape transfers.  These restrictions are
enforced in an effort to preserve the histories which  refer
to  a  specific spectrum by data tape name and record number
(called file number).

     _T_r_a_n_s_f_e_r_s _t_o _t_a_p_e including disc to tape  and  tape  to
tape  transfers  or  disc  to  disc  transfers  must  be  to
corresponding record numbers but do not have to  begin  with
record 1 (if the data file names are equal).

     _T_r_a_n_s_f_e_r_s _t_o _d_i_s_c, including tape  to  disc  transfers,
must  begin with record number 1 (if the data file names are
equal).


_2._3.  _F_i_l_e _P_r_o_t_e_c_t_i_o_n

     All files may be totally  or  partially  protected,  or
completely  unprotected.   The fourth line of the CRT header
gives the protection status for all six devices (devices  v,
w, d, u, v, and s).  If the protection number is positive or
zero, the device is a read/write device where you  can  read
up  to  and including the protection, but you can only write
to the protection +1 file.  A protection number of -1  means
totally unprotected so you may read or write anywhere in the
file randomly.  A protection number of less  than  -1  means
the  device  is  a read-only device where you can read up to
the absolute value of the line in the initialization routine
as  the file ID and protection number.  Example: v0 d-1 u432
y-600 w-600 s-50", where v0 means to protect 0 files on dev-
ice  v  (write  to  file  1 only, 0 files can be read); u432
means to protect records up to 432 records (write to  record
433);  y-600  means  that  y  is a read-only device with 600
records; similarly for w; and s is a read-only  device  with
50  records.   If the protection number is zero or positive,
it is incremented each time the device is written  to.   One
or more device protection numbers may be changed on the same
line.

               _U_s_e _o_f _S_P_E_C_P_R _F_i_l_e _P_r_o_t_e_c_t_i_o_n
9

9                      January 26, 1984







     SPECPR User's Manual                      Page 2.3


     The SPECPR file protection is designed to  protect  the
user  from  destroying existing data and to allow use of the
program with minimal thinking of where data is going (so the
user  can be thinking about the science).  Protection should
be used at all times unless there is some  necessary  reason
for not using it.  Remember that a mistake is what will des-
troy data in an unprotected file--and  everyone  makes  mis-
takes.

     The following is an example of the use of protection:

     Start SPECPR.  Say you have 2 tapes to  be  transferred
to  disc  and  then  do some processing.  Load the tapes (we
will call them A01 and B01):  A01 on MT0, and  B01  on  MT1.
Plan to assign u to MT0, y to MT1, v and w to Disc.  Set the
protection on v and w to 0 (this is the default).   Type  in
the  names  of  the  devices   u and v = A01; y and w = B01.
Assign the devices as noted above.  Now here  is  where  the
protection comes in.  First, let us transfer the tape on MT0
(A01 = u).  The protection is -2000.  Say on  the  label  on
the  tape,  there  are 673 records--do not believe this.  We
could have set the protection to -673, but what if the  last
time  you  added  stuff to the tape you forgot to update the
number or someone else added stuff and did  not  update  it?
If  that  happened and you then added stuff after record 673
and wrote it back to the tape, someone might get  very  mad.
So--let  the  computer find the end of the data.  Go to file
transfer and type "u1 + 1999tv1".  All the records up to the
end of file mark will be transferred.  Say there were really
729 records on the tape.  Then, after the transfer, the pro-
tection  on v would be 729 and -2000 on u.  Now transfer MT1
to the disc:  "y1 + 1999tw1".  Say there are 463 records  on
MT1.   The  protection  after the transfer would be 463 on w
and -2000 on y.  Now go back to  change  protection  routine
and  make  the  protection  on u-729 and on y-463.  All your
data is fully protected.

     Now say you did some processing and added 47 records to
v and 21 to w.  You must then transfer the stuff back to the
tapes.  Take the tape off MT0 and put in a  write  ring  (if
you had a write ring in before, you are asking for trouble).
Go to the change protection routine and change  the  protec-
tion  u  from  -729 to 729.  If the tape was not at the load
point when you put in the write ring,  you  must  reset  the
record  pointer  in the program.  This can be done in one of
several ways:  (1) change the tape name (change the name  of
u  from  A01  to  A01; when the name is changed, the tape is
rewound); (2) display record u1; or (3) transfer u1 to some-
where  else  (this  is  faster  than  a  display).   If d is
assigned to disc and it is used as a workfile (protection  =
-1), transfer "u1td1" or "u1td1000" or even if d is assigned
to /dev/null.  If d is assigned to /dev/null, it  will  read
u1  before  you get the illegal transfer, device assigned to


                      January 26, 1984







     SPECPR User's Manual                      Page 2.4


/dev/null message.

     Now that the tape record pointer is reset, you transfer
your  stuff  from v to u.  Type "v730 + 999tu730".  Note 730
is one more than the current protection.  The transfer  will
continue  up to the protection limit on v (776), which after
transferring v776 to u776 the message "FILE REQUEST  GREATER
THAN FILE PROTECTION" will come on--press return.


     It is now a good idea to list the tape from just before
the point at which data was added to the end of file to make
sure the tape does not have any obvious errors.

     Now you must transfer the  stuff  on  w  to  the  tape.
Change the protection on u to 463; then change the name of u
to B01 (this puts in the correct name and resets the  record
pointer).   Now  go  to  file  transfer  and  type  "w464  +
99tu464".  The program will stop at the protection limit  on
w  of  484, transferring the added 21 records.  Now list the
type as before to check the newly added records.

     Following this method will maximize the safety of  your
data.  Failure to do so will cause no sympathy from the per-
son whose data you accidently destroy (and you must recreate
it for him or her).


_2._4.  _C_o_m_m_a_n_d _I_n_t_e_r_p_r_e_t_a_t_i_o_n

     The specpr terminal input  routine  looks  for  various
special  characters  in  the input. These special characters
are: <, >, ?, %, =, !, ;, and $.  All  of  these  characters
except  ;  and  $  have  special meaning only when it is the
first non blank character on the line. The effect  of  these
characters is as follows:


<    This character when followed  by  a  file  name  causes
     specpr  to  read  input  from  that  file. You can also
     specify a starting and ending line number. For example
     <inputcommands 20 40
     will read commands from  a  file  called  inputcommands
     starting  at  line 20 and stopping after line 40 of the
     file. If the ending line number is  omitted,  the  file
     will  be  read until the end of the file is reached. If
     the starting line number is also omitted  the  file  is
     read starting at the first line.


>    This character when followed  by  a  file  name  causes
     specpr to copy all user input into the named file. When
     not followed by a file name it terminates  the  copying


                      January 26, 1984







     SPECPR User's Manual                      Page 2.5


     of the input.


!    This character when followed by any  string  will  pass
     that  string  to  the UNIX shell (/bin/sh, see the UNIX
     manual) for execution.  For example typing
     !ls
     will give you a listing of the  files  in  the  current
     directory.


;    A semicolon anywhere in an input line is treated as  if
     the user had typed a carriage return instead of a semi-
     colon. For example typing
     c;0 1
     is equivalent to typing
     c
     0 1

     The special characters ?, %, =, and $ involve the "com-
     mand  file"  which  automatically keeps a record of the
     last 20 commands the user has typed,  and  in  addition
     contains  up  to 80 permanent commands. The commands in
     the command file are numbered 1 to  100  with  commands
     1-20  being  the last twenty commands typed by the user
     and commands 21-100 being the permanent  commands.  The
     effect of these 4 special characters is as follows:


?    This character lists the contents of the  command  file
     on the users terminal. The commands are printed in five
     groups of twenty commands. If the ? is  followed  by  a
     digit  from  1 to 5 the corresponding group of commands
     will be printed. If no digit is  specified,  the  first
     group of twenty commands is listed. For example,
     ?2
     will list commands 21-40.


=    This command allows the user to type in  the  permanent
     commands.   The  =  should be followed by the number of
     the command to be entered. The system will  prompt  the
     user with a question mark at which time the user should
     type in up to 80 characters for the  new  command.  For
     example,
     =25
     allows the user to type in command 25.


%    This command allows the user to copy a command from one
     entry  in  the command file to another. Commands may be
     copyed only from commands 1-20 to commands 21-100.  For
     example


                      January 26, 1984







     SPECPR User's Manual                      Page 2.6


     % 10 25
     will copy command 10 to command 25.


$    This command when followed by a number from  1  to  100
     extracts the corresponding entry from the command file.
     For example, if command 25 contains
     0.574
     then typing
     0 $25
     is equivalent to typing
     0 0.574
     Care is needed when the command number is  followed  by
     another  number. If the command ends with a number then
     the user should follow the command number with a  comma
     if  the  number  following  the  command is part of the
     desired final number. For example, if command  25  con-
     tains
     0.574
     then typing
     0 $25,7
     is equivalent to typing
     0 0.5747
     while typing
     0 $25 7
     is equivalent to typing
     0 0.574 7

























9

9                      January 26, 1984



