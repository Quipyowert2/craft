#ifndef cluster_h
#define cluster_h

#include "bool.h"
#include "win.h"
#include "cmap.h"
#include "buttons.h"
#include "craft.h"
#include "craft_def.h"

#define max_types   50
#define max_members 50


class cluster
  {public :

   int anz  [max_types];
   int x    [max_members];
   int y    [max_members];
   int id   [max_members];
   int prio [max_members];
   int num_members;

   cluster  (char name []);
   ~cluster ();

   int match (int color);
   
 };

#endif
