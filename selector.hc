#include "selector.h"
#include "bool.h"
#include "xstring.h"
#include "masks.h"

#define selector_line_color           gray70
#define selector_color_1              gray50
#define selector_color_2              gray90   
#define selector_background_color     gray
#define selector_marked_case_color    yellow 
#define selector_unmarked_case_color  black

selector::selector (char v_name [], 
                    win  *v_w,
                    int  v_num_cases,
                    char v_case_string [max_selector_cases][128],
                    int  v_x,
                    int  v_y,
                    int  v_dx,
                    int  v_dy,
                    bool v_multiple_select,
                    bool v_with_lines)

  {store_params;
   load_colors;
   calc_params;
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
      with_lines  = v_with_lines;
     }.
      
.  calc_params
     {int d;

      w->text_size ("lala", d, case_dy);
      case_dy += 8;
     }.

  }

selector::~selector ()
  {delete (sc);
  }

void selector::set_cases (int  v_num_cases,
                          char v_case_string [max_selector_cases][128])

  {set_num_cases;
   show_selector;
   set_scroller;
   set_case_strings;
   w->tick ();

.  set_num_cases
     {num_cases = v_num_cases;
     }.

.  show_selector
     {w->set_color (c_background);
      w->fill      (x, y, dx, dy);
      frame        (w, x, y, x + dx, y + dy, 
                    c_border_dark, c_border_light);
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
                                  dy / (case_dy+1),
                                  sc_pos);
     }.

.  perhaps_delete_scroller
     {if (is_scroller)
         delete (sc);
     }.
  
  }

void selector::set_mark (int case_no, bool mode)
  {mark [case_no] = mode;
   refresh (case_no);
  } 

void selector::set_string (int case_no, char string [])
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

void selector::refresh (int case_no)
  {if (on_screen)
      draw_string;

.  draw_string
     {set_colors;
      w->write (x      + 2,
                case_y - 2,
                substring (case_strings [case_no], 0, draw_length [case_no]));
      perhaps_line;
     }.

.  perhaps_line
     {if (with_lines)
         draw_line;
     }.

.  draw_line
     {w->set_color (c_line);
      w->line      (x+2, case_y, x + dx - 2, case_y);
     }.

.  set_colors
     {w->set_background (c_background);
      if   (is_mark (case_no))
           w->set_color (c_mark);
      else w->set_color (c_foreground);
     }.

.  on_screen
     (y + case_dy <= case_y && case_y <= y + dy).

.  case_y
     (case_no+1) * case_dy + y - sc_pos * case_dy.

  }

bool selector::is_mark (int case_no)
  {return mark [case_no];
  }

bool selector::on ()
  {int xm;
   int ym;
   int button;

   return (w->is_mouse (xm, ym, button) &&
           x <= xm && xm < x + dx && y <= ym && ym <= y + dy);

  }

bool selector::eval (int &case_no)
  {bool d;

   return eval (case_no, d);
  }

bool selector::eval (int &case_no, bool &is_quit)
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

      case_no = selector_no_case;
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


