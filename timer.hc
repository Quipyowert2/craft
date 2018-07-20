
#include "timer.h"

extern "C" {int gettimeofday (struct timeval *t, struct timezone *z);}

/*----------------------------------------------------------------------*/
/* CLASS timer (funktions)                                              */
/*----------------------------------------------------------------------*/

long sys_time ()
  {timeval  t_val;
   timezone t_zone;

   gettimeofday (&t_val, &t_zone);
   return t_val.tv_sec;
  }

void timer::delay (int dt)
  {long a;

   a = sys_time ();
   while (sys_time () - a < dt)
     {
     };

  }   

void timer::start ()
  {stamp = sys_time ();
  }

void timer::stop ()
  {dt    = (double) (sys_time () - stamp);
   stamp = sys_time ();
  }

double timer::exec ()
  {return (double) (sys_time () - stamp);
  }

double timer::read ()
  {return dt;
  }
