#ifndef buttons_h
#define buttons_h

/*======================================================================*/
/*= CHANGES AND UPDATES                                                =*/
/*======================================================================*/
/*= date   person file       subject                                   =*/
/*=--------------------------------------------------------------------=*/
/*=                                                                    =*/
/*= 0707 hua    buttons.h    created                                   =*/
/*=                                                                    =*/
/*======================================================================*/

#include "stdio.h"
#include "string.h"

#include "win.h"
#include "io.h"
#include "bool.h"
#include "xmath.h"

/*----------------------------------------------------------------------*/
/* CLASS menu (deklarations)                                            */
/*----------------------------------------------------------------------*/

#define default_button_font  "-misc-*-*-*-*-*-*-*-*-*-*-*-*-*"

class button
  {public:

     Pixmap background;
     win    *w;
     
     char   button_dir [128];
     char   label      [128];
     bool   is_icon;
     bool   with_repeat;
     
     bool   is_pressed;

     int    x;
     int    y;
     int    dx;
     int    dy;

     int    x_label;
     int    y_label;

     int    dx_border;
     int    dy_border;

     int    border_color_light;
     int    border_color_dark;
     int    button_color;
     int    label_color;

     char   label_font [128];
     

     button (win  *b_w,
             const char b_label [],
             int  b_x,
             int  b_y,
             bool b_with_repeat = false,
             int  b_dx          = by_default,
             int  b_dy          = by_default,
             int  b_dx_border   = by_default,
             int  b_dy_border   = by_default,
             int  b_label_color = by_default,
             char *b_label_font = NULL);
             
     
     ~button ();

     void press ();
     void press (bool mode);
     bool eval  (int  &button);
     bool eval  ();
     void write (const char label_string []);
     void write (char label_string [], bool is_pressed);

  };

#endif

