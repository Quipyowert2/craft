#include "stdio.h"
#include "sys/types.h"
#include "sys/times.h"
#include "sys/time.h"

/*----------------------------------------------------------------------*/
/* CLASS timer (deklarations)                                           */
/*----------------------------------------------------------------------*/

#ifndef timer_h
#define timer_h

class timer
  {private :

     long   stamp;
     double dt;

   public :

     void   start ();
     void   stop  ();
     double read  ();
     double exec  ();
     void   delay (int dt);

  };

long sys_time ();

#endif
