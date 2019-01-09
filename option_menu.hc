#include "scroller.h"
#include "ppm.h"
#include "dial.h"
#include "buttons.h"
#include "option_menu.h"
#include "getline.h"
#include "win.h"
#include "cmap.h"
#include "craft.h"
#include "xstring.h"

#define w_dx      400
#define w_dy      300
#define flag_dx   100
#define flag_dy   30
#define flag_x    300

#define m_main     0
#define m_details  1
#define m_player   2
#define m_robot    3
#define m_cancel   4
#define m_quit     5
#define m_inactive 6


   cmap   *p   [40];
   bool   is_p [40]; 
   win    *w;
   int    act_menu;
   int    menu_type [10]; 
   int    num_menus;

   int    act_speed;
   int    r_power;
   int    r_agress;
   bool   was_seed;


void show_flags ()
  {prepare;
   for (int i = 0; i < num_menus; i++)
     show_menu_topic;
   w->tick ();

.  prepare
     {w->set_color (gray80);
      w->fill      (flag_x, 0, w_dx, w_dy);
     }.

. show_menu_topic
    {int m_no;

     if   (i == act_menu)
          show_active
     else show_passive;
     show_p;
    }. 

.  show_active
     {m_no = menu_type [i] + 10;
     }.

.  show_passive
     {m_no = menu_type [i] + 20;
     }.

.  show_p
     {if (! is_p [m_no])
         load_p;
      p [m_no]->show (flag_x, flag_y);
     }.

.  load_p
     {char name [128];

      sprintf (name, "hcraft/men%d", m_no);
      p    [m_no] = new cmap (w, name);
      is_p [m_no] = true;
     }.

.  y_msg
     flag_y + flag_dy / 2 + 4.

.  flag_y
     i * flag_dy.

  }

void set_robot (int pno)
  {strcpy  (host [pno], "-");
   switch (i_random (0, 9))    
     {case 0 : strcpy (name [pno], "Sven");     break;
      case 1 : strcpy (name [pno], "Thor");     break;
      case 2 : strcpy (name [pno], "Haegedin"); break;
      case 3 : strcpy (name [pno], "Roland");   break;
      case 4 : strcpy (name [pno], "Lars");     break;
      case 5 : strcpy (name [pno], "Frederik"); break;
      case 6 : strcpy (name [pno], "Oehr");     break;
      case 7 : strcpy (name [pno], "Lunda");    break;
      case 8 : strcpy (name [pno], "Arnhold");  break;
      case 9 : strcpy (name [pno], "Eric");     break;
     };
  }

bool any_flag_request ()
  {int x;
   int y;
   int b;

   if   (w->is_mouse (x, y, b) && on_flag)
        handle_flag_request
   else return false;

.  on_flag
    (x >= flag_x && y <= num_menus * flag_dy).

.  handle_flag_request
     {int xb;
      int yb;
      int prev_menu = act_menu;

      w->mouse (x, y, xb, yb, b);
      if   (b == button1press)
           {act_menu = yb / flag_dy;
            perhaps_type_change;
            return true;
           }
      else return false;
     }.

.  perhaps_type_change
     {if (pno > 0 && 
          (menu_type [act_menu] == m_player ||
           menu_type [act_menu] == m_robot  ||
           menu_type [act_menu] == m_inactive))
         handle_change;
     }.

.  handle_change
     {int b = xb - flag_x;

      if (b > 66 && prev_menu == act_menu) 
         set_to_next;
     }.

.  set_to_next
     {switch (menu_type [act_menu])
        {case m_player   : set_to_robot;    break;
         case m_robot    : set_to_inactive; break;
         case m_inactive : set_to_player;   break;
        };
     }.

.  set_to_inactive
     {if   (pno < 2)
           set_to_player
      else set_inactive;
     }.

.  set_inactive
     {active    [pno]      = false;
      menu_type [act_menu] = m_inactive;
     }.

.  set_to_player
     {active    [pno]      = true;
      menu_type [act_menu] = m_player;
      strcpy  (host [pno], "");
      sprintf (name [pno], "player %d", pno);
     }.

.  set_to_robot
     {active [pno]         = true;
      menu_type [act_menu] = m_robot;
      set_robot (pno);
     }.

.  pno
     (act_menu - 2).

  }

void main_menu (int act_menu, int &tic)
  {dial    *d_is_self;
   dial    *d_is_suny;
   dial    *d_water_world;
   craft_getline *seed;
   char    seed_s [128];

   init;
   session;
   finish;

.  init
     {show_pic;
      show_buttons;
     }.

.  show_pic
     {if (! is_p [m_main])
         load_p;
      p [m_main]->show (0, 0);
     }.

.  load_p 
     {w->set_cursor (150);
      w->tick       ();
      p    [m_main] = new cmap (w, "hcraft/m1");
      is_p [m_main] = true;
      w->set_cursor (2);
      w->tick       ();
     }.

.  show_buttons
     {d_is_self     = new dial (w, "", 0,200, 100, is_self);
      d_is_suny     = new dial (w, "", 0,200, 140,is_suny);
      d_water_world = new dial (w, "", 0,200, 180,is_water_world);
      strcpy (seed_s, "");
      seed = new craft_getline ("", w, seed_s, 200, 250, 90, 24);
     }.

.  finish
     {delete (d_is_self);     
      delete (d_is_suny);     
      delete (d_water_world);
     }.

. session
    {w->mark_mouse ();
     w->tick       ();
     while (! any_flag_request ())
      {w->scratch_mouse ();
       w->mark_mouse    ();
       w->tick          ();
       handle_cmds;
       if (! was_seed)
          tic = (tic + 1) % 123124;
      };
     if (strlen (seed_s) > 0)
        set_seed;
    }.

.  set_seed
     {if   (atoi (seed_s) > 0)
           tic = atoi (seed_s);
      else get_alpha_seed;
      was_seed = true;
     }.

.  get_alpha_seed
     {char strlist [1024];

      strcpy (strlist, "abcdefghijklmnopqrstuvwxyz");
      strcat (strlist, "ABCDEFGHIJKLMNOPQRSTUVWXYZ");
      strcat (strlist, " ,.;_-=+!@#$%^&*()[]{}<>");
      tic = 0;
      for (int i = 0; i < strlen (seed_s); i++)
        {tic += strpos (strlist, seed_s [i]) % 123124;
        };
     }.

.  handle_cmds
     {seed         ->eval ();
      d_is_self    ->eval (is_self);
      d_is_suny    ->eval (is_suny);
      d_water_world->eval (is_water_world);
     }. 

  }

void player_menu (int act_menu, int &tic)
  {craft_getline  *g_host;
   craft_getline  *g_name;

   init;
   session;
   finish;

.  init
     {show_pic;
      show_buttons;
     }.

.  show_pic
     {if (! is_p [m_player])
         load_p;
      p [m_player]->show (0, 0);
     }.

.  load_p 
     {w->set_cursor (150);
      w->tick       ();
      p    [m_player] = new cmap (w, "hcraft/m4");
      is_p [m_player] = true;
      w->set_cursor (2);
      w->tick       ();
     }.

.  show_buttons
     {g_host  = new craft_getline  ("",w, host [pno],60,160,180, 20);
      g_name  = new craft_getline  ("",w, name [pno],60,230,180, 20);
     }.

.  finish
     {delete (g_host);
      delete (g_name);
     }.

. session
    {w->mark_mouse ();
     w->tick       ();
     while (! any_flag_request ())
      {w->scratch_mouse ();
       w->mark_mouse    ();
       w->tick          ();
       handle_cmds;
       if (! was_seed)
          tic = (tic + 1) % 123124;
      };
    }.

.  handle_cmds
     {g_host->get ();
      g_name->get ();
      speed [pno] = 1;
     }.

.  pno
     (act_menu - 2).

  }

void details_menu (int act_menu, double &g_speed, int &tic)
  {dial     *d_min_land_dx;
   dial     *d_min_land_dy;
   dial     *d_max_land_dx;
   dial     *d_max_land_dy;
   scroller *s_act_speed;

   init;
   session;
   finish;

.  init
     {show_pic;
      show_buttons;
     }.

.  show_pic
     {if (! is_p [m_details])
         load_p;
      p [m_details]->show (0, 0);
     }.

.  load_p 
     {w->set_cursor (150);
      w->tick       ();
      p    [m_details] = new cmap (w, "hcraft/m2");
      is_p [m_details] = true;
      w->set_cursor (2);
      w->tick       ();
     }.

.  show_buttons
     {s_act_speed   = new scroller ("", w, 60,200,220,0,1,5,0,
                                    act_speed,1,1);
      d_min_land_dx = new dial     (w, "",
               0,200,70,50,min_rland_dx,400,10, false,40,false, 50, false);
      d_max_land_dx = new dial     (w, "",
               0,200,90,80,max_rland_dx,400,10, false,40,false, 50, false);
      d_min_land_dy = new dial     (w, "",
               0,200,110,50,min_rland_dy,400,10, false,40,false, 50, false);
      d_max_land_dy = new dial     (w, "",
               0,200,130,80,max_rland_dy,400,10, false,40,false, 50, false);
     }.

.  finish
    {delete (d_min_land_dx);
     delete (d_min_land_dy);
     delete (d_max_land_dx);
     delete (d_max_land_dy);
     delete (s_act_speed);
     }.

. session
    {w->mark_mouse ();
     w->tick       ();
     while (! any_flag_request ())
      {w->scratch_mouse ();
       w->mark_mouse    ();
       w->tick          ();
       handle_cmds;
       if (! was_seed)
          tic = (tic + 1) % 123124;
      };
    }.

.  handle_cmds
     {if (d_min_land_dx->eval (min_rland_dx))
         {min_rland_dx = i_min (min_rland_dx, max_rland_dx);
          d_min_land_dx->set (min_rland_dx);
         };
      if (d_min_land_dy->eval (min_rland_dy))
         {min_rland_dy = i_min (min_rland_dy, max_rland_dy);
          d_min_land_dy->set (min_rland_dy);
         };
      if (d_max_land_dx->eval (max_rland_dx))
         {min_rland_dx = i_min (min_rland_dx, max_rland_dx);
          d_min_land_dx->set (min_rland_dx);
         };
      if (d_max_land_dy->eval (max_rland_dy))
         {min_rland_dy = i_min (min_rland_dy, max_rland_dy);
          d_min_land_dy->set (min_rland_dy);
         };
      s_act_speed  ->eval (act_speed);
      switch (act_speed)
        {case 1 : g_speed = 1.0 / 5.0; break;
         case 2 : g_speed = 1.0 / 4.0; break;
         case 3 : g_speed = 1.0 / 2.0; break;
         case 4 : g_speed = 1.0 / 1.0; break;
         case 5 : g_speed = 1.0 / 0.5; break;
        };
     }.

  }

void robo_menu (int act_menu, int &tic)
  {scroller *s_robo_power;
   scroller *s_robo_agress;

   init;
   session;
   finish;

.  init
     {show_pic;
      show_buttons;
     }.

.  show_pic
     {if (! is_p [m_robot])
         load_p;
      p [m_robot]->show (0, 0);
     }.

.  load_p 
     {w->set_cursor (150);
      w->tick        ();
      p    [m_robot] = new cmap (w, "hcraft/m3");
      is_p [m_robot] = true;
      w->set_cursor (2);
      w->tick       ();
     }.

.  show_buttons
     {s_robo_power = new scroller ("", w, 40,180,200,0,1,5,0,
                                   r_power,1,1);
     }.

.  finish
     {delete (s_robo_power);
     }.

. session
    {w->mark_mouse ();
     w->tick       ();
     while (! any_flag_request ())
      {w->scratch_mouse ();
       w->mark_mouse    ();
       w->tick          ();
       handle_cmds;
       if (! was_seed)
          tic = (tic + 1) % 123124;
      };
    }.

.  handle_cmds
     {s_robo_power ->eval (r_power);
     }.

  }

void inactive_menu (int act_menu, int &tic)
  {init;
   session;

.  init
     {if (! is_p [m_inactive])
         load_p;
      p [m_inactive]->show (0, 0);
     }.

.  load_p 
     {w->set_cursor (150);
      w->tick        ();
      p    [m_inactive] = new cmap (w, "hcraft/m5");
      is_p [m_inactive] = true;
      w->set_cursor (2);
      w->tick       ();
     }.

. session
    {w->mark_mouse ();
     w->tick       ();
     while (! any_flag_request ())
      {w->scratch_mouse ();
       w->mark_mouse    ();
       w->tick          ();
       handle_cmds;
       if (! was_seed)
          tic = (tic + 1) % 123124;
      };
    }.

.  handle_cmds
     {
     }.

  }

void option_menu (double &speed, int &tic)
  {bool quit;

   init;
   while (! quit)
     {session;
     };
   finish;

.  finish
     {delete (w);
      switch (act_speed)
        {case 5 : speed = 1.0 / 5.0; break;
         case 4 : speed = 1.0 / 4.0; break;
         case 3 : speed = 1.0 / 2.0; break;
         case 2 : speed = 1.0 / 1.0; break;
         case 1 : speed = 1.0 / 0.5; break;
        };
      switch (r_power)
        {case 1 : robo_power = 1;    break;
         case 2 : robo_power = 1.25; break;
         case 3 : robo_power = 1.5;  break;
         case 4 : robo_power = 3;    break;
         case 5 : robo_power = 8;    break;
        };
      switch (r_agress)
        {case 5 : robo_agress = 0.1;  break;
         case 4 : robo_agress = 0.5;  break;
         case 3 : robo_agress = 1.0;  break;
         case 2 : robo_agress = 1.75; break;
         case 1 : robo_agress = 2;    break;
        };
     }.

.  init
     {open_w;
      init_p;
      init_menus;
      default_params;
     }.

.  init_p
     {for (int i = 0; i < 4; i++)
        is_p [i] = false;
     }.

.  open_w
     {w = new win ("craft_options", "", 10, 10, w_dx, w_dy);
     }.

.  init_menus
     {act_menu      = 0;
      quit          = false;
      menu_type [0] = m_main;
      menu_type [1] = m_details;
      menu_type [2] = m_player;
      menu_type [3] = m_robot;
      menu_type [4] = m_inactive;
      menu_type [5] = m_inactive;
      menu_type [6] = m_cancel;
      menu_type [7] = m_quit;
      num_menus     = 8;
      show_flags ();
      active [0] = true;
      active [1] = true;
      active [2] = false;
      active [3] = false;
     }.

. default_params
    {is_self        = true;
     is_suny        = true;  
     is_water_world = true;  
     act_speed      = 4;
     q_step         = 1;
     r_power        = 3;
     r_agress       = 3;
     min_rland_dx   = 60;
     min_rland_dy   = 60;
     max_rland_dx   = 80;
     max_rland_dy   = 80;
     strcpy (host [0], "");
     strcpy (host [1], "");     
     strcpy (host [2], "");     
     strcpy (host [3], "");     
     strcpy (name [0], "player 0");
     strcpy (name [1], "player 1");     
     strcpy (name [2], "player 2");   
     strcpy (name [3], "player 3");   
     was_seed       = false;
     set_robot (1);
    }.

.  session
     {switch (menu_type [act_menu])
        {case m_main     : main_menu     (act_menu, tic);        break;
         case m_details  : details_menu  (act_menu, speed, tic); break;
         case m_player   : player_menu   (act_menu, tic);        break;
         case m_robot    : robo_menu     (act_menu, tic);        break;
         case m_inactive : inactive_menu (act_menu, tic);        break;
         case m_cancel   : exit (0);                             break;
         case m_quit     : quit = true;                          break;
        };
      show_flags ();      
      if (! was_seed)
         tic = (tic + 1) % 123124;
     }.

  }
