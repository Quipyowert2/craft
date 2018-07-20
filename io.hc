#include "io.h"

void ack () 
  {while (getchar () != '\n');
  }

void s_ack (char msg []) 
  {printf ("%s ", msg);
   ack    ();
  }

bool ok ()
  {return (getchar () != 'q');
  }

double d_get (char msg [])
  {float d;

   printf ("%s", msg);
   scanf  ("%f", &d);
   return (double) d;
 }

int i_get (char msg [])
  {int i;

   printf ("%s", msg);
   scanf  ("%d", &i);
   return i;
 }
