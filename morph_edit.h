
#ifndef morph_edit_h
#define morph_edit_h

#include "objects.h"
#include "ppm.h"
#include "win.h"
#include "ppm.h"
#include "menu.h"

#define max_points    5000
#define max_triangles 2000

class morph_edit
  {public:

      ppm   *orig;
      ppm   *dest;
      win   *w_orig;
      win   *w_dest;
      menu  *men;

      point p        [2][max_points];
      bool  p_free   [max_points];
      bool  p_marked [max_points];
      int   t        [max_triangles][3];
      bool  t_free   [max_triangles];

      int   scale [2];
      int   x0    [2]; 
      int   y0    [2];
     
      int   cx;
      int   cy;
      bool  on_dest;
      bool  on_orig;
      bool  is_shade;

      int   num_marks;
      int   mark [3];
      bool  is_saved;
      bool  point_mode;
      bool  point_grabbed;
      int   grabbed_pno;

      int   l [max_points][2];
      int   num_l;
      int   focus;
      int   point_color;

      int   num_points;
      int   num_triangles;

      char  name [128];


      morph_edit          (char m_name    [],
                           char orig_name [],
                           char dest_name []);

     ~morph_edit          ();

     void load            (char name []);
     void save            (char name []);

     void eval            (bool &is_quit);

     int  add_point       (point p, point p1);
     void delete_point    (int pno);
     int  add_triangle    (int   p1, int p2, int p3);    
     void delete_triangle (int tno);
     void to_back         (int tno);
     void to_front        (int tno);
     int  pno             (point p, point p1);
     bool on_point        (int cx, int cy, int wno, int &pno);

     void invert_cursor   (win *w);
     void handle_cursor   (win  *w,
                           int  eno,
                           bool &on_flag,
                           int  &button,
                           char &cmd);
     void edit_action     (win  *w,
                           ppm  *p,
                           int  wno,
                           int  button,
                           char cmd);

     void invert_marks    ();
     void invert_marks    (win *w, int wno);

     void alloc_mark      (int pno);
     void free_mark       (int pno);

     bool w_line          (int p1, int p2);

     int  xx              (int wno, int x);
     int  yy              (int wno, int y);

     int  px              (int wno, int x);
     int  py              (int wno, int y);

   };

#endif
