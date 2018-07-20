#ifndef cmap_h
#define cmap_h

#include "bool.h"
#include "win.h"

class cmap
  {public :

   win    *w;
   XImage *image;
   XImage *mask;
   bool   is_image_loaded;
   bool   is_mask_loaded;
   bool   is_mask;
   bool   is_init;

   int    dx;
   int    dy;
 
   int    code;
   char   name [128];

   cmap  (win *w, char name []);
   cmap  (win *w, bool with_mask = false);
   ~cmap ();

   void save      ();
   void save      (char name []);
   void load      ();
   void load      (char name []);

   int  get_pixel (int x, int y);
   int  get_mask  (int x, int y);
   void set_pixel (int x, int y);
   void set_mask  (int x, int y);

   void show      (int x, int y, int dx = 0, int dy = 0);

   void edit      ();

 };

#endif
