/*======================================================================*/
/*= CHANGES AND UPDATES                                                =*/
/*======================================================================*/
/*= date   person file          subject                                =*/
/*=--------------------------------------------------------------------=*/
/*=                                                                    =*/
/*= 060794 hua    multi_dial.hc created                                =*/
/*=                                                                    =*/
/*======================================================================*/

#include "multi_dial.h"
#include "masks.h"

#define font "-misc-*-*-*-*-*-*-*-*-*-*-*-*-*"

#define line_dy  20

multi_dial::multi_dial (char name    [], 
                        char buttons [],
                        bool used_history)

  {init;
   pharse_params;
   open_w;
   init_values;
   perhaps_load;
   open_dials;
   
.  init
     {is_history = used_history;
      strcpy (title, name);
     }.

.  init_values
     {for (int i = 0; i < num_buttons; i++)
        values [i] = true;
     }.

.  perhaps_load
     {if (is_history)
         load (name);
     }.

.  open_w
     {w = new win (title, "", by_fix, by_fix,
                   max_b_title_dx + 44,
                   num_buttons * line_dy + 24);
      background  (w);
     }.

.  open_dials
     {for (int i = 0; i < num_buttons; i++)
        d_buttons [i] = new dial (w,
                                  b_title [i],
                                  max_b_title_dx + 12,
                                  12, i * line_dy + 14,
                                  values [i]); 
     }.

.  pharse_params
     {int         p = 0;
      XFontStruct *font_info;
      Display     *display;

      num_buttons    = 0;
      max_b_title_dx = 0;
      open_font_info;
      while (get_cmd (buttons, p, act_title))
        {grab_button;
        };
      close_font_info;
     }.

.  open_font_info
     {char name [128];

      strcpy (name, getenv ("DISPLAY"));
      display   = XOpenDisplay   (name);
      font_info = XLoadQueryFont (display, font);
     }.

.  close_font_info
     {XFreeFont     (display, font_info);
      XCloseDisplay (display);
     }.

.  grab_button
     {max_b_title_dx = i_max (max_b_title_dx, title_length);
      num_buttons++;
     }.

.  title_length
     XTextWidth (font_info, act_title, strlen (act_title)).

.  act_title
     b_title [num_buttons].

  }

multi_dial::~multi_dial ()
  {if (is_history)
      save (title);
   for (int i = 0; i < num_buttons; i++)
     delete (d_buttons [i]);
   delete (w);
  }

void multi_dial::save (char name [])
  {FILE *f;

   open_f;
   write_values;
   fclose (f);

.  open_f
     {f = fopen (complete (name, ".mulopt"), "w");
     }.

.  write_values
     {for (int i = 0; i < num_buttons; i++)
        fprintf (f, "%d\n", values [i]);
     }.

  }

void multi_dial::load (char name [])
  {FILE *f;
   bool exists;

   if (open_f)
      perform_load;

.  perform_load
    {read_values;
     fclose (f);
    }. 

.  open_f
     (f = fopen (complete (name, ".mulopt"), "r")) != NULL.

.  read_values
     {for (int i = 0; i < num_buttons; i++)
        fscanf (f, "%d", &values [i]);
     }.

  }

bool multi_dial::eval ()
  {bool anything = false;

   w->mark_mouse ();
   for (int i = 0; i < num_buttons; i++)
     anything |= d_buttons [i]->eval (values [i]);
   w->scratch_mouse ();
   return anything;
  }

bool multi_dial::pressed (int bno)
  {return values [bno];
  }

bool multi_dial::press (int bno, bool mode)
  {values [bno] = mode;
   eval ();
  }

bool multi_dial::get_cmd (char cmds [], int &p, char cmd [])
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
