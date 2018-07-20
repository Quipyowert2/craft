#include "stdio.h"
#include "sys/types.h"
#include "sys/timeb.h"
#include "sys/time.h"

/*----------------------------------------------------------------------*/
/* CLASS xtimer (deklarations)                                          */
/*----------------------------------------------------------------------*/

#ifndef xtimer_h
#define xtimer_h

class xtimer
  {private :

     long   stamp;
     double dt;

   public :

     void   start ();
     void   cont  ();
     void   stop  ();
     double read  ();
     double exec  ();

  };

long x_sys_time ();
void delay (int dt);

#endif
