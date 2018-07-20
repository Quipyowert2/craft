/*======================================================================*/
/*= CHANGES AND UPDATES                                                =*/
/*======================================================================*/
/*= date   person file       subject                                   =*/
/*=--------------------------------------------------------------------=*/
/*=                                                                    =*/
/*= 180193 hua    menu.hc    only operate if button1press              =*/
/*=                                                                    =*/
/*= 050293 hua    menu.hc    added enable                              =*/
/*=                                                                    =*/
/*======================================================================*/

#include "menu.h"

/*----------------------------------------------------------------------*/
/* CLASS menu (static initializations)                                  */
/*----------------------------------------------------------------------*/

bool menu::manager_init = false;
bool menu::group_enabled [max_menu_groups];

/*----------------------------------------------------------------------*/
/* CLASS menu (funktions)                                               */
/*----------------------------------------------------------------------*/

menu::menu ()
  {
  }

menu::menu (char w_name [],
            int  w_x,
            int  w_y,
            char w_cmds [],
            int  w_mode,
            int  menu_group)

  {init_manager;
   init_status;
   load_colors;
   calc_dim;
   tick ();

.  init_manager
     if (! manager_init)
        init_group_manager.

.  init_group_manager
     {manager_init = true;
      for (int i = 0; i < max_menu_groups; i++)
        group_enabled [i] = false;
      group_enabled [std_menu_group] = true;
     }.

.  load_colors
     {c_border_light = win_default_c ("menu_border_light");
      c_border_dark  = win_default_c ("menu_border_dark");
      c_background   = win_default_c ("menu_background");
      c_foreground   = win_default_c ("menu_foreground");
     }.

.  init_status
     {group             = menu_group;
      x                 = w_x;
      y                 = w_y;
      is_open           = false;
      mode              = w_mode;
      is_press          = false;
      last_mouse_button = nobutton;
      pressed_button    = no_menu_request;
      strcpy (name, w_name);
     }.

.  calc_dim
     if   (is_text_menu)
          calc_text_dim
     else calc_icon_dim.

.  is_text_menu
     (w_cmds [0] != '$' && w_cmds [0] != '/').

.  calc_icon_dim
     {int icon_dx;
      int icon_dy;

      calc_button_dir;
      scan_buttons;
      get_icon_size;
      icon_mode = true;
      button_dx = icon_dx + 2 * border_dx;
      button_dy = icon_dy + 2 * border_dy;
      dy        = button_dy * num_buttons;
      dx        = button_dx;
     }.

.  calc_button_dir
     {if   (w_cmds [0] == '$')
           strcpy  (button_dir, "");
      else sprintf (button_dir, "%s/", win_default_s ("button_dir"));
     }.     

.  get_icon_size
     {char name [128];

      sprintf     (name, "%s%s", button_dir, cmds [0]);
      bitmap_size (name, icon_dx, icon_dy);
     }.

.  calc_text_dim
     {scan_buttons;
      dy        = button_dy * num_buttons;
      dx        = button_dx;
      icon_mode = false;
     }.

.  scan_buttons
     {int         p = 0;
      char        cmd [128];
      XFontStruct *font_info;
      Display     *display;

      open_font_info;
      button_dx   = 0;
      num_buttons = 0;
      while (get_cmd (w_cmds, p, cmd))
        handle_button;
      close_font_info;
     }.

.  open_font_info
     {char name [128];

      strcpy (name, getenv ("DISPLAY"));
      display   = XOpenDisplay   (name);
      font_info = XLoadQueryFont (display, men_font);
     }.

.  close_font_info
     {XFreeFont     (display, font_info);
      XCloseDisplay (display);
     }.

.  handle_button
     {calc_tdx_tdy;

      strcpy (cmds [num_buttons], cmd);
      is_pressed [num_buttons] = false;
      button_dy = act_tdy + 2 * border_dy * 2;
      button_dx = i_max (button_dx, act_tdx + 2 * border_dx + 10);
      num_buttons++;
     }.

.  calc_tdx_tdy
     {act_tdx = XTextWidth (font_info, cmd, strlen (cmd));
      act_tdy = font_info->max_bounds.width;
     }.

.  act_tdx   tdx [num_buttons].
.  act_tdy   tdy [num_buttons].

  }

menu::~menu ()
  {if (is_open)
      delete (w);
  }

void menu::open ()
  {open_window;
   write_cmds;
   is_open = true;
   w->tick ();

.  open_window
    {w = new win (name, "", x, y, dx, dy);
     w->set_font (men_font);
    }.

.  write_cmds
     {for (int i = 0; i < num_buttons; i++)
        write (i, cmds [i], is_pressed [i]);
     }.

  }

void menu::close ()
  {delete (w);
   is_open = false;
  }

int menu::mouse_button ()
  {return last_mouse_button;
  }

void menu::enable (int group, bool mode)
  {group_enabled [group] = mode;
  }

void menu::tick ()
  {if      (is_visable && ! is_open)
           open ();
   else if (! is_visable && is_open)
           close ();

.  is_visable
     group_enabled [group].

  }

void menu::write (int no, char string [], bool pressed)
  {draw_border;
   if   (icon_mode)
        write_icon
   else write_text;

.  draw_border
     {if   (pressed)
           pressed_border
      else none_pressed_border;
     }.

.  pressed_border
     {clear;
      for (int i = 0; i < border_dx; i++)
        draw_pressed_line;
     }.

.  draw_pressed_line
     {w->set_color (c_border_dark);
      if (i < border_dx-1)
         w->set_color (black);
      w->line      (x_button+i, y_button+i, xe_button - i, y_button   + i);
      w->line      (x_button+i, y_button+i, x_button  + i,  ye_button - i);
      w->set_color (c_border_light);
      if (i < border_dx-1)
         w->set_color (black);
      w->line      (x_button+i, ye_button-i, xe_button- i, ye_button - i);
      w->line      (xe_button-i, y_button+i, xe_button- i, ye_button - i);
     }.

.  draw_released_line
     {w->set_color (c_border_light);
      w->line      (x_button+i, y_button+i, xe_button - i, y_button   + i);
      w->line      (x_button+i, y_button+i, x_button  + i,  ye_button - i);
      w->set_color (c_border_dark);
      w->line      (x_button+i, ye_button-i, xe_button- i, ye_button - i);
      w->line      (xe_button-i, y_button+i, xe_button- i, ye_button - i);
     }.

.  none_pressed_border
     {clear;
      for (int i = 0; i < border_dx; i++)
        draw_released_line;
     }.

.  clear
     {w->set_color (c_background);
      w->fill      (x_button, y_button, button_dx, button_dy);
     }.

.  write_icon
     {char m_name [128];

      sprintf (m_name, "%s%s", button_dir, string);

      w->set_background (c_background);
      w->set_color      (c_foreground);
      w->show_map       (border_dx, yy + border_dy, m_name);
      w->tick           ();
     }.

.  write_text
     {w->function       (GXcopy);
      w->set_background (c_background);
      w->set_color      (c_foreground);
      w->write          (xtext, ytext, string);
      w->tick           ();
     }.

.  xtext      border_dx + (((button_dx - 2 * border_dx) - act_tdx) / 2).
.  ytext      yy + 
              border_dy +
              act_tdy +
              2 +
              (((button_dy - 2 * border_dy) - act_tdy) / 2).

.  act_tdx    tdx [no].
.  act_tdy    tdy [no].

.  x_button   0.
.  y_button   yy.
.  xe_button  x_button + button_dx.
.  ye_button  y_button + button_dy.

.  yy   no * button_dy.

  }

int menu::eval (bool is_repeat)
  {tick ();
   if   (is_open)
        exec_eval
   else return no_menu_request;
 
.  exec_eval
     {int x;
      int y;
      int button;

      get_button;
      return_result;
     }.

.  get_button
     {int d;

      w->tick  ();
      w->mouse (d, d, x, y, button);
      if      (button == button1press || button == button3press)
              handle_new_press
      else if (button == button1release || button == button3release)
              handle_release
      else if (! is_repeat && button != button1press && button != button3press)
              handle_release;
     }.

.  handle_new_press
     {last_mouse_button = button;
      if (pressed_button != menu_point)
         release ();
      press (menu_point);
      is_press       = true;
      pressed_button = menu_point;
     }.

.  handle_release
     {release ();
      is_press       = false;
      pressed_button = no_menu_request;
     }.
       
.  return_result
     {return pressed_button;
     }.

.  menu_point
     (y / button_dy).

  }

void menu::press (int no)
  {write (no, cmds [no], true);
   is_pressed [no] = true;
  }

void menu::release ()
  {if (pressed_button != no_menu_request)
      release (pressed_button);
   pressed_button = no_menu_request;
  }

void menu::release (int no)
  {write (no, cmds [no], false);
   is_pressed [no] = false;
  }

bool menu::get_cmd (char cmds [], int &p, char cmd [])
  {if   (eof)
        return false;
   else read_cmd;
   return true;

.  read_cmd
     {int  c         = 0;
      bool skip_mode = false;

      skip_icon_symbol;
      while (cmd_char != ':' && ! eof)
        {handle_skip_mode;
         store_char;
         p++;
        };
      cmd [c] = 0;
      p++;
     }.

.  handle_skip_mode
     {if (cmd_char == ';')
         switch_skip_mode;
     }.

.  store_char
     {if (! skip_mode)
         cmd [c++] = cmd_char;
     }.
       
.  switch_skip_mode
     {skip_mode = ! skip_mode;
      p++;
     }.

.  skip_icon_symbol
     if (cmd_char == '$' || cmd_char == '&')
        p++.

.  eof 
     (p >= strlen (cmds)).

.  cmd_char 
     cmds [p].

  }


  
