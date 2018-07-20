#ifndef sector_map_h
#define sector_map_h

#include "bool.h"
/*
#include "win.h"
*/
#include "cmap.h"
#include "buttons.h"
#include "craft.h"
#include "craft_def.h"
#include "formation.h"
#include "menu.h"

class sector_map
  {public :

   int s     [8];
   int l     [8];
   int ss    [8];
   int ll    [8];
   int sa    [8];
   int la    [8];
   int sid   [8][max_objects];
   int s_num [8];
   int lid   [8][max_objects];
   int l_num [8];

   sector_map  (int x, int y, int own_color);
   ~sector_map ();

   void print  ();


 };

#endif
