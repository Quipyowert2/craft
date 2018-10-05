#ifndef selector_h
#define selector_h

#include "bool.h"
#include "win.h"
#include "scroller.h"

#define selector_no_case   0
#define max_selector_cases 300

class selector
  {public:

   char     name [128];
   win      *w;
   int      x;
   int      y;
   int      dx;
   int      dy;

   int  c_border_light;
   int  c_border_dark;
   int  c_background;
   int  c_foreground;
   int  c_line;
   int  c_mark;

   scroller *sc;
   int      sc_pos;
   bool     is_scroller;
  
   bool     is_multiple;
   bool     with_lines;

   int      draw_length  [max_selector_cases];   
   char     case_strings [max_selector_cases][128];
   int      num_cases;
   bool     mark         [max_selector_cases];
   int      case_dy;   
   
   selector (const char name [],
             win  *w,
             int  num_cases,
             char case_string [max_selector_cases][128],
             int  x,
             int  y,
             int  dx,
             int  dy,
             bool multiple_select = false,
             bool with_lines      = false);

   ~selector ();

   void set_cases  (int  num_cases,
                    char case_string [max_selector_cases][128]);
   void set_mark   (int  case_no, bool mode);
   void set_string (int  case_no, char string []);
   void refresh    (int  case_no);
   bool is_mark    (int  case_no);
   bool on         ();

   bool eval       (int  &case_no);
   bool eval       (int  &case_no, bool &is_quit);

  }; 

#endif

