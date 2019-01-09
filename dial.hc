/*======================================================================*/
/*= CHANGES AND UPDATES                                                =*/
/*======================================================================*/
/*= date   person file       subject                                   =*/
/*=--------------------------------------------------------------------=*/
/*=                                                                    =*/
/*= 291193 hua    dial.hc    created                                   =*/
/*=                                                                    =*/
/*======================================================================*/

#include "dial.h"

#define button_dx 12
#define button_dy 8
 
#define val_dy    20

dial::dial (win  *p_w,
            const char p_title [],
            int  p_title_dx, 
            int  p_x,
            int  p_y,
            int  p_v_min,
            int  p_val,
            int  p_v_max,
            int  p_incr,
            bool with_hist,
            int  values_dx,
            bool may_edit,
            int  p_incr2,
            bool auto_repeat)

  {store_params;
   show_buttons;
   show_msg;
   init_history;
   w->tick ();

.  store_params
     {w         = p_w;
      x         = p_x;
      y         = p_y;
      v_min     = p_v_min;
      v_max     = p_v_max;
      incr      = p_incr;
      incr2     = p_incr2;
      val_dx    = values_dx;
      title_dx  = p_title_dx;
      is_bool   = false;
      is_hist   = with_hist; 
      with_edit = may_edit;
      strcpy  (title, p_title);
      sprintf (s_value, "%d", p_val);
     }.

.  show_msg
     {w->write (x, y + val_dy - 5, title);
     }.

.  show_buttons
     {g_value = new craft_getline ("dial", w, s_value,
                             x + title_dx, y,
                             val_dx, val_dy); 
      up   = new button (w, "/dial.up", 
                             x + title_dx + val_dx + 2,
                             y, auto_repeat, by_default, by_default,1,1);
      down = new button (w, "/dial.down",
                             x + title_dx + val_dx + 2,
                             y+button_dy+2, auto_repeat,
                             by_default, by_default,1,1);
      if (incr2 != 0)
         {up2   = new button (w, "/dial.up2", 
                                 x + title_dx + val_dx + 18,
                                 y, auto_repeat, by_default, by_default,1,1);
          down2 = new button (w, "/dial.down2",
                                 x + title_dx + val_dx + 18,
                                 y+button_dy+2,auto_repeat,
                                 by_default,by_default,1,1);
         };
     }.

.  init_history
     {if (is_hist)
         open_history;
     }.

.  open_history
     {hist_button = new button  (w, 
                                 "/hist.open",
                                 x + title_dx + val_dx + 20, y + button_dy/2);
      hist        = new history (title, hist_button);
     }.

  }


dial::dial (win  *p_w,
            const char p_title [],
            int  p_title_dx, 
            int  p_x,
            int  p_y,
            bool p_val)

  {store_params;
   show_buttons;
   show_msg;
   w->tick ();

.  store_params
     {w        = p_w;
      x        = p_x;
      y        = p_y;
      title_dx = p_title_dx;
      is_bool  = true;
      strcpy  (title, p_title);
      b_val    = p_val;
      is_hist  = false;
     }.

.  show_msg
     {w->write (x, y + val_dy - 10, title);
     }.

.  show_buttons
     {if   (b_val)
           show_on
      else show_off;
     }.
 
.  show_off
     {up   = new button (w, "/dial.bool.off", 
                            x + title_dx + 2,
                            y, false, by_default, by_default,0,0);
      up->press (b_val);
     }.

.  show_on
     {up   = new button (w, "/dial.bool.on", 
                            x + title_dx + 2,
                            y, false, by_default, by_default,0,0);
      up->press (b_val);
     }.

  }

dial::~dial ()
  {delete (up);
   if (! is_bool)
      {delete (g_value);
       delete (down);
       if (incr2 != 0)
          {delete (up2);
           delete (down2);
          };
      };
   if (is_hist)
      {delete (hist);
       delete (hist_button);
      };
  }

void dial::set (int val)
  {if   (is_bool)
        perform_bool_set
   else perform_int_set;

.  perform_bool_set
     {b_val = val;
      if   (b_val)
           up->write ("/dial.bool.on");
      else up->write ("/dial.bool.off");
      }.

.  perform_int_set
     {sprintf          (s_value, "%d", val);
      g_value->refresh ();
     }.

  }

bool dial::eval (int &val)
  {bool any_change = false;

   if   (is_bool)
        perform_bool_eval
   else perform_int_eval;
   return any_change;

.  perform_bool_eval
     {if (up->eval ())
         handle_bool_event;
     }.

.  handle_bool_event
     {any_change = true;
      b_val = ! b_val;
      show_bool_button;
      up->press (b_val);
      val = b_val;
      any_change = true;
     }.

.  show_bool_button
      {if   (b_val)
            up->write ("/dial.bool.on");
       else up->write ("/dial.bool.off");
      }.

.  perform_int_eval
     {set_value;
      check_up;
      check_down;
      if (incr2 != 0) 
         {check_up2;
          check_down2;
         };
      check_hist_button;
      show_value;
      return any_change;
     }.

.  add_to_hist
     {char v [128];

      sprintf (v, "%d", val);
      if (any_change && is_hist)
         hist->push (v);
     }.

.  set_value
     {sprintf (s_value, "%d", val);
     }.

.  show_value
     {set_value;
      if (with_edit && g_value->get ())
         {val        = atoi (s_value);
          val        = i_min (v_max, i_max (v_min, val));
          any_change = true;
          set_value;
          g_value->refresh ();
          add_to_hist;
         };
     }.  
 
.  check_hist_button
     {if (is_hist && hist_button->eval ())
         handle_hist;
     }.

.  handle_hist
     {char hist_line [256];

      hist_button->press (true);
      strcpy             (hist_line, hist->select (by_fix,by_fix,val_dx,140));
      hist_button->press (false);
      if (strlen (hist_line) > 0)
         use_hist_line;
     }.

.  use_hist_line
     {strcpy           (s_value, hist_line);
      g_value->refresh ();
      val        = atoi (s_value);
      any_change = true;
     }.

.  check_up
     {if (up->eval ())
        handle_up;
     }.

.  handle_up
     {up->press (true);
      any_change = true;
      val = i_min (v_max, val + incr);
      sprintf          (s_value, "%d", val);
      g_value->refresh ();
      up->press (false);
     }.

.  check_down
     {if (down->eval ())
         handle_down;
     }.

.  handle_down
     {down->press (true);
      any_change = true;
      val = i_max (v_min, val - incr);
      sprintf          (s_value, "%d", val);
      g_value->refresh ();
      down->press (false);
     }.
   
.  check_up2
     {if (up2->eval ())
        handle_up2;
     }.

.  handle_up2
     {up2->press (true);
      any_change = true;
      val = i_min (v_max, val + incr2);
      sprintf          (s_value, "%d", val);
      g_value->refresh ();
      up2->press (false);
     }.

.  check_down2
     {if (down2->eval ())
         handle_down2;
     }.

.  handle_down2
     {down2->press (true);
      any_change = true;
      val = i_max (v_min, val - incr2);
      sprintf          (s_value, "%d", val);
      g_value->refresh ();
      down2->press (false);
     }.
   
  }

