#ifndef cmap_selector_h
#define cmap_selector_h

#include "bool.h"
#include "win.h"
#include "scroller.h"
#include "cmap.h"

#define cmap_selector_no_case   0
#define max_cmap_selector_cases 300

class cmap_selector
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

   int      draw_length  [max_cmap_selector_cases];   
   char     case_strings [max_cmap_selector_cases][128];
   cmap     *case_map    [max_cmap_selector_cases];
   int      num_cases;
   bool     mark         [max_cmap_selector_cases];
   int      case_dy;   
   int      case_dx;
   
   cmap_selector     (char name [], 
                      win  *w,
                      int  num_cases,
                      char case_string [max_cmap_selector_cases][128],
                      int  x,
                      int  y,
                      int  dx,
                      int  dy,
                      bool multiple_select = false);

   ~cmap_selector    ();

   void set_cases     (int  num_cases,
                       char case_string [max_cmap_selector_cases][128]);
   void set_mark      (int  case_no, bool mode);
   void set_string    (int  case_no, char string []);
   void refresh       (int  case_no);
   bool is_mark       (int  case_no);
   bool on            ();

   bool eval          (int  &case_no);
   bool eval          (int  &case_no, bool &is_quit);

  }; 

bool cmap_sel      (char name [], char pattern []);
void get_file_list (char file_pattern [],
                    int  &num_files,
                    char file_list [max_cmap_selector_cases][128]);

#endif

