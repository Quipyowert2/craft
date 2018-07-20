#include "win.h"
#include "buttons.h"
#include "bool.h"
#include "setupedit.h"
#include "cmap.h"
#include "craft_def.h"
#include "masks.h"

edit_setup::edit_setup (char host [], int initial_money)
  {init_config;
   open_w;
   open_buttons;
   money = initial_money;

.  open_w
     {w = new win ("setupedit", host, 30, 30, 300, 340);
      frame (w);
     }.

.  open_buttons
     {open_man_buttons;
      open_quit;
     }.

.  open_quit
     {quit = new button (w, "ok", 220, 300);
     }.

.  open_man_buttons
     {show_man_pics;
      for (int i = 0; i < 5; i++)
        open_man_button;
     }.

.  show_man_pics
     {cmap *m [5];
      char s  [128];

      sprintf (s, "hcraft/pic.%d", xpic_pawn_idle);    m [0] = new cmap (w, s);
      sprintf (s, "hcraft/pic.%d", xpic_knight_idle);  m [1] = new cmap (w, s);
      sprintf (s, "hcraft/pic.%d", xpic_archer_idle);  m [2] = new cmap (w, s);
      sprintf (s, "hcraft/pic.%d", xpic_cata_idle);    m [3] = new cmap (w, s);
      sprintf (s, "hcraft/pic.%d", xpic_doktor_idle);  m [4] = new cmap (w, s);
      m [0]->show (80,  50 - 20); 
      m [1]->show (80, 100 - 20);
      m [2]->show (80, 150 - 20);
      m [3]->show (80, 200 - 20);
      m [4]->show (80, 250 - 20);
      w->set_color      (black);
      w->set_background (gray80);
      sprintf (s, "%d $", price_pawn/2); w->write (30,  50+18-20, s); 
      sprintf (s, "%d $", price_knight); w->write (30, 100+18-20, s); 
      sprintf (s, "%d $", price_archer); w->write (30, 150+18-20, s); 
      sprintf (s, "%d $", price_cata);   w->write (30, 200+18-20, s); 
      sprintf (s, "%d $", price_doktor); w->write (30, 250+18-20, s); 
     }.

.  open_man_button
     {incr [i] = new button (w, "/dial.up",   110, i * 50 + 50 - 20);
      decr [i] = new button (w, "/dial.down", 110, i * 50 + 64 - 20);
     }.   

.  init_config
     {for (int i = 0; i < 5; i++)
        {num [i] = 0;
        };
      s         = 0;
      price [0] = price_pawn / 2;
      price [1] = price_knight;
      price [2] = price_archer;
      price [3] = price_cata;
      price [4] = price_doktor;
     }.
  
  }

edit_setup::~edit_setup ()
  {delete (quit);
   for (int i = 0; i < 5; i++)
     {delete (incr [i]);
      delete (decr [i]);
     };
   delete (w);
  }

void edit_setup::eval (bool &is_quit, int anz [5])
  {init_edit;
   edit_a_bit;

.  init_edit
     {is_quit = false;
      show_money;
     }.

.  edit_a_bit
     {w->mark_mouse ();
      w->tick       ();
      check_buttons;
      w->scratch_mouse ();
     }.

.   check_buttons
      {if (quit  ->eval ()) handle_quit;
       check_incr;
       check_decr;
      }.

.  check_incr
     {for (int i = 0; i < 5; i++)
        if (incr [i]->eval ())
           handle_incr;
     }.

.  handle_incr
     {if (money - price [i] >= 0 && s < 45 && 
          (i < 3 || num [i] < 2))
         {incr [i]->press (true);
          num [i]++;
          s++;
          money -= price [i];
          show_money;
          incr [i]->press (false);
         };
     }. 

.  check_decr
     {for (int i = 0; i < 5; i++)
        if (decr [i]->eval ())
           handle_decr;
     }.

.  handle_decr 
     {if (num [i] > 0)
         {decr [i]->press (true);
          num [i]--;
          s--;
          money += price [i];
          show_money;
          decr [i]->press (false);
         };
     }. 

.  handle_quit
     {quit->press (true);
      is_quit = true;
      for (int i = 0; i < 5; i++)
        anz [i] = num [i];
     }.
	
.  show_money
     {char s [128];

      sprintf  (s, "%d $     ", money);
      w->write (150,280, s);
      for (int j = 0; j < 5; j++)
        write_man_num;
     }.

.  write_man_num
     {if   (j < 3)
           sprintf  (s, "%3d        ", num [j]);
      else sprintf  (s, "%3d (max 2)", num [j]);
      w->write (150, j * 50 + 18 + 50 - 20, s);
     }. 

.  finish
     {perhaps_save_config;
      delete (w);
     }.
 
.  perhaps_save_config
     {if (is_save)
         perform_save;
     }.

.  perform_save
     {FILE *f;

      f_open (f,  complete (file_name, ".mans"), "w");
      write_mans;
      fclose (f);
     }.

.  write_mans
     {for (int i = 0; i < 5; i++)
        fprintf (f, "%d %d\n", i, num [i]);
     }.

  }

