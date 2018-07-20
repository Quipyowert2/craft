#ifndef cmap_edit_h
#define cmap_edit_h

#include "bool.h"
#include "win.h"
#include "buttons.h"
#include "dial.h"
#include "objects.h"

#define max_map_dx 800
#define max_map_dy 800



class cmap_edit
  {public :

   bool   changed;
   win    *map_win;
   win    *color_table;
   win    *picture;
   win    *cmd_win;
   button *bquit;
   button *bsplit;
   button *bload;
   button *bsave;
   button *bsaveas;
   button *bimport;
   button *bresize;
   button *brotate;
   button *brotateh;
   button *bflip;
   button *breplace;
   button *boverlay;
   button *bpaste;
   button *bleft;
   button *bright;
   button *bup;
   button *bdown;
   dial   *d_mark;
   int    fg_color;
   int    bg_color;
   int    t_color;
   int    last_x;
   int    last_y;
   int    last_color;

   int    pixel_dx;
   int    pixel_dy;

   int    xcross;
   int    ycross;

   bool   is_mark;
   bool   d_is_mark;

   char   name [128];
   int    dx;
   int    dy;
   int    map  [max_map_dx][max_map_dy];
   bool   omap [5][5];

   cmap_edit      (char name []);
   cmap_edit      ();
   ~cmap_edit     ();

   void load      ();
   void save      ();
   void save_as   (char new_name []);
   void save_as   (char name [], int x0, int y0, int sdx, int sdy);
   void flip_ud   ();
   void flip_lr   ();
   void rotate_r  ();
   void rotate_rh ();
   void rotate    (int orig [max_map_dx][max_map_dy],
                   int rot  [max_map_dx][max_map_dy],
                   int x0,
                   int y0,
                   int x1, 
                   int y1);
   void recolor   (int n);
   void colorize  (int ddx, int ddy, int c, int n);
   void colorize  (int ddx, int ddy);
   void edit      (bool &was_quit);
   void overlay   (char name []);
   void paste     (char name [], int x, int y);

   void split     (int sdx, int sdy, char name [], int no);

   void set_to_ppm (char map_name [], char ppm_name []);
  
 };

#endif
