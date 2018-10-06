#include "cmap_selector.h"
#include "bool.h"
#include "xstring.h"
#include "masks.h"
#include "pattern_match.h"

#define cmap_selector_line_color           gray70
#define cmap_selector_color_1              gray50
#define cmap_selector_color_2              gray90   
#define cmap_selector_background_color     gray
#define cmap_selector_marked_case_color    yellow 
#define cmap_selector_unmarked_case_color  black

cmap_selector::cmap_selector (const char v_name [],
                              win  *v_w,
                              int  v_num_cases,
                              char v_case_string[max_cmap_selector_cases][128],
                              int  v_x,
                              int  v_y,
                              int  v_dx,
                              int  v_dy,
                              bool v_multiple_select)

  {store_params;
   load_colors;
   load_maps;
   set_cases (v_num_cases, v_case_string);
   
.  load_colors
     {c_border_light = win_default_c ("selector_border_light");
      c_border_dark  = win_default_c ("selector_border_dark");
      c_background   = win_default_c ("selector_background");
      c_foreground   = win_default_c ("selector_foreground");
      c_line         = win_default_c ("selector_line");
      c_mark         = win_default_c ("selector_mark");
     }.

.  store_params
     {strcpy (name, v_name);
      w           = v_w;
      x           = v_x;
      y           = v_y;
      dx          = v_dx;
      dy          = v_dy;
      is_multiple = v_multiple_select;
      is_scroller = false;
     }.
      
.  load_maps
     {case_dy = 0;
      case_dx = 0;
      for (int i = 0; i < v_num_cases; i++)
        {case_map [i] = new cmap (w, v_case_string [i]);
         case_dy      = i_max (case_dy, case_map [i]->dy);
         case_dx      = i_max (case_dx, case_map [i]->dx);
        };
      case_dy += 2;
     }.

  }

cmap_selector::~cmap_selector ()
  {delete (sc);
  }

void cmap_selector::set_cases (int  v_num_cases,
                          char v_case_string [max_cmap_selector_cases][128])

  {set_num_cases;
   show_cmap_selector;
   set_scroller;
   set_case_strings;
   draw_frame;
   w->tick ();

.  draw_frame
     {frame (w, x, y, x + dx, y + dy, c_border_dark, c_border_light);
     }.

.  set_num_cases
     {num_cases = v_num_cases;
     }.

.  show_cmap_selector
     {w->set_color (c_background);
      w->fill      (x, y, dx, dy);
     }.

.  set_case_strings
     {for (int i = 0; i < num_cases; i++)
        {mark [i] = false;
         set_string (i, v_case_string [i]);
        };
     }.

.  set_scroller
     {perhaps_delete_scroller;
      is_scroller = true;
      sc_pos      = 0;
      sc          = new scroller (name,
                                  w,
                                  x + dx + 1, y,
                                  1, dy,
                                  0, num_cases-1, 
                                  dy / (case_dy+2),
                                  sc_pos);
     }.

.  perhaps_delete_scroller
     {if (is_scroller)
         delete (sc);
     }.
  
  }

void cmap_selector::set_mark (int case_no, bool mode)
  {mark [case_no] = mode;
   refresh (case_no);
  } 

void cmap_selector::set_string (int case_no, char string [])
  {strcpy  (case_strings [case_no], string);
   get_draw_length;
   refresh (case_no);

.  get_draw_length
     {int s_dx;

      dl = strlen (act_string);
      get_s_dx;
      for (dl = strlen (act_string); dl > 0  && (s_dx > dx-8); dl--)
        get_s_dx;
     }.

.  get_s_dx
     {int d;

      w->text_size (substring (act_string, 0, dl), s_dx, d);
     }.

.  dl          draw_length  [case_no].
.  act_string  case_strings [case_no].

  }

void cmap_selector::refresh (int case_no)
  {if (on_screen)
      draw_string;

.  draw_string
     {set_colors;

      w->set_clip (x+2, y+2, dx-4, dy-4);
      case_map [case_no]->show (x + 2, case_y);
      w->write (x + case_dx + 8,
                case_y + case_dy / 2,
                substring (case_strings [case_no], 0, draw_length [case_no]));
      w->tick     ();
      w->set_clip (0, 0, w->dx (), w->dy ());
     }.


.  set_colors
     {w->set_background (c_background);
      if   (is_mark (case_no))
           w->set_color (c_mark);
      else w->set_color (c_foreground);
     }.

.  on_screen
     (y <= case_y && case_y + case_dy <= y + dy).

.  case_y
     (case_no) * case_dy + y - sc_pos * case_dy + 2.

  }

bool cmap_selector::is_mark (int case_no)
  {return mark [case_no];
  }

bool cmap_selector::on ()
  {int xm;
   int ym;
   int button;

   return (w->is_mouse (xm, ym, button) &&
           x <= xm && xm < x + dx && y <= ym && ym <= y + dy);

  }

bool cmap_selector::eval (int &case_no)
  {bool d;

   return eval (case_no, d);
  }

bool cmap_selector::eval (int &case_no, bool &is_quit)
  {bool any_select = false;

   handle_scroller;
   handle_list_event;
   return any_select;

.  handle_scroller  
     {if (sc->eval (sc_pos))
         scroll_to_new_pos;
     }.

.  scroll_to_new_pos
     {clear_fields;
      for (int i = 0; i < num_cases; i++)
        refresh (i);
      w->tick ();
     }.

.  clear_fields
     {w->set_color (c_background);
      w->fill      (x+1, y+1, dx-1, dy-1);
     }.

.  handle_list_event
     {if (on ())
         perform_list_event;
     }.

.  perform_list_event
     {int xm;
      int ym;
      int button;

      case_no = cmap_selector_no_case;
      is_quit = false;
      get_event;
      if (any_press_event && event_case < num_cases)
         handle_mark_event;
     }.

.  any_press_event
     (button == button1press || 
      button == button2press ||  
      button == button3press).

.  get_event
     {int d;

      w->mouse (d, d, xm, ym, button);
     }.

.  handle_mark_event
     {switch (button)
        {case button1press : handle_mark;   break;
         case button2press : handle_unmark; break;
         case button3press : handle_quit;   break;
        };
     }.

.  handle_mark
     {perhaps_clear_all_marks;
      set_mark (event_case, true);
      w->tick  ();
      any_select = true;
      case_no    = event_case;
     }.

.  perhaps_clear_all_marks
     {if (! is_multiple)
         clear_all_marks;
     }.

.  clear_all_marks
     {for (int i = 0; i < num_cases; i++)
        set_mark (i, false);
     }.

.  handle_unmark
     {set_mark (event_case, false);
      w->tick  ();
      any_select = true;
     }.

.  handle_quit
     {any_select = true;
      is_quit    = true;
     }.

.  event_case
     (ym - y) / case_dy + sc_pos. 

  }


bool cmap_sel (char name [], const char pattern [])
  {int  num_cases;
   char cases [max_cmap_selector_cases][128];
   bool quit;

   get_files;
   perform_sel;
   return ! quit;

.  perform_sel
     {win           *w;
      cmap_selector *sel;
      int           case_no;
      button        *cancel;

      open_sel;
      w->mark_mouse ();
      while (! sel->eval (case_no) && ! quit)
        {w->scratch_mouse ();
         w->mark_mouse    ();
         quit = cancel->eval ();
        };
      if (! quit)  
         strcpy (name, cases [case_no]);
      delete (cancel);
      delete (sel);
      delete (w);
     }.

.  get_files
     {get_file_list (pattern, num_cases, cases);
     }.

.  open_sel
     {quit   = false;
      w      = new win           ("cmap_sel", "", by_fix, by_fix, 400, 700);
      frame (w);
      cancel = new button        (w, "cancel", 180, 640); 
      sel    = new cmap_selector ("cmap_sel",
                                  w,
                                  num_cases,
                                  cases,
                                  10, 10,
                                  340, 600);
     }.

  }


void get_file_list (const char pattern [],
                    int  &num_files,
                    char file_list [max_cmap_selector_cases][128])

  {char file_name    [256];
   char file_pattern [256];

   set_name_and_pattern;
   get_file_list;
   read_file_list;

.  set_name_and_pattern
     {strcpy (file_name,    f_path (pattern));
      strcpy (file_pattern, f_name (pattern)); 
     }.

.  get_file_list
     {char cmd [512];

      if   (strlen (file_name) == 0)
           sprintf (cmd, "csh -f -c \"ls -F > filesel.temp\"");
      else sprintf (cmd, "csh -f -c \"ls -F %s > filesel.temp\"", file_name);
      system (cmd);
     }.

.  file_path
     f_path (file_name).

.  read_file_list
     {FILE *l_file;
      char f_line [1024];

      l_file    = fopen ("filesel.temp", "r");
      num_files = 0;
      while (another_name)
        if (p_match (f_line, file_pattern))
           store_name;
      perhaps_skip_empty_msg;
      fclose (l_file);
     }.
 
.  perhaps_skip_empty_msg
     {if (num_files == 4 && 
          strcmp (file_list [3], "found") == 0 &&
          strcmp (file_list [2], "not")   == 0)
      num_files = 0;
      if (num_files == 4 && 
          strcmp (file_list [3], "match.") == 0 &&
          strcmp (file_list [2], "No")     == 0)
      num_files = 0;
     }.

.  another_name
     (fscanf (l_file, "%1023s", f_line) != EOF &&
      num_files < max_cmap_selector_cases).

.  store_name
     {sprintf (act_f_name, "%s/%s", file_name, f_tail (f_line));
      num_files = i_min (max_cmap_selector_cases-1, num_files + 1);
     }.

.  act_f_name
     file_list [num_files].

  }
