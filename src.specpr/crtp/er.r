	subroutine er
	implicit integer*4 (i-n)

#ccc  version date: 06/01/83
#ccc  author(s): Roger Clark & Jeff Hoover
#ccc  language:  Ratfor
#ccc
#ccc  short description:
#ccc                   This subroutine erases the screen
#ccc  algorithm description: none
#ccc  system requirements:   none
#ccc  subroutines called:
#ccc                    respag
#ccc  argument list description:
#ccc     arguments: none
#ccc  parameter description:
#ccc  common description:
#ccc  message files referenced:
#ccc  internal variables:
#ccc  file description:
#ccc  user command lines:
#ccc  update information:
#ccc  NOTES:
#ccc

      call respag
      return
      end
