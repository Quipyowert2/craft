#ifndef ilfield_h
#define ilfield_h

#include "craft.h"
#include "craft_def.h"

#define max_il 1000

class ilfield
  {public :

   int  f [max_land_dx][max_land_dy];

   int  num_il;
   int  x_il        [max_il];
   int  y_il        [max_il];
   int  own         [max_il];
   int  num_homes   [max_il];
   int  num_mines   [max_il];
   int  num_worker  [max_il];
   int  num_fighter [max_il];
   int  num_healer  [max_il];
   int  num_trade   [max_il];
   int  others      [max_il];
   int  size        [max_il];


   ilfield               ();
   ~ilfield              ();

   void new_isle (int color, int x, int y);
   void update   (int color);
   void expand   ();
   void set_zero ();
  
 };

#endif
