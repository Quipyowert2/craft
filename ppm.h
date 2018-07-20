/*======================================================================*/
/*= CHANGES AND UPDATES                                                =*/
/*======================================================================*/
/*= date   person file       subject                                   =*/
/*=--------------------------------------------------------------------=*/
/*=                                                                    =*/
/*= 111094 hua    ppm.h      created                                   =*/
/*=                                                                    =*/
/*======================================================================*/

#include "win.h"

#ifndef ppm_h
#define ppm_h

#include "bool.h"

class ppm
  {public:

     int  *r_data;
     int  *g_data;
     int  *b_data;
     int  *cache;

     int  dx;
     int  dy;
     bool is_cache;
     bool cache_loaded;

     ppm        (int dx, int dy, int r, int g, int b);
     ppm        (char name [], bool with_cache = false);
     ppm        (ppm *p);
     ~ppm       ();


     void save  (char name []);

     void rgb   (int x, int y, int &r, int &g, int &b);     
     void set   (int x, int y, int r, int g, int b);
    
     void get_map (win *w, Pixmap &p);
 
     void show  (win *w, int x, int y1);

     void show  (win *w,
                 int wx, int wy, int wdx, int wdy,
                 int x0, int y0, int scale);

     int  ind   (int x, int y);

     bool equal (ppm *p, int x, int y);

   };

     void copy  (ppm *dest, ppm *src);


#endif

