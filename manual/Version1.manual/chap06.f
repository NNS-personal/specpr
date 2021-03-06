



     SPECPR User's Manual                      Page 6.1


_6.  _W_A_V_E_L_E_N_G_T_H _A_S_S_I_G_N_M_E_N_T_S


_6._1.  _W_a_v_e_l_e_n_g_t_h_s

     The wavelengths can be stored in any of 99  "wavelength
records".   Each  wavelength  record  may  contain up to 256
points.  Although it is called a wavelength  record,  it  is
really  the  horizontal  axis values which correspond to the
data  records  (the  vertical  axis   data   values).    The
"wavelength  record" could actually be time, phase angle, or
whatever you wish to plot.  Then, when  you  actually  do  a
plot,  you can label the horizontal axis (and vertical axis)
anything you  want  (e.g.  time,  phase  angle,  wavelength,
etc.).  This makes the program more than a spectrum process-
ing program.  Wavelengths will  be  assumed  to  be  in  the
wavelength  record  for  the  rest of this manual, but it is
understood that it could be other data (e.g.  time).

     The wavelength assignments  also  sets  the  number  of
channels to be processed (2 to 256).  The number of channels
is stored in the wavelength header record.






























9

9                      January 26, 1984







     SPECPR User's Manual                      Page 6.2


_6._2.  '_W_e_d_g_e' _C_V_F _W_a_v_e_l_e_n_g_t_h_s

     Wavelengths of the standard  "Wedge"  CVF  spectrometer
can  be  generated with small calibration shifts by typing _w
and then the calibration shift in angstroms when asked.  The
program  will  then  ask in which wavelength record to store
the wavelengths.  The number of  channels  is  set  to  120.
Table 6.2.1 shows the CVF wavelengths.

                        Table 6.2.1









































9


9                      January 26, 1984







     SPECPR User's Manual                      Page 6.3


8_______________________________________________________________________
                          IR  CVF wavelengths
8_______________________________________________________________________
 channel   wavelength    channel   wavelength    channel   wavelength
8_______________________________________________________________________
       1   6.20300e-01         2   6.33200e-01         3   6.44100e-01
       4   6.56000e-01         5   6.67900e-01         6   6.79900e-01
       7   6.91700e-01         8   7.04700e-01         9   7.16400e-01
      10   7.28900e-01        11   7.39800e-01        12   7.51900e-01
      13   7.63600e-01        14   7.75600e-01        15   7.86300e-01
      16   7.99000e-01        17   8.11700e-01        18   8.22400e-01
      19   8.37100e-01        20   8.49800e-01        21   8.62500e-01
      22   8.75800e-01        23   8.87300e-01        24   8.99600e-01
      25   9.11800e-01        26   9.24000e-01        27   9.36200e-01
      28   9.48400e-01        29   9.61300e-01        30   9.73500e-01
      31   9.86300e-01        32   9.97800e-01        33   1.01080e+00
      34   1.02180e+00        35   1.03450e+00        36   1.04710e+00
      37   1.05980e+00        38   1.07250e+00        39   1.08520e+00
      40   1.09780e+00        41   1.10970e+00        42   1.12270e+00
      43   1.13520e+00        44   1.14770e+00        45   1.16040e+00
      46   1.17300e+00        47   1.18550e+00        48   1.19810e+00
      49   1.21060e+00        50   1.22320e+00        51   1.23570e+00
      52   1.24810e+00        53   1.26150e+00        54   1.27450e+00
      55   1.28780e+00        56   1.30000e+00        57   1.31300e+00
      58   1.32880e+00        59   1.34080e+00        60   1.35300e+00
      61   1.31100e+00        62   1.33220e+00        63   1.35340e+00
      64   1.37540e+00        65   1.39790e+00        66   1.41990e+00
      67   1.44190e+00        68   1.46370e+00        69   1.48640e+00
      70   1.50670e+00        71   1.52540e+00        72   1.54870e+00
      73   1.56890e+00        74   1.59040e+00        75   1.61190e+00
      76   1.63290e+00        77   1.65520e+00        78   1.67750e+00
      79   1.69980e+00        80   1.72210e+00        81   1.74430e+00
      82   1.76470e+00        83   1.78670e+00        84   1.80850e+00
      85   1.83120e+00        86   1.85320e+00        87   1.87620e+00
      88   1.89920e+00        89   1.92220e+00        90   1.94500e+00
      91   1.96800e+00        92   1.99090e+00        93   2.01240e+00
      94   2.03490e+00        95   2.05790e+00        96   2.08090e+00
      97   2.10410e+00        98   2.12720e+00        99   2.15040e+00
     100   2.17360e+00       101   2.19700e+00       102   2.21880e+00
     103   2.24180e+00       104   2.26390e+00       105   2.28580e+00
     106   2.30630e+00       107   2.32780e+00       108   2.34890e+00
     109   2.37010e+00       110   2.39160e+00       111   2.41260e+00
     112   2.43460e+00       113   2.45460e+00       114   2.47460e+00
     115   2.49510e+00       116   2.51560e+00       117   2.53610e+00
     118   2.55660e+00       119   2.57710e+00       120   2.59760e+00
8_______________________________________________________________________
7|8|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|









































9                      |7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|








































                                              |7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|








































                                                                      |8|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|











































9






9

9                      January 26, 1984







     SPECPR User's Manual                      Page 6.4


_6._3.  _V_i_s_i_b_l_e _W_e_d_g_e _W_a_v_e_l_e_n_g_t_h_s

     Wavelengths of the visible "Wedge" CVF spectrometer can
be  generated by typing _v.  The number of channels is set to
120. Table 6.3.1 shows the visible CVF wavelengths.

                        Table 6.3.1

8__________________________________________________________________________
                         Visible CVF wavelengths
8__________________________________________________________________________
 channel    wavelength    channel    wavelength    channel    wavelength
8__________________________________________________________________________
       1   -1.23000e+34         2   -1.23000e+34         3    3.26800e-01
       4    3.26800e-01         5    3.26800e-01         6    3.26800e-01
       7    3.26800e-01         8   -1.23000e+34         9   -1.23000e+34
      10    3.50500e-01        11    3.50500e-01        12    3.50500e-01
      13    3.50500e-01        14   -1.23000e+34        15   -1.23000e+34
      16   -1.23000e+34        17    3.75000e-01        18    3.75000e-01
      19    3.75000e-01        20    3.75000e-01        21   -1.23000e+34
      22   -1.23000e+34        23    3.70161e-01        24    3.75236e-01
      25    3.80341e-01        26    3.85475e-01        27    3.90638e-01
      28    3.95831e-01        29    4.01053e-01        30    4.06305e-01
      31    4.11585e-01        32    4.16895e-01        33    4.22235e-01
      34    4.27604e-01        35    4.33002e-01        36    4.38429e-01
      37    4.43886e-01        38    4.49372e-01        39    4.54888e-01
      40    4.60433e-01        41    4.66007e-01        42    4.71611e-01
      43    4.77244e-01        44    4.82906e-01        45    4.88598e-01
      46    4.94319e-01        47    5.00069e-01        48    5.05849e-01
      49    5.11657e-01        50    5.17496e-01        51    5.23363e-01
      52    5.29261e-01        53    5.35187e-01        54    5.41143e-01
      55    5.47128e-01        56    5.53142e-01        57    5.59186e-01
      58    5.65259e-01        59    5.71362e-01        60    5.77493e-01
      61    5.83655e-01        62    5.89845e-01        63    5.96065e-01
      64    6.02314e-01        65    6.08593e-01        66    6.14900e-01
      67    6.21238e-01        68    6.27604e-01        69    6.43000e-01
      70    6.40425e-01        71    6.46880e-01        72    6.53364e-01
      73    6.59877e-01        74    6.66420e-01        75    6.72992e-01
      76    6.79593e-01        77    6.82244e-01        78    6.92884e-01
      79    6.99574e-01        80    7.06292e-01        81    7.13040e-01
      82   -1.23000e+34        83   -1.23000e+34        84   -1.23000e+34
      85   -1.23000e+34        86   -1.23000e+34        87    6.78967e-01
      88    6.91550e-01        89    7.04134e-01        90    7.16717e-01
      91    7.29300e-01        92    7.41883e-01        93    7.54466e-01
      94    7.67049e-01        95    7.79632e-01        96    7.92215e-01
      97    8.04798e-01        98    8.17381e-01        99    8.29964e-01
     100    8.42547e-01       101    8.55130e-01       102    8.67713e-01
     103    8.80296e-01       104    8.92879e-01       105    9.05463e-01
     106    9.18046e-01       107    9.30629e-01       108    9.43212e-01
     109    9.55795e-01       110    9.68378e-01       111    9.80961e-01
     112    9.93544e-01       113    1.00613e+00       114    1.01871e+00
     115    1.03129e+00       116    1.04388e+00       117    1.05646e+00
     118    1.06904e+00       119    1.08163e+00       120    1.09421e+00



9                      January 26, 1984







     SPECPR User's Manual                      Page 6.5


8__________________________________________________________________________
799|99|99|99|99|99|99|99|
77777777799                       |9|99|99|99|99|99|99|99|99|
7777777777899                                                |9|99|99|99|99|99|99|99|99|
7777777777899                                                                         |99|99|99|99|99|99|99|
7777777




















































9                      January 26, 1984







     SPECPR User's Manual                      Page 6.6


_6._4.  _P_D_S _N_o_m_i_n_a_l _W_a_v_e_l_e_n_g_t_h_s

     The Nominal wavelengths of the PDS photometer are  gen-
erated  and stored by typing _p.  Then type in the wavelength
record number.  The number of channels is set to 25.   Table
6.4.1 shows the PDS nominal wavelengths.
                        Table 6.4.1

8      _______________________________________________
            PDS photometer nominal wavelengths
8      _______________________________________________
       channel   wavelength    channel   wavelength
8      _______________________________________________
             1   3.25000e-01         2   3.50000e-01
             3   3.75000e-01         4   4.00000e-01
             5   4.33000e-01         6   4.66000e-01
             7   5.00000e-01         8   5.33000e-01
             9   5.66000e-01        10   6.00000e-01
            11   6.33000e-01        12   6.66000e-01
            13   7.00000e-01        14   7.33000e-01
            15   7.66000e-01        16   8.00000e-01
            17   8.33000e-01        18   8.66000e-01
            19   9.00000e-01        20   9.33000e-01
            21   9.66000e-01        22   1.00000e+00
            23   1.03300e+00        24   1.06600e+00
            25   1.10000e+00
8      _______________________________________________
7     |8|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|














9                            |7|7|7|7|7|7|7|7|7|7|7|7|7|7|













                                                    |8|7|7|7|7|7|7|7|7|7|7|7|7|7|7|7|
















9


_6._5.  _R_e_a_d _W_a_v_e_l_e_n_g_t_h_s

     To read data from v, w, d, u, or y and put  it  in  the
wavelength  record,  type _r.  Now type in the file ID (v, w,
d, u, or y), the record number, a space, and the  number  of
channels.  Next type in the wavelength record number.



_6._6.  _W_r_i_t_e _W_a_v_e_l_e_n_g_t_h_s

     To write data from the wavelength file to a  data  file
(v, w, d, u, y) type _t.  Next type in the file ID and record
number of where to write the wavelengths.  The record number
is  set  to the protected record plus 1, but you must give a
nonzero number.  For example, type _v_1 and, if the protection
is 153, the wavelengths will be written to v154. After which
you are prompted to enter the wavelength record number which
you want to write the data.




9

9                      January 26, 1984







     SPECPR User's Manual                      Page 6.7


_6._7.  _T_y_p_e _I_n _Y_o_u_r _O_w_n _W_a_v_e_l_e_n_g_t_h_s

     To type in your own wavelengths, type _y.  Then type  in
the  number,  and  return  for  each  channel.  When you are
through typing in wavelengths, type _n.  The number of  chan-
nels  will  be  set.   Then  type  in  the wavelength record
number.  If you  wish  to  stop  input  and  not  write  the
wavelengths  to  the wavelength file, type _x.  If you do not
type x you will be prompted for a title, history, date,  and
manual history to be associated with this wavelength record.
Title, history information and channel number is saved in  a
wavelength header file.


_6._8.  _C_h_a_n_g_e _C_h_a_n_n_e_l _N_u_m_b_e_r

     To change the number of channels, type _c.  Then type in
the number of channels and the wavelength record number.


_6._9.  _E_d_i_t _W_a_v_e_l_e_n_g_t_h_s

     Type _d to edit the  wavelength  file.   The  wavelength
record  number  given in the header information will be read
into  memory  for  editing.   Then  type  _p  to  print   the
wavelengths  or  _x to exit the editor.  To edit, you type in
the channel number and the wavelength of that channel.  Then
type  in  the  wavelength record number of where you wish to
store the edited wavelengths.


_6._1_0.  _L_i_s_t _w_a_v_e_l_e_n_g_t_h _r_e_c_o_r_d_s

     Typing _l will allow you to list the titles,  number  of
channels and the dates of your wavelength file records.


_6._1_1.  _W_a_v_e_l_e_n_g_t_h _R_o_u_t_i_n_e _C_a_p_a_b_i_l_i_t_i_e_s

     The capabilities of the wavelength routines  allow  you
to generate your own wavelengths by typing them in yourself,
creating them from math operations or  editing.   Since  the
wavelengths  can  be  treated as data when written to a data
file, you can create your own data or  edit  existing  data.
Similarly data written to the wavelength file can be treated
as wavelengths, time, phase angle, or whatever you wish.






9

9                      January 26, 1984



