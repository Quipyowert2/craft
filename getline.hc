#include "xstring.h"
#include "getline.h"
#include "masks.h"

#define hist_button_name         "/hist.open"

craft_getline::craft_getline (const char v_name   [],
                              win  *v_w,
                              char v_string [],
                              int  v_x,
                              int  v_y,
                              int  v_dx,
                              int  v_dy,
                              bool v_with_history,
                              bool show_history_top,
                              bool single_char)
            
  {store_params;
   get_colors;
   calc_params;
   show_box;
   init;
   init_history;
   refresh ();

.  get_colors
     {c_background = win_default_c ("getline_background");
      c_foreground = win_default_c ("getline_foreground");
      c_cursor     = win_default_c ("getline_cursor");
      c_light      = win_default_c ("getline_border_light");
      c_dark       = win_default_c ("getline_border_dark");
     }.

.  init
     {key          = 0;
      key_cnt      = 0;
      is_active    = false;
      was_deactive = false;
      pos          = 0;
      pos_0        = 0;
     }.

.  store_params
     {strcpy (name, v_name);
      with_history   = v_with_history;
      is_single_char = single_char;
      w              = v_w;
      line           = v_string;
      x              = v_x;        
      y              = v_y;        
      dx             = v_dx;       
      dy             = v_dy;
     }.

.  calc_params
     {int t_dx;
      int t_dy;

      w->text_size ("Yy|", t_dx, t_dy);
      lx  = 4;
      ly  = (dy - t_dy) / 2 + t_dy;
     }.
       
.  show_box
     {frame (w, x, y, x + dx, y + dy, c_dark, c_light);
     }.

.  init_history
     {if (with_history)
         open_history;
     }.

.  open_history
     {hist_button = new button  (w, 
                                 hist_button_name,
                                 x + dx + 2, y);
      hist        = new history (name,
                                 hist_button);
      if (show_history_top)
         show_hist_top;    
     }.

.  show_hist_top
     {if (hist->num_entries > 0)
         strcpy (line, hist->entry [0]);
     }.

  }

craft_getline::~craft_getline ()
  {if (with_history)
      {delete (hist_button);
       delete (hist);
      };
  }

void craft_getline::refresh ()
  {int cx;
   int dl;
   int d;

   calc_dl;
   show_frame;
   show_text;
   validate_cursor;
   if (is_active)   
      show_cursor;
   w->tick ();

.  validate_cursor
     {pos = i_min (pos, strlen (line));
     }.

.  show_frame
     {w->function  (GXcopy);
      w->set_color (c_background);
      w->fill      (x+1, y+1, dx-1, dy-1);
     }.

.  show_text
     {w->set_background (c_background);
      w->set_color      (c_foreground);
      w->write          (x + lx, y + ly, substring (line, pos_0, dl));
     }.

.  show_cursor 
     {w->set_color (c_cursor);
      w->function  (GXcopy);
      w->line      (x + cx, y + dy - 2, x + cx, y + 2);
     }.

.  calc_dl
     {int s_dx = 0;

      for (dl = pos_0; dl <= strlen (line) && (s_dx < dx-8); dl++)
        get_s_dx;
      if (s_dx >= dx-8)
         dl--;
     }.

.  get_s_dx
     {int d;

      w->text_size (substring (line, pos_0, dl), s_dx, d);
      if (dl == pos)
         cx = lx + s_dx;
     }.

  }

void craft_getline::check_activation ()
  {int d;

   w->tick ();
   if (w->is_mouse (d, d, d))
      active (on ());
  }

bool craft_getline::on ()
  {int xm;
   int ym;
   int button;
   int is_click;

   w->tick ();
   is_click = w->is_mouse (xm, ym, button);
   return within_edit_box;

.  within_edit_box
     (x <= xm && xm <= x + dx && y <= ym && ym <= y + dy).

  }

void craft_getline::active (bool mode)
  {was_deactive = (is_active && ! mode);
   is_active    = mode;
  }

bool craft_getline::eval ()
  {check_activation ();
   check_hist_button;
   if (was_deactive)
      handle_deactivation;
   if (is_active)
      handle_active;
   return false;

.  handle_deactivation
     {refresh ();
      if (with_history)
         hist->push (line);
      was_deactive = false;
      return true;
     }.

.  check_hist_button
     {if (with_history && hist_button->eval ())
         handle_hist;
     }.

.  handle_hist
     {char hist_line [256];

      hist_button->press (true);
      strcpy             (hist_line, hist->select (by_fix, by_fix, dx, 140));
      hist_button->press (false);
      if (strlen (hist_line) > 0)
         use_hist_line;
     }.

.  use_hist_line
     {strcpy (line, hist_line);
      was_deactive = true;
      is_active    = false;
     }.

.  handle_active
     {int  xm;
      int  ym;
      int  button;

      w->tick ();
      if   (is_mouse_event) 
           handle_mouse_event
      else handle_key_event;
      return false;
     }.

.  is_mouse_event
     w->is_mouse (xm, ym, button).

.  handle_mouse_event
     {int d;
      int mouse_pos   = 0;
      int mouse_delta = 10000;

      if (on ())
         {get_mouse_pos;
          pos = mouse_pos + pos_0;
         };
      w->mouse (d, d, d);
      refresh  ();
     }.

.  get_mouse_pos
     {for (int i = pos_0; i <= strlen (line); i++)
        check_mouse_pos;
     }.

.  check_mouse_pos
     {int sdx;
      int sdy;

      w->text_size (substring (line, pos_0, i), sdx, sdy);
      if (act_delta < mouse_delta)
         {mouse_delta = act_delta;
          mouse_pos   = i;
         };
     }.

.  act_delta 
     (i_abs (x + sdx - xm)).    

.  handle_key_event
     {char c;
      int  key;
      char cntl [32];

      get_cmd;   
      if (key != 0)
         exec_cmd;
     }.

.  is_quit
     (key == 96).

.  get_cmd
     {w->tick ();
      c = w->inchar (key, cntl);
     }.

.  exec_cmd
     {if      (strcmp (cntl, "Left")      == 0 ||
               strcmp (cntl, "KP_Left")   == 0)    handle_cursor_left
      else if (strcmp (cntl, "Right")     == 0 ||
               strcmp (cntl, "KP_Right")  == 0)    handle_cursor_right  
      else if (strcmp (cntl, "BackSpace") == 0 ||
               strcmp (cntl, "Delete")    == 0)    handle_delete_prev
      else if (strcmp (cntl, "KP_Delete") == 0)    handle_delete_act
      else if (strcmp (cntl, "Return")    == 0)    handle_return
      else handle_text_input;
      refresh ();
     }.

.  handle_return
     {active (false);
     }.
 
.  handle_cursor_left
     {pos   = i_max (0, pos - 1);
      pos_0 = i_min (pos_0, pos);
     }.

.  handle_cursor_right
     {int cx;

      pos = i_min (pos + 1, strlen (line));
      calc_cx;
      while (cx > dx - 5)
        {pos_0++;
         calc_cx;
        };
     }.

.  calc_cx
     {int d;

      w->text_size (substring (line, pos_0, pos), cx, d);
     }.

.  handle_delete_prev
     {delchar (line, pos-1);
      handle_cursor_left;
     }.

.  handle_delete_act
     {delchar (line, pos);
      pos--;
      handle_cursor_right;
     }.

.  handle_text_input
     {if (c != 0)
         insert_new_char;
     }.

.  insert_new_char
     {inschar (line, pos, c);
      handle_cursor_right;
     }.

  }

bool craft_getline::get ()
  {bool any_edit;

   eval ();
   any_edit = is_active;
   while (is_active)
     eval ();
   return any_edit;
  } 

