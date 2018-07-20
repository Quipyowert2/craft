#ifndef field_h
#define field_h

#include "craft.h"
#include "craft_def.h"

#define forti 111111


class field
  {public :

   int  f        [max_land_dx][max_land_dy];
   bool is_water [max_land_dx][max_land_dy];
   win  *w;
   bool w_is_open;
   int  max_p;

   int  b_x [2];
   int  b_y [2];
   int  a_x [2];
   int  a_y [2];


   bool in_cand  [max_land_dx][max_land_dy];
   int  cand_x   [10000];
   int  cand_y   [10000];
   int  first_cand;
   int  last_cand;


   field               ();
   ~field              ();

   void set_zero       ();
   void incr           (int x, int y, int p);
   void decr           ();
   void init_man       (int color);
   void init_building  (int color);
   void add_stayaway   (int x, int y, int p, int dx, int dy);
   void add_forti      (int x, int y, int p, int dx, int dy, int p0);
   void sub_forti      (int x, int y, int p, int dx, int dy);
   bool expand         (int max_time, int color);
   void climb          (int &x, int &y, int p);
   void down           (int &x, int &y);

   void nbest          (int xmin, int ymin, int xmax, int ymax, 
                        int p0, int &pbest, int &xx, int &yy);
   void nbest          (int &x, int &y);

   void nbest          (int xmin, int ymin, int xmax, int ymax, 
                        int p0, int &pbest, int &xx, int &yy, field *pf);
   void nbest          (int &x, int &y, field *pf);

   void dump           (int x, int y);

   bool another_cand   ();
   void init_cand      ();
   void push_cand      (int x, int y);
   void pop_cand       ();
   void push_neighbors (int x, int y);

   bool any_water      (int x, int y);

 };

void add (field *a, field *b, field *c);

#endif
