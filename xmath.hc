/*======================================================================*/
/*= CHANGES AND UPDATES                                                =*/
/*======================================================================*/
/*= date   person file       subject                                   =*/
/*=--------------------------------------------------------------------=*/
/*=                                                                    =*/
/*= 170293 hua    xmath.hc   added i_abs                               =*/
/*=                                                                    =*/
/*======================================================================*/

#include "xmath.h"
#include "bool.h"
#include "objects.h"

extern "C" {
double drand48 ();
void srand48(long seedval);
}

bool b_on (int bits, int bno)
  {return ((bits & (1 << bno)) != 0);
  }

int b_set (int current, int bno)
  {return current | (1 << bno);
  }

int b_reset (int current, int bno)
  {return current & (~(1 << bno));
  }

int i_abs (int a)
  {return (a < 0) ? -a : a;
  }
  
int i_sign (int a)
  {if      (a == 0) return 0;
   else if (a >  0) return 1;
   else             return -1;
  }

int i_min (int a, int b)
  {return (a < b) ? a : b;
  }

int i_max (int a, int b)
  {return (a < b) ? b : a;
  }

int i_mean (int a, int b)
  {return (a + b) / 2;
  }

int i_bound (int min, int i, int max)
  {return (i_min (max, i_max (min, i)));
  }

int i_random (int lower_bound, int upper_bound)
  {return (int) d_random ((double) lower_bound, (double) upper_bound+1-0.001);
  }

double d_min (double a, double b)
  {return (a < b) ? a : b;
  }

double d_max (double a, double b)
  {return (a < b) ? b : a;
  }

double d_bound (double vmin, double v, double vmax)
  {return (d_min (vmax, d_max (vmin, v)));
  }

double d_abs (double a)
  {return (a < 0) ? -a : a;
  }

double d_sign (double a)
  {if      (a == 0) return 0;
   else if (a >  0) return 1;
   else             return -1;
  }
      
double d_round (double d, int s)
  {int i = (int) (d * s);

   return ((double) i / s);
  }

double g_sin (double x)
  {return sin ((x / 180) * M_PI);
  }

double g_arc_tan2 (double dx, double dy)
  {return (atan2 (dy, dx) * 180 / M_PI);
  }

double g_cos (double x)
  {return cos ((x / 180) * M_PI);
  }

double g_arc_sin (double x)
  {return asin (x) * 180 / M_PI;
  }

double g_arc_cos (double x)
  {return acos (x) * 180 / M_PI;
  }

double g_norm (double a)
  {if   (a >= 360)
        return a - 360;
   if   (a < 0)
        return a + 360;
   else return a;
 }

double g_diff (double a1, double a2)
  {
    return g_norm (a2 - a1);
  } 

double d_random (double lower_bound, double upper_bound)
  {return (drand48 () * (upper_bound - lower_bound) + lower_bound);
  }

void d_randomize (int d)
  {srand48 (d);
  }

float f_min (float a, float b)
  {return (a < b) ? a : b;
  }

float f_max (float a, float b)
  {return (a < b) ? b : a;
  }

int nible (char c)
  {if (c == '0')             return 0;
   if (c == '1')             return 1;
   if (c == '2')             return 2;
   if (c == '3')             return 3;
   if (c == '4')             return 4;
   if (c == '5')             return 5;
   if (c == '6')             return 6;
   if (c == '7')             return 7;
   if (c == '8')             return 8;
   if (c == '9')             return 9;
   if (c == 'a' || c == 'A') return 10;
   if (c == 'b' || c == 'B') return 11;
   if (c == 'c' || c == 'C') return 12;
   if (c == 'd' || c == 'D') return 13;
   if (c == 'e' || c == 'E') return 14;
   if (c == 'f' || c == 'F') return 15;
  }

int hextoint (char hex [])
  {return ((nible (hex [0]) * 16) + nible (hex [1]));
  }

char hnible (int i)
  {switch (i)
     {case 0  : return '0';
      case 1  : return '1';
      case 2  : return '2';
      case 3  : return '3';
      case 4  : return '4';
      case 5  : return '5';
      case 6  : return '6';
      case 7  : return '7';
      case 8  : return '8';
      case 9  : return '9';
      case 10 : return 'a';
      case 11 : return 'b';
      case 12 : return 'c';
      case 13 : return 'd';
      case 14 : return 'e';
      case 15 : return 'f';
     };
  }   

char *inttohex (int i)
  {static char r [128];

   fill_r;
   return r;

.  fill_r
     {r [0] = hnible (i / 16);
      r [1] = hnible (i % 16);
      r [2] = 0;
     }.

  }
