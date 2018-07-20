#ifndef scroller_h
#define scroller_h

#include "win.h"
#include "bool.h"
#include "buttons.h"

class scroller
  {public:

     char   name [256];
     win    *w;
     int    x;
     int    y;
     int    dx;
     int    dy;

     int    ruler_x;
     int    ruler_y;
     int    ruler_dx;
     int    ruler_dy;
     int    ruler_x_center;
     int    ruler_y_center;

     int    c_border_dark;
     int    c_border_light;
     int    c_foreground;
     int    c_background;

     int    step_small;
     int    step_large;
     int    min;
     int    max;
     int    size; 
     int    pos;

     bool   was_event;

     button *button_incr;
     button *button_decr;

     scroller  (char name [],
                win  *w,
                int  x,
                int  y,
                int  dx,
                int  dy,
                int  min,
                int  max,
                int  size,
                int  pos,
                int  step_small = 0,
                int  step_large = 0);

     ~scroller (); 
    
     void display           ();
     void display_ruler     ();
     void clear_ruler       ();
     void calc_ruler_params ();

     bool on            ();
     bool eval          (int &pos);
     void set           (int pos);
     void resize        (int size);

  }; 

#endif

