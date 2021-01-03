      Subroutine Ssube (xn,xk,s,Se)
      implicit none

      real xn,xk,s,Se
c
      real*4 offset 
      real*4 xnew
      offset=0.05
c     xn less than 1 case
      if (xn.ge.1.0) goto 4 
      xnew=1/xn
      if (xnew.le.1.3) offset = 0.05 - 0.16667*(1.3-xnew)
      if (xnew.ge.2.5) offset = 0.05 - 0.015*((xnew-2.5)**(1.0/2.0)) 
      goto 7
4     if (xn.le.1.3) offset = 0.05 - 0.16667*(1.3-xn)
      if (xn.ge.2.5) offset = 0.05 - 0.015*((xn-2.5)**(1.0/2.0)) 
7     if (offset.le.0.0) offset=0.0 	
      Se = s + offset
      if (Se.gt.1.0) Se = 1.0
c
c      write (6,*) 'S sub e = ', Se

      return
      end      
