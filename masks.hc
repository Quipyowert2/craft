/*======================================================================*/
/*= CHANGES AND UPDATES                                                =*/
/*======================================================================*/
/*= date   person file       subject                                   =*/
/*=--------------------------------------------------------------------=*/
/*=                                                                    =*/
/*= 160793 hua    masks.hc   created                                   =*/
/*=                                                                    =*/
/*======================================================================*/

#include "bool.h"
#include "win.h"
#include "menu.h"
#include "masks.h"
#include "buttons.h"
#include "getline.h"

void background (win *w)
  {background (w, 0, 0, w->dx (), w->dy ());
  }

void background (win *w, int x, int y, int dx, int dy)
  {w->function       (GXcopy);
   w->set_color      (win_default_c ("frame_background"));
   w->fill           (x, y, dx, dy);
   w->set_font       (frame_font);
   w->set_color      (win_default_c ("frame_foreground"));
   w->set_background (win_default_c ("frame_background"));
   w->tick ();
  }

void frame (win *w)
  {int dx             = w->dx ();
   int dy             = w->dy ();
   int c_border_dark  = win_default_c ("frame_border_dark");
   int c_border_light = win_default_c ("frame_border_light");

   fill_background;
   for (int i = 0; i < frame_size; i++)
     draw_frame_line;
   w->tick ();

.  fill_background
     {w->function  (GXcopy);
      w->set_color (win_default_c ("frame_background"));
      w->fill      (0, 0, dx, dy);
      w->set_font  (frame_font);
     }.

.  draw_frame_line
     {w->set_color (c_border_light);
      w->line      (i, i, dx - i, i);
      w->line      (i, i, i, dy - i);
      w->set_color (c_border_dark);
      w->line      (dx - i, dy - i, i, dy - i);
      w->line      (dx - i, dy - i, dx - i, i);
     }.

  }

void frame (win *w, int x1, int y1, int x2, int y2, int color_1, int color_2)
  {w->set_color (color_1);
   w->line      (x1, y1, x2, y1);
   w->line      (x2, y1, x2, y2);
   w->set_color (color_2);
   w->line      (x2, y2, x1, y2);
   w->line      (x1, y2, x1, y1);
  }

bool yes (const char question [])
  {return yes ("", question);
  }

bool yes (const char host [], const char question [])
  {win    *w;
   button *ok;
   button *no;
   bool   ok_pressed;

   open_mask;
   get_answer;
   delete_mask;
   return ok_pressed;

.  open_mask
     {int dx;
      int dy;

      w  = new win      ("janus:yes", host,  100, 100, 200, 100);
      frame             (w);
      ok = new button   (w, "/yes",     40, 60);
      no = new button   (w, "/no",  200-64, 60);
      w->set_background (win_default_c ("yes_background"));
      w->set_color      (win_default_c ("yes_foreground"));
      w->text_size      (question, dx, dy);
      w->write          (x_text, 40, question);
     }.

.  x_text
     (200 - dx) / 2.

.  delete_mask
     {delete (ok);
      delete (no);
      delete (w);
     }.

.  get_answer
     {bool answer   = false;
      int  event_id = -1;

      ok_pressed = false;
      while (! answer)
        {try_to_get_the_answer;
        };
     }.

.  try_to_get_the_answer
     {w->mark_mouse ();
      event_id   = w->event_id;
      ok_pressed = ok->eval ();
      answer     = ok_pressed || no->eval ();
      w->scratch_mouse ();
     }.

  }

bool yes (win *parent, char host [], const char question [])
  {win    *w;
   button *ok;
   button *no;
   bool   ok_pressed;

   open_mask;
   get_answer;
   delete_mask;
   return ok_pressed;

.  open_mask
     {int dx;
      int dy;

      w  = new win      (parent, "janus:yes", host,  100, 100, 200, 100);
      frame             (w);
      ok = new button   (w, "/yes",     40, 60);
      no = new button   (w, "/no",  200-64, 60);
      w->set_background (win_default_c ("yes_background"));
      w->set_color      (win_default_c ("yes_foreground"));
      w->text_size      (question, dx, dy);
      w->write          (x_text, 40, question);
     }.

.  x_text
     (200 - dx) / 2.

.  delete_mask
     {delete (ok);
      delete (no);
      delete (w);
     }.

.  get_answer
     {bool answer   = false;
      int  event_id = -1;

      ok_pressed = false;
      while (! answer)
        {try_to_get_the_answer;
        };
     }.

.  try_to_get_the_answer
     {w->mark_mouse ();
      event_id   = w->event_id;
      ok_pressed = ok->eval ();
      answer     = ok_pressed || no->eval ();
      w->scratch_mouse ();
     }.

  }

void ack (char message [])
  {ack ("", message);
  }

void ack (const char host [], char message [])
  {win    *w;
   button *ok;
   int    dx;
   int    dy;

   calc_dx_dy;
   open_mask;
   write_message;
   get_answer;
   delete_mask;

.  calc_dx_dy
     {int num_lines;

      text_size (message, win_default_font, dx, dy, num_lines);
     }.

.  open_mask
     {w  = new win      ("janus:ack", host,  100, 100, dx + 40,dy + 100);
      frame             (w);
      ok = new button   (w, "/ok", (dx+40)/2 - 12, dy+100 - 40);
      w->set_background (win_default_c ("ack_background"));
      w->set_color      (win_default_c ("ack_foreground"));
     }.

.  write_message
     {char record [1024];
      int  y  = 20;
      int  rp = 0;

      for (int i = 0; i < strlen (message); i++)
        handle_char;
      handle_new_record;
     }.

.  handle_char
     {if   ( message [i] == '\n')
           handle_new_record
      else record [rp++] = message [i];
     }.

.  handle_new_record
     {int tdx;
      int tdy;

      record [rp] = 0;
      calc_tdx_tdy;
      y += tdy + 10;
      w->write ((dx+40-tdx) / 2, y, record);
      rp = 0;
     }.

.  calc_tdx_tdy
     {w->text_size (record, tdx, tdy);
     }.

.  delete_mask
     {delete (ok);
      delete (w);
     }.

.  get_answer
     {bool answer   = false;
      int  event_id = -1;

      while (! answer)
        {try_to_get_the_answer;
        };
     }.

.  try_to_get_the_answer
     {w->mark_mouse ();
      answer =  ok->eval ();
      w->scratch_mouse ();
     }.

  }

void tell (win *&w, char message [])
  {tell ("", w, message);
  }

void tell (const char host [], win *&w, char message [])
  {open_mask;
   tell_message;

.  open_mask
     {w = new win ("janus:tell", host, 100, 100, 300, 100);
      frame   (w);
      w->tick ();
     }.

.  tell_message
     {int dx;
      int dy;

      w->set_background (win_default_c ("tell_background"));
      w->set_color      (win_default_c ("tell_foreground"));
      w->text_size      (message, dx, dy);
      w->write          (x_text, y_text, message);
      w->tick           ();
     }.

.  x_text
     (300 - dx) / 2.

.  y_text
     (100 - dy) / 2.

  }

void tell (char host [], win *parent, win *&w, char message [])
  {open_mask;
   tell_message;

.  open_mask
     {w = new win (parent, "janus:tell", host, 100, 100, 300, 100);
      frame   (w);
      w->tick ();
     }.

.  tell_message
     {int dx;
      int dy;

      w->set_background (win_default_c ("tell_background"));
      w->set_color      (win_default_c ("tell_foreground"));
      w->text_size      (message, dx, dy);
      w->write          (x_text, y_text, message);
      w->tick           ();
     }.

.  x_text
     (300 - dx) / 2.

.  y_text
     (100 - dy) / 2.

  }

bool get_line (char s    [],
               char name [],
               int  dx,
               bool with_history)
 
  {win     *w;
   getline *gl;
   button  *cancel;
   bool    is_cancel;

   open_win;
   perform_get;
   delete_win;
   return ! is_cancel;

.  open_win
     {w      = new win (name, "", 100, 100, dx + 40, 80);
      background (w);
      gl     = new getline (name, w, s, 20, 20, dx, 20, with_history);
      cancel = new button (w, "cancel", (dx+40) / 2 - 60, 50);
     }.

.  perform_get
     {is_cancel = false;
      while (! gl->eval () && ! is_cancel)
        {check_cancel;
        };
     }.

.  check_cancel
     {is_cancel = cancel->eval ();
     }.

.  delete_win
     {delete (gl);
      delete (cancel);
      delete (w);
     }.

  }
        
int select (char menu_string [], char *name)
  {menu *m;
   char *m_string;
   char m_name [512];
   int  selected;

   complete_m_string;
   open_m;
   perform_select;
   adjust_selected;
   delete (m);
   delete[] (m_string);
   return selected;

.  complete_m_string
     {m_string = new char [strlen (menu_string) + 30];
      strcpy (m_string, menu_string);
      strcat (m_string, "cancel:");
      if   (name == NULL)
           strcpy (m_name, "select");
      else strcpy (m_name, name);
     }.

.  open_m
     {m = new menu (m_name, by_fix, by_fix, m_string);
     }.

.  perform_select
     {while ((selected = m->eval ()) == no_menu_request)
        {
        };
     }.

.  adjust_selected
     {if (selected == m->num_buttons-1)
         selected = -1;
     }.

  }
   
