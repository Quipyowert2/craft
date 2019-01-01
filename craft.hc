#include "win.h"
#include "cmap.h"
#include "masks.h"
#include "player.h"
#include "craft_def.h"
#include "object_handler.h"
#include "land.h"
#include "xstring.h"
#include "setupedit.h"
#include "dial.h"
#include "scroller.h"
#include "buttons.h"
#include "ship.h"
#include "option_menu.h"
#include "xtimer.h"


#define        min_cycle_time  50

double         robo_power;
double         robo_agress;

int            overall_money;

int            q_step;

int            min_rland_dx;
int            min_rland_dy;
int            max_rland_dx;
int            max_rland_dy;

int            speed_stag;
int            speed_worker;
int            speed_trader;
int            speed_knight;
int            speed_pawn;
int            speed_scout;
int            speed_archer;
int            speed_home;
int            speed_farm;
int            speed_farm_exec;
int            speed_zombi;
int            speed_schrott;
int            speed_swim;
int            speed_water;
int            speed_hit;
int            speed_building_zombi;
int            speed_archer_hit;
int            speed_cata;
int            speed_cata_load;
int            speed_explosion;
int            speed_doktor;
int            speed_doktor_hit;
int            speed_general;
int            speed_trap;
int            speed_arrow;
int            speed_stone;
int            speed_ship1;
int            speed_ship2;
int            speed_ship_zombi;

char           land_name [128];

int            ilid        [max_land_dx][max_land_dy];
int            landscape   [max_land_dx][max_land_dy];
int            landhight   [max_land_dx][max_land_dy];
int            landpic     [max_land_dx][max_land_dy];
int            landoverlay [max_land_dx][max_land_dy][2];
int            landscape_dx;
int            landscape_dy;
int            landscale;
int            olandscale;

int            unit      [max_land_dx][max_land_dy];
int            upic      [max_land_dx][max_land_dy][8];

int            color_player [max_cols];
int            player_color [max_players];
bool           paused       [max_players];
double         p_speed      [max_players];
char           p_name       [max_players][128];
int            num_paused;

int            ticker;

bool           is_self;
bool           is_suny;
bool           is_water_world;

land_prop      land_properties [max_land_types]; 

object_handler *objects;

player         *players [max_players];
int            num_humans;
int            num_players;
int            active [max_players];

char           host  [max_players][128];
char           name  [max_players][128];
double         speed [max_players];           

      

/*--- main ------------------------------------------------------------------*/

void dump ()
  {print_landscape;
   print_landhight;
   print_landpic;
   print_units;
   print_upic;
   print_objs;

.  print_landscape
     {printf ("--- landscape\n");
      printf ("dx %d dy %d\n", landscape_dx, landscape_dy);
      for (int y = 0; y < landscape_dy; y++)
        {for (int x = 0; x < landscape_dx; x++)
           printf ("%4d ", landscape [x][y]);
         printf ("\n");
        };
     }.

.  print_landhight
     {printf ("--- landhight\n");
      printf ("dx %d dy %d\n", landscape_dx, landscape_dy);
      for (int y = 0; y < landscape_dy; y++)
        {for (int x = 0; x < landscape_dx; x++)
           printf ("%4d ", landhight [x][y]);
         printf ("\n");
        };
     }.

.  print_landpic
     {printf ("--- landpic\n");
      printf ("dx %d dy %d\n", landscape_dx, landscape_dy);
      for (int y = 0; y < landscape_dy; y++)
        {for (int x = 0; x < landscape_dx; x++)
           printf ("%4d ", landpic [x][y]);
         printf ("\n");
        };
     }.

.  print_units
     {printf ("--- unit\n");
      printf ("dx %d dy %d\n", landscape_dx, landscape_dy);
      for (int y = 0; y < landscape_dy; y++)
        {for (int x = 0; x < landscape_dx; x++)
           printf ("%4d ", unit [x][y]);
         printf ("\n");
        };
     }.

.  print_upic
     {printf ("--- upic\n");
      printf ("dx %d dy %d\n", landscape_dx, landscape_dy);
      for (int y = 0; y < landscape_dy; y++)
        {for (int x = 0; x < landscape_dx; x++)
           {for (int i = 0; i < 8; i++)
              printf ("%4d ", upic [x][y][i]);
            printf (",");
           };
         printf ("\n");
        };
     }.

.  print_objs
     {for (int i = 0; i < max_objects; i++)
        printf ("%d %d %d %d %d %d %d %d %d\n", 
                i, 
                objects->type [i],
                objects->is_free [i],
                objects->color [i],
                objects->x  [i],
                objects->y  [i], 
                objects->wx [i],
                objects->wy [i],
                objects->pic [i]);
    }.

  }

void handle_abnormal_termination ()
  {printf ("\nabnormal termination occurred ***\n");
/*
   dump   ();
*/
   exit   (0);
  }       

void handle_bus_error ()
  {printf ("\nbus error occurred ***\n");
/*
   dump   ();
*/
   exit   (0);
  }   

void handle_seg_fault ()
  {printf ("\nsegmentation fault occurred ***\n");
/*
   dump   ();
*/
   exit   (0);
  }  

void install_abnormal_termination_handler ()
  {
/*
   set_interrupt (SIGINT,  handle_abnormal_termination);
   set_interrupt (SIGBUS,  handle_bus_error);
   set_interrupt (SIGSEGV, handle_seg_fault);
   set_interrupt (SIGABRT, handle_abnormal_termination);
*/
  }

/*--- main ------------------------------------------------------------------*/

double pdist (int x1, int y1, int x2, int y2)
  {int xx = x1 - x2;
   int yy = y1 - y2;

   return sqrt (xx * xx + yy * yy);
  }

void init_speed (double factor)
  {speed_stag           = i_max (1, xspeed_stag);
   speed_worker         = i_max (1, (int)((double) xspeed_worker * factor));
   speed_trader         = i_max (1, (int)((double) xspeed_trader * factor));
   speed_knight         = i_max (1, (int)((double) xspeed_knight * factor));
   speed_pawn           = i_max (1, (int)((double) xspeed_pawn * factor));
   speed_scout          = i_max (1, (int)((double) xspeed_scout * factor));
   speed_archer         = i_max (1, (int)((double) xspeed_archer * factor));
   speed_home           = i_max (1, (int)((double) xspeed_home * factor));
   speed_farm           = i_max (1, (int)((double) xspeed_farm * factor));
   speed_farm_exec      = i_max (1, speed_farm - (int) (200.0 * factor));
   speed_zombi          = i_max (1, (int)((double) xspeed_zombi * factor));
   speed_schrott        = i_max (1, (int)((double) xspeed_schrott * factor));
   speed_swim           = i_max (1, (int)((double) xspeed_swim * factor));
   speed_water          = i_max (1, (int)((double) xspeed_water * factor));
   speed_hit            = i_max (1, (int)((double) xspeed_hit * factor));
   speed_building_zombi = i_max (1, (int)((double) xspeed_building_zombi * factor));
   speed_archer_hit     = i_max (1, (int)((double) xspeed_archer_hit * factor));
   speed_cata           = i_max (1, (int)((double) xspeed_cata * factor));
   speed_cata_load      = i_max (1, (int)((double) xspeed_cata_load * factor));
   speed_explosion      = i_max (1, (int)((double) xspeed_explosion * factor));
   speed_doktor         = i_max (1, (int)((double) xspeed_doktor * factor));
   speed_doktor_hit     = i_max (1, (int)((double) xspeed_doktor_hit * factor));
   speed_general        = i_max (1, (int)((double) xspeed_general * factor));
   speed_trap           = i_max (1, (int)((double) xspeed_trap * factor));
   speed_arrow          = i_max (1, (int)((double) xspeed_arrow * factor));
   speed_stone          = i_max (1, (int)((double) xspeed_stone * factor));
   speed_ship1          = i_max (1, (int)((double) xspeed_ship1 * factor));
   speed_ship2          = i_max (1, (int)((double) xspeed_ship2 * factor));
   speed_ship_zombi     = i_max (1, (int)((double) xspeed_ship_zombi*factor));
  }

void init_craft (char   host  [max_players][128],
                 char   name  [max_players][128],
                 double speed [max_players])

  {install_abnormal_termination_handler ();
   store_params;
   init_ticker;
   load_troups;
   init_land;
   init_players;

.  init_land
     {load_land_props ();
      if   (is_water_world)
           rnd_water_land  ();  
      else rnd_land ();
     }.

.  init_ticker
     {ticker = 0;
     }.

.  store_params
     {num_players = 0;
      num_humans  = 0;
      for (int i = 0; i < max_players; i++)
        cnt_player;
      num_paused  = 0;
     }.

.  cnt_player
     {if (active [i])
         {num_players++; 
          if (! is_robot)
             num_humans++;
         };
     }.

.  init_players
     {int i;

      olandscale = 1;
      for (i = 0; i < max_players; i++)
        {paused [i] = false; 
         strcpy (p_name [i], name [i]);
         p_speed [i] = 1;
        };
      for (i = 0; i < max_players; i++)
        if (active [i])
           gen_player;
      for (i = 0; i < max_players; i++)
        if (active [i])
           players [i]->initial_display ();
      color_player [red]    = 0;
      color_player [blue]   = 1;
      color_player [yellow] = 2;
      color_player [cyan]   = 3;
      player_color [0]      = red;
      player_color [1]      = blue;
      player_color [2]      = yellow;
      player_color [3]      = cyan;
     }.

.  gen_player
     {if (i == 0) players [i] = new player (i,
                                            name [i],
                                            host [i],
                                            red,
                                            p_speed [i],
                                            is_robot);
      if (i == 1) players [i] = new player (i,
                                            name [i],
                                            host [i],
                                            blue,
                                            p_speed [i],
                                            is_robot);
      if (i == 2) players [i] = new player (i,
                                            name [i],
                                            host [i],
                                            yellow,
                                            p_speed [i],
                                            is_robot);
      if (i == 3) players [i] = new player (i,
                                            name [i],
                                            host [i],
                                            cyan,
                                            p_speed [i],
                                            is_robot);
     }.

.  is_robot
     (strcmp (host [i], "-") == 0).

.  load_troups
     {objects = new object_handler ();
     }.

  }

void finish_craft ()
  {for (int i = 0; i < max_players; i++)
     if (active [i])
        delete (players [i]);
   delete (objects);
  }

void set_initial_objects ()
   {int color = blue;
    int il_locked [15];

    init;
    if (active [0]) {color = blue;   gen;};
    if (active [1]) {color = red;    gen;};
    if (active [2]) {color = yellow; gen;};
    if (active [3]) {color = cyan;   gen;};

.  init
     {for (int i = 0; i < 15; i++)
        il_locked [i] = false;
     }.

.  gen
     {int xx;
      int yy;

      get_xx_yy;
      gen_on_land;
     }.

.  gen_on_land
     {objects->create_worker (xx,     yy,  color, none);
      objects->create_worker (xx+1,   yy,  color, none);
      objects->create_knight (xx+1, yy+1,  color, none, is_self && ! is_robo);
      players [color_player [color]]->focus (xx, yy);
     }.

.  is_robo
     players [color_player [color]]->is_robot.

.  get_xx_yy
     {if   (is_water_world)
           get_island_xx_yy
      else get_land_xx_yy;
     }.

.  get_island_xx_yy
     {int il;

      get_il;
      while (il_locked [il])
        {get_il;
        };
      xx             = land_x_il (il);
      yy             = land_y_il (il);
      il_locked [il] = true;
      march;
     }.     

.  march
     {int  ox = xx;
      int  oy = yy;
      bool il_ok;

      check_il;
      while (! il_ok)
        {perhaps_backstep;
         step;
         check_il;
        };
      set_to_grass;
     }.

.  check_il
     {il_ok = could_become_grass;
     }.

.  set_to_grass
     {for (int xa = i_max (0, xx-2); xa < i_min (landscape_dx, xx+3); xa++)
        for (int ya = i_max (0, yy-2); ya < i_min (landscape_dy, yy+3); ya++)
          if (landhight [xa][ya] > 0 && unit [xa][ya] == none)
             {landscape [xa][ya] = land_grass;
              landpic   [xa][ya] = land_grass + land_profile (xa, ya, 1);;
              objects->refresh (xa, ya);
             };
      il_ok = true;
     }.

.  could_become_grass
     (1 <= xx && xx <= landscape_dx - 3 &&
      1 <= yy && yy <= landscape_dy - 3 &&
      unit [xx]  [yy]        == none &&
      unit [xx+1][yy]        == none &&
      unit [xx+1][yy+1]      == none &&
      landscape [xx]  [yy]   != land_water &&
      landscape [xx+1][yy]   != land_water &&
      landscape [xx+1][yy+1] != land_water &&
      landscape [xx]  [yy]   != land_sea   &&
      landscape [xx+1][yy]   != land_sea   &&
      landscape [xx+1][yy+1] != land_sea).

.  perhaps_backstep
     {if (is_water (10000, xx, yy))
         {xx = ox;
          yy = oy;
         };
     }.

.  step
     {ox = xx;
      oy = yy;
      xx = i_bound (1, xx + i_random (-2, 2), landscape_dx - 3);
      yy = i_bound (1, yy + i_random (-2, 2), landscape_dy - 3);
     }.

.  get_il
     {il = i_random (0, land_num_il () - 4 - 1);
     }.

.  get_land_xx_yy
     {bool ok;

      rnd;
      while (! ok)
        {rnd;
        };
     }.

.  rnd
     {int s;

      if (i_random (0, 100) > 50) s = 1; else s = -1;
      xx = landscape_dx/2 + i_random (10, landscape_dx/2 - 5) * s;
      if (i_random (0, 100) > 50) s = 1; else s = -1;
      yy = landscape_dy/2 + i_random (10, landscape_dy/2 - 5) * s;
      check_ok;
     }.

.  check_ok
     {ok = (! is_water_world                     &&
            landscape [xx]  [yy]   == land_grass &&
            landscape [xx+1][yy]   == land_grass &&
            landscape [xx+1][yy+1] == land_grass) ||
           (is_water_world && is_water (10000, xx, yy));
      for (int i = 0; i < max_objects; i++)
        if (! objects->is_free [i] && objects->type [i] == object_knight)
           ok &= (pdist (xx, yy, objects->x [i], objects->y [i]) > 25);
     }.
                 
  }

int main (int num_params, char *shell_params [])
  {double act_speed;

   start_message;
   init_players;
   set_initial_objects ();
   exec_craft;
   finish_craft ();

.  start_message
     {printf ("CRAFT Version 3.5 (http://set.gmd.de/~hua) started\n");
     }.

.  init_players
     {int tic;

      get_params;
      d_randomize (tic);
      init_speed  (act_speed);
      init_craft  (host, name, speed);
      printf      ("starting game with seed %d\n", tic);
     }.

.  get_params
     {for (int i = 0; i < max_players; i++)
        active [i] = false;
      option_menu (act_speed, tic);
     }.

.  exec_craft
     {bool quit = false;
      int  cnt;
      int  h = 0;

      set_cnt;
      while (! quit)
        cycle;
     }.

.  set_cnt
     {cnt = num_players;
     }.

.  cycle
     {int    suspend = -1;
      double cycle_start_time = x_sys_time ();

      read_cmds;
      if (h % 3 == 0)
         check_pause;
      exec_objects;
      check_over;
      perhaps_delay;
     }.

.  perhaps_delay
     {int rest_dt = (int)(min_cycle_time - (x_sys_time () - cycle_start_time));

      if (rest_dt > 10)
         {delay (rest_dt);
         };
     }.

.  check_pause
     {bool was = false;

      while (num_paused > 0) 
        {pause_a_bit;
        };
      if (was)
         pause_a_bit;
     }.

.  pause_a_bit
     {was = true;
      for (int i = 0; i < max_players; i++)
        if (active [i] && ! players [i]->is_robot)
           players [i]->handle_pause ();
     }.

.  read_cmds
     {for (int pi = 0; pi < max_players; pi++)
        if (active [pi] && ! players [pi]->is_robot)
           read_player_cmd;
     }.

.  read_player_cmd 
     {int  cmd [max_marked];
      int  x   [max_marked];
      int  y   [max_marked];
      int  id  [max_marked];
      int  num;
      int  suspend    = -1;
      bool is_suspend = false;

      players [pi]->get_cmds (is_suspend, num, cmd, id, x, y);
      perhaps_exec_player_cmd;
      if (is_suspend)
         {suspend = pi;
          check_over;
         };
     }.

.  perhaps_exec_player_cmd
     {for (int p = 0; p < num; p++)
        exec_player_cmd;
     }.

.  exec_player_cmd
     {objects->new_order (id [p], cmd [p], x [p], y [p]);
     }.

.  exec_objects
     {for (int i = 0; i < 1; i++)
        {objects->exec ();
         ticker++;
        };
     }.

.  check_over
     {int only = -1;

      for (int i = 0; i < max_players; i++)
        if (active [i] &&
             (players [i]->num_mans <= 0 ||
              suspend == i ||
              players [i]->master_dead))
           handle_game_over
     }.

.  handle_game_over
     {char   msg       [128];
      win    *w        [max_players];
      button *b        [max_players];
      bool    m_active [max_players];

      if      (players [i]->master_dead)
              sprintf (msg, "%s haes been killed", name [i]);
      else if (players [i]->num_mans <= 0)
              sprintf (msg, "%s lost all his man", name [i]);
      else if (suspend == i)
              sprintf (msg, "%s gives up",         name [i]); 
      tell_to_players;
      ack_from_players;
      if (! players [i]->is_robot)
         num_humans--;
      cnt--;
      quit = (cnt <= 1 || num_humans < 1);
      for (int o = 0; o < max_players; o++)
        if (active [o] && o != i && ! players [o]->is_robot)
           only = o;
      if      (quit && only != -1)
              {sprintf (msg, "%s wins", name [only]);
               tell_to_players;
               ack_from_players;
              }
      else if (quit && only == -1)
              {sprintf (msg, "The computer wins, haha...");
               tell_to_players;
               ack_from_players;
              };
      players [i]->deactivate ();
      active [i] = false;
     }.

.  tell_to_players
     {for (int j = 0; j < max_players; j++)
        {m_active [j] = false;
         if (active [j] && ! players [j]->is_robot)
           tell_to_player;
        };
     }.

.  tell_to_player
     {tell (host [j], players [j]->w_land, w [j], msg);
      b        [j] = new button (w [j], "OK", 120, 80);
      m_active [j] = true;
     }.

.  ack_from_players
     {bool any_active = true;

      while (any_active)
        check_buttons;
     }.

.  check_buttons
     {any_active = false;
      for (int j = 0; j < max_players; j++)
        if (m_active [j])
           ack_from_player;
     }.

.  ack_from_player
     {any_active = true;
      w [j]->mark_mouse ();
      w [j]->tick ();
      if   (b [j]->eval ())
           {delete (b [j]);
            delete (w [j]);
            m_active [j] = false;
           }
      else w [j]->scratch_mouse ();
     }.

  }
