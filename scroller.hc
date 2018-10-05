#include "scroller.h"
#include "masks.h"
 
#define bar_button_size 14
#define bar_size        16

scroller::scroller (const char v_name [],
                    win  *v_w,
                    int  v_x,
                    int  v_y,
                    int  v_dx,
                    int  v_dy,
                    int  v_min,
                    int  v_max,
                    int  v_size,
                    int  v_pos,
                    int  v_step_small,
                    int  v_step_large)

  {store_params;
   get_colors;
   calc_display_params;
   init_status;
   display ();

.  get_colors
     {c_border_light = win_default_c ("scroller_border_light");
      c_border_dark  = win_default_c ("scroller_border_dark");
      c_background   = win_default_c ("scroller_background");
      c_foreground   = win_default_c ("scroller_foreground");
     }.

.  store_params
     {strcpy (name, v_name);
      w          = v_w;
      x          = v_x;   
      y          = v_y;   
      dx         = v_dx;  
      dy         = v_dy;  
      min        = v_min; 
      max        = v_max; 
      size       = v_size;
      pos        = v_pos;
      step_small = v_step_small;
      step_large = v_step_large;
     }.

.  calc_display_params
     {if   (dx > dy)
           dy = bar_size;
      else dx = bar_size;
     }.

.  init_status
     {was_event = false;
      if (step_small == 0)
         step_small = i_max (1, (max - min) / 20);
      if (step_large == 0)
         step_large = i_max (1, (max - min) / 5);
     }.     
 
  }

scroller::~scroller ()
  {delete (button_incr);
   delete (button_decr);
  }

void scroller::display ()
  {display_bar;
   calc_ruler_params ();
   display_ruler     ();

.  display_bar
     {draw_background;
      draw_buttons;
     }.

.  draw_background
     {w->set_color (c_background);
      w->fill      (x, y, dx, dy);
      w->set_color (black);
      frame        (w, x, y, x + dx, y + dy, c_border_dark, c_border_light);
      w->tick      ();
     }.

.  draw_buttons  
     {if   (dx > dy)  
           draw_horizontal
      else draw_vertical;
     }.
 
.  draw_horizontal
     {button_decr = new button (w,
                                "/scroll_left", 
                                x + 1, y + 1, true);
      button_incr = new button (w,
                                "/scroll_right",
                                x + dx - bar_button_size, y + 1, true);
     }.

.  draw_vertical
     {button_decr = new button (w,
                                "/scroll_up", 
                                x + 1, y + 1, true);
      button_incr = new button (w,
                                "/scroll_down",
                                 x + 1, y + dy - bar_button_size, true);
     }.
      
  }

void scroller::calc_ruler_params ()
  {if   (dx > dy)
        calc_horizontal_params
   else calc_vertical_params;
   calc_centers;

.  calc_centers
     {ruler_x_center = ruler_x + ruler_dx / 2;
      ruler_y_center = ruler_y + ruler_dy / 2;
     }.

.  calc_horizontal_params
     {ruler_x  = x + hor_x0 + (int) (hor_scale * (double) (pos-min));
      ruler_y  = y + 2;
      ruler_dy = i_max (4, bar_button_size - 1);
      ruler_dx = i_min (hor_space,
                        i_max (4, (int) (hor_scale * (double) size)));
     }.

.  hor_x0     (bar_button_size + 2).
.  hor_scale  ((double) hor_space / (double) (max - min)).  
.  hor_space  (dx - 4 - 2 * bar_button_size).

.  calc_vertical_params
     {ruler_y  = y + vert_y0 + (int) (vert_scale * (double) (pos-min));
      ruler_x  = x + 2;
      ruler_dx = i_max (4, bar_button_size - 1);
      ruler_dy = i_min (vert_space,
                        i_max (4, (int) (vert_scale * (double) size)));
     }.

.  vert_y0     (bar_button_size + 2).
.  vert_scale  ((double) vert_space / (double) (max - min)).  
.  vert_space  (dy - 4 - 2 * bar_button_size).

  }

void scroller::display_ruler ()
  {w->set_color (c_foreground);
   w->fill      (ruler_x, ruler_y, ruler_dx, ruler_dy);
   w->tick      ();
  }

void scroller::clear_ruler ()
  {w->set_color (c_background);
   w->fill      (ruler_x, ruler_y, ruler_dx, ruler_dy);
  }

bool scroller::on ()
  {int xm;
   int ym;
   int button;

   w->tick ();
   return w->is_mouse (xm, ym, button) && within_scroller_box;

.  within_scroller_box
     (x <= xm && xm <= x + dx && y <= ym && ym <= y + dy).

  }

bool scroller::eval(int &v_pos)
  {handle_mouse_events;
   store_results;

.  handle_mouse_events
     {if (on ())
         handle_event;
     }.

.  handle_event
     {if      (on_small_incr) handle_small_incr_event 
      else if (on_small_decr) handle_small_decr_event 
      else                    handle_none_button_event;
     }.

.  handle_none_button_event
     {int d;
      int xm;
      int ym;
      int button;

      w->tick  ();
      w->mouse (d, d, xm, ym, button);
      if (button == button1press)
         handle_move_event;
     }.

.  handle_move_event
     {if   (on_ruler)
           handle_ruler_event
      else handle_bar_event
     }.

.  on_ruler
     (ruler_x <= xm && xm <= ruler_x + ruler_dx && 
      ruler_y <= ym && ym <= ruler_y + ruler_dy).

.  on_small_incr
     (button_incr->eval ()).

.  on_small_decr
     (button_decr->eval ()).

.  handle_ruler_event
     {while (mouse_hold_down)
        {shift_ruler;
         w->tick ();
        };
      was_event = true;
     }.

.  shift_ruler
     {if   (dx > dy)
           horizontal_shift
      else vertical_shift;
     }.

.  horizontal_shift
     {if      (xm < ruler_x_center) set (pos - 1);
      else if (xm > ruler_x_center) set (pos + 1);
     }.

.  vertical_shift
     {if      (ym < ruler_y_center) set (pos - 1);
      else if (ym > ruler_y_center) set (pos + 1);
     }.

.  mouse_hold_down
     ((w->mouse (xm, ym, button) || true) && button != button1release).

.  handle_small_incr_event
     {set (pos + step_small);
      was_event = true;
     }.

.  handle_small_decr_event
     {set (pos - step_small);
      was_event = true;
     }.

.  handle_bar_event
     {if   (xm < ruler_x || ym < ruler_y)
           handle_large_decr_event
      else handle_large_incr_event;
     }.

.  handle_large_incr_event
     {set (pos + step_large);
      was_event = true;
     }.

.  handle_large_decr_event
     {set (pos - step_large);
      was_event = true;
     }.

.  skip_events
     {while (on ())
        {skip_event;
        };
     }.

.  skip_event
     {int d;

      w->mouse (d, d, d);
     }.

.  store_results
     {bool there_was_an_event = was_event;

      v_pos     = pos;
      was_event = false; 
      return there_was_an_event;
     }.
     
  }

void scroller::set (int v_pos)
  {clear_ruler       ();
   pos = i_bound (min, v_pos, i_max (min, max - size));
   calc_ruler_params ();
   display_ruler     ();
  }

void scroller::resize (int v_size)
  {clear_ruler       ();
   size = i_min   (v_size, max - min);
   pos  = i_bound (min, pos, max - size);
   calc_ruler_params ();
   display_ruler     ();   
  }



