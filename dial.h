#ifndef dial_h
#define dial_h

/*======================================================================*/
/*= CHANGES AND UPDATES                                                =*/
/*======================================================================*/
/*= date   person file       subject                                   =*/
/*=--------------------------------------------------------------------=*/
/*=                                                                    =*/
/*= 291193 hua    dial.h     created                                   =*/
/*=                                                                    =*/
/*======================================================================*/

#include "bool.h"
#include "buttons.h"
#include "getline.h"

class dial
  {public :

     win *w;
     char title [128];
     int  title_dx;
     int  x;
     int  y;

     int  v_min;
     int  v_max;
     int  incr;
     int  incr2;
     bool is_bool;
     bool b_val;
     char s_value [128];
     bool is_hist;

     int  val_dx;

     craft_getline *g_value;
     button  *up;
     button  *down;
     button  *up2;
     button  *down2;
     history *hist;
     button  *hist_button;
     dial    *d_mark;
     bool    with_edit;

   dial  (win  *w, 
          const char title [],
          int  title_dx,
          int  x, 
          int  y,
          int  v_min,
          int  val,
          int  v_max,
          int  incr,
          bool with_hist   = false,
          int  value_dx    = 80,
          bool may_edit    = true,
          int  incr2       = 0,
          bool auto_repeat = false);
   dial  (win  *w, 
          const char title [],
          int  title_dx,
          int  x, 
          int  y,
          bool val);
   ~dial ();

   bool eval (int &val);
   void set  (int val);

 };

#endif
