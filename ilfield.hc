#include "ilfield.h"
#include "building.h"

ilfield::ilfield ()
  {num_il = 0;
  }

ilfield::~ilfield ()
  {
  }

void ilfield::new_isle (int color, int x, int y)
  {int cand_x [10000];
   int cand_y [10000];
   int num_cand = 0;
   int best_dist;
   int ccx;
   int ccy;

   init;
   while (num_cand > 0)
     {prop;
     };

.  init
     {int cx = x;
      int cy = y;

      ccx                   = i_random (5, landscape_dx - 5);
      ccy                   = i_random (5, landscape_dy - 5);
      f            [x][y]   = num_il;
      x_il         [num_il] = x;
      y_il         [num_il] = y;
      best_dist             = act_dist;
      num_homes    [num_il] = 0;
      num_mines    [num_il] = 0;
      own          [num_il] = 0;
      others       [num_il] = 0;
      num_worker   [num_il] = 0;
      num_healer   [num_il] = 0;
      num_fighter  [num_il] = 0;
      num_trade    [num_il] = 0;
      size         [num_il] = 0;
      num_il++;
      push;      
     }.

.  prop
     {int cx;
      int cy;
  
      num_cand--;     
      cx = cand_x [num_cand];
      cy = cand_y [num_cand];
      if (no_f && on_land)
         {set_il;
          perhaps_unit;
          f [cx][cy] = num_il - 1;
          push;
         };
     }.

.  set_il
     {f [cx][cy] = num_il - 1;
      size [num_il-1]++;
      if (act_dist < best_dist && i_random (1, 100) > 70 && dry)
         {x_il [num_il-1] = cx;
          y_il [num_il-1] = cy;
          best_dist       = act_dist;
         };
     }.

.  dry
     (landscape [cx][cy] != land_sea && landscape [cx][cy] != land_water).

.  act_dist
     (cx - ccx) * (cx - ccx) + (cy - ccy) * (cy - ccy).

.  perhaps_unit
     {int u = unit [cx][cy];

      if (u != none)
         handle_unit;
     }.

.  handle_unit
     {if      (objects->color [u] == color)
              add_own
      else if (objects->type [u] == object_mine)
              num_mines [num_il-1]++;
      else    others [num_il-1]++;
      if (landscape [cx][cy] == land_t_gold)
         num_trade [num_il-1]++;
     }. 

.  add_own
     {if (! is_building (objects->type [u]))
         own [num_il-1]++;
      switch (objects->type [u])
        {case object_home   : handle_home;              break;
         case object_worker : num_worker  [num_il-1]++; break;
         case object_pawn   :
         case object_knight :
         case object_archer :
         case object_cata   : num_fighter [num_il-1]++; break;
         case object_doktor : num_healer  [num_il-1]++; break;
        };
     }.
  
.  handle_home
     {if (cx == objects->x [u] && cy == objects->y [u])
         num_homes   [num_il-1]++;
     }.

.  no_f
     f [cx][cy] < 0.

.  on_land
     (landscape [cx][cy] != land_sea && landscape [cx][cy] != land_water).

.  push
     {for (int xx = i_max (0, cx-1); xx < i_min (landscape_dx,cx+2); xx++)
        for (int yy = i_max (0, cy-1); yy < i_min (landscape_dy,cy+2); yy++)
          if (f [xx][yy] == -500)
             {cand_x [num_cand] = xx;
              cand_y [num_cand] = yy;
              f [xx][yy]        = -501;
              num_cand++;
             };
     }.

  }

void ilfield::expand ()
  {   
  }

void ilfield::update (int color)
  {set_zero ();
   for (int y = 0; y < landscape_dy; y++)
     for (int x = 0; x < landscape_dx; x++)
       if (no_f && on_land)
          new_isle (color, x, y);
 
.  no_f
     f [x][y] < 0.

.  on_land
    (landscape [x][y] != land_sea && landscape [x][y] != land_water).

  }

void ilfield::set_zero ()
  {for (int y = 0; y < landscape_dy; y++)
     for (int x = 0; x < landscape_dx; x++)
       f [x][y] = -500;
   num_il = 0;
  }

