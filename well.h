#ifndef well_h
#define well_h

#include "bool.h"
#include "win.h"
#include "cmap.h"
#include "buttons.h"
#include "craft.h"
#include "craft_def.h"


#define no_pot    -555555
#define path_pot  -555556

class well
  {public :

 
   int dx;
   int dy;
   int f [max_land_dx][max_land_dy];


   well  (int dx, int dy);
   well  (well *w);
   ~well ();

   void  init   ();
   void  set    (int x, int y, int v);
   void  add    (int x, int y, int v);
   int   ff     (int x, int y);
   bool  prop   (int decent);
   void  show   (char title [], win *&w);
   void  renorm ();
   void  climb  (int x, int y);
   int   climb  (int x, int y, well *but, int &xt, int &yt);
   

 };

void add (well *a, well *b, well *&c); 
void sub (well *a, well *b, well *&c); 

#endif
