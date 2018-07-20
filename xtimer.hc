 
#include "xtimer.h"

#include "unistd.h"
#include "sys/time.h"
#include "signal.h"

extern "C"
  {int ftime (struct timeb *);
  }

/*----------------------------------------------------------------------*/
/* CLASS xtimer (funktions)                                              */
/*----------------------------------------------------------------------*/

long x_sys_time ()
  {struct timeb	tb;

   ftime (&tb);
   return (tb.time * 1000 + (unsigned long) tb.millitm);
  }

void xtimer::start ()
  {stamp = x_sys_time ();
   dt    = 0;
  }

void xtimer::stop ()
  {dt    += (double) (x_sys_time () - stamp);
   stamp =  x_sys_time ();
  }

void xtimer::cont ()
  {stamp = x_sys_time ();
  }

double xtimer::exec ()
  {return (double) (x_sys_time () - stamp) + dt;
  }

double xtimer::read ()
  {return dt;
  }

void sig (int signo)
  {signal (SIGALRM, sig);
  }

void delay (int dt)
  {itimerval tick;

   tick.it_value.tv_sec     = dt / 10000;
   tick.it_interval.tv_sec  = 0;
   tick.it_value.tv_usec    = dt * 10;
   tick.it_interval.tv_usec = 600000;

   signal (SIGALRM, sig);
   if (setitimer (ITIMER_REAL, &tick, 0) == 0)
      {pause ();
      }
  }   

