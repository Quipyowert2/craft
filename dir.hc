
#include "stdio.h"

#include "dir.h"
#include "xmath.h"
#include "errorhandling.h"

int dir_left (int dir)
  {int d = dir - 1;   

   if (d < 0)
      d = 7;
   return d;
  } 

int dir_right (int dir)
  {int d = dir + 1;   

   if (d == 8)
      d = 0;
   return d;
  } 

void dir_dx_dy (int dir, int &dx, int &dy)
  {switch (dir)
     {case 0  : dx =  0; dy = -1; break;
      case 1  : dx = -1; dy = -1; break;
      case 2  : dx = -1; dy =  0; break;
      case 3  : dx = -1; dy =  1; break;
      case 4  : dx =  0; dy =  1; break;
      case 5  : dx =  1; dy =  1; break;
      case 6  : dx =  1; dy =  0; break;
      case 7  : dx =  1; dy = -1; break;
      default : errorstop (1, "DIR", "invalid direction"); break;
     };
  }
       
int direction (int dx, int dy)
  {if (dx == 0 && dy <  0) return 0;
   if (dx <  0 && dy <  0) return 1;
   if (dx <  0 && dy == 0) return 2;
   if (dx <  0 && dy >  0) return 3;
   if (dx == 0 && dy >  0) return 4;
   if (dx >  0 && dy >  0) return 5;
   if (dx >  0 && dy == 0) return 6;
   if (dx >  0 && dy <  0) return 7;
   return 0;
   errorstop (2, "DIR", "invalid direction");
  }

int fdir (int dx, int dy)
   {if      (dy != 0) perform_fdir
    else if (dx <  0) return 2;
    else              return 6;     

.  perform_fdir
     {double d = g_arc_tan2 (dx, dy);

      if ( -22 <= d && d <=   22) return 6;
      if (  22 <= d && d <=   66) return 5;
      if (  66 <= d && d <=  110) return 4;
      if ( 110 <= d && d <=  154) return 3;
      if ( -66 <= d && d <=   22) return 7;
      if (-110 <= d && d <=  -66) return 0;
      if (-154 <= d && d <= -110) return 1;
      return 2;
     }.

   }

int dir_back (int dir)
  {int d = dir + 4;
  
   if (d > 7)
      d -= 8;
   return d;
  }

int left_dist (int dir1, int dir2)
  {int c = 0;
   int d = dir1;

   while (d != dir2)
     {c++;
      d = dir_left (d);
     };
   return c;
  }
    

