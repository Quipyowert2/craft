#include "sector_map.h"
#include "dir.h"

#define s_dist  7 /* scope cata */

sector_map::sector_map (int x, int y, int own_color)
  {init;
   pick_up_sectors;

.  init
     {for (int i = 0; i < 8; i++)
        {s_num [i] = 0;
         l_num [i] = 0;
         s     [i] = 0;
         l     [i] = 0;
         ss    [i] = 0;
         ll    [i] = 0;
         sa    [i] = 0;
         la    [i] = 0;
        };
     }.

.  pick_up_sectors
     {for (int i = 0; i < max_objects; i++)
        if (! objects->is_free [i] && objects->color [i] != own_color)
           pick_up_object;
     }.

.  pick_up_object
     {if   (dist (x, y, objects->x [i], objects->y [i]) < s_dist)
           get_s_object
      else get_l_object;
     }.

.  get_s_object
     {int d = fdir (objects->x [i] - x, objects->y [i] - y);
  
      sid [d][s_num [d]] = i;
      s_num [d]++;
      switch (objects->type [i])
        {case object_knight        : s  [d] += 2; break;
         case object_archer        : ss [d] += 1; break;
         case object_pawn          : s  [d] += 1; break;
         case object_cata          : ss [d] += 6; break;
         case object_worker        : sa [d] += 1; break;
         case object_home          : sa [d] += 2; break;
         case object_building_site : sa [d] += 2; break;
         case object_camp          : sa [d] += 3; break;
         case object_farm          : sa [d] += 3; break;
         case object_mill          : sa [d] += 3; break;
         case object_smith         : sa [d] += 3; break;
         case object_uni           : sa [d] += 3; break;
         case object_doktor        : sa [d] += 3; break;
        };
     }.

.  get_l_object
     {int d = fdir (objects->x [i] - x, objects->y [i] - y);
  
      lid [d][l_num [d]] = i;
      l_num [d]++;
      switch (objects->type [i])
        {case object_knight        : l  [d] += 2; break;
         case object_archer        : ll [d] += 1; break;
         case object_pawn          : l  [d] += 1; break;
         case object_cata          : ll [d] += 6; break;
         case object_worker        : la [d] += 1; break;
         case object_home          : la [d] += 2; break;
         case object_building_site : la [d] += 2; break;
         case object_camp          : la [d] += 3; break;
         case object_farm          : la [d] += 3; break;
         case object_mill          : la [d] += 3; break;
         case object_smith         : la [d] += 3; break;
         case object_uni           : la [d] += 3; break;
         case object_doktor        : la [d] += 3; break;
        };
     }.

  }

sector_map::~sector_map ()
  {
  };

void sector_map::print ()
  {int i;

   i = 1; x;
   i = 0; x;
   i = 7; x; printf ("\n");
   i = 2; x;
   print_space;
   i = 6; x; printf ("\n");
   i = 3; x;
   i = 4; x;
   i = 5; x; printf ("\n");

.  x
     {printf ("(%3d,%3d,%3d)(%3d,%3d,%3d)", 
              s [i], ss [i], sa [i],
              l [i], ll [i], la [i]);
     }.

.  print_space
     {printf ("                          ");
     }.
     
  }