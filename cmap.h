#ifndef cmap_h
#define cmap_h

#include "bool.h"
#include "win.h"
#include "color_trans.h"

class cmap
  {public :

   Pixmap      image;
   Pixmap      mask;
   bool        is_mask;
   bool        is_loaded;
   win         *w;

   int         dx;
   int         dy;
   char        name [128];

   color_trans *ct;
   bool        is_color_trans;
   int         rot;

   cmap      (win  *w_i,
              char name_i [],
              bool preload = true,
              bool smart_load = true);
   ~cmap     ();

   void set_color_trans (color_trans *t);
   void set_rot         (int r);
   void load            (bool smart = true);
   void show            (int x, int y);
   void show            (int x, int y, int xclip, int yclip);
   void showd           (int x, int y, int xclip, int yclip, int dx, int dy);
   void show            (int x, int y,int src_x,int src_y,int xclip,int yclip);
   void show            (int x, int y,int max_x, int max_y, 
                         int src_x,int src_y,int xclip,int yclip);
   void fill            (int x, int y, int dx, int dy);
   void rotate          (int x, int y, int &xn, int &yn);


 };

#endif
