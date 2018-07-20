#ifndef formation_h
#define formation_h

#include "bool.h"
#include "win.h"
#include "cmap.h"
#include "buttons.h"
#include "craft.h"
#include "craft_def.h"


class sector_map;

#define max_forms 20

class formation
  {public :

   int   num;
   int   type   [max_forms];
   int   prio   [max_forms];
   int   x      [max_forms];
   int   y      [max_forms]; 
   char  f_name [128];

   int   s  [8];
   int   l  [8];
   int   ss [8];
   int   ll [8];

   formation    (char name []);
   ~formation   ();

   void  save   ();
   void  save   (char name []);
   void  load   (char name []);
       
   void  edit   ();

   int   match  (sector_map *s);

   void  init   ();

 };

#endif
