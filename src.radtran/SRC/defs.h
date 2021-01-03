
integer*4 MAXCHNS # maximum number of channels per spectrum
integer*4 MAXTEXT # maximum number characters in a text record

parameter (MAXCHNS = 4852)
parameter (MAXTEXT = 19408)

integer*4 NBND    # number of band depths allowed
integer*4 NMINL   # number of minerals allowed in the intimate mix computation

parameter (NBND = 3)
parameter (NMINL = 9)

integer*4 NAREF   # number of spectra for areal fractions
integer*4 NMMIX   # number of working arrays for molecular mix

parameter (NAREF = 2)
parameter (NMMIX = 5)


