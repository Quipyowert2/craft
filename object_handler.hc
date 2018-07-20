#include "dir.h"
#include "object_handler.h"
#include "craft.h"
#include "player.h"
#include "land.h"
#include "building.h"
#include "pic.h"
#include "robot.h"
#include "ship.h"

#define step_over  8
#define step_t     6
#define arrow_t    4
#define hack_t     50

#define delay_time 1000
#define look_n     7

/*--- div --------------------------------------------------------------*/

bool no_water (int x, int y)
  {for (int xx = xmin; xx < xmax; xx++)
    for (int yy = ymin; yy < ymax; yy++)
      if (landscape [xx][yy] == land_water || landscape [xx][yy] == land_sea)
         return false;
   return true;
  
.  xmin  i_max (x - 1, 0).
.  xmax  i_min (x + 2, landscape_dx-1).
.  ymin  i_max (y - 1, 0).
.  ymax  i_min (y + 2, landscape_dy-1).

  }

double dist (int x1, int y1, int x2, int y2)
  {int xx = x1 - x2;
   int yy = y1 - y2;

   return sqrt (xx * xx + yy * yy);
  }

int stepdist (int x1, int y1, int x2, int y2)
  {return i_max (i_abs (x1 - x2), i_abs (y1 - y2));
  }

bool is_moving (int id)
  {int c = objects->cmd [id][0];

   return (c == cmd_move_to || c == cmd_perform_steps || c == cmd_sail);
  }

bool is_g_moving (int id)
  {int c = objects->cmd [id][0];

   return (c == cmd_move_to       ||
           c == cmd_perform_steps ||
           c == cmd_wait ||
           c == cmd_sail);
  }

/*--- construct/destruct -----------------------------------------------*/

object_handler::object_handler ()
  {init_objects;
   free [max_objects-1] = none;
   first_free           = 0;
   ticker               = 0;
   qticker              = 0;
/*
   fx                   = 0;
   fy                   = 0;
*/
   pv                   = 0;
   num_hd               = 0;
   fresh_pot            = true;
   init_traps;

.  init_traps
     {for (int x = 0; x < max_land_dx; x++)
        for (int y = 0; y < max_land_dy; y++)
          {is_a_trap [x][y] = false;
           fv        [x][y] = -1;
          };
     }.

.  init_objects
     {for (int i = 0; i < max_objects; i++)
        init_obj;
     }.

.  init_obj
     {free    [i] = i+1;
      is_free [i] = true;
     }.

  }
   
object_handler::~object_handler ()
  {
  }

/*--- delay ------------------------------------------------------------*/

void object_handler::delay_wait (int id)
  {push_order (id, cmd_wait, delay [id] + i_random (0, 5), 0);
   delay [id] = i_min (500, (int) ((double) delay [id] * 2));
  }

/*--- object -----------------------------------------------------------*/

int object_handler::create_object ()
  {int free_obj = first_free;

   if (free_obj != none)
      grab_obj;
   return free_obj;

.  grab_obj
     {first_free         = free [free_obj];
      is_free [free_obj] = false;
      age     [free_obj] = 0;
      home_id [free_obj] = none;
      trace   [free_obj] = false;
      trapped [free_obj] = false;
      oid     [free_obj] = ticker;
      delay   [free_obj] = 3;
      master  [free_obj] = false;
      on_ship [free_obj] = -1;
      atta_x  [free_obj] = none;
     }.

  }

void object_handler::delete_object (int id)
  {free [id]    = first_free;
   first_free   = id;
   is_free [id] = true;
   type    [id] = -1;
   on_ship [id] = -1;
  }

void object_handler::exec ()
  {ticker++;
   exec_mans;
   exec_robots;
   if ((ticker % 10) == 0)
      handle_grow;

.  exec_mans
     {for (int i = 0; i < max_objects; i++)
        exec (i);
     }.

.  exec_robots
     {for (int k = 0; k < num_players; k++)  
        {if (players [k]->active && ! players [k]->is_robot)
            players [k]->w_land->tick ();
         if (players [k]->is_robot)
            players [k]->rob->eval ();
        };
     }.

.  handle_grow
     {int x = i_random (0, landscape_dx - 1);
      int y = i_random (0, landscape_dy - 1);
 
      if (landscape [x][y] == land_mud)
         {landscape [x][y] = land_grass;
          readjust_land (x, y, 0);
         };
     }.

  } 

void object_handler::exec (int id)
  {if   (is_free [id] || (age [id] % speed [id]) != 0)
        exec_delay
   else exec_action;
   age [id]++;
   qticker++;

.  exec_delay
     {
     }.

/*
     {int j = 0;

      if (j >= delay_time)
         fy = i_max (0, fy-1);
      for (; j < delay_time; j++)
        {fx = fx;
        };
     }.
*/

.  exec_action 
     {if   (cmd [id][0] == cmd_die)
           handle_death
      else perform_individual_action;
     }.

.  handle_death
     {players [color_player [color [id]]]->any_kill = true;
      if      (type [id] == object_ship1)
              create_ship_zombi (id); 
      else if (type [id] == object_cata)
              create_schrott (id);
      else    create_zombi   (id);
     }.

.  perform_individual_action
     {switch (type [id])
        {case object_home           : exec_home           (id); break;
         case object_market         : exec_market         (id); break;
         case object_tents          : exec_tents          (id); break;
         case object_mine           : exec_mine           (id); break;
         case object_camp           : exec_camp           (id); break;
         case object_mill           : exec_mill           (id); break;
         case object_uni            : exec_uni            (id); break;
         case object_smith          : exec_smith          (id); break;
         case object_docks          : exec_docks          (id); break;
         case object_site_docks     :
         case object_building_site  : exec_building_site  (id); break;
         case object_worker         : exec_worker         (id); break;
         case object_trader         : exec_trader         (id); break;
         case object_knight         : exec_knight         (id); break;
         case object_pawn           : exec_pawn           (id); break;
         case object_scout          : exec_scout          (id); break;
         case object_ship1          : exec_ship           (id); break;
         case object_ship_zombi     : exec_ship_zombi     (id); break;
         case object_arrow          : exec_arrow          (id); break;
         case object_stone          : exec_stone          (id); break;
         case object_archer         : exec_archer         (id); break;
         case object_doktor         : exec_doktor         (id); break;
         case object_cata           : exec_cata           (id); break;
         case object_zombi          : exec_zombi          (id); break;
         case object_schrott        : exec_schrott        (id); break;
         case object_explosion      : exec_explosion      (id); break;
         case object_building_zombi : exec_building_zombi (id); break;
         case object_swim           : exec_swim           (id); break;
         case object_water          : exec_water          (id); break;
         case object_farm           : exec_farm           (id); break;
         case object_trap           : exec_trap           (id); break;
         case object_msg            : exec_msg            (id); break;
        };
     }.

  }

bool object_handler::any_object (int oid, int p_type, int p_color, int &id)
  {for (id = 0; id < max_objects; id++)
     if (! is_free [id] && type [id] == p_type && color [id] == p_color &&
         home_proper)
        return true;
   return false;

.  home_proper
     ((p_type != object_home   &&
       p_type != object_market &&
       p_type != object_tents) ||
       can_walk_to (oid, 1, x [id], y [id])).

  }

bool object_handler::can_walk_to (int id, int dist, int x, int y)
  {int  gxo = gx [id][0];
   int  gyo = gy [id][0];
   bool r;

   gx [id][0] = x;
   gy [id][0] = y;
   r          = man_plan_path (id, dist, true);
   gx [id][0] = gxo;
   gy [id][0] = gyo;
   return r;
  }

/*--- msg --------------------------------------------------------------*/

int object_handler::create_msg (int p_x, int p_y, int speacker, char msg [])
  {int id;

   id = create_object ();
   if (id != none)
      add_msg_data;
   return id;

.  add_msg_data
     {add_object_data;
      add_to_land;
     }.

.  add_object_data
     {strcpy (name [id], msg);
      type    [id]    = object_msg;
      x       [id]    = p_x;
      y       [id]    = p_y;
      gx      [id][0] = x [speacker];
      gy      [id][0] = y [speacker];
      wx      [id]    = x_center (p_x);
      wy      [id]    = y_center (p_y);
      t       [id]    = 4000;
      speed   [id]    = 20;
      color   [id]    = color [speacker];
      home_id [id]    = speacker;  
     }.

.  add_to_land
     {for (int xx = p_x; xx < i_min (landscape_dx - 1, p_x + 4); xx++)
        {land_push (id, xx, p_y, 0, 0);
         refresh (xx, p_y);
        };
     }.

  }

void object_handler::exec_msg (int id)
  {bool field_full;

   t [id]--;
   check_field_full;
   if (over)
      remove_msg;

.  over
     (t [id] <= 0 || speacker_away || field_full).

.  check_field_full
     {field_full = false;
      for (int xx = x [id]; xx < i_min (landscape_dx, x [id] + 4); xx++)
        if (unit [xx][y [id]] != none)
           field_full = true;
     }. 

.  speacker_away
     (is_free [speacker]         ||
      x [speacker] != gx [id][0] ||
      y [speacker] != gy [id][0] ||
      color [speacker] != color [id]).

.  remove_msg
     {for (int xx = x [id]; xx < i_min (landscape_dx, x [id] + 4); xx++)
         {land_pop (id, xx, y [id]);
          refresh (xx, y [id]);
         };
      delete_object (id);
     }.

.  speacker  
     home_id [id].

  }

void object_handler::exec_talk (int id)
  {create_msg (x [id] + 1,
               y [id] - 1,
               id,
               players [color_player [color [id]]]->message); 
   pop_order  (id);
  }

/*--- trap -------------------------------------------------------------*/

void object_handler::setup_trap (int id)
  {int xx = gx [id][0];   
   int yy = gy [id][0];

   readjust_land (xx, yy, 2);
   for (int x = xmin; x <= xmax; x++)
     for (int y = ymin; y <= ymax; y++)
       if (landpic [x][y] == land_mud)
          {landpic   [x][y] = land_grass;
           landscape [x][y] = land_grass;
          };
   readjust_land (xx, yy, 0);
   landscape [xx][yy] = land_trap;

.  xmin  i_max (xx - 1, 0).
.  xmax  i_min (xx + 1, landscape_dx-1).
.  ymin  i_max (yy - 1, 0).
.  ymax  i_min (yy + 1, landscape_dy-1).

  }
   
int object_handler::create_trap (int p_x, int p_y)
  {int id;

   id = create_object ();
   if (id != none)
      add_trap_data;
   return id;

.  add_trap_data
     {add_object_data;
      add_to_land;
     }.

.  add_object_data
     {strcpy (name [id], "trap");
      type    [id]    = object_trap;
      pic     [id]    = pic_stone;
      x       [id]    = p_x;
      y       [id]    = p_y;
      wx      [id]    = x_center (p_x);
      wy      [id]    = y_center (p_y);
      t       [id]    = 0;
      speed   [id]    = speed_trap;
      color   [id]    = red;
     }.

.  add_to_land
     {landscape [p_x][p_y] = land_mud;
      readjust_land (x [id], y [id], -2);
     }.

  }

void object_handler::exec_trap (int id)
  {t [id]++;
   if   (over)
        remove_trap
   else new_pic;

.  over
     t [id] >= 9.

.  new_pic
     {if (t [id] == 1)
         hit_unit; 
      pic [id] = pic_trap + t [id];
      refresh (x [id], y [id]);
     }.

.  hit_unit
     {int u = unit [x [id]][y [id]];

      if (u != none) 
         {hit (id, u, power_trap);
          trapped [u] = true;
         };
      land_push (id, x [id], y [id], 0, 0);   
     }.

.  remove_trap
     {land_pop      (id, x [id], y [id]);   
      is_a_trap [x [id]][y [id]] = false;
      delete_object (id);
     }.

  }

/*--- mine -------------------------------------------------------------*/

void object_handler::exec_mine (int id)
  {if (health [id] != 100)
      set_health;
   if (money [id] <= 0)
      destroy_mine;

.  destroy_mine
     {destroy_building (id);
      delete_object    (id);
     }.

.  set_health
     {health  [id] = 100;
      version [id]++;
     }.

  }

/*--- farm -------------------------------------------------------------*/

bool can_grow (int x, int y, int d)
  {if   (0 <= x && x < landscape_dx && 0 <= y && y < landscape_dy)
        return (landhight [x][y] == d);
   else return true;
  }

void object_handler::exec_farm (int id)
  {perhaps_destoried;
   adjust_power;
   handle_grown_shrink;

.  perhaps_destoried
     {if (health [id] <= 0)
         handle_destoried;
      ex [id] = none;
     }.

.  handle_destoried
     {create_building_zombi (id);
      return;
     }.

.  adjust_power
     {speed [id] = speed_farm_exec;
     }.

.  handle_grown_shrink
     {version [id]++;
      check_fields;
      add_food;
      if (power [id] < max_power_per_farm)
         try_to_grow;
     }.

.  add_food
    {players [color_player [color [id]]]->food += power [id];
    }.

.  try_to_grow
     {int  nx;
      int  ny;
      bool any_new;

      search_new;
      if (any_new)
         let_grow;
     }.

.  search_new
     {int xx = i_random (xmin, xmax);
      int yy = i_random (ymin, ymax);

      any_new = false;
      perhaps_new_field;
     }.

.  xmin  i_max (x [id] - 5, 0).
.  xmax  i_min (x [id] + 5, landscape_dx-1).
.  ymin  i_max (y [id] - 5, 0).
.  ymax  i_min (y [id] + 5, landscape_dy-1).

.  perhaps_new_field
     {int h = landhight [xx][yy];

      if (land_properties [landscape [xx][yy]].can_grow && hight_ok)
         grab_new_grown;
     }.

.  hight_ok
     (landpic [xx][yy] == land_mud   || 
      landpic [xx][yy] == land_grass ||
      landpic [xx][yy] == land_stump).

.  grab_new_grown
     {any_new = true;
      nx      = xx;
      ny      = yy;
     }.

.  let_grow
     {xpush (ny, step [id]);
      xpush (nx, step [id]);
      landscape [nx][ny] = land_field;
      landpic   [nx][ny] = land_field;
      refresh (nx, ny);
     }.

.  check_fields
     {int i = 0;

      power [id] = 0;
      while (step [id][i] != none)
        {check_field;
        };
     }.

.  check_field
     {if   (landscape [step [id][i]][step [id][i+1]] == land_field)
           count_field
      else remove_field;
     }.

.  count_field
     {i += 2;
      power [id]++;
     }.

.  remove_field
     {for (int j = i; step [id][j] != none; j += 2)
        {step [id][j]   = step [id][j+2];
         step [id][j+1] = step [id][j+3];
        }
     }.

  }

/*--- building destoy --------------------------------------------------*/

void object_handler::destroy_building (int id)
  {int bdx;
   int bdy;

   calc_bdx_dy;
   is_marked [id] = false;
   remove_from_field;
   reshow;
   administrate;

.  administrate
     {switch (type [id])
       {case object_camp          : handle_camp;   break;
        case object_market        : handle_market; break;
        case object_tents         : handle_tents;  break;
        case object_farm          : handle_farm;   break;
        case object_mill          : handle_mill;   break;
        case object_uni           : handle_uni;    break;
        case object_smith         : handle_smith;  break;
        case object_docks         : handle_docks;  break;
        case object_home          : handle_home;   break;
        case object_site_docks    : 
        case object_building_site : handle_sb;     break;
       };
     }. 

.  handle_sb
     {if (dir [id] == object_home)
         players [color_player [color [id]]]->town_hall_in_progress--;
      if (dir [id] == object_market)
         players [color_player [color [id]]]->market_in_progress--;
     }.

.  handle_market
     {players [color_player [color [id]]]->num_markets--;
     }.

.  handle_tents
     {players [color_player [color [id]]]->num_tents--;
     }.

.  handle_camp
     {players [color_player [color [id]]]->num_camps--;
     }.

.  handle_mill
     {players [color_player [color [id]]]->num_mills--;
     }.

.  handle_smith
     {players [color_player [color [id]]]->num_smiths--;
     }.

.  handle_docks
     {players [color_player [color [id]]]->num_docks--;
     }.

.  handle_uni
     {players [color_player [color [id]]]->num_unis--;
     }.

.  handle_home
     {players [color_player [color [id]]]->num_town_halls--;
     }.

.  handle_farm
     {players [color_player [color [id]]]->num_farms--;
      delete_farm_ground;
     }.

.  delete_farm_ground
     {int i = 0;

      while (step [id][i] != none)
        {delete_ground;
         i += 2;
        };
     }.

.  delete_ground
     {if (landscape [step [id][i]][step [id][i+1]] == land_field)
         delete_field;
     }.

.  delete_field
     {landscape [step [id][i]][step [id][i+1]] = land_grass;
      landpic   [step [id][i]][step [id][i+1]] = land_grass;
      refresh (step [id][i], step [id][i+1]);
     }.

.  remove_from_field
     {for (int xx = x [id]; xx < x [id] + bdx; xx++)
       for (int yy = y [id]; yy < y [id] + bdy; yy++)
         set_field;
     }.

.  calc_bdx_dy
      {if     (type [id] == object_mine)
              {bdx = 1;
               bdy = 1;
              }
      else if (type [id] == object_site_docks || type [id] == object_docks)
              {bdx = 3;
               bdy = 3;
              }
      else    {bdx = 2;
               bdy = 2;
              };
     }.

.  set_field
     {unit      [xx][yy] = none;
      landscape [xx][yy] = land_mud;
      land_pop  (id, xx, yy);
     }.

.  reshow
    {for (int xx = x [id]; xx < x [id] + bdx; xx++)
       for (int yy = y [id]; yy < y [id] + bdy; yy++)
         readjust_land (xx, yy, 0);  
     }.

  }


/*--- building site ----------------------------------------------------*/

void object_handler::exec_building_site (int id)
  {if (power [id] >= 100)
      finish_build;
   if (health [id] <= 0 || worker_away)
      destroy_cite;
   if (health [id] % 20 == 0)
      version [id]++;

.  worker_away
     (moving_goal [id] != none && 
      (is_free [moving_goal [id]] ||
       (cmd [moving_goal [id]][0] != cmd_harvest &&
        cmd [moving_goal [id]][1] != cmd_harvest &&
        cmd [moving_goal [id]][2] != cmd_harvest &&
        cmd [moving_goal [id]][3] != cmd_harvest))).

.  destroy_cite
     {destroy_building (id);
      delete_object    (id);
     }.

.  finish_build
     {int type = dir   [id];
      int col  = color [id];
      int xp   = x     [id];
      int yp   = y     [id];
      int ii;
      int gg   = moving_goal [id];
      int p    = color_player [col];

      delete_object   (id);
      ii = create_building (xp, yp, type, 0, 0, col);
      if (players [p]->is_robot)
         players [p]->rob->just_finished = ii;      
      if (type == object_home)
         home_id [gg] = ii;
      players [p]->num_building_sites++;
     }.

  }

/*--- market -------------------------------------------------------------*/

void object_handler::exec_market (int id)
  {perhaps_destroied;
   handle_cmds;

.  perhaps_destroied
     {if (health [id] <= 0)
         handle_destroied;
      ex [id] = none;
     }.

.  handle_destroied
     {create_building_zombi (id);
      return;
     }.

.  handle_cmds
     {switch (cmd [id][0])
        {case cmd_train_trader : exec_train_trader; break;
        };
     }.

.  exec_train_trader
     {power [id] += (int) players [color_player [color [id]]]->grow_speed;
      if      (support [id] <= 0) interrupt_training
      else if (power [id] >= 100) handle_train_finished;
      if (power [id] % 20 == 0)
          version [id]++;
     }.

.  interrupt_training
     {power   [id] = 0;
      pop_order (id);
      write (color [id], "Too many mans");
     }.

.  handle_train_finished
     {place_trader;
      power   [id] = 0;
      support [id] = i_max (0, support [id] - 1);
      pop_order (id);
     }.

.  place_trader
     {int  xx;   
      int  yy;
      bool any_free_place;
      
      get_free_place;
      if (any_free_place)
         create_trader (xx, yy, color [id], id);
     }.

.  get_free_place
     {double best_dist = DBL_MAX;

      any_free_place = false;
      for (int xp = xmin; xp < xmax; xp++)
        for (int yp = ymin; yp < ymax; yp++)
          check_field;
     }.

.  check_field
     {double d = dist (x [id], y [id], xp, yp);

      if (lp.walk_possible && unit [xp][yp] == none && d < best_dist)
         grab_field;
     }.

.  grab_field
     {best_dist      = d;
      xx             = xp;
      yy             = yp;
      any_free_place = true;
     }.

.  lp    land_properties [landscape [xp][yp]].

.  xmin  i_max (x [id] - 10, 0).
.  xmax  i_min (x [id] + 10, landscape_dx-1).
.  ymin  i_max (y [id] - 10, 0).
.  ymax  i_min (y [id] + 10, landscape_dy-1).


  }

/*--- tents --------------------------------------------------------------*/

void object_handler::exec_tents (int id)
  {perhaps_destroied;
   handle_cmds;

.  perhaps_destroied
     {if (health [id] <= 0)
         handle_destroied;
      ex [id] = none;
     }.

.  handle_destroied
     {create_building_zombi (id);
      return;
     }.

.  handle_cmds
     {switch (cmd [id][0])
        {case cmd_train_scout : exec_train_scout; break;
        };
     }.

.  exec_train_scout
     {power [id] += (int) players [color_player [color [id]]]->grow_speed;
      if      (support [id] <= 0) interrupt_training
      else if (power [id] >= 100) handle_train_finished;
      if (power [id] % 20 == 0)
          version [id]++;
     }.

.  interrupt_training
     {power   [id] = 0;
      pop_order (id);
      write (color [id], "Too many mans");
     }.

.  handle_train_finished
     {place_scout;
      power   [id] = 0;
      support [id] = i_max (0, support [id] - 1);
      pop_order (id);
     }.

.  place_scout
     {int  xx;   
      int  yy;
      bool any_free_place;
      
      get_free_place;
      if (any_free_place)
         create_scout (xx, yy, color [id], id);
     }.

.  get_free_place
     {double best_dist = DBL_MAX;

      any_free_place = false;
      for (int xp = xmin; xp < xmax; xp++)
        for (int yp = ymin; yp < ymax; yp++)
          check_field;
     }.

.  check_field
     {double d = dist (x [id], y [id], xp, yp);

      if (lp.walk_possible && unit [xp][yp] == none && d < best_dist)
         grab_field;
     }.

.  grab_field
     {best_dist      = d;
      xx             = xp;
      yy             = yp;
      any_free_place = true;
     }.

.  lp    land_properties [landscape [xp][yp]].

.  xmin  i_max (x [id] - 10, 0).
.  xmax  i_min (x [id] + 10, landscape_dx-1).
.  ymin  i_max (y [id] - 10, 0).
.  ymax  i_min (y [id] + 10, landscape_dy-1).


  }

/*--- camp -------------------------------------------------------------*/

void object_handler::exec_camp (int id)
  {perhaps_destroied;
   handle_cmds;

.  perhaps_destroied
     {if (health [id] <= 0)
         handle_destroied;
      ex [id] = none;
     }.

.  handle_destroied
     {create_building_zombi (id);
      return;
     }.

.  handle_cmds
     {switch (cmd [id][0])
        {case cmd_train_knight : exec_train_knight; break;
         case cmd_idle         : perhaps_new_unit;  break;
        };
     }.

.  perhaps_new_unit
     {if (players [color_player [color [id]]]->money >= money_limit [id] &&
          players [color_player [color [id]]]->wood  >= wood_limit  [id] &&
          players [color_player [color [id]]]->money >= price_knight     &&
          players [color_player [color [id]]]->wood  >= wood_knight      &&
          support [id] > 0)
          new_order (id, cmd_train_knight, 0, 0);
     }.

.  exec_train_knight
     {power [id] += (int) players [color_player [color [id]]]->grow_speed;
      if      (support [id] <= 0) interrupt_training
      else if (power [id] >= 100) handle_train_finished;
      if (power [id] % 20 == 0)
          version [id]++;
     }.

.  interrupt_training
     {power   [id] = 0;
      pop_order (id);
      write (color [id], "Too many mans");
     }.

.  handle_train_finished
     {place_knight;
      power   [id] = 0;
      support [id] = i_max (0, support [id] - 1);
      pop_order (id);
     }.

.  place_knight
     {int  xx;   
      int  yy;
      bool any_free_place;
      
      get_free_place;
      if (any_free_place)
         create_knight (xx, yy, color [id], id);
     }.

.  get_free_place
     {double best_dist = DBL_MAX;

      any_free_place = false;
      for (int xp = xmin; xp < xmax; xp++)
        for (int yp = ymin; yp < ymax; yp++)
          check_field;
     }.

.  check_field
     {double d = dist (x [id], y [id], xp, yp);

      if (lp.walk_possible && unit [xp][yp] == none && d < best_dist)
         grab_field;
     }.

.  grab_field
     {best_dist      = d;
      xx             = xp;
      yy             = yp;
      any_free_place = true;
     }.

.  lp    land_properties [landscape [xp][yp]].

.  xmin  i_max (x [id] - 10, 0).
.  xmax  i_min (x [id] + 10, landscape_dx-1).
.  ymin  i_max (y [id] - 10, 0).
.  ymax  i_min (y [id] + 10, landscape_dy-1).


  }

/*--- mill -------------------------------------------------------------*/

void object_handler::exec_mill (int id)
  {perhaps_destroied;
   handle_cmds;

.  perhaps_destroied
     {if (health [id] <= 0)
         handle_destroied;
      ex [id] = none;
     }.

.  handle_destroied
     {create_building_zombi (id);
      return;
     }.

.  handle_cmds
     {switch (cmd [id][0])
        {case cmd_train_archer : exec_train_archer; break;
         case cmd_idle         : perhaps_new_unit;  break;
        };
     }.

.  perhaps_new_unit
     {if (players [color_player [color [id]]]->money >= money_limit [id] &&
          players [color_player [color [id]]]->wood  >= wood_limit  [id] &&
          players [color_player [color [id]]]->money >= price_archer     &&
          players [color_player [color [id]]]->wood  >= wood_archer      &&
          support [id] > 0)
         new_order (id, cmd_train_archer, 0, 0);
     }.

.  exec_train_archer
     {power [id] += (int) players [color_player [color [id]]]->grow_speed;
      if      (support [id] <= 0) interrupt_training
      else if (power [id] >= 100) handle_train_finished;
      if (power [id] % 20 == 0)
          version [id]++;
     }.

.  interrupt_training
     {power   [id] = 0;
      pop_order (id);
      write (color [id], "Too many mans");
     }.

.  handle_train_finished
     {place_archer;
      power   [id] = 0;
      support [id] = i_max (0, support [id] - 1);
      pop_order (id);
     }.

.  place_archer
     {int  xx;   
      int  yy;
      bool any_free_place;
      
      get_free_place;
      if (any_free_place)
         create_archer (xx, yy, color [id], id);
     }.

.  get_free_place
     {double best_dist = DBL_MAX;

      any_free_place = false;
      for (int xp = xmin; xp < xmax; xp++)
        for (int yp = ymin; yp < ymax; yp++)
          check_field;
     }.

.  check_field
     {double d = dist (x [id], y [id], xp, yp);

      if (lp.walk_possible && unit [xp][yp] == none && d < best_dist)
         grab_field;
     }.

.  grab_field
     {best_dist      = d;
      xx             = xp;
      yy             = yp;
      any_free_place = true;
     }.

.  lp    land_properties [landscape [xp][yp]].

.  xmin  i_max (x [id] - 10, 0).
.  xmax  i_min (x [id] + 10, landscape_dx-1).
.  ymin  i_max (y [id] - 10, 0).
.  ymax  i_min (y [id] + 10, landscape_dy-1).


  }

/*--- uni --------------------------------------------------------------*/

void object_handler::exec_uni (int id)
  {perhaps_destroied;
   handle_cmds;

.  perhaps_destroied
     {if (health [id] <= 0)
         handle_destroied;
      ex [id] = none;
     }.

.  handle_destroied
     {create_building_zombi (id);
      return;
     }.

.  handle_cmds
     {switch (cmd [id][0])
        {case cmd_train_doktor : exec_train_doktor; break;
         case cmd_idle         : perhaps_new_unit;  break;
        };
     }.

.  perhaps_new_unit
     {if (players [color_player [color [id]]]->money >= money_limit [id] &&
          players [color_player [color [id]]]->wood  >= wood_limit  [id] &&
          players [color_player [color [id]]]->money >= price_doktor     &&
          players [color_player [color [id]]]->wood  >= wood_doktor      &&
          support [id] > 0)
         new_order (id, cmd_train_doktor, 0, 0);
     }.

.  exec_train_doktor
     {power [id] += (int) players [color_player [color [id]]]->grow_speed;
      if      (support [id] <= 0) interrupt_training
      else if (power [id] >= 100) handle_train_finished;
      if (power [id] % 20 == 0)
          version [id]++;
     }.

.  interrupt_training
     {power   [id] = 0;
      pop_order (id);
      write (color [id], "Too many mans");
     }.

.  handle_train_finished
     {place_doktor;
      power   [id] = 0;
      support [id] = i_max (0, support [id] - 1);
      pop_order (id);
     }.

.  place_doktor
     {int  xx;   
      int  yy;
      bool any_free_place;
      
      get_free_place;
      if (any_free_place)
         create_doktor (xx, yy, color [id], id);
     }.

.  get_free_place
     {double best_dist = DBL_MAX;

      any_free_place = false;
      for (int xp = xmin; xp < xmax; xp++)
        for (int yp = ymin; yp < ymax; yp++)
          check_field;
     }.

.  check_field
     {double d = dist (x [id], y [id], xp, yp);

      if (lp.walk_possible && unit [xp][yp] == none && d < best_dist)
         grab_field;
     }.

.  grab_field
     {best_dist      = d;
      xx             = xp;
      yy             = yp;
      any_free_place = true;
     }.

.  lp    land_properties [landscape [xp][yp]].

.  xmin  i_max (x [id] - 10, 0).
.  xmax  i_min (x [id] + 10, landscape_dx-1).
.  ymin  i_max (y [id] - 10, 0).
.  ymax  i_min (y [id] + 10, landscape_dy-1).


  }

/*--- smith -------------------------------------------------------------*/

void object_handler::exec_smith (int id)
  {perhaps_destroied;
   handle_cmds;

.  perhaps_destroied
     {if (health [id] <= 0)
         handle_destroied;
      ex [id] = none;
     }.

.  handle_destroied
     {create_building_zombi (id);
      return;
     }.

.  handle_cmds
     {switch (cmd [id][0])
        {case cmd_train_cata : exec_train_cata; break;
         case cmd_idle       : perhaps_new_unit;  break;
        };
     }.

.  perhaps_new_unit
     {if (players [color_player [color [id]]]->money >= money_limit [id] &&
          players [color_player [color [id]]]->wood  >= wood_limit  [id] &&
          players [color_player [color [id]]]->money >= price_cata       &&
          players [color_player [color [id]]]->wood  >= wood_cata        &&
          support [id] > 0)
         new_order (id, cmd_train_cata, 0, 0);
     }.

.  exec_train_cata
     {power [id] += (int) players [color_player [color [id]]]->grow_speed;
      if      (support [id] <= 0) interrupt_training
      else if (power [id] >= 100) handle_train_finished;
      if (power [id] % 20 == 0)
         version [id]++;
     }.

.  interrupt_training
     {power   [id] = 0;
      pop_order (id);
      write (color [id], "Too many mans");
     }.

.  handle_train_finished
     {place_cata;
      power   [id] = 0;
      support [id] = i_max (0, support [id] - 1);
      pop_order (id);
     }.

.  place_cata
     {int  xx;   
      int  yy;
      bool any_free_place;
      
      get_free_place;
      if (any_free_place)
         create_cata (xx, yy, color [id], id);
     }.

.  get_free_place
     {double best_dist = DBL_MAX;

      any_free_place = false;
      for (int xp = xmin; xp < xmax; xp++)
        for (int yp = ymin; yp < ymax; yp++)
          check_field;
     }.

.  check_field
     {double d = dist (x [id], y [id], xp, yp);

      if (lp.walk_possible && unit [xp][yp] == none && d < best_dist)
         grab_field;
     }.

.  grab_field
     {best_dist      = d;
      xx             = xp;
      yy             = yp;
      any_free_place = true;
     }.

.  lp    land_properties [landscape [xp][yp]].

.  xmin  i_max (x [id] - 10, 0).
.  xmax  i_min (x [id] + 10, landscape_dx-1).
.  ymin  i_max (y [id] - 10, 0).
.  ymax  i_min (y [id] + 10, landscape_dy-1).


  }

/*--- smith -------------------------------------------------------------*/

void object_handler::exec_docks (int id)
  {perhaps_destoried;
   perform_actions;

.  perform_actions
     {switch (cmd [id][0])
        {case cmd_built_ship  : 
         case cmd_built_bship : exec_built_ship; break;
         case cmd_wait        : handle_wait;     break;
         case cmd_idle        : set_idle;        break;
        };
     }.

.  handle_wait
     {if   (gx [id][0] == 0)
           pop_order (id);
      else gx [id][0]--;
     }. 

.  set_idle
     {power [id] = 0;
     }.

.  perhaps_destoried
     {if (health [id] <= 0)
         handle_destoried;
      ex [id] = none;
     }.

.  handle_destoried
     {create_building_zombi (id);
      return;
     }.

.  exec_built_ship
     {perhaps_start_pic;
      power [id] += i_max (1,
                        (int)players[color_player[color [id]]]->grow_speed/50);
      power [id] = i_min (100, power [id]);
      if (power [id] >= 100)
         handle_train_finished;
      if (power [id] % 20 == 0)
         version [id]++;
     }.

.  perhaps_start_pic
     {if (power [id] == 0)
         set_ship_pic;
     }.

.  handle_train_finished
     {bool any_free_place;

      place_unit;
      if   (any_free_place)
           {set_dock_pic;
            pop_order (id);
            power   [id] = 0;
           }
      else push_order (id, cmd_wait, i_random (1, 200), 0);
     }.

.  set_dock_pic
     {for (int xx = 0; xx < 3; xx++)
        for (int yy = 0; yy < 3; yy++)
          landpic [x [id]+xx][y[id]+yy]=docks_pic (dir [id],
                                                   xx,
                                                   yy,
                                                   health [id]);
      refresh (x [id], y [id], 1, 1, 4, 4);
     }.

.  set_ship_pic
     {for (int xx = 0; xx < 3; xx++)
        for (int yy = 0; yy < 3; yy++)
          landpic [x [id]+xx][y [id]+yy]=docks_ship_pic (dir [id],
                                                         xx,
                                                         yy,
                                                         health [id]);
      refresh (x [id], y [id], 1, 1, 4, 4);
     }.

.  place_unit
     {int  xx;   
      int  yy;
      
      get_free_place;
      if (any_free_place)
         exec_create;
     }.

.  exec_create 
     {int p;

      p = create_ship (xx, yy, color[id],dir[id],cmd[id][0]==cmd_built_bship);
      home_id [p]  = id;            
      power   [id] = 0;
     }.

.  get_free_place
     {calc_xx_yy;
      check_field;
     }.

.  calc_xx_yy
     {switch (dir [id])
       {case 0: xx = x [id];     yy = y [id] - 3; break;
        case 2: xx = x [id] - 3; yy = y [id];     break;
        case 4: xx = x [id];     yy = y [id] + 3; break;
        case 6: xx = x [id] + 3; yy = y [id];     break;
       };
     }.

.  check_field
     {any_free_place = true;
      for (int xp = xx; xp < xx + 3; xp++)
        for (int yp = yy; yp < yy + 3; yp++)
          if (! lp.is_water || unit [xp][yp] != none)
             any_free_place = false;
     }.

.  lp    land_properties [landscape [xp][yp]].

.  xmin  i_max (x [id] - 10, 0).
.  xmax  i_min (x [id] + 10, landscape_dx-1).
.  ymin  i_max (y [id] - 10, 0).
.  ymax  i_min (y [id] + 10, landscape_dy-1).

  }

/*--- home -------------------------------------------------------------*/

void object_handler::exec_home (int id)
  {perhaps_destoried;
   perform_actions;

.  perform_actions
     {switch (cmd [id][0])
        {case cmd_train_worker : exec_train_worker; break;
         case cmd_train_pawn   : exec_train_pawn;   break;
        };
     }.

.  perhaps_destoried
     {if (health [id] <= 0)
         handle_destoried;
      ex [id] = none;
     }.

.  handle_destoried
     {create_building_zombi (id);
      return;
     }.

.  exec_train_worker
     {int typ = object_worker;

      power [id] += (int) players [color_player [color [id]]]->grow_speed;
      if (power [id] >= 100)
         handle_train_finished;
      if (power [id] % 20 == 0)
         version [id]++;
     }.

.  exec_train_pawn
     {int typ = object_pawn;

      power [id] += (int) players [color_player [color [id]]]->grow_speed;
      if (power [id] >= 100)
         handle_train_finished;
      if (power [id] % 20 == 0)
         version [id]++;
     }.

.  handle_train_finished
     {place_unit;
      pop_order (id);
     }.

.  place_unit
     {int  xx;   
      int  yy;
      bool any_free_place;
      
      get_free_place;
      if (any_free_place)
         exec_create;
     }.

.  exec_create 
     {if   (typ == object_worker)
           create_worker (xx, yy, color [id], id);
      else create_a_pawn;
     }.

.  create_a_pawn
     {int p = create_pawn (xx, yy, color [id]);

      home_id [p] = id;            
     }.

.  get_free_place
     {double best_dist = DBL_MAX;

      any_free_place = false;
      for (int xp = xmin; xp < xmax; xp++)
        for (int yp = ymin; yp < ymax; yp++)
          check_field;
     }.

.  check_field
     {double d = dist (x [id], y [id], xp, yp);

      if (lp.walk_possible && unit [xp][yp] == none && d < best_dist)
         grab_field;
     }.

.  grab_field
     {best_dist      = d;
      xx             = xp;
      yy             = yp;
      any_free_place = true;
     }.

.  lp    land_properties [landscape [xp][yp]].

.  xmin  i_max (x [id] - 10, 0).
.  xmax  i_min (x [id] + 10, landscape_dx-1).
.  ymin  i_max (y [id] - 10, 0).
.  ymax  i_min (y [id] + 10, landscape_dy-1).


  }

/*--- worker -----------------------------------------------------------*/

int object_handler::create_worker (int p_x, int p_y, int p_color, int home)
  {int id;

   check_num_mans;
   id = create_object ();
   if (id != none)
      add_worker_data;
   return id;

.  check_num_mans
     {int p = color_player [p_color];

      if (players [p]->num_mans >= max_num_mans)
         handle_to_many_mans;
     }.

.  handle_to_many_mans
     {write (p_color, "Too many mans");
      return none;
     }.

.  add_worker_data
     {add_object_data;
      add_to_land;
     }.

.  add_object_data
     {strcpy (name [id], "worker");
      color         [id]    = p_color;
      with_overview [id]    = true;
      is_marked     [id]    = false;
      type          [id]    = object_worker;
      pic           [id]    = pic_worker_idle (p_color);
      x             [id]    = p_x;
      y             [id]    = p_y;
      wx            [id]    = x_center (p_x);
      wy            [id]    = y_center (p_y);
      dir           [id]    = 0;
      cmd           [id][0] = cmd_idle;
      t             [id]    = ticker;
      health        [id]    = 100;
      power         [id]    = 50;
      speed         [id]    = speed_worker;
      wood          [id]    = 0;
      money         [id]    = 0;
      version       [id]    = 0; 
      interrupted   [id]    = false;
      ex            [id]    = none;
      home_id       [id]    = home;
      vr            [id]    = vr_man;
      players [color_player [p_color]]->num_mans++;
      players [color_player [p_color]]->add_sun (p_x, p_y, vr [id]);
     }.

.  add_to_land
     {unit [p_x][p_y] = id;
      land_push (id, p_x, p_y, 0, 0);
      refresh   (x [id], y [id]);
     }.
  
  }

void object_handler::exec_worker (int id)
  {consume_food;
   check_health;
   exec_cmd;

.  check_health
     {if (health [id] <= 0 || on_water)
         ouhgh;
     }.

.  on_water
     (on_ship [id]==-1 && land_properties [landscape[x[id]][y[id]]].is_water). 

.  ouhgh
     {new_order (id, cmd_die, none, none);
     }.

.  exec_cmd
     {switch (cmd [id][0])
        {case cmd_move_to       : worker_handle_move_to; break;
         case cmd_perform_steps : worker_handle_steps;   break;
         case cmd_harvest       : worker_harvest (id);   break;
         case cmd_dig           : worker_harvest (id);   break;
         case cmd_heap          : worker_harvest (id);   break;
         case cmd_idle          : worker_handle_idle;    break;
         case cmd_stop          : worker_handle_stop;    break;
         case cmd_hack          : worker_hack (id);      break;
         case cmd_upgrade       : worker_upgrade (id);   break;
         case cmd_wait          : worker_handle_wait;    break;
         case cmd_setup_trap    : worker_setup_trap;     break;
         case cmd_dig_trap      : worker_dig_trap;       break;
         case cmd_talk          : exec_talk (id);        break;
        };
     }.
   
.  worker_dig_trap
     {int xx = gx [id][0];
      int yy = gy [id][0];

      if   (land_properties [landscape [xx][yy]].is_dig &&
            landhight       [xx][yy] >= 1               &&
            (landscape [xx][yy] == land_grass ||
             landscape [xx][yy] == land_mud) && no_water (xx, yy))
           {push_order (id, cmd_setup_trap, xx, yy); 
            push_order (id, cmd_dig,        xx, yy);
            push_order (id, cmd_dig,        xx, yy);
            harvest_type [id] = harvest_dig;
           }
      else pop_order (id);
     }.
 
.  worker_setup_trap
     {int xx = gx [id][0];
      int yy = gy [id][0];

      if (land_properties [landscape [xx][yy]].is_dig &&
          landhight       [xx][yy] >= -3 &&
          landhight       [x [id]][y [id]] - landhight [xx][yy] <= 3)
         {setup_trap (id);
          if (players [color_player [color [id]]]->is_robot)
              is_a_trap [gx [id][0]][gy [id][0]] = true;
         };          
      new_order  (id, cmd_idle, 0, 0);
     }.

.  consume_food
     {double f = player_food;

      if   (player_food <= 0)
           reduce_health
      else reduce_food;
     }.

.  reduce_health
     {health  [id] = i_max (0, health [id] - 1);
      version [id]++;
     }.

.  reduce_food
     {player_food -= (double) speed_worker / (double) speed_farm;
     }.

.  player_food
     players [color_player [color [id]]]->food.

.  worker_handle_stop
     {pop_order (id);
     }.

.  worker_handle_idle
     {int p = pic [id] - pic_worker_idle (color [id]);

      if (! is_idle_pic)
         set_idle_pick;
     }.

.  is_idle_pic
     (0 <= p && p <= 30).

.  set_idle_pick
     {int dx;
      int dy;

      dir_dx_dy    (dir [id], dx, dy);
      set_move_pic (id, pic_worker_idle (color [id]), 0, dx, dy);
      refresh      (x [id], y [id]);
     }.

.  worker_handle_move_to
     {int goal_dist;

      calc_goal_dist;
      if   (no_way)
           handle_no_way
      else perhaps_new_home;
      delay_wait (id);
     }.

.  handle_no_way
     {int g_unit = unit [x [id] + i_sign (gx [id][0] - x [id])]
                        [y [id] + i_sign (gy [id][0] - y [id])];

      if       (at_home)
               {home_id [id] = g_unit;
                delay   [id] = 3;
                pop_order (id);
               }
      else if (at_building)
               {home_id [id] = g_unit;
                delay   [id] = 3;
                pop_order (id);
               }
      else     {pop_order  (id);
                delay_wait (id);
               };
     }.

.  perhaps_new_home
     {int g_unit;

      if   (gx [id][1] != none && gy [id][1] != none) 
           g_unit = unit [gx [id][1]][gy [id][1]];
      else g_unit = none; 
      delay [id] = 3;
      if (at_home)
         home_id [id] = g_unit;
     }.

.  at_building
     (g_unit != none              && 
      is_building (type [g_unit]) && 
      g_unit == unit [gx [id][0]][gy [id][0]]).

.  at_home
     (g_unit         != none        && 
      type  [g_unit] == object_home && 
      color [g_unit] == color [id]).

.  calc_goal_dist
     {if   (cmd [id][1] == cmd_heap ||
            cmd [id][1] == cmd_dig  ||
            cmd [id][1] == cmd_harvest)
           goal_dist = 1;
      else goal_dist = 0;
     }.

.  no_way
    ! ((move_to_possible || far_away) && man_plan_path (id, goal_dist, false)).

.  far_away
     ((i_abs (x [id] - gx [id][0]) > 1) || (i_abs (y [id] - gy [id][0]) > 1)).

.  move_to_possible
     land_properties [landscape [gx [id][0]][gy [id][0]]].walk_possible.

.  worker_handle_steps
     {exec_step;
      handle_t;
     }.

.  handle_t
     {t [id]--;
      if (t [id] == 0)
         next_step;
     }.

.  next_step
     {t [id] = step_t;
      xpop (step [id]);
     }.

.  exec_step
     {if   (step [id][0] == step_over)
           worker_step_over
      else worker_step_somewhere;
     }.

.  worker_step_somewhere
     {int dx;
      int dy;

      dir_dx_dy (step [id][0], dx, dy);
      man_step  (id, dx, dy);
     }. 

.  worker_handle_wait
     {if   (gx [id][0] == 0)
           pop_order (id);
      else gx [id][0]--;
     }. 

.  worker_step_over
     {pop_order (id);
      delay [id] = 3;
     }.

  }

void object_handler::worker_hack (int id)
  {if   (t [id] == 0)
        handle_hack_finished
   else hack_a_bit;
   
.  handle_hack_finished
     {int m = unit [gx [id][0]][gy [id][0]];

      switch (harvest_type [id])
        {case harvest_gold  : handle_minig_finished;  break;
         case harvest_wood  : handle_lumber_finished; break;
         case harvest_dig   : handle_dig_finished;    break;
         case harvest_heap  : handle_heap_finished;   break;
         case harvest_built : handle_build_finished;  break;
        };
     }.

.  handle_build_finished
     {pop_order (id);
      power [m] += (int) (25.0*players [color_player[color[id]]]->grow_speed); 
      version [m]++;
     }.

.  handle_dig_finished
     {readjust_land (gx [id][0], gy [id][0], -1);
      push_hd       (gx [id][0], gy [id][0]);
      pop_order     (id);
      pop_order     (id);
     }.

.  handle_heap_finished
     {bool over;

      readjust_land (gx [id][0], gy [id][0], 1);
      push_hd       (gx [id][0], gy [id][0]);
      over = (landscape [gx [id][0]][gy [id][0]] != land_water);
      pop_order (id);
      if (over)
         pop_order (id);
     }.

.  handle_minig_finished
     {money   [id]  += money_per_harvest;
      if (m != none)
         money [m] -= money_per_harvest;
      version [id]++;
      pop_order (id);
      refresh   (x [id], y [id]);
     }. 

.  handle_lumber_finished
     {bool anything_to_harvest;

      wood_to_harvest;
      if (anything_to_harvest)
         finish_lumber;
     }.

.  finish_lumber
     {int xx = gx [id][0];
      int yy = gy [id][0];

      wood    [id] += wood_per_harvest;
      version [id]++;
      ll--; 
      lp--;

      if (abs_diff (xx, yy) > 0)
         {landscape [xx][yy] = land_grass;
          landpic   [xx][yy] = land_grass;
          readjust_land (xx, yy, 0);
         };
      refresh   (xx, yy);
      pop_order (id);
      refresh   (x [id], y [id]);
     }. 

.  hack_a_bit
     {int m = unit [gx [id][0]][gy [id][0]];
      bool anything_to_harvest;

      check_still_anything_to_harvest;
      if   (anything_to_harvest)
           continue_harvest
      else handle_interrupted
     }.

.  handle_interrupted
     {interrupted [id] = true;
      pop_order (id);
     }.

.  check_still_anything_to_harvest
     {anything_to_harvest = false;
      switch (harvest_type [id])
        {case harvest_gold  : gold_to_harvest; break;
         case harvest_wood  : wood_to_harvest; break;
         case harvest_dig   : to_dig;          break;
         case harvest_heap  : to_heap;         break;
         case harvest_built : to_built;        break;
        };
     }.
 
.  to_built
     {anything_to_harvest = (m != none && (
                             type [m] == object_building_site ||
                             type [m] == object_site_docks)) ;
      if (! anything_to_harvest)
         version [id]++;
     }.

.  gold_to_harvest
     {anything_to_harvest = (m != none               &&
                             type [m] == object_mine &&
                             money [m] > 0);
     }.

.  wood_to_harvest
     {anything_to_harvest = pp.is_forest;
     }.

.  to_dig
     {anything_to_harvest =
         land_properties [landscape [gx [id][0]][gy [id][0]]].is_dig &&
         min_diff (gx [id][0], gy [id][0], 3);
     }.

.  to_heap
     {int u = unit [gx [id][0]][gy [id][0]];

      anything_to_harvest =
         land_properties [landscape [gx [id][0]][gy [id][0]]].is_dig &&
         max_diff (gx [id][0], gy [id][0], 3)                        &&
         (landhight [x [id]][y [id]]-landhight [gx [id][0]][gy [id][0]] < 2 ||
          landscape [gx [id][0]][gy [id][0]] == land_water) &&
         (u == none || type [u] != object_ship1);
     }.
         
.  continue_harvest
     {t [id]--;
      set_move_pic (id,
                    pic_worker_work (color [id]),
                    t [id] % 7,
                    gx [id][0] - x [id],
                    gy [id][0] - y [id]);
      refresh      (x [id], y [id]);
     }.

.  pp  land_properties [ll].
.  ll  landscape       [gx [id][0]][gy [id][0]].
.  lp  landpic         [gx [id][0]][gy [id][0]].

  }

void object_handler::worker_harvest (int id)
  {if   (any_material)
        try_to_move_home
   else try_to_get_material;

.  any_material
     (wood [id] != 0 || money [id] != 0).

.  try_to_get_material
     {if   (at_harvest_place)
           harvest
      else move_to_harvest_place;
     }.

.  harvest
     {push_order (id, cmd_hack, gx [id][0], gy [id][0]);
      delay [id] = 3;
      if   (harvest_type [id] == harvest_wood)
           t [id] = hack_t * 2;
      else if (harvest_type [id] == harvest_dig ||
               harvest_type [id] == harvest_heap)
           t [id] = hack_t / 4;
      else t [id] = hack_t;
     }.

.  at_harvest_place
     (near_by || at_mine || at_building_site) && ! interrupted [id].

.  at_mine
     (harvest_type [id] == harvest_gold &&
      uu != none                        && 
      type [uu] == object_mine).

.  at_building_site
     (harvest_type [id] == harvest_built &&
      uu != none                         && 
      (type [uu] == object_building_site || type [uu] == object_site_docks)).

.  uu  unit [x [id] + i_sign (gx [id][0] - x [id])]
            [y [id] + i_sign (gy [id][0] - y [id])].

.  near_by
     (i_abs (x [id] - gx [id][0]) <= 1 &&
      i_abs (y [id] - gy [id][0]) <= 1 &&
      (cmd [id][0] != cmd_heap ||
       landscape [gx [id][0]][gy [id][0]] == land_water ||
       landhight [x [id]][y [id]] - landhight [gx [id][0]][gy [id][0]] < 2)).

.  move_to_harvest_place
     {bool any_goal;

      select_goal;
      if   (any_goal)
           {push_order (id, cmd_move_to, gx [id][0], gy [id][0]);
            delay [id] = 3;
           }
      else {pop_order  (id);
            version [id] -= 2;
           };
     }.

.  select_goal
     {switch (harvest_type [id])
        {case harvest_gold  : look_up_goal;    break;
         case harvest_wood  : look_up_goal;    break;
         case harvest_dig   : handle_dig_goal; break;
         case harvest_heap  : handle_dig_goal; break;
         case harvest_built : handle_build;    break;
        };
     }.      

.  handle_build
     {int m = unit [gx [id][0]][gy [id][0]];

      any_goal = (m != none && 
                  (type [m] == object_building_site ||
                   type [m] == object_site_docks));
     }.
     
.  handle_dig_goal
     {any_goal = ! interrupted [id];
     }.

.  look_up_goal
     {int xg;
      int yg;

      interrupted [id] = false;
      any_goal         = false;
      look_for_goal;
      if (any_goal)
         {gx [id][0] = xg;
          gy [id][0] = yg;
         };
     }.

.  look_for_goal
     {int    xs = gx [id][0];
      int    ys = gy [id][0];
      double d  = DBL_MAX;

      for (int xx = min_x; xx < max_x; xx++)
        for (int yy = min_y; yy < max_y; yy++)
          check_field;
     }.

.  check_field
     {int u = unit [xx][yy];

      if (field_contains_material)
         grab_field;
     }. 

.  field_contains_material
     (harvest_type [id] == harvest_wood && lp.is_forest) ||
     (harvest_type [id] == harvest_gold && is_mine).

.  is_mine
     (u != none && type [u] == object_mine).

.  grab_field
     {double dd = dist (xs, ys, xx, yy);

      if (dd < d)
         grab_goal;
     }.

.  grab_goal
     {d        = dd;
      xg       = xx;
      yg       = yy;
      any_goal = true;
     }.

.  lp    land_properties [ll].
.  ll    landscape       [xx][yy].
.  min_x i_max (0, xs - harvest_dx).
.  min_y i_max (0, ys - harvest_dy).
.  max_x i_min (landscape_dx, xs + harvest_dx).
.  max_y i_min (landscape_dy, ys + harvest_dy).

.  try_to_move_home
     {if  (harvest_type [id] == harvest_wood ||
           harvest_type [id] == harvest_gold)
           perform_to_home
      else throw_away;
     }.

.  throw_away
     {money [id] = 0;
      wood  [id] = 0;
     }.

.  perform_to_home
     {int  x_home;
      int  y_home;
      bool any_home;

      search_home;
      if   (any_home)
           push_order (id, cmd_move_to, x_home + ir, y_home + ir);
      else new_order  (id, cmd_idle, 0, 0);
     }.

.  ir  i_random (0, 1).

.  search_home
     {any_home = false;
      if   (home_id [id]         != none       &&
            home_id [id]         < max_objects &&
            ! is_free [home_id [id]]           &&
            color [home_id [id]] == color [id] &&
            type  [home_id [id]] == object_home)
           {x_home   = x [home_id [id]];
            y_home   = y [home_id [id]];
            any_home = true;
           }
      else look_for_home_id;
     }.

.  look_for_home_id
     {any_home = any_object (id, object_home, color [id], home_id [id]);
      if (any_home)
         {x_home = x [home_id [id]];
          y_home = y [home_id [id]];
         };
     }.

  }

void object_handler::worker_upgrade (int id)
  {int  x_market;
   int  y_market;
   bool any_market;
   int  g_unit;
   int dx;
   int dy;

   search_market;
   if (any_market)
      g_unit = unit [x_market][y_market];
   dx     = x [id] - x_market;
   dy     = y [id] - y_market;
   if      (at_market)
           become_trader
   else if (any_market)
           push_order (id, cmd_move_to, x_market + ir, y_market + ir);
   else    new_order  (id, cmd_idle, 0, 0);

.  at_market
     (near_by                         &&
      g_unit         != none          &&
      type  [g_unit] == object_market &&
      color [g_unit] == color [id]).
      
.  near_by
     (-1 <= dx && dx <= 2 && -1 <= dy && dy <= 2).

.  become_trader
     {int pno = color_player [color [id]];

      money [id]     = 0;
      wood  [id]     = 0;
      if (players [pno]->money >= price_trader &&
          players [pno]->wood  >= wood_trader  &&
          cmd [g_unit][0] == cmd_idle)
         start_trainig;
      refresh (x [id], y [id]);
     }.

.  start_trainig 
     {readmin    (color [id], -price_trader, -wood_trader, false);
      push_order (g_unit, cmd_train_trader, 0, 0);
      players [pno]->num_mans--;
      kill_unit  (id);
     }.

.  pbonus
     players [color_player [color [id]]]->bonus.

.  ir  i_random (0, 1).

.  search_market
     {any_market = false;
      if   (home_id [id] != none               &&
            home_id [id] < max_objects         && 
            ! is_free [home_id [id]]           &&
            color [home_id [id]] == color [id] &&
            type  [home_id [id]] == object_market)
           {x_market   = x [home_id [id]];
            y_market   = y [home_id [id]];
            any_market = true;
           }
      else look_for_market_id;
     }.

.  look_for_market_id
     {any_market = any_object (id, object_market, color [id], home_id [id]);
      if (any_market)
         {x_market = x [home_id [id]];
          y_market = y [home_id [id]];
         };
     }.

  }

/*--- trader -----------------------------------------------------------*/

int object_handler::create_trader (int p_x, int p_y, int p_color, int home)
  {int id;

   check_num_mans;
   id = create_object ();
   if (id != none)
      add_trader_data;
   return id;

.  check_num_mans
     {int p = color_player [p_color];

      if (players [p]->num_mans >= max_num_mans)
         handle_to_many_mans;
     }.

.  handle_to_many_mans
     {write (p_color, "Too many mans");
      return none;
     }.

.  add_trader_data
     {add_object_data;
      add_to_land;
     }.

.  add_object_data
     {strcpy (name [id], "merchant");
      color         [id]    = p_color;
      with_overview [id]    = true;
      is_marked     [id]    = false;
      type          [id]    = object_trader;
      pic           [id]    = pic_trader_idle (p_color);
      x             [id]    = p_x;
      y             [id]    = p_y;
      wx            [id]    = x_center (p_x);
      wy            [id]    = y_center (p_y);
      dir           [id]    = 0;
      cmd           [id][0] = cmd_idle;
      t             [id]    = ticker;
      health        [id]    = 100;
      power         [id]    = 50;
      speed         [id]    = speed_trader;
      wood          [id]    = 0;
      money         [id]    = 0;
      version       [id]    = 0; 
      interrupted   [id]    = false;
      ex            [id]    = none;
      home_id       [id]    = home;
      vr            [id]    = vr_man;
      players [color_player [p_color]]->num_mans++;
      players [color_player [p_color]]->add_sun (p_x, p_y, vr [id]);
     }.

.  add_to_land
     {unit [p_x][p_y] = id;
      land_push (id, p_x, p_y, 0, 0);
      refresh   (x [id], y [id]);
     }.
  
  }

void object_handler::exec_trader (int id)
  {consume_food;
   check_health;
   exec_cmd;

.  check_health
     {if (health [id] <= 0 || on_water)
         ouhgh;
     }.

.  on_water
     (on_ship [id]==-1 && land_properties [landscape[x[id]][y[id]]].is_water). 


.  ouhgh
     {new_order (id, cmd_die, none, none);
     }.

.  exec_cmd
     {switch (cmd [id][0])
        {case cmd_move_to       : trader_handle_move_to;  break;
         case cmd_perform_steps : trader_handle_steps;    break;
         case cmd_trade         : trader_trade      (id); break;
         case cmd_exec_trade    : trader_exec_trade (id); break;
         case cmd_idle          : trader_handle_idle;     break;
         case cmd_talk          : exec_talk (id);         break;
         case cmd_stop          : trader_handle_stop;     break;
         case cmd_wait          : trader_handle_wait;     break;
        };
     }.

.  consume_food
     {double f = player_food;

      if   (player_food <= 0)
           reduce_health
      else reduce_food;
     }.

.  reduce_health
     {health  [id] = i_max (0, health [id] - 1);
      version [id]++;
     }.

.  reduce_food
     {player_food -= (double) speed_worker / (double) speed_farm;
     }.

.  player_food
     players [color_player [color [id]]]->food.

.  trader_handle_stop
     {pop_order (id);
     }.

.  trader_handle_idle
     {int p = pic [id] - pic_trader_idle (color [id]);

      if (! is_idle_pic)
         set_idle_pick;
     }.

.  is_idle_pic
     ((0 <= p && p <= 30) || money [id] != 0 || wood [id] != 0).

.  set_idle_pick
     {int dx;
      int dy;

      dir_dx_dy    (dir [id], dx, dy);
      set_move_pic (id, pic_trader_idle (color [id]), 0, dx, dy);
      refresh      (x [id], y [id]);
     }.

.  trader_handle_move_to
     {if   (no_way)
           {pop_order (id);
            delay_wait (id);
           }
      else perhaps_new_market;
     }.

.  perhaps_new_market
     {int g_unit;

      if  (gx [id][1] != none && gy [id][1] != none)
           g_unit = unit [gx [id][1]][gy [id][1]];
      else g_unit = none;
      if (at_market)
         home_id [id] = g_unit;
     }.

.  at_market
     (g_unit         != none          && 
      type  [g_unit] == object_market && 
      color [g_unit] == color [id]).

.  no_way
    ! ((move_to_possible || far_away) && man_plan_path(id, 0, false)).

.  far_away
     ((i_abs (x [id] - gx [id][0]) > 1) || (i_abs (y [id] - gy [id][0]) > 1)).

.  move_to_possible
     (land_properties [landscape [gx [id][0]][gy [id][0]]].walk_possible ||
      enter_ship).

.  enter_ship 
      (uu != none && type [uu] == object_ship1).

.  uu unit [gx [id][0]][gy [id][0]].

.  trader_handle_steps
     {exec_step;
      handle_t;
     }.

.  handle_t
     {t [id]--;
      if (t [id] == 0)
         next_step;
     }.

.  next_step
     {t [id] = step_t;
      xpop (step [id]);
     }.

.  exec_step
     {if   (step [id][0] == step_over)
           trader_step_over
      else trader_step_somewhere;
     }.

.  trader_step_somewhere
     {int dx;
      int dy;

      dir_dx_dy (step [id][0], dx, dy);
      man_step  (id, dx, dy);
     }. 

.  trader_handle_wait
     {if (landscape [x [id]][y [id]] == land_t_wood ||
          landscape [x [id]][y [id]] == land_t_gold)
         {gx [id][0] = i_min (5, gx [id][0]);
         };
      if    (gx [id][0] > 50 && near_trade_place &&
             (cmd [id][1] == cmd_trade ||
              cmd [id][2] == cmd_trade ||
              cmd [id][3] == cmd_trade))
             handle_walk_away 
     else if (gx [id][0] == 0)
             pop_order (id);
      else   gx [id][0]--;
     }. 

.  near_trade_place
     ((cmd [id][1] == cmd_move_to && 
       i_abs (gx [id][1] - x [id]) < 5 && i_abs (gy [id][1] - y [id]) < 5) ||
      (cmd [id][2] == cmd_move_to && 
       i_abs (gx [id][2] - x [id]) < 5 && i_abs (gy [id][2] - y [id]) < 5) ||
      (cmd [id][3] == cmd_move_to && 
       i_abs (gx [id][3] - x [id]) < 5 && i_abs (gy [id][3] - y [id]) < 5)).

.  handle_walk_away
     {int  ogx      = gx [id][0];
      bool any_walk = false;

      for (int xx = min_x; xx < max_x && ! any_walk; xx++)
        for (int yy = min_y; yy < max_y && ! any_walk; yy++)
          if (xx != x [id] || yy != y [id])
             try_it;
      gx [id][0] = ogx;
      if (! any_walk)
         gx [id][0]--;
     }.

.  try_it
     {int dx;
      int dy;

      gx [id][0] = xx;
      gy [id][0] = yy;
      if (direct_move (id, 0, dx, dy))
         {push_order (id, cmd_move_to, xx, yy);
          ogx        = gx [id][0];
          delay [id] = 0;
          any_walk   = true;
         };
     }.

.  min_x i_max (0, x [id] - 6).
.  min_y i_max (0, y [id] - 6).
.  max_x i_min (landscape_dx, x [id] + 7).
.  max_y i_min (landscape_dy, y [id] + 7).

.  trader_step_over
     {pop_order (id);
      delay [id] = 3;
     }.

  }

void object_handler::trader_exec_trade (int id)
  {t [id]--;
   if (t [id] == step_t / 2)
      do_trade;
   if   (t [id] <= 0)
        {wx [id] = x_center (x [id]);
         wy [id] = y_center (y [id]);
         pop_order (id);
        }
   else set_pic;

.  set_pic
     {int dx;
      int dy;

      calc_dx_dy;
      if (t [id] < step_t)
 	 {dx = -dx;
          dy = -dy;
         };
      wx [id] += dx * pic_dx / step_t;
      wy [id] += dy * pic_dy / step_t;
      if      (money [id] > 0)
              set_move_pic (id, pic_trader_gold (color [id]),
                            0, dx, dy);
      else if (wood [id] > 0)
              set_move_pic (id, pic_trader_wood (color [id]),
                            0, dx, dy);
      else    set_move_pic (id, pic_trader_move (color [id]),
                           0, dx, dy);
      refresh (x [id], y [id]);
     }.

.  calc_dx_dy
     {if (x [id] == 0              ) {dx = -1; dy = 0;};
      if (x [id] == landscape_dx -1) {dx =  1; dy = 0;};
      if (y [id] == 0              ) {dy = -1; dx = 0;};
      if (y [id] == landscape_dy -1) {dy =  1; dx = 0;};
     }.

.  do_trade
     {if  (wood [id] != 0)
          {wood  [id] = 0;
           money [id] = 300;
          }
     else {money [id] = 0;
           wood  [id] = 300;
          };
     }.

  }

void object_handler::trader_trade (int id)
  {if   (anything_to_sell)
        try_to_move_to_trade_point
   else try_to_move_to_market;

.  anything_to_sell
     ((landscape [gx [id][0]][gy [id][0]] == land_t_wood && money [id] != 0) ||
      (landscape [gx [id][0]][gy [id][0]] == land_t_gold && wood  [id] != 0)).

.  try_to_move_to_trade_point
     {if   (at_exit_place)
           exit
      else move_to_exit_place;
     }.

.  exit
     {push_order (id, cmd_exec_trade, gx [id][0], gy [id][0]);
      t [id] = step_t * 2;
     }.

.  at_exit_place
     (x [id] == gx [id][0] && y [id] == gy [id][0]).

.  move_to_exit_place
     {push_order (id, cmd_move_to, gx [id][0], gy [id][0]);
     }.

.  try_to_move_to_market
     {int  x_market;
      int  y_market;
      bool any_market;
      int  g_unit;
      int dx;
      int dy;

      search_market;
      if (any_market)
         g_unit = unit [x_market][y_market];
      dx     = x [id] - x_market;
      dy     = y [id] - y_market;
      if        (at_market)
                get_material
      else if   (any_market)
                push_order (id, cmd_move_to, x_market + ir, y_market + ir);
      else      new_order  (id, cmd_idle, 0, 0);
     }.

.  at_market
     (near_by                         &&
      g_unit         != none          &&
      type  [g_unit] == object_market &&
      color [g_unit] == color [id]).
      
.  near_by
     (-1 <= dx && dx <= 2 && -1 <= dy && dy <= 2).

.  get_material
     {int pno = color_player [color [id]];

      readmin (color [g_unit],
               (int) ((double) money [id] * pbonus),
               (int) ((double) wood  [id] * pbonus), true);
      money [id]     = 0;
      wood  [id]     = 0;
      if (landscape [gx [id][0]][gy [id][0]] == land_t_wood && 
          players [pno]->money >= 100                       &&
          money_limit [g_unit] <=  players [pno]->money)
	{money [id] = 100;
         readmin (color [id], -100, 0, true);
        }; 
      if (landscape [gx [id][0]][gy [id][0]] == land_t_gold && 
          players [pno]->wood >= 100                        &&
          wood_limit [g_unit] <=  players [pno]->wood)
	{wood [id] = 100;
         readmin (color [id], 0, -100, true);
        }; 
      refresh (x [id], y [id]);
     }.

.  pbonus
     players [color_player [color [id]]]->bonus.

.  ir  i_random (0, 1).

.  search_market
     {any_market = false;
      if   (home_id [id] >= 0                  &&
            home_id [id] < max_objects         &&
            ! is_free [home_id [id]]           &&
            color [home_id [id]] == color [id] &&
            type  [home_id [id]] == object_market)
           {x_market   = x [home_id [id]];
            y_market   = y [home_id [id]];
            any_market = true;
           }
      else look_for_market_id;
     }.

.  look_for_market_id
     {any_market = any_object (id, object_market, color [id], home_id [id]);
      if (any_market)
         {x_market = x [home_id [id]];
          y_market = y [home_id [id]];
         };
     }.

  }

/*--- man --------------------------------------------------------------*/

bool object_handler::man_plan_path (int  id,
                                    int  min_dist,
                                    bool probe)

  {return man_plan_path (id, min_dist, stack_size - 2, probe);
  }
 
bool object_handler::man_plan_path (int  id,
                                    int  min_dist,
                                    int  max_n,
                                    bool probe)

  {int u;
   int d;

   gx [id][0] = i_bound (0, gx [id][0], landscape_dx-1);
   gy [id][0] = i_bound (0, gy [id][0], landscape_dy-1);
   d = stepdist (x [id], y [id], gx [id][0], gy [id][0]);
   u = unit [gx [id][0]][gy [id][0]];
   if   (at_goal)
        path_plan_finished
   else gen_new_path;

.  at_goal
     start_dist_ok || 
     (u != none && (color[u] != color [id] || type[u] != object_ship1) &&
      type [id] != object_trader && d<2).

.  start_dist_ok
     (d <= min_dist && start_heap_possible && start_archer_shoot_ok).

.  start_archer_shoot_ok
     (type [id] != object_archer   || 
      (min_dist  <  scope_archer - 1 ||
       landhight [gx [id][0]][gy [id][0]] - landhight [x [id]][y [id]] < 3)).

.  start_heap_possible
     (cmd [id][1] != cmd_heap ||
      landscape [gx [id][0]][gy [id][0]] == land_water ||
      landhight [x [id]][y [id]] - landhight [gx [id][0]][gy [id][0]] < 2).

.  path_plan_finished
     {if (! probe)
         pop_order (id);
      return true;
     }.

.  gen_new_path
     {bool is_ship = (type [id] == object_ship1);
      bool cand_at_goal;
      int  xz;
      int  yz;

      init_field;
      expand_field;
      if   (! cand_at_goal)
           return false;
      else get_path;
     }.

.  get_path
     {int  xp           = xz;
      int  yp           = yz;
      bool another_step = true;
      int  k            = 0;

      start_grab;
      while (! steps_finished && cand_at_goal && another_step)
        {try_to_get_step;
         k++;
        };
      perhaps_start_perform_steps;
      return steps_finished;
     }.

.  start_grab
     {step [id][0] = step_over;
     }.

.  perhaps_start_perform_steps
     {if (cand_at_goal && ! probe)
         {gx [id][0] = xz;
          gy [id][0] = yz;
          push_order (id, cmd_perform_steps, 0, 0);
          t [id] = step_t;
          if (max_n < stack_size - 2)
             step [id][max_n+1] = step_over;
         };
     }.

.  steps_finished
     (k == stack_size - 2 || f [xp][yp] <= 0).

.  try_to_get_step
     {int sdx;
      int sdy;
      int p = f [xp][yp];

      another_step = false;
      check_steps;
      if (another_step)
         store_step;
     }.

.  store_step
     {if (! probe)
         xpush (dir_back (direction (sdx, sdy)), step [id]);
      xp += sdx;
      yp += sdy;
/*
players [0]->show_int (xp, yp, -f [xp][yp]);
*/
      another_step   &= (k < stack_size-2);
     }.    

.  check_steps
     {for (int dx = -1; dx <= 1; dx++)
        for (int dy = -1; dy <= 1; dy++)
          if (dx != 0 || dy != 0)
             check_step;
     }.
 
.  check_step
     {int xx = xp + dx;
      int yy = yp + dy;

      if (0 <= xx && xx < landscape_dx && 0 <= yy && yy < landscape_dy) 
         if (f [xx][yy] < p && fv [xx][yy] == pv && no_hol && f [xx][yy] >= 0)
            grab_new_p;
     }.

.  no_hol
    (travel_on_water || 
      (( ((xp-xx) == 0 ||
          (yp-yy) == 0 ||
          (uu != none && type [uu] == object_ship1)) &&
         (i_abs (landhight [xp][yp] - landhight [xx][yy])<2))||
         (i_abs (landhight [xp][yp] - landhight [xx][yy])<1))).

.  uu unit [xx][yy].

.  travel_on_water
    (land_properties [landscape [xp][yp]].is_water || 
     land_properties [landscape [xx][yy]].is_water).

.  grab_new_p
     {another_step = true;
      sdx          = dx;
      sdy          = dy;
      p            = f [xx][yy];
     }.            

.  init_field
     {pv++;
      dist_no_way = 10000;
     }.

.  expand_field
     {int  cand;
      int  cnt;

      to_start;
      while (any_cand && ! cand_at_goal)
        {prop;
         handle_cnt;
        };
      if (cand != -1 && cand_at_goal)
         {xz = cx;
          yz = cy;
         };
      if (probe)
         return cand_at_goal;
     }.

.  handle_cnt
     {int limit;

      if   (delay [id] < 10 && 
            (! players [color_player [color [id]]]->is_robot || 
             (type [id] == object_ship1)))
           limit = 2500;
      else limit = 250;
      cnt++;
      if (cnt > limit)
         cand = -1;
     }.
  
.  to_start
     {cand         = 0;
      cx           = x [id];
      cy           = y [id];
      cnt          = 0;
      cand_at_goal = false;
      set_init;
     }.

.  set_init
     {f  [x [id]][y [id]] = -1;
      fv [x [id]][y [id]] = pv;
     }. 

.  prop
     {set_pot;
      check_at_goal;
      if (! cand_at_goal)
         push_neighbors;
     }.

.  check_at_goal
     {double d = stepdist (cx, cy, gx [id][0], gy [id][0]);
      int    u = unit [gx [id][0]][gy [id][0]];
      bool   ship_at_goal;

      check_ship_at_goal;
      cand_at_goal = dist_ok || at_unit || ship_at_goal;
     }.

.  dist_ok
     (d <= min_dist && heap_possible && archer_shoot_ok).

.  archer_shoot_ok
     (type [id] != object_archer   || 
      (min_dist  <  scope_archer - 1 ||
       landhight [gx [id][0]][gy [id][0]] - landhight [cx][cy] < 3)).

.  heap_possible
     (! cmd [id][1] == cmd_heap ||
      landscape [gx [id][0]][gy [id][0]] == land_water ||
      landhight [cx][cy] - landhight [gx [id][0]][gy [id][0]] < 2).

.  check_ship_at_goal
     {int sx = gx [id][0];
      int sy = gy [id][0];

      ship_at_goal = is_ship;
      if   (sx > cx)
           ship_at_goal &= (sx - cx < 3);
      else ship_at_goal &= (sx - cx == 0);
      if   (sy > cy)
           ship_at_goal &= (sy - cy < 3);
      else ship_at_goal &= (sy - cy == 0);
     }.

.  at_unit
     (u != none && unit [cx][cy] == u &&
      (color[u] != color [id] || type[u] != object_ship1)).

.  set_pot
     {int pot = INT_MAX;

      get_pot;
      if     (fv [cx][cy] != pv)
             f [cx][cy] = INT_MAX;
      if     (pot != INT_MAX)
              f [cx][cy] = i_min (i_max (0, f [cx][cy]), pot + 1);
      else    f [cx][cy] = i_max (0, f [cx][cy]);
      fv [cx][cy] = pv;
/*
   players [0]->show_int (cx, cy, f [cx][cy]);
*/
     }.

.  get_pot
     {for (int dx = -1; dx <= 1; dx++)
        for (int dy = -1; dy <= 1; dy++)
          if (dx != 0 || dy != 0)
             get_neighbor_pot; 
     }.

.  get_neighbor_pot
     {int xx = cx + dx;
      int yy = cy + dy;

      if (0 <= xx && xx < landscape_dx && 0 <= yy && yy < landscape_dy &&
          f [xx][yy] >= 0 && fv [xx][yy] == pv && (no_hole || f [xx][yy] < 0))
          pot = i_min (pot, i_max (0, f [xx][yy]));               
     }.

.  no_hole
    (trav_on_water || 
    ((((cx-xx)==0||(cy-yy)==0 ||
      (uus != none && type [uus] == object_ship1))&&
     (i_abs(landhight[cx][cy]-landhight [xx][yy])<2))
     || (i_abs (landhight [cx][cy] - landhight [xx][yy])<1))).

.  uus unit [xx][yy].

.  trav_on_water
    (land_properties [landscape [cx][cy]].is_water || 
     land_properties [landscape [xx][yy]].is_water).

.  push_neighbors
     {int xx   = cx;
      int yy   = cy;
      int dir  = direction (i_sign (gx [id][0] - cx),
                            i_sign (gy [id][0] - cy)); 
      int idir = dir_back  (dir);

      cand--;
      man_plan_path (id, cand, xx, yy, idir,                         is_ship);
      man_plan_path (id, cand, xx, yy, dir_left  (idir),             is_ship);
      man_plan_path (id, cand, xx, yy, dir_right (idir),             is_ship);
      man_plan_path (id, cand, xx, yy, dir_left  (dir_left  (idir)), is_ship);
      man_plan_path (id, cand, xx, yy, dir_right (dir_right (idir)), is_ship);
      man_plan_path (id, cand, xx, yy, dir_left  (dir_left  (dir)),  is_ship);
      man_plan_path (id, cand, xx, yy, dir_right (dir_right (dir)),  is_ship);
      man_plan_path (id, cand, xx, yy, dir_left  (dir),              is_ship);
      man_plan_path (id, cand, xx, yy, dir_right (dir),              is_ship);
      man_plan_path (id, cand, xx, yy, dir,                          is_ship);
     }.

.  any_cand   (cand >= 0).
.  cx         px [cand].
.  cy         py [cand].

  }

void object_handler::man_plan_path (int  id,
                                    int  &cand,
                                    int  x,
                                    int  y,
                                    int  dir,
                                    bool is_ship)

  {int xx;
   int yy;
   int dx;
   int dy;

   get_xx_yy;
   if (within_field)
      handle_step;

.  handle_step
     {int ff; 
      int ll;
      int uu;

      if (fv [xx][yy] != pv)
         {f  [xx][yy] = INT_MAX;
          fv [xx][yy] = pv;
         };
      ff = f         [xx][yy];
      ll = landscape [xx][yy];
      uu = unit      [xx][yy];
      check_step;
     }.

.  check_step
     {if   (step_possible)
           push_new_cand
      else get_reason;
     }.

.  step_possible
     (ff == -1 || ((ff == INT_MAX || ff == -2) &&
      no_trap                                  &&
      walk_is_possible                         &&
      no_unit                                  &&
      (no_hole || ff == -2))).
      
.  get_reason
     {if ((ll == land_wall  ||
           ll == land_water ||
           ll == land_sea   ||
           uu != id) &&
         stepdist (xx, yy, gx [id][0], gy [id][0]) < dist_no_way)
         grab_a_new_reason;
     }.

.  grab_a_new_reason
     {dist_no_way = stepdist (xx, yy, gx [id][0], gy [id][0]);
      x_no_way    = xx;
      y_no_way    = yy;
     }.

.  get_xx_yy
     {dir_dx_dy (dir, dx, dy);
      xx = x + dx;
      yy = y + dy;
     }.

.  within_field
     (0 <= xx && xx <= landscape_dx && 0 <= yy && yy <= landscape_dy).

.  walk_is_possible
     ((! is_ship && land_properties [ll].walk_possible)                   || 
      (is_ship   && is_water (id, xx, yy,unit [gx [id][0]][gy [id][0]]))  ||
      (uu != none && uu == unit [gx [id][0]][gy [id][0]])                 ||
      enter_or_leave_a_ship).

.  no_trap
     ! (ll == land_trap && is_a_trap [xx][yy] &&
        players [color_player [color [id]]]->is_robot).

.  no_hole
    (travel_on_water || travel_from_or_to_ship || anyway_possible).

.  anyway_possible
     (i_abs (landhight [xx][yy] - landhight [x][y])<1 || 
      ((dx==0 || dy==0) && i_abs (landhight [xx][yy] - landhight [x][y])<2)).

.  travel_from_or_to_ship
     (((uu != none && type [uu] == object_ship1) ||
       (unit [x][y] != none && type [unit [x][y]] == object_ship1)) && 
      i_abs (landhight [xx][yy] - landhight [x][y])<2).

.  travel_on_water
    (land_properties [ll].is_water &&
     land_properties [landscape [x][y]].is_water).

.  no_unit
     (uu == none                                          || 
      uu == id                                            ||
      (uu != none && uu == unit [gx [id][0]][gy [id][0]]) ||
      enter_or_leave_a_ship                               ||
      (is_moving (uu) && color [uu] == color [id])).

.  enter_or_leave_a_ship
     (uu         != none && 
      uu         != id   &&
      ! is_ship          &&
      type  [uu] == object_ship1).

.  push_new_cand
     {cand++;
      px [cand] = xx;
      py [cand] = yy;
     }.

  }

void object_handler::man_step (int id, int dx, int dy)
  {int xx = x [id] + dx;
   int yy = y [id] + dy;

   if (t [id] == step_t) start_move;
   if (t [id] == 1)      finished_move;
   wx [id]  += pic_dx / step_t * dx;
   wy [id]  += pic_dy / step_t * dy;
   set_pic;
   refresh (x [id], y [id], -dx, -dy);

.  set_pic
     {switch (type [id])
        {case object_worker : set_worker_pic; break;
         case object_trader : set_trader_pic; break;
         case object_knight : set_move_pic (id,
                                            pic_knight_move (color [id]), 
                                            step_t - t [id], dx, dy); break;
         case object_pawn   : set_move_pic (id,
                                            pic_pawn_move(color [id]), 
                                            step_t - t [id], dx, dy); break;
         case object_scout  : set_move_pic (id,
                                            pic_scout_move(color [id]), 
                                            step_t - t [id], dx, dy); break;
         case object_archer : set_move_pic (id,
                                            pic_archer_move(color [id]), 
                                            step_t - t [id], dx, dy); break;
         case object_doktor : set_move_pic (id,
                                            pic_doktor_move(color [id]), 
                                            step_t - t [id], dx, dy); break;
         case object_cata   : set_move_pic (id,
                                            pic_cata_move(color [id]), 
                                            0, dx, dy); break;
        };
     }.
  
.  set_worker_pic
     {if      (money [id] > 0)
              set_move_pic (id, pic_worker_sack (color [id]),
                            step_t - t [id], dx, dy);
      else if (wood [id] > 0)
              set_move_pic (id, pic_worker_wood (color [id]),
                            step_t - t [id], dx, dy);
      else    set_move_pic (id, pic_worker_move (color [id]),
                           step_t - t [id], dx, dy);
     }.
 
.  set_trader_pic
     {if      (money [id] > 0)
              set_move_pic (id, pic_trader_gold (color [id]),
                            i_max (0, step_t - t [id] -1), dx, dy);
      else if (wood [id] > 0)
              set_move_pic (id, pic_trader_wood (color [id]),
                            i_max (0, step_t - t [id] -1), dx, dy);
      else    set_move_pic (id, pic_trader_move (color [id]),
                            i_max (0, step_t - t [id] -1), dx, dy);
     }.
 
.  start_move
     {int g_unit = none;

      wx [id] = x_center (x [id]);
      wy [id] = y_center (y [id]);
      if   (within_field)
           handle_start
      else over;
     }.

.  handle_start
     {int g_unit = unit [xx][yy];

      if      (goal_field_ship) perform_enter
      else if (leave_ship)      perform_leave
      else if (goal_field_free) perform_start
      else                      homing_or_over;
     }.

.  leave_ship
     (on_ship [id] != -1 && goal_field_free).

.  goal_field_ship
     (g_unit              != none                                &&
      type  [g_unit]      == object_ship1                        &&
      (color [g_unit] == color [id] || s [g_unit]->empty ())     &&
      s [g_unit]->num_man < s [g_unit]->capa || g_unit==unit [x [id]][y [id]]).

.  perform_enter
     {dir [id]      =  direction (dx, dy);
      if (on_ship [id] == -1)
         s_unit = none;
      if (on_ship [id] == -1)
         players [color_player [color [id]]]->sub_sun (x [id],y [id],vr [id]);
      x   [id]  += dx;
      y   [id]  += dy;
      buf [id]  =  speed [id];
      if (on_ship [id] != -1 && on_ship [id] != g_unit)
         s [on_ship [id]]->leave (id);
      if (on_ship [id] != g_unit)  
         {s [g_unit]->enter (id);
          on_ship [id]  =  g_unit;
          perhaps_change_owner;
         };
     }.

.  perhaps_change_owner
     {if (color [g_unit] != color [id])
         {iplayer->num_mans++;
          gplayer->num_mans--;
          gplayer->sub_sun (x [g_unit], y [g_unit], vr [g_unit]);
          color [g_unit] = color [id];
          iplayer->add_sun (x [g_unit], y [g_unit], vr [g_unit]);
          is_marked [g_unit] = false;
          s [g_unit]->is_shown = false;
          version   [g_unit]++;
         };
     }.

.  gplayer players [color_player [color [g_unit]]].
.  iplayer players [color_player [color [id]]].

.  perform_leave
     {int dh = landhight [x [id]+dx][y [id]+dy] - landhight [x [id]][y [id]];
 
      land_push (id, xx, yy);
      dir [id]      =  direction (dx, dy);
      unit [xx][yy] =  id;
      x   [id]  += dx;
      y   [id]  += dy;
      players [color_player [color [id]]]->add_sun (x [id],y [id],vr [id]);
      buf [id]  =  speed [id];
      speed [id] = 1;
      s [on_ship [id]]->leave (id);
      on_ship [id]  =  -1;
     }.

.  perform_start
     {int dh = landhight [x [id]+dx][y [id]+dy] - landhight [x [id]][y [id]];

      land_push (id, x [id], y [id], dx, dy);
      dir [id]      =  direction (dx, dy);
      s_unit        =  none;
      unit [xx][yy] =  id;
      players [color_player [color [id]]]->move_sun (x [id],
                                                     y [id],
                                                     dx,
                                                     dy,
                                                     vr [id]);
      x [id]        += dx;
      y [id]        += dy;
      buf [id]      =  speed [id];
      if (dh > 0) speed [id] = (int) ((double) speed [id] * 3);
      if (dh < 0) speed [id] = i_max (1, (int) ((double) speed [id] / 2));
      if (on_ship [id] !=  -1)
         speed [id] = 1;
     }.

.  finished_move
     {land_pop (id, x [id], y [id], -dx, -dy);
      delay [id] = 3;
      speed [id] = buf [id];
      if (landscape [x [id]][y [id]] == land_trap)
         {create_trap (x [id], y [id]);
          new_order (id, cmd_idle, 0, 0);
         };
     }.

.  homing_or_over
     {if (at_home)
         perform_homing;
      over;
     }.

.  perform_homing
     {money [g_unit] += money [id];
      wood  [g_unit] += wood  [id];
      readmin (color [g_unit],
               (int) ((double) money [id] * pbonus),
               (int) ((double) wood  [id] * pbonus), true);
      money [id]     = 0;
      wood  [id]     = 0;
      home_id [id]   = g_unit;
      version [id]++;
      version [g_unit]++;
     }.

.  pbonus
     players [color_player [color [id]]]->bonus.

.  over
     {pop_order  (id);
      if      ((is_sad && ! out_of_range) || 
               (players [color_player [color [id]]]->is_robot && 
                on_ship [id] == -1))
              pop_order (id);
      else if (! at_home && (on_ship [id] == -1 || g_unit == none))
              delay_wait (id);
      return;
     }.

.  is_sad
      (g_unit != none &&
       color [g_unit] != color [id] &&
       (type [id] == object_knight || type [id] == object_pawn) &&    
       (cmd [id][1]==cmd_sad || cmd [id][2]==cmd_sad ||
        cmd [id][1]==cmd_fad || cmd [id][2]==cmd_fad)).

.  out_of_range
     (gx [id][0] < attack_x_min [id] || gx [id][0] > attack_x_max [id] ||
      gy [id][0] < attack_y_min [id] || gy [id][0] > attack_y_max [id]).

.  goal_field_free
     (g_unit == none && act_prop.walk_possible && no_hole).

.  within_field
     (0 <= xx && xx < landscape_dx && 0 <= yy && yy < landscape_dy).

.  no_hole
     (i_abs (landhight [x [id]][y [id]] - landhight [xx][yy]) < 2).

.  at_home
     (g_unit         != none       && 
      color [g_unit] == color [id] &&
      (type [id] == object_worker && type  [g_unit] == object_home)).

.  s_unit         unit            [x [id]][y [id]].
.  act_prop       land_properties [act_landscape].
.  act_landscape  landscape       [xx][yy].

  }

/*--- ship ------------------------------------------------------------*/

void object_handler::ship_step (int id, int dx, int dy)
  {int xx = x [id] + dx;
   int yy = y [id] + dy;

   if (t [id] == step_t) start_move;
   if (t [id] == 1)      finished_move;
   wx [id]  += pic_dx / step_t * dx;
   wy [id]  += pic_dy / step_t * dy;
   set_pic;
   perform_refresh;

.  perform_refresh
     {refresh (i_min (x [id], x [id] - dx),
               i_min (y [id], y [id] - dy), 1, 1, 4, 4);
     }.

.  set_pic
     {if   (support [id] == 0)
           set_ship_pic (id,
                         pic_ship2_move (color [id]), 
                         i_max (0, (step_t-t [id]-1) % 2), dx, dy);
      else set_ship_pic (id,
                         pic_ship_move (color [id]), 
                         i_max (0, step_t-t [id]-1), dx, dy);
     }.
 
.  start_move
     {int g_unit = none;

      if   (within_field)
           handle_start
      else over;
     }.

.  within_field
     (0 <= xx && xx < landscape_dx-1 && 0 <= yy && yy < landscape_dy-1).

.  handle_start
     {bool goal_field_free;

      check_goal_field_free;
      if   (goal_field_free)
           perform_start
      else over;
     }.

.  check_goal_field_free
     {goal_field_free = true;
      for (int sx = xx; sx < xx + 3 && goal_field_free; sx++)
        for (int sy = yy; sy < yy + 3 && goal_field_free; sy++)
          if (sx < landscape_dx && sy < landscape_dy &&
              ! on_water || (unit [sx][sy] != none &&
              unit [sx][sy] != id))
             goal_field_free = false;
     }.

.  on_water
     land_properties [landscape [sx][sy]].is_water.

.  perform_start
     {land_push (id, i_min (xx, x [id]), i_min (yy, y [id]), 1, 1, 4, 4);
      dir [id]      =  direction (dx, dy);
      clear_s_unit;
      set_d_unit;
      players [color_player [color [id]]]->move_sun (x [id],
                                                     y [id],
                                                     dx,
                                                     dy,
                                                     vr [id]);
      x [id] += dx;
      y [id] += dy;
      s [id]->move (dx, dy);
     }.

.  clear_s_unit
     {for (int sx = x [id]; sx < x [id] + 3; sx++)
        for (int sy = y [id]; sy < y [id] + 3; sy++)
          if (sx < landscape_dx && sy < landscape_dy)
             unit [sx][sy] = none;
     }.

.  set_d_unit
     {for (int sx = xx; sx < xx + 3; sx++)
        for (int sy = yy; sy < yy + 3; sy++)
          if (sx < landscape_dx && sy < landscape_dy)
             unit [sx][sy] = id;
     }.
 
.  finished_move
     {land_pop  (id,i_min (x [id],x [id]-dx),i_min (y [id],y [id]-dy),1,1,4,4);
      land_push (id, x [id], y [id], 1, 1, 3, 3);
      delay [id] = 3;
     }.

.  over
     {pop_order  (id);
      if   (players [color_player [color [id]]]->is_robot)
           players [color_player [color [id]]]->rob->urgent = id;
      else delay_wait (id);
      return;
     }.

  }

/*--- unit -------------------------------------------------------------*/

void object_handler::kill_unit (int id)
  {land_pop      (id, x [id], y [id]);
   unit [x [id]][y [id]] = none;
   refresh       (x [id], y [id]);
   delete_object (id);
  }

/*--- water ------------------------------------------------------------*/

int object_handler::create_water (int p_x, int p_y)
  {int id = create_object ();

   if (id != none)
      add_water_data;
   return id;

.  add_water_data
     {x     [id] = p_x;
      y     [id] = p_y;
      type  [id] = object_water;
      speed [id] = 1;
      t     [id] = speed_water;
     }.

  }

void object_handler::exec_water (int id)
  {if   (t [id] == speed_water)
        set_water
   else if (t [id] <= 0)
        handle_over;
   t [id] --;

.  handle_over
     {check_neighbors;
      delete_object (id);
     }.

.  set_water
     {if (landscape [x [id]][y [id]] != land_water &&
          landscape [x [id]][y [id]] != land_sea)
         perform_water;
      kill_units;
     }.

.  perform_water
     {set_to_water;
     }.

.  set_to_water
     {landscape   [x [id]][y [id]]    = land_water;
      landpic     [x [id]][y [id]]    = land_water;
      landoverlay [x [id]][y [id]][0] = none;
      landoverlay [x [id]][y [id]][1] = none;
      refresh (x [id], y [id]);
     }.

.  kill_units
     {int u = unit [x [id]][y [id]];
 
      if (u != none)
         create_swim (u);
     }.

.  check_neighbors
     {for (int xx = xmin; xx < xmax; xx++)
        for (int yy = ymin; yy < ymax; yy++)
          check_neighbor;
     }.

.  check_neighbor
     {if (landscape [xx][yy] != land_water && landhight [xx][yy] <= 0)
         create_water (xx, yy);
     }.

.  xmin  i_max (x [id] - 1, 0).
.  xmax  i_min (x [id] + 2, landscape_dx).
.  ymin  i_max (y [id] - 1, 0).
.  ymax  i_min (y [id] + 2, landscape_dy).
  
  }

/*--- zombi ------------------------------------------------------------*/


int object_handler::create_ship_zombi (int id)
  {type      [id]    = object_ship_zombi;
   t         [id]    = 5;
   speed     [id]    = speed_ship_zombi;
   is_marked [id]    = false;
   version   [id]++; 
   cmd       [id][0] = cmd_idle;
   age       [id]    = 0;
   oid       [id]    = 0;
   refresh (x [id], y [id], 1, 1, 4, 4);
  }


void object_handler::exec_ship_zombi (int id)
  {t [id]--;
   if   (over)
        remove_zombi
   else new_pic;

.  over
     t [id] <= 0.

.  new_pic
     {int dx;
      int dy;

      dir_dx_dy    (dir [id], dx, dy);
      set_ship_pic (id, pic_ship_zombi (color [id]), 
                        i_bound (0, 4 - t [id], 4), dx, dy);
      refresh (x [id], y [id], 1, 1, 4, 4);
     }.

.  remove_zombi
     {for (int xx = x [id]; xx < x [id] + 4; xx++)
        for (int yy = y [id]; yy < y [id] + 4; yy++)
          unit [xx][yy] = none;
      land_pop      (id, x [id], y [id], 1, 1, 4, 4);
      refresh       (x [id], y [id], 1, 1, 4, 4);
      players [color_player [color [id]]]->num_mans--;
      players [color_player [color [id]]]->sub_sun (x [id], y [id], vr [id]);
      for (int i = 0; i < s [id]->num_man; i++)
        send_a_man_swim;
      delete        (s [id]);
      delete_object (id);
     }.

.  send_a_man_swim
     {int mid =  s [id]->unit [i];

      on_ship [mid] = -1;
      x       [mid] = x [id] + (i % 3);
      y       [mid] = y [id] + (i / 3);
      wx      [mid] = x_center (x [mid]);
      wy      [mid] = y_center (y [mid]);
      players [color_player [color [id]]]->add_sun (x [mid],y [mid],vr [mid]);
     }.

  }      

int object_handler::create_zombi (int id)
  {remove_from_ship;
   if   (on_water)
        create_swim (id);
   else normal_zombi;

.  remove_from_ship
     {int ss = on_ship [id];

      if (ss != -1 && type [ss] == object_ship1)
         s [ss]->leave (id);
     }.
          
.  on_water
     (on_ship [id]==-1 && land_properties [landscape[x[id]][y[id]]].is_water). 

.  normal_zombi
     {handle_support;
      set_to_zombi;
     }.

.  set_to_zombi
     {type      [id]             = object_zombi;
      if (on_ship [id] == -1)
         unit [x [id]][y [id]] = none;
      t         [id]             = 5;
      speed     [id]             = speed_zombi;
      is_marked [id]             = false;
      version   [id]++;
      cmd       [id][0]          = cmd_idle;
      age       [id]             = 0;
      oid       [id]             = 0;
      players [color_player [color [id]]]->num_mans--;
      land_pop (id, x [id], y [id],  1,  1);
      land_pop (id, x [id], y [id], -1, -1);
      if   (on_ship [id] != -1)
           delete_object (id); 
      else players [color_player [color [id]]]->sub_sun (x [id],y [id],vr[id]);
     }.

.  handle_support
     {switch (type [id])
        {case object_knight : handle_knight; break;
         case object_archer : handle_archer; break;
         case object_doktor : handle_doktor; break;
         case object_cata   : handle_cata;   break;
         case object_worker : handle_worker; break;
         case object_trader : handle_trader; break;
         case object_scout  : handle_scout;  break;
        };
     }.

.  handle_scout
     {int hm = home_id [id];

      if (hm != none               && 
          hm < max_objects         &&
          ! is_free [hm]           &&
          color [hm] == color [id] &&
          type [hm] == object_tents)
         {support [hm] = i_min (max_scouts_per_tents, support [hm] + 1);
          version [hm]++; 
         };
     }.

.  handle_trader
     {int hm = home_id [id];

      if (hm != none               && 
          hm < max_objects         &&
          ! is_free [hm]           &&
          color [hm] == color [id] &&
          type [hm] == object_market)
         {support [hm] = i_min (max_traders_per_market, support [hm] + 1);
          version [hm]++; 
         };
     }.

.  handle_knight
     {int hm = home_id [id];

      if (hm != none               && 
          hm < max_objects         &&
          ! is_free [hm]           &&
          color [hm] == color [id] &&
          type [hm] == object_camp)
         {support [hm] = i_min (max_knights_per_camp, support [hm] + 1);
          version [hm]++; 
         };
      if (master [id])
         players [color_player [color [id]]]->master_dead = true;
     }.

.  handle_archer
     {int hm = home_id [id];

      if (hm != none               && 
          hm <  max_objects        &&
          ! is_free [hm]           &&
          color [hm] == color [id] &&
          type [hm] == object_mill)
         {support [hm] = i_min (max_archers_per_mill, support [hm] + 1);
          version [hm]++; 
         };
     }.

.  handle_doktor
     {int hm = home_id [id];

      if (hm != none               && 
          hm < max_objects         &&
          ! is_free [hm]           &&
          color [hm] == color [id] &&
          type [hm] == object_uni)
         {support [hm] = i_min (max_doktors_per_uni, support [hm] + 1);
          version [hm]++; 
         };
      if (master [id])
         players [color_player [color [id]]]->master_dead = true;
     }.

.  handle_cata
     {int hm = home_id [id];

      if (hm != none               && 
          hm < max_objects         &&
          ! is_free [hm]           &&
          color [hm] == color [id] &&
          type [hm] == object_smith)
         {support [hm] = i_min (max_catas_per_smith, support [hm] + 1);
          version [hm]++; 
         };
     }.

.  handle_worker
     {
     }.

  } 

void object_handler::exec_zombi (int id)
  {t [id]--;
   if   (over)
        remove_zombi
   else new_pic;

.  over
     t [id] <= 0.

.  new_pic
     {int dx;
      int dy;

      dir_dx_dy    (dir [id], dx, dy);
      if (on_ship [id] == -1)
         set_move_pic (id, pic_zombi (color [id]), 
                       i_bound (0, 4 - t [id], 4), dx, dy);
      refresh      (x [id], y [id]);
      speed [id] = i_min (500, speed [id] * 10);
     }.

.  remove_zombi
     {land_pop      (id, x [id], y [id]);
      refresh       (x [id], y [id]);
      delete_object (id);
     }.

  }      

/*--- zombi ------------------------------------------------------------*/

int object_handler::create_schrott (int id)
  {remove_from_ship;
   if   (on_water)
        create_swim (id);
   else normal_zombi;

.  remove_from_ship
     {int ss = on_ship [id];

      if (ss != -1 && type [ss] == object_ship1)
         s [ss]->leave (id);
     }.

.  on_water
     (on_ship [id]==-1 && land_properties [landscape[x[id]][y[id]]].is_water). 

.  normal_zombi
     {handle_support;
      set_to_schrott;
     }.

.  set_to_schrott
     {type      [id]             = object_schrott;
      if (on_ship [id] == -1)
         unit [x [id]][y [id]] = none;
      power     [id]             = 5;
      speed     [id]             = speed_schrott;
      is_marked [id]             = false;
      version   [id]++;
      cmd       [id][0]          = cmd_idle;
      oid       [id]             = 0;
      players [color_player [color [id]]]->num_mans--;
      land_pop (id, x[id], y [id],  1,  1);
      land_pop (id, x[id], y [id], -1, -1);
      if   (on_ship [id] != -1)
           delete_object (id); 
      else players [color_player [color [id]]]->sub_sun (x [id],y[id],vr [id]);
     }.

.  handle_support
     {int hm = home_id [id];

      if (hm != none               && 
          hm < max_objects         &&
          ! is_free [hm]           &&
          color [hm] == color [id] &&
          type [hm] == object_smith)
         {support [hm] = i_min (max_catas_per_smith, support [hm] + 1);
          version [hm]++; 
         };
     }.

  } 

void object_handler::exec_schrott (int id)
  {power [id]--;
   if   (over)
        remove_schrott
   else new_pic;

.  over
     power [id] == 0.

.  new_pic
     {int dx;
      int dy;

      dir_dx_dy    (dir [id], dx, dy);
      pic [id]   = i_bound (pic_schrott ,
                            pic_schrott + (4 - power [id]),
                            pic_schrott + 3);
      refresh      (x [id], y [id]);
      speed [id] = i_min (500, speed [id] * 10);
     }.

.  remove_schrott
     {land_pop      (id, x [id], y [id]);
      refresh       (x [id], y [id]);
      delete_object (id);
     }.

  }      

/*--- explosion --------------------------------------------------------*/

int object_handler::create_explosion (int xp, int yp)
  {int id = create_object ();

   if (id != none)
      add_data;
   return id;

.  add_data
     {type      [id] = object_explosion;
      power     [id] = 7;
      speed     [id] = speed_explosion;
      is_marked [id] = false;
      x         [id] = xp;
      y         [id] = yp;
      wx        [id] = x_center (xp);
      wy        [id] = x_center (yp);
      pic       [id] = pic_building_zombi;
      land_push (id, x [id], y [id]);
     }.

  } 

void object_handler::exec_explosion (int id)
  {power [id]--;
   if   (over)
        remove_zombi
   else new_pic;

.  over
     power [id] <= 0.

.  new_pic
     {pic [id] = i_bound (pic_building_zombi, 
                          pic_building_zombi + i_max (0, 6 - power [id]),
                          pic_building_zombi + 5);
      refresh (x [id], y [id]);
     }.

.  remove_zombi
     {land_pop      (id, x [id], y [id]);
      refresh       (x [id], y [id]);
      delete_object (id);
     }.

  }      

/*--- building zombi --------------------------------------------------*/

int object_handler::create_building_zombi (int id)
  {if (type [id] != object_building_site &&
       type [id] != object_site_docks)
      players [color_player [color [id]]]->sub_sun (x [id], y [id], vr [id]);
   destroy_building (id);

   dir     [id] = type [id];
   type    [id] = object_building_zombi;
   t       [id] = 7;
   speed   [id] = speed_building_zombi;
   wx      [id] = x_center (x [id]);
   wy      [id] = y_center (y [id]);
   pic     [id] = pic_building_zombi;
   oid     [id] = 0;
   set_to_field;
   version [id]++;
   any_building_event = true;

.  set_to_field
     {int bdx;
      int bdy;
 
      calc_bdx_dy
      for (int xx = x [id]; xx < x [id] + bdx; xx++)
        for (int yy = y [id]; yy < y [id] + bdy; yy++)
          land_push (id, xx, yy);
     }.

.  calc_bdx_dy
      {if     (dir [id] == object_mine)
              {bdx = 1;
               bdy = 1;
              }
      else if (dir [id] == object_site_docks || dir [id] == object_docks)
              {bdx = 3;
               bdy = 3;
              }
      else    {bdx = 2;
               bdy = 2;
              };
     }.

  } 

void object_handler::exec_building_zombi (int id)
  {int bdx;
   int bdy;

   calc_bdx_dy;
   t [id]--;
   if   (over)
        remove_building_zombi
   else new_pic;

.  over
     t [id] == 0.

.  new_pic
     {pic [id] = pic_building_zombi + 6 - t [id];
      for (int xx = x [id]; xx < x [id] + bdx; xx++)
        for (int yy = y [id]; yy < y [id] + bdy; yy++)
          {wx [id] = x_center (xx);
           wy [id] = y_center (yy);
           refresh (xx, yy);
          };
     }.

.  remove_building_zombi
     {for (int xx = x [id]; xx < x [id] + bdx; xx++)
        for (int yy = y [id]; yy < y [id] + bdy; yy++)
          {land_pop (id, xx, yy);
           refresh  (xx, yy);
          };
      delete_object (id);
      if (ex [id] != none && unit [x [id]][y [id]] == none)
         {create_building (x [id],y [id], object_mine, 1000, 0, none);
          refresh         (x [id], y [id]);
         };
     }.


.  calc_bdx_dy
      {if     (dir [id] == object_mine)
              {bdx = 1;
               bdy = 1;
              }
      else if (dir [id] == object_site_docks || dir [id] == object_docks)
              {bdx = 3;
               bdy = 3;
              }
      else    {bdx = 2;
               bdy = 2;
              };
     }.

  }      

/*--- swim ------------------------------------------------------------*/

int object_handler::create_swim (int id)
  {if   (is_building (type [id]))
        remove_building
   else start_swim;

.  start_swim
     {handle_support;
      type  [id]             = object_swim;
      unit  [x [id]][y [id]] = none;
      t     [id]             = 30;
      speed [id]             = speed_swim;
      oid   [id]             = 0;
      cmd   [id][0]          = cmd_idle;
      players [color_player [color [id]]]->sub_sun (x [id], y [id], vr [id]);
      players [color_player [color [id]]]->num_mans--;
      land_push (id, x [id], y [id]);   
     }.

.  handle_support
     {switch (type [id])
        {case object_knight : handle_knight; break;
         case object_archer : handle_archer; break;
         case object_doktor : handle_doktor; break;
         case object_cata   : handle_cata;   break;
        };
     }.

.  handle_knight
     {int hm = home_id [id];

      if (hm != none               && 
          hm < max_objects         &&
          ! is_free [hm]           &&
          color [hm] == color [id] &&
          type [hm] == object_camp)
         {support [hm] = i_min (max_knights_per_camp, support [hm] + 1);
          version [hm]++; 
         };
      if (master [id])
         players [color_player [color [id]]]->master_dead = true;
     }.

.  handle_archer
     {int hm = home_id [id];

      if (hm != none               && 
          hm < max_objects         &&
          ! is_free [hm]           &&
          color [hm] == color [id] &&
          type [hm] == object_mill)
         {support [hm] = i_min (max_archers_per_mill, support [hm] + 1);
          version [hm]++; 
         };
     }.

.  handle_doktor
     {int hm = home_id [id];

      if (hm != none               && 
          hm < max_objects         &&
          ! is_free [hm]           &&
          color [hm] == color [id] &&
          type [hm] == object_uni)
         {support [hm] = i_min (max_doktors_per_uni, support [hm] + 1);
          version [hm]++; 
         };
      if (master [id])
         players [color_player [color [id]]]->master_dead = true;
     }.

.  handle_cata
     {int hm = home_id [id];

      if (hm != none               && 
          hm < max_objects         &&
          ! is_free [hm]           &&
          color [hm] == color [id] &&
          type [hm] == object_smith)
         {support [hm] = i_min (max_catas_per_smith, support [hm] + 1);
          version [hm]++; 
         };
     }.

.  remove_building
     {destroy_building (id);
      delete_object    (id);
     }.

  } 

void object_handler::exec_swim (int id)
  {t [id]--;
   if   (over)
        remove_swim
   else new_pic;

.  over
     t [id] == 0.

.  new_pic
     {int dx;
      int dy;

      dir_dx_dy    (dir [id], dx, dy);
      set_move_pic (id, pic_swim (color [id]), t [id] % 4, dx, dy);
      refresh      (x [id], y [id]);
     }.

.  remove_swim
     {land_pop      (id, x [id], y [id]);
      refresh       (x [id], y [id]);
      delete_object (id);
     }.

  }      

/*--- pawn   -----------------------------------------------------------*/

int object_handler::create_pawn (int p_x, int p_y, int p_color)
  {int id;

   check_num_mans;
   id = create_object ();
   if (id != none)
      add_pawn_data;
   return id;

.  check_num_mans
     {int p = color_player [p_color];

      if (players [p]->num_mans >= max_num_mans)
         handle_to_many_mans;
     }.

.  handle_to_many_mans
     {write (p_color , "Too many mans");
      return none;
     }.

.  add_pawn_data
     {add_object_data;
      add_to_land;
     }.

.  add_object_data
     {strcpy (name [id], "pawn");
      color         [id]    = p_color;
      with_overview [id]    = true;
      is_marked     [id]    = false;
      type          [id]    = object_pawn;
      pic           [id]    = pic_pawn_idle (color [id]);
      x             [id]    = p_x;
      y             [id]    = p_y;
      wx            [id]    = x_center (p_x);
      wy            [id]    = y_center (p_y);
      dir           [id]    = 0;
      cmd           [id][0] = cmd_idle;
      t             [id]    = ticker;
      health        [id]    = 100;
      power         [id]    = 50;
      speed         [id]    = speed_pawn;
      wood          [id]    = 0;
      money         [id]    = 0;
      version       [id]    = 0;
      idle_attack_r [id]    = 1;
      interrupted   [id]    = false;
      vr            [id]    = vr_man;
      players [color_player [p_color]]->num_mans++;
      players [color_player [p_color]]->add_sun (p_x, p_y, vr [id]);
     }.

.  add_to_land
     {unit [p_x][p_y] = id;
      land_push (id, p_x, p_y, 0, 0);
      refresh   (x [id], y [id]);
     }.
  
  }

void object_handler::exec_pawn (int id)
  {consume_food;
   check_health;
   exec_cmd;

.  check_health
     {if (health [id] <= 0 || on_water)
         ouhgh;
     }.

.  on_water
     (on_ship [id]==-1 && land_properties [landscape[x[id]][y[id]]].is_water). 


.  ouhgh
     {new_order (id, cmd_die, none, none);
     }.
        
.  exec_cmd
     {switch (cmd [id][0])
        {case cmd_move_to       : pawn_handle_move_to;          break;
         case cmd_perform_steps : pawn_handle_steps;            break;
         case cmd_fad           : fighter_sad      (id, true);  break;
         case cmd_sad           : fighter_sad      (id, false); break;
         case cmd_attack        : fighter_attack   (id);        break;
         case cmd_hit           : exec_fighter_hit (id);        break;
         case cmd_guard         : 
         case cmd_idle          : pawn_handle_idle;             break;
         case cmd_talk          : exec_talk        (id);        break;
         case cmd_upgrade       : pawn_upgrade     (id);        break;
         case cmd_stop          : pawn_handle_stop;             break;
         case cmd_wait          : pawn_handle_wait;             break;
        };
     }.
   
.  consume_food
     {double f = player_food;

      if   (player_food <= 0)
           reduce_health
      else reduce_food;
     }.

.  reduce_health
     {health  [id] = i_max (0, health [id] - 1);
      version [id]++;
     }.

.  reduce_food
     {player_food -= (double) speed_pawn / (double) speed_farm;
     }.

.  player_food
     players [color_player [color [id]]]->food.

.  pawn_handle_stop
     {pop_order (id);
     }.

.  pawn_handle_idle
     {int p = pic [id] - pic_pawn_idle (color [id]);

      if   (! is_idle_pic)
           set_idle_pick;
      grab_new_enemy;
     }.

.  grab_new_enemy           
     {if   (cmd [id][0] == cmd_guard)
           handle_guard_pic;
      if   (ex [id] != none)
           perhaps_attack
      else look_for_enemy;
      ex [id] = none;
     }.

.  look_for_enemy
     {bool over = false;

      for (int h = 0; h < max_objects/look_n && ! over; h++)
        try_look;
     }.

.  try_look
     {int e;

      t [id]++;
      if (t [id] < 0 || t [id] >= max_objects)
         t [id] = 0;
      e = t [id];
      if (any_enemy)
         grab_enemy;
     }.

.  any_enemy
     (! is_free [e]                  && 
      color [e] != color [id]        && 
      type  [e] != object_mine       &&
      type  [e] != object_zombi      && 
      type  [e] != object_ship_zombi && 
      type  [e] != object_schrott    && 
      type  [e] != object_ship1      &&
      i_random (0, 100) > 50).

.  grab_enemy
     {int u;

      ex [id] = x [e];
      ey [id] = y [e];
      u       = unit [ex [id]][ey [id]];
      if (near_by)
         perhaps_attack;
     }.

.  perhaps_attack
     {int u = unit [ex [id]][ey [id]];

      if (u != none && u != id && color [u] != color [id] &&
          near_by && ! hidden)
         attack_archer;
     }.

.  hidden
     (type [u] == object_scout && wood [u] == 1).

.  near_by
     (near_ship || is_neighbor || guard_event).

.  near_ship
     (on_ship [id] != -1                               &&
      ship_on_side (x [id],y [id], u, ex [id],ey [id]) &&
      type [u] == object_ship1                         &&
      ! s [u]->empty ()). 

.  guard_event
     (cmd [id][0] == cmd_guard &&
      i_abs (x [id] - ex [id]) <= guard_range &&
      i_abs (y [id] - ey [id]) <= guard_range).

.  is_neighbor
     (i_abs (x [id] - ex [id]) <= idle_attack_r [id] &&
      i_abs (y [id] - ey [id]) <= idle_attack_r [id]).

.  attack_archer
     {push_order (id, cmd_attack, ex [id], ey [id]);
      attack_x_min [id] = ex [id] - idle_attack_r [id]-1;
      attack_y_min [id] = ey [id] - idle_attack_r [id]-1;
      attack_x_max [id] = ex [id] + idle_attack_r [id]+1;
      attack_y_max [id] = ey [id] + idle_attack_r [id]+1;
      in_formation [id] = idle_attack_r [id] <= 1 && cmd [id][1] != cmd_guard;
      moving_goal  [id] = u;
      moving_id    [id] = oid [u];
     }.

.  is_idle_pic
     (0 <= p && p <= 30).

.  set_idle_pick
     {int dx;
      int dy;

      dir_dx_dy    (dir [id], dx, dy);
      set_move_pic (id, pic_pawn_idle (color [id]), 0, dx, dy);
      refresh      (x [id], y [id]);
     }.

.  handle_guard_pic
     {if (i_random (1, 100) > 93)
         set_guard_pic;
     }.

.  set_guard_pic
     {int dx;
      int dy;

      if   (i_random (1, 100) > 50)
           dir [id] = dir_left (dir [id]);
      else dir [id] = dir_right (dir [id]);
      dir_dx_dy    (dir [id], dx, dy);
      set_move_pic (id, pic_pawn_idle (color [id]), 0, dx, dy);
      refresh      (x [id], y [id]);
     }.

.  pawn_handle_move_to
     {int dx;
      int dy;
      int max_d;
      int dxx;
      int dyy;
      int uu1;

      if ((cmd [id][1] == cmd_attack || 
           cmd [id][1] == cmd_sad    ||
           cmd [id][1] == cmd_fad) &&
           moving_goal [id] != none &&
           moving_id [id] == oid [moving_goal [id]])
         {gx [id][0] = x [moving_goal [id]];
          gy [id][0] = y [moving_goal [id]];
          uu1        = unit [gx [id][0]][gy [id][0]];
          if   (uu1 != none)
               max_d = i_max (2,(int) dist (x [uu1], y [uu1],x[id], y [id])/2);
          else max_d = 2;
         }
      else max_d = 5000;
      dir_dx_dy    (dir [id], dx, dy);
      dxx = i_sign (gx [id][0] - x [id]);
      dyy = i_sign (gy [id][0] - y [id]);
      uu1 = unit [gx [id][0]][gy [id][0]];
      if      (! far_battle_point)
              {gx [id][0] = x [id] + dx;
               gy [id][0] = y [id] + dy;
               pop_order (id);
              }
      else if (at_goal)
              pop_order (id);
      else if (! move_to_possible &&
               ! players [color_player [color [id]]]->is_robot)
              {pop_order  (id);
               delay_wait (id);
              }
      else if (no_pawn_way)
              handle_no_way;
     }.

.  handle_no_way
     {if   (landscape [x_no_way][y_no_way] == land_water ||
            landscape [x_no_way][y_no_way] == land_sea   ||
            robot_waits_to_long                          ||
            landscape [x_no_way][y_no_way] == land_wall)
           new_order (id, cmd_idle, 0, 0);
      else {pop_order  (id);
            delay_wait (id);
           };
     }.

.  robot_waits_to_long
     (players [color_player [color [id]]]->is_robot && delay [id] > 5).

.  move_to_possible
     (land_properties [landscape [gx [id][0]][gy [id][0]]].walk_possible ||
      landscape [gx [id][0]][gy [id][0]] == land_building                ||
      enter_ship).

.  at_goal
     (x [id] == gx [id][0] && y [id] == gy [id][0]).

.  no_pawn_way
    ! ((goal_free || far_away) && man_plan_path (id, 0, max_d, false)).

.  far_battle_point
     (uu == none || uu != unit [x [id] + dxx][y [id] + dyy] ||
      type [uu] == object_ship1 && (color[uu]==color[id]||s [uu]->empty())).

.  goal_free
     (unit [gx [id][0]][gy [id][0]] == none ||
      enter_ship                            ||
      is_g_moving (unit [gx [id][0]][gy [id][0]])).

.  enter_ship 
      (uu != none && type [uu] == object_ship1).

.  uu unit [gx [id][0]][gy [id][0]].

.  far_away
     ((i_abs (x [id] - gx [id][0]) > 1) ||
      (i_abs (y [id] - gy [id][0]) > 1) ||
      ! landhight_ok).

.  landhight_ok
     (i_abs (landhight [x[id]][y[id]]-landhight [gx[id][0]][gy[id][0]]) < 2).

.  pawn_handle_steps
     {exec_step;
      handle_t;
     }.

.  handle_t
     {t [id]--;
      if (t [id] == 0)
         next_step;
     }.

.  next_step
     {t [id] = step_t;
      xpop (step [id]);
     }.

.  exec_step
     {if   (step [id][0] == step_over)
           pawn_step_over
      else pawn_step_somewhere;
     }.

.  pawn_step_somewhere
     {int dx;
      int dy;

      dir_dx_dy (step [id][0], dx, dy);
      man_step  (id, dx, dy);
     }. 

.  pawn_handle_wait
     {if   (gx [id][0] == 0)
           pop_order (id);
      else gx [id][0]--;
     }. 

.  pawn_step_over
     {pop_order (id);
      delay [id] = 3;
     }.

  }

void object_handler::pawn_upgrade (int id)
  {int  x_tents;
   int  y_tents;
   bool any_tents;
   int  g_unit;
   int dx;
   int dy;

   search_tents;
   if (any_tents)
      g_unit = unit [x_tents][y_tents];
   dx     = x [id] - x_tents;
   dy     = y [id] - y_tents;
   if      (at_tents)
           become_scout
   else if (any_tents)
           push_order (id, cmd_move_to, x_tents + ir, y_tents + ir);
   else    new_order  (id, cmd_idle, 0, 0);

.  at_tents
     (near_by                         &&
      g_unit         != none          &&
      type  [g_unit] == object_tents &&
      color [g_unit] == color [id]).
      
.  near_by
     (-1 <= dx && dx <= 2 && -1 <= dy && dy <= 2).

.  become_scout
     {int pno = color_player [color [id]];

      money [id]     = 0;
      wood  [id]     = 0;
      if (players [pno]->money >= price_scout &&
          players [pno]->wood  >= wood_scout  &&
          cmd [g_unit][0] == cmd_idle)
         start_trainig;
      refresh (x [id], y [id]);
     }.

.  start_trainig 
     {readmin    (color [id], -price_scout, -wood_scout, true);
      push_order (g_unit, cmd_train_scout, 0, 0);
      players [pno]->num_mans--;
      kill_unit  (id);
     }.

.  pbonus
     players [color_player [color [id]]]->bonus.

.  ir  i_random (0, 1).

.  search_tents
     {any_tents = false;
      if   (home_id [id] != none               &&
            home_id [id] < max_objects         &&
            ! is_free [home_id [id]]           &&
            color [home_id [id]] == color [id] &&
            type  [home_id [id]] == object_tents)
           {x_tents   = x [home_id [id]];
            y_tents   = y [home_id [id]];
            any_tents = true;
           }
      else look_for_tents_id;
     }.

.  look_for_tents_id
     {any_tents = any_object (id, object_tents, color [id], home_id [id]);
      if (any_tents)
         {x_tents = x [home_id [id]];
          y_tents = y [home_id [id]];
         };
     }.

  }

/*--- scout ------------------------------------------------------------*/

int object_handler::create_scout (int p_x, int p_y, int p_color, int home_no)
  {int id;

   check_num_mans;
   id = create_object ();
   if (id != none)
      add_scout_data;
   return id;

.  check_num_mans
     {int p = color_player [p_color];

      if (players [p]->num_mans >= max_num_mans)
         handle_to_many_mans;
     }.

.  handle_to_many_mans
     {write (p_color , "Too many mans");
      return none;
     }.

.  add_scout_data
     {add_object_data;
      add_to_land;
     }.

.  add_object_data
     {strcpy (name [id], "scout");
      color         [id]    = p_color;
      with_overview [id]    = true;
      is_marked     [id]    = false;
      type          [id]    = object_scout;
      pic           [id]    = pic_scout_idle (color [id]);
      x             [id]    = p_x;
      y             [id]    = p_y;
      ex            [id]    = p_x;
      ey            [id]    = p_y;
      wx            [id]    = x_center (p_x);
      wy            [id]    = y_center (p_y);
      dir           [id]    = 0;
      cmd           [id][0] = cmd_idle;
      t             [id]    = ticker;
      health        [id]    = 100;
      power         [id]    = 50;
      speed         [id]    = speed_scout;
      wood          [id]    = 0;
      money         [id]    = 0;
      version       [id]    = 0;
      idle_attack_r [id]    = 1;
      home_id       [id]    = home_no;
      interrupted   [id]    = false;
      vr            [id]    = vr_man * 2;
      players [color_player [p_color]]->num_mans++;
      players [color_player [p_color]]->add_sun (p_x, p_y, vr [id]);
     }.

.  add_to_land
     {unit [p_x][p_y] = id;
      land_push (id, p_x, p_y, 0, 0);
      refresh   (x [id], y [id]);
     }.
  
  }

void object_handler::exec_scout (int id)
  {consume_food;
   check_health;
   exec_cmd;

.  check_health
     {if (health [id] <= 0 || on_water)
         ouhgh;
     }.

.  on_water
     (on_ship [id]==-1 && land_properties [landscape[x[id]][y[id]]].is_water). 


.  ouhgh
     {new_order (id, cmd_die, none, none);
     }.
        
.  exec_cmd
     {switch (cmd [id][0])
        {case cmd_move_to       : scout_handle_move_to;  break;
         case cmd_perform_steps : scout_handle_steps;    break;
         case cmd_hide          : scout_exec_hide (id);  break;
         case cmd_talk          : exec_talk (id);        break;
         case cmd_idle          : scout_handle_idle;     break;
         case cmd_stop          : scout_handle_stop;     break;
         case cmd_wait          : scout_handle_wait;     break;
        };
     }.
   
.  consume_food
     {double f = player_food;

      if   (player_food <= 0)
           reduce_health
      else reduce_food;
     }.

.  reduce_health
     {health  [id] = i_max (0, health [id] - 1);
      version [id]++;
     }.

.  reduce_food
     {player_food -= (double) speed_scout / (double) speed_farm;
     }.

.  player_food
     players [color_player [color [id]]]->food.

.  scout_handle_stop
     {pop_order (id);
      wood [id] = 0;
     }.

.  scout_handle_idle
     {int p = pic [id] - pic_scout_idle (color [id]);

      wood [id] = 0;
      if   (! is_idle_pic)
           set_idle_pick;
     }.

.  is_idle_pic
     (0 <= p && p <= 30).

.  set_idle_pick
     {int dx;
      int dy;

      dir_dx_dy    (dir [id], dx, dy);
      set_move_pic (id, pic_scout_idle (color [id]), 0, dx, dy);
      refresh      (x [id], y [id]);
     }.

.  scout_handle_move_to
     {int dx;
      int dy;
      int max_d;

      wood [id] = 0;
      ex [id] = x [id];
      ey [id] = y [id];
      if ((cmd [id][1] == cmd_attack || 
           cmd [id][1] == cmd_sad    ||
           cmd [id][1] == cmd_fad) &&
           moving_goal [id] != none &&
           moving_id [id] == oid [moving_goal [id]])
         {max_d = 2;
          gx [id][0] = x [moving_goal [id]];
          gy [id][0] = y [moving_goal [id]];
         }
      else max_d = 5000;
      dir_dx_dy    (dir [id], dx, dy);
      if      (! goal_free && ! far_battle_point)
              {gx [id][0] = x [id] + dx;
               gy [id][0] = y [id] + dy;
               pop_order (id);
              }
      else if (at_goal)
              pop_order (id);
      else if (! move_to_possible && 
               ! players [color_player [color [id]]]->is_robot)
              {pop_order  (id);
               delay_wait (id);
              }
      else if (no_scout_way)
              handle_no_way;
     }.

.  handle_no_way
     {if   (landscape [x_no_way][y_no_way] == land_water ||
            landscape [x_no_way][y_no_way] == land_sea   ||
            robot_waits_to_long                          ||
            landscape [x_no_way][y_no_way] == land_wall)
           new_order (id, cmd_idle, 0, 0);
      else {pop_order  (id);
            delay_wait (id);
           };
     }.

.  robot_waits_to_long
     (players [color_player [color [id]]]->is_robot && delay [id] > 5).

.  move_to_possible
     (land_properties [landscape [gx [id][0]][gy [id][0]]].walk_possible ||
      landscape [gx [id][0]][gy [id][0]] == land_building                ||
      enter_ship).

.  enter_ship 
      (uu != none && type [uu] == object_ship1).

.  uu unit [gx [id][0]][gy [id][0]].

.  at_goal
     (x [id] == gx [id][0] && y [id] == gy [id][0]).

.  no_scout_way
    ! ((goal_free || far_away) && man_plan_path (id, 0, max_d, false)).

.  far_battle_point
     (uu == none || uu != unit [x [id] + dx][y [id] + dy] ||
      type [uu] == object_ship1 && (color[uu]==color[id]||s [uu]->empty())).

.  goal_free
     (unit [gx [id][0]][gy [id][0]] == none ||
      enter_ship                            ||
      is_g_moving (unit [gx [id][0]][gy [id][0]])).

.  far_away
     ((i_abs (x [id] - gx [id][0]) > 1) ||
      (i_abs (y [id] - gy [id][0]) > 1) ||
      ! landhight_ok).

.  landhight_ok
     (i_abs (landhight [x[id]][y[id]]-landhight [gx[id][0]][gy[id][0]]) < 2).

.  scout_handle_steps
     {wood [id] = 0;
      exec_step;
      handle_t;
     }.

.  handle_t
     {t [id]--;
      if (t [id] == 0)
         next_step;
     }.

.  next_step
     {t [id] = step_t;
      xpop (step [id]);
     }.

.  exec_step
     {if   (step [id][0] == step_over)
           scout_step_over
      else scout_step_somewhere;
     }.

.  scout_step_somewhere
     {int dx;
      int dy;

      dir_dx_dy (step [id][0], dx, dy);
      man_step  (id, dx, dy);
     }. 

.  scout_handle_wait
     {if   (gx [id][0] == 0)
           pop_order (id);
      else gx [id][0]--;
     }. 

.  scout_step_over
     {pop_order (id);
      delay [id] = 3;
     }.

  }

void object_handler::scout_exec_hide (int id)
  {if   (x [id] == gx [id][0] && y [id] == gy [id][0])
        handle_hiding
   else push_order (id, cmd_move_to, gx [id][0], gy [id][0]);

.  handle_hiding
     {bool is_visable;
      int  op = wood [id];
      int  dx;
      int  dy;

      dir_dx_dy    (dir [id], dx, dy);
      set_move_pic (id, pic_scout_hide (color [id]), 0, dx, dy);
      check_if_visable;
      if   (! is_visable)
           wood [id] = 1;
      else wood [id] = 0;
      if (op != wood [id])
         refresh (x [id], y [id]);
     }.

.  check_if_visable
     {int u = unit [ex [id]][ey [id]];

      is_visable = false;
      if   (u         != none         &&
            color [u] != color [id]   &&
            type  [u] != object_arrow &&
            type  [u] != object_stone)
           is_visable = true;
      else check_neighbours;
     }.

.  check_neighbours
     {int xmin = i_max (0, x [id] - 2);
      int xmax = i_min (landscape_dx - 1,x [id] + 3);
      int ymin = i_max (0, y [id] - 2);
      int ymax = i_min (landscape_dy - 1,y [id] + 3);

      t [id]++;
      if   ((t [id] % 2) == 0)
	   xmin = x [id];
      else xmax = x [id];
      for (int xx = xmin; xx < xmax && ! is_visable; xx++)
        for (int yy = ymin; yy < ymax && ! is_visable; yy++)
          check_field
     }.

.  check_field
     {u = unit [xx][yy];

      if (u != none && color [u] != color [id])
         {ex [id]    = xx;
          ey [id]    = yy;
          is_visable = true;
         };
     }.

  }

/*--- ship -------------------------------------------------------------*/

int object_handler::create_ship (int  p_x, 
                                 int  p_y, 
                                 int  p_color, 
                                 int  p_dir, 
                                 bool with_cata)

  {int id;

   check_num_mans;
   id = create_object ();
   if (id != none)
      add_ship_data;
   return id;

.  check_num_mans
     {int p = color_player [p_color];

      if (players [p]->num_mans >= max_num_mans)
         handle_to_many_mans;
     }.

.  handle_to_many_mans
     {write (p_color , "Too many mans");
      return none;
     }.

.  add_ship_data
     {add_object_data;
      s [id]->with_master = false;
      add_to_land;
     }.

.  add_object_data
     {int pno = color_player [p_color];
      int dx; 
      int dy;

      strcpy (name [id], "ship");
      color         [id]    = p_color;
      with_overview [id]    = true;
      is_marked     [id]    = false;
      type          [id]    = object_ship1;
      x             [id]    = p_x;
      y             [id]    = p_y;
      ex            [id]    = p_x;
      ey            [id]    = p_y;
      wx            [id]    = x_center (p_x);
      wy            [id]    = y_center (p_y);
      dir           [id]    = p_dir;
      cmd           [id][0] = cmd_idle;
      t             [id]    = ticker;
      health        [id]    = 100;
      power         [id]    = 50;
      speed         [id]    = speed_ship1;
      wood          [id]    = 0;
      money         [id]    = 0;
      version       [id]    = 0;
      idle_attack_r [id]    = 1;
      support       [id]    = 1;
      interrupted   [id]    = false;
      harvest_type  [id]    = 0;
      vr            [id]    = vr_man * 2;
      s             [id]    = new ship (id);
      players [color_player [p_color]]->num_mans++;
      players [color_player [p_color]]->add_sun (p_x, p_y, vr [id]);
     }.

.  add_to_land
     {int dx; 
      int dy;

      for (int sx = p_x; sx < p_x + 3; sx++)
        for (int sy = p_y; sy < p_y + 3; sy++)
          {unit [sx][sy] = id;
          };
      dir_dx_dy (dir [id], dx, dy);
      if   (support [id] == 0)
           set_ship_pic (id, pic_ship2_empty (color [id]), 0, dx, dy);
      else set_ship_pic (id, pic_ship_empty  (color [id]), 0, dx, dy);
      land_push (id, p_x, p_y, 1, 1, 4, 4);
      refresh   (x [id], y [id], 1, 1, 4, 4);
     }.
  
  }

void object_handler::exec_ship (int id)
  {consume_food;
   check_health;
   exec_cmd;

.  check_health
     {if (health [id] <= 0)
         ouhgh;
     }.

.  ouhgh
     {new_order (id, cmd_die, none, none);
     }.
        
.  exec_cmd
     {switch (cmd [id][0])
        {case cmd_sail          : ship_handle_move_to; break;
         case cmd_enter         : ship_enter (id);     break;
         case cmd_entered       : ship_enter (id);     break;
         case cmd_attack        : ship_attack (id);    break;
         case cmd_perform_steps : ship_handle_steps;   break;
         case cmd_talk          : exec_talk (id);      break;
         case cmd_idle          : ship_handle_idle;    break;
         case cmd_stop          : ship_handle_stop;    break;
         case cmd_wait          : ship_handle_wait;    break;
        };
     }.

.  consume_food
     {double f = player_food;

      if   (player_food <= 0)
           reduce_health
      else reduce_food;
     }.

.  reduce_health
     {health  [id] = i_max (0, health [id] - 1);
      version [id]++;
     }.

.  reduce_food
     {player_food -= (double) speed_scout / (double) speed_farm;
     }.

.  player_food
     players [color_player [color [id]]]->food.

.  ship_handle_stop
     {pop_order (id);
      wood [id] = 0;
     }.

.  ship_handle_idle
     {if   (support [id] == 0)
           handle_battle_ship
      else handle_transport_ship;
     }.

.  handle_transport_ship
     {if   (s [id]->empty ())
           set_t_empty
      else set_t_full
     }.

.  set_t_full
     {int p = pic [id] - pic_ship_idle (color [id]);

      if   (! is_idle_pic)
           set_t_idle_pick;
     }.

.  set_t_empty
     {int p = pic [id] - pic_ship_empty (color [id]);

      if   (! is_idle_pic)
           set_t_empty_pick;
     }.

.  is_idle_pic
     (0 <= p && p <= 35).

.  set_t_idle_pick
     {int dx;
      int dy;

      dir_dx_dy    (dir [id], dx, dy);
      set_ship_pic (id, pic_ship_idle (color [id]), 0, dx, dy);
      refresh      (x [id], y [id], 1, 1, 4, 4);
     }.

.  set_t_empty_pick
     {int dx;
      int dy;

      dir_dx_dy    (dir [id], dx, dy);
      set_ship_pic (id, pic_ship_empty (color [id]), 0, dx, dy);
      refresh      (x [id], y [id], 1, 1, 4, 4);
     }.

.  handle_battle_ship
     {if   (s [id]->empty ())
           set_b_empty
      else set_b_full
     }.

.  set_b_full
     {int p = pic [id] - pic_ship2_idle (color [id]);

      if   (! is_idle_pic)
           set_b_idle_pick;
     }.

.  set_b_empty
     {int p = pic [id] - pic_ship2_empty (color [id]);

      if   (! is_idle_pic)
           set_b_empty_pick;
     }.

.  set_b_idle_pick
     {int dx;
      int dy;

      dir_dx_dy    (dir [id], dx, dy);
      set_ship_pic (id, pic_ship2_idle (color [id]), 0, dx, dy);
      refresh      (x [id], y [id], 1, 1, 4, 4);
     }.

.  set_b_empty_pick
     {int dx;
      int dy;

      dir_dx_dy    (dir [id], dx, dy);
      set_ship_pic (id, pic_ship2_empty (color [id]), 0, dx, dy);
      refresh      (x [id], y [id], 1, 1, 4, 4);
     }.

.  ship_handle_move_to
     {int dx;
      int dy;
      int max_d;
      int goal_d;

      if   (cmd [id][1] == cmd_attack || cmd [id][1] == cmd_enter)
           {max_d = i_max (1, 
                          (int) dist (x [id],y [id],gx [id][0],gy [id][0])/3);
            if   (cmd [id][1] == cmd_enter)
                 goal_d = 0;
            else goal_d = scope_archer -1;
           }
      else {max_d  = 600;
            goal_d = 0;
           };
      dir_dx_dy (dir [id], dx, dy);
      if      (s [id]->empty ())
              pop_order (id);
      else if (! goal_free)
              pop_order (id);
      else if (at_goal)
              pop_order (id);
      else if (! move_to_possible || no_ship_way)
              {pop_order  (id);
               delay_wait (id);
              };
     }.

.  move_to_possible
     (land_properties [landscape [gx [id][0]][gy [id][0]]].is_water ||
      goal_d > 0).

.  at_goal
     ((x [id] == gx [id][0] && y [id] == gy [id][0]) || 
      (cmd [id][1] == cmd_enter && 
      ship_on_side (x [id],y [id],moving_goal [id],gx [id][0],gy [id][0]))).

.  no_ship_way
    ! ((goal_free || far_away) && man_plan_path (id, goal_d, max_d, false)).

.  goal_free
     (unit [gx [id][0]][gy [id][0]]                       == none || 
      unit [gx [id][0]][gy [id][0]]                       == id   ||
      (int) dist (x [id], y [id], gx [id][0], gy [id][0]) > 2     ||
      is_g_moving (unit [gx [id][0]][gy [id][0]])).

.  far_away
     ((i_abs (x [id] - gx [id][0]) > 1) || (i_abs (y [id] - gy [id][0]) > 1)).

.  ship_handle_steps
     {exec_step;
      handle_t;
     }.

.  handle_t
     {if (t [id] == 0)
         next_step;
     }.

.  next_step
     {t [id] = step_t;
      xpop (step [id]);
      if (s [id]->empty ())
         new_order (id, cmd_idle, 0, 0);
     }.

.  exec_step
     {if   (step [id][0] == step_over)
           ship_step_over
      else ship_step_somewhere;
     }.

.  ship_step_somewhere
     {int dx;
      int dy;

      if   (dir [id] == step [id][0])
           perform_step
      else turn;
     }.

.  turn 
     {if   (left_dist (dir [id],  step [id][0]) <= 4)
           dir [id] = dir_left  (dir [id]);
      else dir [id] = dir_right (dir [id]);
      dir_dx_dy    (dir [id], dx, dy);
      if   (support [id] == 0)
           set_ship_pic (id, pic_ship2_idle (color [id]), 0, dx, dy);
      else set_ship_pic (id, pic_ship_idle  (color [id]), 0, dx, dy);
      refresh      (x [id], y [id], 1, 1, 3, 3);
     }.

.  perform_step
     {dir_dx_dy (step [id][0], dx, dy);
      ship_step  (id, dx, dy);
      t [id]--;
     }. 

.  ship_handle_wait
     {if   (gx [id][0] == 0)
           pop_order (id);
      else gx [id][0]--;
     }. 

.  ship_step_over
     {pop_order (id);
      delay [id] = 3;
      if (players [color_player [color [id]]]->is_robot)
         players [color_player [color [id]]]->rob->urgent = id;
     }.

  }

void object_handler::ship_attack (int id)
  {int weapon_dist;
   int uu = moving_goal [id];

   if   (s [id]->empty () || no_enemy)
        pop_order (id);
   else do_it;

.  no_enemy
     (! cata_goal && ! archer_goal).

.  cata_goal
     (s [id]->num_cata () >0 &&
      landscape [gx [id][0]][gy [id][0]] == land_wall).

.  archer_goal
     (uu != none                       &&
      ! is_free [uu]                   &&
      color [uu] != color [id]         && 
      type  [uu] != object_mine        &&
      type  [uu] != object_zombi       && 
      type  [uu] != object_ship_zombi  && 
      type  [uu] != object_schrott     && 
      type  [uu] != object_mine).

.  do_it
     {if (archer_goal)
         readjust_goal_point;
      calc_weapon_dist;
      if   (! at_goal)
           try_to_move_to_goal
      else exec_attack;
     }.

.  exec_attack
     {for (int i = 0; i < s [id]->num_man; i++)
        start_one_attack;
     }.

.  start_one_attack
     {int  u                  = s [id]->unit [i];
      int  xa                 = gx [id][0];
      int  ya                 = gy [id][0];
      bool any_attack_started = false;

      if ((type [u] == object_cata || type [u] == object_archer) &&
          ! yet_attacking)
         {new_order (u, cmd_attack, gx [id][0], gy [id][0]);
          any_attack_started = true;
         };
      if   (any_attack_started)
           delay [id] = 3; 
      else delay_wait (id);
     }.

.  yet_attacking
     (cmd [u][0] == cmd_attack ||
      cmd [u][1] == cmd_attack ||
      cmd [u][2] == cmd_attack).

.  readjust_goal_point
     {if   (type [uu] == object_ship1)
           {gx [id][0] = x [uu] + 1;
            gy [id][0] = y [uu] + 1;
           }
      else {gx [id][0] = x [uu];
            gy [id][0] = y [uu];
           };
     }.

.  calc_weapon_dist
     {if   (support [id] == 0)
           weapon_dist = scope_cata;
      else weapon_dist = scope_archer;
     }.

.  at_goal
     ((int) dist (x [id], y [id], gx [id][0], gy [id][0]) < weapon_dist).

.  try_to_move_to_goal
     {push_order (id, cmd_sail, gx [id][0], gy [id][0]);
     }.

  }

void object_handler::ship_enter (int id)
  {int uu = moving_goal [id];

   if   (no_enemy)
        pop_order (id);
   else do_it;

.  no_enemy
     (uu == none || type [uu] != object_ship1 || s [id]->empty () || 
      (s [uu]->no_fighter () && s [id]->no_fighter ()) ||
      color [uu] == color [id]).

.  do_it
     {gx [id][0] = x [uu];
      gy [id][0] = y [uu];
      if   (at_goal)
           yeah_yeah
      else move_to_goal;
     }.

.  at_goal
     ship_on_side (x [id], y [id], uu, x [uu], y [uu]).

.  yeah_yeah
     {if   (s [uu]->empty ())
           jump_on_board
      else hit_them;
     }.

.  jump_on_board
     {for (int i = 0; i < s [id]->num_man; i++)
         new_order (s [id]->unit [i], cmd_idle, 0, 0);
      if (s [id]->num_man > 1)
         new_order (s [id]->unit [1], cmd_move_to, gx [id][0], gy [id][0]);
      pop_order (id);
     }. 

.  hit_them
     {new_order (id, cmd_entered, gx [id][0], gy [id][0]);
      for (int i = 0; i < s [id]->num_man; i++)
        start_one_attack;
      fix_enemy;
     }.

.  fix_enemy
     {if (! yet_killed)
         let_enemy_attack;
     }.

.  let_enemy_attack
     {new_order (uu, cmd_entered, x [id], y [id]);
      moving_goal [uu] = id;
     }.

.  yet_killed        
     (cmd [uu][0] == cmd_die || cmd [uu][1] == cmd_die).

.  start_one_attack
     {int  u                  = s [id]->unit [i];
      bool any_attack_started = false;
      int  xa                 = gx [id][0];
      int  ya                 = gy [id][0];

      if (! yet_attacking)
         {new_order (u, cmd_attack, gx [id][0], gy [id][0]);
          any_attack_started = true;
         };
     }.

.  yet_attacking
     (cmd [u][0] == cmd_attack ||
      cmd [u][1] == cmd_attack ||
      cmd [u][2] == cmd_attack).

.  move_to_goal
     {push_order (id, cmd_sail, gx [id][0], gy [id][0]);
     }.

  }

/*--- knight -----------------------------------------------------------*/

int object_handler::create_knight (int  p_x, 
                                   int  p_y,
                                   int  p_color,
                                   int  home_no,
                                   bool is_master) 

  {int id;

   check_num_mans;
   id = create_object ();
   if (id != none)
      add_knight_data;
   return id;

.  check_num_mans
     {int p = color_player [p_color];

      if (players [p]->num_mans >= max_num_mans)
         handle_to_many_mans;
     }.

.  handle_to_many_mans
     {write (p_color, "Too many mans");
      return none;
     }.

.  add_knight_data
     {add_object_data;
      add_to_land;
     }.

.  add_object_data
     {strcpy (name [id], "knight");
      color         [id]    = p_color;
      with_overview [id]    = true;
      is_marked     [id]    = false;
      type          [id]    = object_knight;
      pic           [id]    = pic_knight_idle (color [id]) ;
      x             [id]    = p_x;
      y             [id]    = p_y;
      wx            [id]    = x_center (p_x);
      wy            [id]    = y_center (p_y);
      dir           [id]    = 0;
      cmd           [id][0] = cmd_idle;
      t             [id]    = ticker;
      health        [id]    = 100;
      power         [id]    = 50;
      speed         [id]    = speed_knight;
      wood          [id]    = 0;
      money         [id]    = 0;
      version       [id]    = 0;
      idle_attack_r [id]    = 1;
      interrupted   [id]    = false;
      home_id       [id]    = home_no;
      master        [id]    = is_master;
      vr            [id]    = vr_man;
      players [color_player [p_color]]->num_mans++;
      players [color_player [p_color]]->add_sun (p_x, p_y, vr [id]);
     }.

.  add_to_land
     {unit [p_x][p_y] = id;
      land_push (id, p_x, p_y, 0, 0);
      refresh   (x [id], y [id]);
     }.
  
  }

void object_handler::exec_knight (int id)
  {consume_food;
   check_health;
   exec_cmd;

.  check_health
     {if (health [id] <= 0 || on_water)
         ouhgh;
     }.

.  on_water
     (on_ship [id]==-1 && land_properties [landscape[x[id]][y[id]]].is_water). 


.  ouhgh
     {new_order (id, cmd_die, none, none);
     }.
        
.  exec_cmd
     {switch (cmd [id][0])
        {case cmd_move_to       : knight_handle_move_to;   break;
         case cmd_perform_steps : knight_handle_steps;     break;
         case cmd_fad           : fighter_sad (id, true);  break;
         case cmd_sad           : fighter_sad (id, false); break;
         case cmd_attack        : fighter_attack (id);     break;
         case cmd_hit           : exec_fighter_hit (id);   break;
         case cmd_guard         :
         case cmd_idle          : knight_handle_idle;      break;
         case cmd_talk          : exec_talk (id);          break;
         case cmd_stop          : knight_handle_stop;      break;
         case cmd_wait          : knight_handle_wait;      break;
        };
     }.
   
.  consume_food
     {double f = player_food;

      if   (player_food <= 70 && ! master [id])
           reduce_health
      else reduce_food;
     }.

.  reduce_health
     {health  [id] = i_max (0, health [id] - 1);
      version [id]++;
     }.

.  reduce_food
     {player_food -= (double) speed_knight / (double) speed_farm;
     }.

.  player_food
     players [color_player [color [id]]]->food.

.  knight_handle_stop
     {pop_order (id);
     }.

.  knight_handle_idle
     {int p = pic [id] - pic_knight_idle (color [id]);

      if (! is_idle_pic)
         set_idle_pick;
      grab_new_enemy;
     }.

.  grab_new_enemy           
     {if   (ex [id] != none)
           perhaps_attack
      else look_for_enemy
      ex [id] = none;
     }.

.  look_for_enemy
     {bool over = false;

      for (int h = 0; h < max_objects/look_n && ! over; h++)
        try_look;
     }.

.  try_look
     {int e;

      t [id]++;
      if (t [id] < 0 || t [id] >= max_objects)
         t [id] = 0;
      e = t [id];
      if (any_enemy)
         grab_enemy;
     }.

.  any_enemy
     (! is_free [e]                  && 
      color [e] != color [id]        && 
      type  [e] != object_mine       &&
      type  [e] != object_zombi      && 
      type  [e] != object_ship_zombi && 
      type  [e] != object_schrott    && 
      type [e] != object_ship1       &&
      i_random (0, 100) > 50).

.  grab_enemy
     {int u;

      ex [id] = x [e];
      ey [id] = y [e];
      u       = unit [ex [id]][ey [id]];
      if (near_by)
         perhaps_attack;
     }.

.  perhaps_attack
     {int u = unit [ex [id]][ey [id]];

      if (u != none && u != id && color [u] != color [id] && near_by
          && ! hidden)
         attack_archer;
     }.

.  hidden
     (type [u] == object_scout && wood [u] == 1).

.  near_by
     (near_ship || is_neighbor || guard_event).

.  near_ship
     (on_ship [id] != -1 &&
      ship_on_side (x [id],y [id], u, ex [id],ey [id]) && 
      type [u] == object_ship1                        &&
      ! s [u]->empty ()). 

.  guard_event
     (cmd [id][0] == cmd_guard &&
      i_abs (x [id] - ex [id]) <= guard_range &&
      i_abs (y [id] - ey [id]) <= guard_range).

.  is_neighbor
     (i_abs (x [id] - ex [id]) <= idle_attack_r [id] &&
      i_abs (y [id] - ey [id]) <= idle_attack_r [id]).

.  attack_archer
     {push_order (id, cmd_attack, ex [id], ey [id]);
      attack_x_min [id] = ex [id] - idle_attack_r [id]-1;
      attack_y_min [id] = ey [id] - idle_attack_r [id]-1;
      attack_x_max [id] = ex [id] + idle_attack_r [id]+1;
      attack_y_max [id] = ey [id] + idle_attack_r [id]+1;
      in_formation [id] = idle_attack_r [id] <= 1 && cmd [id][1] != cmd_guard;
      moving_goal [id]  = u;
      moving_id   [id]  = oid [u];
     }.

.  is_idle_pic
     (0 <= p && p <= 30).

.  set_idle_pick
     {int dx;
      int dy;

      dir_dx_dy    (dir [id], dx, dy);
      set_move_pic (id, pic_knight_idle (color [id]), 0, dx, dy);
      refresh      (x [id], y [id]);
     }.

.  knight_handle_move_to
     {int dx;
      int dy;
      int max_d;
      int uu  = unit [gx [id][0]][gy [id][0]];
      int dxx;
      int dyy;

      if ((cmd [id][1] == cmd_attack || 
           cmd [id][1] == cmd_sad    ||
           cmd [id][1] == cmd_fad) &&
           moving_goal [id] != none &&
           moving_id [id] == oid [moving_goal [id]])
         {gx [id][0] = x [moving_goal [id]];
          gy [id][0] = y [moving_goal [id]];
          uu         = unit [gx [id][0]][gy [id][0]];
          if   (uu != none)
               max_d = i_max (2,(int) dist (x [uu], y [uu], x [id], y [id])/2);
          else max_d = 2;
         }
      else max_d = 5000;
      dir_dx_dy    (dir [id], dx, dy);
      dxx = i_sign (gx [id][0] - x [id]);
      dyy = i_sign (gy [id][0] - y [id]);
      if      (! far_battle_point)
              {gx [id][0] = x [id] + dx;
               gy [id][0] = y [id] + dy;
               pop_order (id);
              }
      else if (at_goal)
              pop_order (id);
      else if (! move_to_possible && 
               ! players [color_player [color [id]]]->is_robot)
              {pop_order  (id);
               delay_wait (id);
              }
      else if (no_knight_way)
              handle_no_way
     }.

.  handle_no_way
     {if   (landscape [x_no_way][y_no_way] == land_water ||
            landscape [x_no_way][y_no_way] == land_sea   ||
            robot_waits_to_long                          ||
            landscape [x_no_way][y_no_way] == land_wall)
           new_order (id, cmd_idle, 0, 0);
      else {pop_order  (id);
            delay_wait (id);
           };
     }.

.  robot_waits_to_long
     (players [color_player [color [id]]]->is_robot && delay [id] > 5).

.  move_to_possible
     (land_properties [landscape [gx [id][0]][gy [id][0]]].walk_possible ||
      landscape [gx [id][0]][gy [id][0]] == land_building                ||
      enter_ship).

.  at_goal
     (x [id] == gx [id][0] && y [id] == gy [id][0]).

.  no_knight_way
    ! ((goal_free || far_away) && man_plan_path (id, 0, max_d, false)).

.  far_battle_point
     (uu == none || uu != unit [x [id] + dxx][y [id] + dyy] ||
      type [uu] == object_ship1 && (color[uu]==color[id]||s [uu]->empty())).

.  goal_free
     (uu == none || enter_ship || is_g_moving (uu)).

.  enter_ship 
      (uu != none && type [uu] == object_ship1).

.  far_away
     ((i_abs (x [id] - gx [id][0]) > 1) ||
      (i_abs (y [id] - gy [id][0]) > 1) ||
      ! landhight_ok).

.  landhight_ok
     (i_abs (landhight [x[id]][y[id]]-landhight [gx[id][0]][gy[id][0]]) < 2).

.  knight_handle_steps
     {exec_step;
      handle_t;
     }.

.  handle_t
     {t [id]--;
      if (t [id] == 0)
         next_step;
     }.

.  next_step
     {t [id] = step_t;
      xpop (step [id]);
     }.

.  exec_step
     {if   (step [id][0] == step_over)
           knight_step_over
      else knight_step_somewhere;
     }.

.  knight_step_somewhere
     {int dx;
      int dy;

      dir_dx_dy (step [id][0], dx, dy);
      man_step  (id, dx, dy);
     }. 

.  knight_handle_wait
     {if   (gx [id][0] == 0)
           pop_order (id);
      else gx [id][0]--;
     }. 

.  knight_step_over
     {pop_order (id);
      delay [id] = 3;
     }.

  }

/*--- archers -----------------------------------------------------------*/

int object_handler::create_archer (int p_x, int p_y, int p_color, int home_no)
  {int id;

   check_num_mans;
   id = create_object ();
   if (id != none)
      add_archer_data;
   return id;

.  check_num_mans
     {int p = color_player [p_color];

      if (players [p]->num_mans >= max_num_mans)
         handle_to_many_mans;
     }.

.  handle_to_many_mans
     {write (p_color, "Too many mans");
      return none;
     }.

.  add_archer_data
     {add_object_data;
      add_to_land;
     }.

.  add_object_data
     {strcpy (name [id], "archer");
      color         [id]    = p_color;
      with_overview [id]    = true;
      is_marked     [id]    = false;
      type          [id]    = object_archer;
      pic           [id]    = pic_archer_idle (color [id]);
      x             [id]    = p_x;
      y             [id]    = p_y;
      wx            [id]    = x_center (p_x);
      wy            [id]    = y_center (p_y);
      dir           [id]    = 0;
      cmd           [id][0] = cmd_idle;
      t             [id]    = ticker;
      health        [id]    = 100;
      power         [id]    = 50;
      speed         [id]    = speed_archer;
      wood          [id]    = 0;
      money         [id]    = 0;
      version       [id]    = 0;
      interrupted   [id]    = false;
      home_id       [id]    = home_no;
      vr            [id]    = vr_man;
      players [color_player [p_color]]->num_mans++;
      players [color_player [p_color]]->add_sun (p_x, p_y, vr [id]);
     }.

.  add_to_land
     {unit [p_x][p_y] = id;
      land_push (id, p_x, p_y, 0, 0);
      refresh   (x [id], y [id]);
     }.
  
  }

void object_handler::exec_archer (int id)
  {consume_food;
   check_health;
   exec_cmd;

.  check_health
     {if (health [id] <= 0 || on_water)
         ouhgh;
     }.

.  on_water
     (on_ship [id]==-1 && land_properties [landscape[x[id]][y[id]]].is_water). 

.  ouhgh
     {new_order (id, cmd_die, none, none);
     }.
        
.  exec_cmd
     {switch (cmd [id][0])
        {case cmd_move_to       : archer_handle_move_to;  break;
         case cmd_perform_steps : archer_handle_steps;    break;
         case cmd_fad           : archer_sad (id, true);  break;
         case cmd_sad           : archer_sad (id, false); break;
         case cmd_attack        : archer_attack  (id);    break;
         case cmd_hit           : exec_archer_hit (id);   break;
         case cmd_guard         :
         case cmd_idle          : archer_handle_idle;     break;
         case cmd_talk          : exec_talk (id);         break;
         case cmd_stop          : archer_handle_stop;     break;
         case cmd_wait          : archer_handle_wait;     break;
        };
     }.
   
.  consume_food
     {double f = player_food;

      if   (player_food <= 70)
           reduce_health
      else reduce_food;
     }.

.  reduce_health
     {health  [id] = i_max (0, health [id] - 1);
      version [id]++;
     }.

.  reduce_food
     {player_food -= (double) speed_archer / (double) speed_farm;
     }.

.  player_food
     players [color_player [color [id]]]->food.

.  archer_handle_stop
     {pop_order (id);
     }.

.  archer_handle_idle
     {int  p = pic [id] - pic_archer_idle (color [id]);
      bool over;

      if (! is_idle_pic)
         set_idle_pick;
      grab_new_enemy;
     }.

.  grab_new_enemy           
     {if   (ex [id] != none)
           perhaps_attack
      else look_for_enemy;
      ex [id] = none;
     }.

.  look_for_enemy
     {bool over = false;

      for (int h = 0; h < max_objects/look_n && ! over; h++)
        try_look;
     }.

.  try_look
     {int e;

      t [id]++;
      if (t [id] < 0 || t [id] >= max_objects)
         t [id] = 0;
      e = t [id];
      if (any_enemy)
         grab_enemy;
     }.

.  any_enemy
     (! is_free [e]                  && 
      color [e] != color [id]        && 
      type  [e] != object_mine       &&
      type  [e] != object_zombi      && 
      type  [e] != object_ship_zombi && 
      type  [e] != object_schrott    && 
      (type [e] != object_ship1  || ! s [e]->empty ()) &&
      (type [e] == object_doktor || i_random (0, 100) > 30)).

.  grab_enemy
     {ex [id] = x [e];
      ey [id] = y [e];
      if (type [e] == object_ship1)
         {ex [id]++;
          ey [id]++;
         };
      perhaps_attack;
     }.

.  perhaps_attack
     {int u = unit [ex [id]][ey [id]];

      if (u != none               &&
          u != id                 &&
          near_by                 &&
          color [u] != color [id] &&
         ! hidden)
         attack_archer;
     }.

.  hidden
     (type [u] == object_scout && wood [u] == 1).

.  near_by
     (dist (x [id], y [id], ex [id], ey [id]) <= scope_archer+1 &&
      (type [u] != object_ship1 || ! s [u]->empty ())).

.  attack_archer
     {push_order (id, cmd_attack, ex [id], ey [id]);
      attack_x_min [id] = ex [id];
      attack_y_min [id] = ey [id];
      attack_x_max [id] = ex [id];
      attack_y_max [id] = ey [id];
      in_formation [id] = true;
      moving_goal [id]  = u;
      moving_id   [id]  = oid [u];
      over              = true;
     }.

.  is_idle_pic
     (0 <= p && p <= 30).

.  set_idle_pick
     {int dx;
      int dy;

      dir_dx_dy    (dir [id], dx, dy);
      set_move_pic (id, pic_archer_idle (color [id]), 0, dx, dy);
      refresh      (x [id], y [id]);
     }.

.  archer_handle_move_to
     {int dx;
      int dy;
      int goal_dist;
      int max_d;
      int uu1;

      dir_dx_dy (dir [id], dx, dy);
      calc_goal_dist;
      if ((cmd [id][1] == cmd_attack || 
           cmd [id][1] == cmd_sad    ||
           cmd [id][1] == cmd_fad) &&
           moving_goal [id] != none &&
           moving_id [id] == oid [moving_goal [id]])
         {gx [id][0] = x [moving_goal [id]];
          gy [id][0] = y [moving_goal [id]];
          uu1        = unit [gx [id][0]][gy [id][0]];
          if   (uu1 != none)
               max_d = i_max (2,(int) dist (x [uu1], y [uu1],x [id],y [id])/2);
          else max_d = 2;
         }
      else max_d = 5000;
      dir_dx_dy    (dir [id], dx, dy);
      if      (at_goal)
              {pop_order (id);
              }
      else if (! move_to_possible && 
               ! players [color_player [color [id]]]->is_robot)
              {pop_order  (id);
               delay_wait (id);
              }
      else {if (no_archer_way)
              handle_no_way;
           };
     }.

.  handle_no_way
     {if   (landscape [x_no_way][y_no_way] == land_water ||
            landscape [x_no_way][y_no_way] == land_sea   ||
            robot_waits_to_long                          ||
            landscape [x_no_way][y_no_way] == land_wall)
           new_order (id, cmd_idle, 0, 0);
      else {pop_order  (id);
            delay_wait (id);
           };
     }.

.  robot_waits_to_long
     (players [color_player [color [id]]]->is_robot && delay [id] > 5).

.  move_to_possible
     (land_properties [landscape [gx [id][0]][gy [id][0]]].walk_possible ||
      landscape [gx [id][0]][gy [id][0]] == land_building                ||
      enter_ship).

.  at_goal
     (x [id] == gx [id][0] && y [id] == gy [id][0]).

.  calc_goal_dist
     {if (cmd [id][1] == cmd_attack)
           goal_dist = scope_archer;
      else goal_dist = 0;
     }.

.  enter_ship 
      (uu != none && type [uu] == object_ship1).

.  uu unit [gx [id][0]][gy [id][0]].

.  no_archer_way
    ! ((goal_free||far_away) &&  man_plan_path (id,goal_dist,max_d, false)).

.  goal_free
     (unit [gx [id][0]][gy [id][0]] == none ||
      enter_ship                            ||
      is_g_moving (unit [gx [id][0]][gy [id][0]])).

.  far_away
     ((int) dist (x [id], y [id], gx [id][0], gy [id][0]) > scope_archer).

.  archer_handle_steps
     {exec_step;
      handle_t;
     }.

.  handle_t
     {t [id]--;
      if (t [id] == 0)
         next_step;
     }.

.  next_step
     {t [id] = step_t;
      xpop (step [id]);
     }.

.  exec_step
     {if   (step [id][0] == step_over)
           archer_step_over
      else archer_step_somewhere;
     }.

.  archer_step_somewhere
     {int dx;
      int dy;

      dir_dx_dy (step [id][0], dx, dy);
      man_step  (id, dx, dy);
     }. 

.  archer_handle_wait
     {if   (gx [id][0] == 0)
           pop_order (id);
      else gx [id][0]--;
     }. 

.  archer_step_over
     {pop_order (id);
      delay [id] = 3;
     }.

  }

/*--- cata --------------------------------------------------------------*/

int object_handler::create_cata (int p_x, int p_y, int p_color, int home_no)
  {int id;

   check_num_mans;
   id = create_object ();
   if (id != none)
      add_cata_data;
   return id;

.  check_num_mans
     {int p = color_player [p_color];

      if (players [p]->num_mans >= max_num_mans)
         handle_to_many_mans;
     }.

.  handle_to_many_mans
     {write (p_color, "Too many mans");
      return none;
     }.

.  add_cata_data
     {add_object_data;
      add_to_land;
     }.

.  add_object_data
     {strcpy (name [id], "catapult");
      color         [id]    = p_color;
      with_overview [id]    = true;
      is_marked     [id]    = false;
      type          [id]    = object_cata;
      pic           [id]    = pic_cata_idle (color [id]);
      x             [id]    = p_x;
      y             [id]    = p_y;
      wx            [id]    = x_center (p_x);
      wy            [id]    = y_center (p_y);
      dir           [id]    = 0;
      cmd           [id][0] = cmd_idle;
      t             [id]    = ticker;
      health        [id]    = 100;
      power         [id]    = 50;
      speed         [id]    = speed_cata;
      wood          [id]    = 0;
      money         [id]    = 0;
      version       [id]    = 0;
      interrupted   [id]    = false;
      harvest_type  [id]    = -1;
      support       [id]    = 1;
      home_id       [id]    = home_no;
      vr            [id]    = vr_man;
      players [color_player [p_color]]->num_mans++;
      players [color_player [p_color]]->add_sun (p_x, p_y, vr [id]);
     }.

.  add_to_land
     {if (landscape [x [id]][y [id]] != land_water &&
          landscape [x [id]][y [id]] != land_sea)
         {unit [p_x][p_y] = id;
          land_push (id, p_x, p_y, 0, 0);
          refresh   (x [id], y [id]);
         };
     }.
  
  }

void object_handler::exec_cata (int id)
  {consume_food;
   check_health;
   exec_cmd;

.  check_health
     {if (health [id] <= 0 || on_water)
         ouhgh;
     }.

.  on_water
     (on_ship [id]==-1 && land_properties [landscape[x[id]][y[id]]].is_water). 

.  ouhgh
     {new_order (id, cmd_die, none, none);
     }.
        
.  exec_cmd
     {switch (cmd [id][0])
        {case cmd_move_to       : cata_handle_move_to;    break;
         case cmd_perform_steps : cata_handle_steps;      break;
         case cmd_fad           : archer_sad (id, true);  break;
         case cmd_sad           : archer_sad (id, false); break;
         case cmd_attack        : archer_attack  (id);    break;
         case cmd_hit           : exec_archer_hit (id);   break;
         case cmd_guard         : 
         case cmd_idle          : cata_handle_idle;       break;
         case cmd_talk          : exec_talk (id);         break;
         case cmd_stop          : cata_handle_stop;       break;
         case cmd_load          : exec_cata_load (id);    break;
         case cmd_wait          : cata_handle_wait;       break;
        };
     }.
   
.  consume_food
     {double f = player_food;

      if   (player_food <= 0)
           reduce_health
      else reduce_food;
     }.

.  reduce_health
     {health  [id] = i_max (0, health [id] -1);
      version [id]++;
     }.

.  reduce_food
     {player_food -= (double) speed_cata / (double) speed_farm;
     }.

.  player_food
     players [color_player [color [id]]]->food.

.  cata_handle_stop
     {pop_order (id);
     }.

.  cata_handle_idle
     {int p = pic [id] - pic_cata_idle (color [id]);

      if   (! is_idle_pic)
           set_idle_pick;
      grab_new_enemy;
      if (players [color_player [color [id]]]->is_robot && ! is_water_world)
         players [color_player [color [id]]]->rob->urgent = id;      
     }.

.  grab_new_enemy           
     {if   (ex [id] != none)
           perhaps_attack
      else look_for_enemy
      ex [id] = none;
     }.

.  look_for_enemy
     {bool over = false;

      for (int h = 0; h < max_objects/look_n && ! over; h++)
        try_look;
     }.

.  try_look
     {int e;

      t [id]++;
      if (t [id] < 0 || t [id] >= max_objects)
         t [id] = 0;
      e = t [id];
      if (any_enemy)
         grab_enemy;
     }.

.  any_enemy
     (! is_free [e]                    && 
      color [e]   != color [id]        && 
      type  [e]   != object_mine       &&
      on_ship [e] == -1                &&
      type  [e]   != object_ship_zombi && 
      type  [e]   != object_zombi      && 
      type  [e]   != object_schrott    && 
      (type [e] != object_ship1  || ! s [e]->empty ()) &&
      (type [e] == object_doktor || i_random (0, 100) > 30)).

.  grab_enemy
     {int u;

      ex [id] = x  [e];
      ey [id] = y  [e];
      u       = unit [ex [id]][ey [id]];
      if (type [e] == object_ship1)
         {ex [id]++;
          ey [id]++;
         };
      if (near_by)
         perhaps_attack;
     }.

.  perhaps_attack
     {int u = unit [ex [id]][ey [id]];

      if (u != none               &&
          u != id                 &&
          near_by                 &&
          color [id] != color [u] &&
          ! hidden)
         attack_archer;
     }.

.  hidden
     (type [u] == object_scout && wood [u] == 1).

.  near_by
     (dist (x [id], y [id], ex [id], ey [id]) <= scope_cata+1 &&
      u != none &&
      (type [u] != object_ship1 || ! s [u]->empty ())).

.  attack_archer
     {push_order (id, cmd_attack, ex [id], ey [id]);
      attack_x_min [id] = ex [id];
      attack_y_min [id] = ey [id];
      attack_x_max [id] = ex [id];
      attack_y_max [id] = ey [id];
      in_formation [id] = true;
      moving_goal  [id] = u;
      moving_id    [id] = oid [u];
     }.

.  is_idle_pic
     (0 <= p && p <= 30).

.  set_idle_pick
     {int dx;
      int dy;

      dir_dx_dy    (dir [id], dx, dy);
      set_move_pic (id, pic_cata_idle (color [id]), 0, dx, dy);
      refresh      (x [id], y [id]);
     }.

.  cata_handle_move_to
     {if   (support [id] == 1)
           perform_move_to
      else pop_order (id);
     }.

.  perform_move_to
     {int dx;
      int dy;
      int goal_dist;
      int max_d;

      if      ((cmd [id][1] == cmd_attack || 
               cmd [id][1] == cmd_sad    ||
               cmd [id][1] == cmd_fad) &&
               moving_goal [id] != none &&
               moving_id [id] == oid [moving_goal [id]])
              {gx [id][0] = x [moving_goal [id]];
               gy [id][0] = y [moving_goal [id]];
               pop_order (id);
              }
      else if (players [color_player [color [id]]]->is_robot)
              max_d = 3;
      else    max_d = 5000;
      dir_dx_dy (dir [id], dx, dy);
      calc_goal_dist;
      if      (at_goal)
              pop_order (id);
      else if (! move_to_possible && 
               ! players [color_player [color [id]]]->is_robot)
              {pop_order  (id);
               delay_wait (id);
              }
      else if (no_cata_way)
              handle_no_way;
     }.

.  handle_no_way
     {if   (landscape [x_no_way][y_no_way] == land_water ||
            landscape [x_no_way][y_no_way] == land_sea   ||
            robot_waits_to_long                          ||
            landscape [x_no_way][y_no_way] == land_wall)
           new_order (id, cmd_idle, 0, 0);
      else {pop_order  (id);
            delay_wait (id);
           };
     }.

.  robot_waits_to_long
     (players [color_player [color [id]]]->is_robot && delay [id] > 5).

.  move_to_possible
     (land_properties [landscape [gx [id][0]][gy [id][0]]].walk_possible ||
      enter_ship                                                         ||
      landscape [gx [id][0]][gy [id][0]] == land_building).

.  at_goal
     (x [id] == gx [id][0] && y [id] == gy [id][0]).

.  calc_goal_dist
     {if (cmd [id][1] == cmd_attack)
           goal_dist = scope_cata;
      else goal_dist = 0;
     }.

.  no_cata_way
    ! ((goal_free||far_away) && man_plan_path (id,goal_dist,max_d, false)).

.  goal_free
     (unit [gx [id][0]][gy [id][0]] == none ||
      enter_ship                            ||
      is_g_moving (unit [gx [id][0]][gy [id][0]])).

.  enter_ship 
      (uu != none && type [uu] == object_ship1).

.  uu unit [gx [id][0]][gy [id][0]].

.  far_away
     ((int) dist (x [id], y [id], gx [id][0], gy [id][0]) > scope_cata).

.  cata_handle_steps
     {exec_step;
      handle_t;
     }.

.  handle_t
     {t [id]--;
      if (t [id] == 0)
         next_step;
     }.

.  next_step
     {t [id] = step_t;
      xpop (step [id]);
     }.

.  exec_step
     {if   (step [id][0] == step_over)
           cata_step_over
      else cata_step_somewhere;
     }.

.  cata_step_somewhere
     {int dx;
      int dy;

      speed [id] = speed_cata;
      dir_dx_dy (step [id][0], dx, dy);
      man_step  (id, dx, dy);
     }. 

.  cata_handle_wait
     {if   (gx [id][0] == 0)
           pop_order (id);
      else gx [id][0]--;
     }. 

.  cata_step_over
     {pop_order (id);
      delay [id] = 3;
     }.

  }

void object_handler::exec_cata_load (int id)
  {if      (t [id] == duration_hit-1) start_load
   else if (t [id] == 0)            finish_load
   else                             set_load_pic;
   t [id]--;

.  start_load
     {speed [id] = speed_cata_load;
     }.

.  finish_load
     {pop_order (id);
      speed [id] = speed_cata;
     }.

.  set_load_pic
     {int dx;
      int dy;

      dir_dx_dy    (dir [id], dx, dy);
      set_move_pic (id, pic_cata_fight (color [id]),(t [id] - 1), dx, dy);
      refresh      (x [id], y [id]);
     }.

  }

/*--- cata / archer -----------------------------------------------------*/

void object_handler::archer_sad (int id, bool follow)
  {int eid;

   look_for_enemy;
   if   (eid != none)
        push_attack
   else push_order (id, cmd_wait, i_random (3, 10), 0);
 
.  look_for_enemy
     {double best_dist = DBL_MAX;

      eid = none;
      for (int i = 0; i < max_objects; i++)
        check_object;
     }.

.  check_object
     {if (nice_enemy)
         grab_it;
     }.

.  grab_it
     {eid       = i;
      best_dist = act_dist;
     }.

.  nice_enemy
     (! is_free [i]                  &&
      color [i] != color [id]        &&
      type  [i] != object_mine       && 
      type  [i] != object_zombi      && 
      type  [i] != object_ship_zombi && 
      type  [i] != object_schrott    && 
      center_dist < sad_radius       &&
      act_dist    < best_dist).

.  act_dist
     dist (x [id], y [id], x [i], y [i]).

.  center_dist
     i_max (i_abs (gx [id][0] - x [i]), i_abs (gy [id][0] - y [i])).

.  push_attack      
     {push_order (id, cmd_attack, x [eid], y [eid]);
      if   (! follow)
           set_local_range
      else set_global_range;
      in_formation [id] = false;
      moving_goal  [id] = eid;
      moving_id    [id] = oid [eid];
     }.

.  set_local_range
     {attack_x_min [id] = gx [id][0] - sad_radius;
      attack_y_min [id] = gy [id][0] - sad_radius;
      attack_x_max [id] = gx [id][0] + sad_radius;
      attack_y_max [id] = gy [id][0] + sad_radius;
     }.

.  set_global_range
     {attack_x_min [id] = 0;
      attack_y_min [id] = 0;
      attack_x_max [id] = landscape_dx - 1;
      attack_y_max [id] = landscape_dy - 1;
     }.

  }

void object_handler::archer_attack (int id)
  {int weapon_dist;

   calc_weapon_dist;
   if   (at_goal)
        try_to_attack
   else try_to_move_to_goal;

.  readjust_goal_point
     {int uu = unit [gx [id][0]][gy [id][0]];

      if (type [uu] == object_ship1)
         {gx [id][0] = x [uu] + 1;
          gy [id][0] = y [uu] + 1;
         };
     }.

.  calc_weapon_dist
     {if   (type [id] == object_cata)
           weapon_dist = scope_cata;
      else weapon_dist = scope_archer;
     }.

.  at_goal
     (int) dist (x [id], y [id], gx [id][0], gy [id][0]) <= weapon_dist &&
     g_archer_can_attack.

.  g_archer_can_attack
     (type [id] != object_archer ||
      i_max (0, landhight [gx [id][0]][gy [id][0]]) - 
      i_max (0, landhight [x [id]][y [id]]) < 3).

.  at_m_goal
     dist (x [id], y [id], x [moving_goal[id]], y [moving_goal [id]])
       <= weapon_dist.

.  try_to_attack
     {int u = unit [gx [id][0]][gy [id][0]];

      if      (u != none &&
               ((type [id] == object_cata && 
                dist (x [id], y [id], gx [id][0], gy [id][0]) < 2) ||
               type [u] == object_ship1 && color [u] == color [id]))
              {pop_order (id);
               moving_goal [id] = none;
              }
      else if (cata_can_attack || archer_can_attack)
              perform_attack
      else    suspend_attack;
     }.

.  archer_can_attack
     (u              != none              &&
      type [u]       != object_mine       && 
      type [u]       != object_zombi      && 
      type [u]       != object_ship_zombi && 
      type [u]       != object_schrott    && 
      u              == moving_goal [id]  &&
      moving_id [id] == oid [u]).

.  cata_can_attack
     (type [id] == object_cata &&
      moving_goal [id] == none &&
      landscape [gx [id][0]][gy [id][0]] == land_wall).

.  perform_attack
     {push_order (id, cmd_hit, gx [id][0], gy [id][0]);
      t [id] = duration_hit;
     }.

.  try_to_move_to_goal
     {if   (in_formation [id])
           {pop_order (id);
            moving_goal [id] = none;
           }
      else perform_move_to_steps;
     }.

.  perform_move_to_steps
     {int edx;
      int edy;

      if   (direct_move (id, weapon_dist-1, edx, edy)) 
           perform_direct_move
      else push_order (id, cmd_move_to, gx [id][0], gy [id][0]);
     }.

.  perform_direct_move
     {step [id][0] = direction (edx, edy);
      step [id][1] = step_over;
      t    [id]    = step_t;
      push_order (id, cmd_perform_steps, 0, 0);
      age  [id]    = speed [id] - 1;
     }.
 
.  suspend_attack
     {int mg = moving_goal [id];
      int tg;
 
      if (mg != none)
         tg = type [mg];
      if   (mg                            != none              &&
            moving_id [id]                == oid [mg]          &&
            ! is_free [mg]                                     &&
            color [mg]                    != color [id]        &&
            tg                            != object_zombi      && 
            tg                            != object_ship_zombi && 
            tg                            != object_schrott    && 
            tg                            != object_mine       && 
            tg                            != object_arrow      && 
            tg                            != object_stone      && 
            unit [gx [id][0]][gy [id][0]] != mg &&
            (at_m_goal || type [id] == object_archer))
            readjust_goal
      else {pop_order (id);
            moving_goal [id] = none;
           };
     }.

.  readjust_goal
     {gx [id][0] = x [moving_goal [id]];
      gy [id][0] = y [moving_goal [id]];
      if (type [moving_goal [id]] == object_ship1)
         {gx [id][0] = x [moving_goal [id]] + 1;
          gy [id][0] = y [moving_goal [id]] + 1;
         };
      perform_attack;
     }.

  }

void object_handler::exec_archer_hit (int id)
  {if      (t [id] == duration_hit) start_hit
   else if (t [id] == 0)            finish_hit
   else                             set_hit_pic;
   t [id]--;

.  start_hit
     {switch (type [id]) 
        {case object_archer : speed [id] = speed_archer_hit; break;
         case object_cata   : speed [id] = 3;                break;
        };
      dir   [id] = fdir (gx [id][0] - x [id], gy [id][0] - y [id]);
     }.

.  finish_hit
     {int u = unit [gx [id][0]][gy [id][0]];
      int weapon_dist;

      calc_weapon_dist; 
      if   (u != id && (u != none || cata_can_attack) && dist_ok)
           try_to_hit_unit
      else perhaps_readjust_goal;
      pop_order  (id);
      handle_load;
     }.

.  cata_can_attack
     (type [id] == object_cata &&
      moving_goal [id] == none &&
      landscape [gx [id][0]][gy [id][0]] == land_wall).

.  dist_ok
     (int) dist (x [id], y [id], gx [id][0], gy [id][0]) <= weapon_dist.

.  handle_load
     {switch (type [id]) 
        {case object_archer : push_order (id, cmd_wait, i_random (1, 3), 0);
                              break;
         case object_cata   : push_order (id, cmd_load, none, none);
                              t [id] = duration_hit;
                              break;
        };
     }.

.  perhaps_readjust_goal
     {if (moving_goal [id] != none     &&
          ! is_free [moving_goal [id]] &&
          moving_id [id] == oid [moving_goal [id]] &&
          type [moving_goal [id]] != object_zombi  &&
          type [moving_goal [id]] != object_ship_zombi)
         readjust_goal;
     }.

.  readjust_goal
     {gx [id][0] = x [moving_goal [id]];
      gy [id][0] = y [moving_goal [id]];
      u = unit [gx [id][0]][gy [id][0]];
      if (dist_ok)
         try_to_hit_unit;
     }.

.  calc_weapon_dist
     {if   (type [id] == object_cata)
           weapon_dist = scope_cata;
      else weapon_dist = scope_archer;
     }.

.  try_to_hit_unit
     {switch (type [id]) 
        {case object_archer : start_arrow; break;
         case object_cata   : start_stone; break;
        };
     }.

.  start_stone
     {create_stone (x [id], y [id], gx [id][0], gy [id][0], id);
     }.

.  start_arrow
     {create_arrow (x [id], y [id], gx [id][0], gy [id][0], id);
     }.

.  set_hit_pic
     {switch (type [id]) 
        {case object_archer : set_move_pic (id,
                                            pic_archer_fight (color [id]),
                                            i_bound (0, 
                                                     6 - (t [id] - 1),
                                                     6),
                                            gx [id][0] - x [id],
                                            gy [id][0] - y [id]);
                              break;
         case object_cata   : set_move_pic (id,
                                            pic_cata_fight (color [id]),
                                            i_bound (0, 
                                                     6 - (t [id] - 1),
                                                     6),
                                            gx [id][0] - x [id],
                                            gy [id][0] - y [id]);
                              break;
        };
      refresh (x [id], y [id]);
     }.

  }

/*--- doktors -----------------------------------------------------------*/

int object_handler::create_doktor (int  p_x,
                                   int  p_y, 
                                   int  p_color,
                                   int  home_no, 
                                   bool is_master)

  {int id;

   check_num_mans;
   id = create_object ();
   if (id != none)
      add_doktor_data;
   return id;

.  check_num_mans
     {int p = color_player [p_color];

      if (players [p]->num_mans >= max_num_mans)
         handle_to_many_mans;
     }.

.  handle_to_many_mans
     {write (p_color, "Too many mans");
      return none;
     }.

.  add_doktor_data
     {add_object_data;
      add_to_land;
     }.

.  add_object_data
     {strcpy (name [id], "scientist");
      color         [id]    = p_color;
      with_overview [id]    = true;
      is_marked     [id]    = false;
      type          [id]    = object_doktor;
      pic           [id]    = pic_doktor_idle (color [id]);
      x             [id]    = p_x;
      y             [id]    = p_y;
      wx            [id]    = x_center (p_x);
      wy            [id]    = y_center (p_y);
      dir           [id]    = 0;
      cmd           [id][0] = cmd_idle;
      t             [id]    = ticker;
      health        [id]    = 100;
      power         [id]    = 50;
      speed         [id]    = speed_doktor;
      wood          [id]    = 0;
      money         [id]    = 0;
      version       [id]    = 0;
      interrupted   [id]    = false;
      home_id       [id]    = home_no;
      master        [id]    = is_master;
      idle_attack_r [id]    = 1;
      harvest_type  [id]    = -1;
      vr            [id]    = vr_man;
      players [color_player [p_color]]->num_mans++;
      players [color_player [p_color]]->add_sun (p_x, p_y, vr [id]);
     }.

.  add_to_land
     {unit [p_x][p_y] = id;
      land_push (id, p_x, p_y, 0, 0);
      refresh   (x [id], y [id]);
     }.
  
  }

void object_handler::exec_doktor (int id)
  {consume_food;
   check_health;
   exec_cmd;

.  check_health
     {if (health [id] <= 0 || on_water)
         ouhgh;
     }.

.  on_water
     (on_ship [id]==-1 && land_properties [landscape[x[id]][y[id]]].is_water). 

.  ouhgh
     {new_order (id, cmd_die, none, none);
     }.
        
.  exec_cmd
     {switch (cmd [id][0])
        {case cmd_move_to       : doktor_handle_move_to; break;
         case cmd_perform_steps : doktor_handle_steps;   break;
         case cmd_sad           : doktor_sad     (id);   break;
         case cmd_heal          : doktor_attack  (id);   break;
         case cmd_hit           : exec_doktor_hit (id);  break;
         case cmd_guard         :
         case cmd_idle          : doktor_handle_idle;    break;
         case cmd_talk          : exec_talk (id);        break;
         case cmd_stop          : doktor_handle_stop;    break;
         case cmd_wait          : doktor_handle_wait;    break;
        };
     }.
   
.  consume_food
     {double f = player_food;

      if   (player_food <= 0)
           reduce_health
      else reduce_food;
     }.

.  reduce_health
     {health  [id] = i_max (0, health [id] - 1);
      version [id]++;
     }.

.  reduce_food
     {player_food -= (double) speed_doktor / (double) speed_farm;
     }.

.  player_food
     players [color_player [color [id]]]->food.

.  doktor_handle_stop
     {pop_order (id);
     }.

.  doktor_handle_idle
     {int p = pic [id] - pic_doktor_idle (color [id]);

      if (! is_idle_pic)
         set_idle_pick;
      look_for_patient;
     }.

.  look_for_patient
     {bool over = false;

      for (int h = 0; h < max_objects/look_n && ! over; h++)
        try_look;
     }.

.  try_look
     {int e;

      t [id]++;
      if (t [id] < 0 || t [id] >= max_objects)
         t [id] = 0;
      e = t [id];
      if (any_enemy)
         grab_enemy;
     }.

.  any_enemy
     (! is_free [e]                   && 
      color  [e] == color [id]        && 
      type   [e] != object_mine       &&
      type   [e] != object_zombi      && 
      type   [e] != object_ship_zombi && 
      type   [e] != object_schrott    &&
      type   [e] != object_ship1      &&
      hight_ok                        &&
      health [e] < 100). 

.  hight_ok
     (i_abs (landhight [x [id]][y [id]] - landhight [x [e]] [y [e]]) < 2).

.  grab_enemy
     {ex [id] = x [e];
      ey [id] = y [e];
      if (near_by)
         perhaps_attack;
     }.

.  perhaps_attack
     {int u = e;

     if (u != none && u != id && color [u] == color [id])
         attack_archer;
     }.

.  near_by
     (is_neighbor || guard_event || 
      (on_ship [id] != -1 && on_ship [id] == on_ship [e])).

.  guard_event
     (cmd [id][0] == cmd_guard &&
      i_abs (x [id] - ex [id]) <= guard_range &&
      i_abs (y [id] - ey [id]) <= guard_range).

.  is_neighbor
     (i_abs (x [id] - ex [id]) <= idle_attack_r [id] &&
      i_abs (y [id] - ey [id]) <= idle_attack_r [id]).

.  attack_archer
     {push_order (id, cmd_heal, ex [id], ey [id]);
      attack_x_min [id] = ex [id] - 2;
      attack_y_min [id] = ey [id] - 2;
      attack_x_max [id] = ex [id] + 2;
      attack_y_max [id] = ey [id] + 2;
      in_formation [id] = idle_attack_r [id] <= 1 && cmd [id][1] != cmd_guard;
      moving_goal  [id] = u;
      moving_id    [id] = oid [u];
     }.

.  is_idle_pic
     (0 <= p && p <= 30).

.  set_idle_pick
     {int dx;
      int dy;

      dir_dx_dy    (dir [id], dx, dy);
      set_move_pic (id, pic_doktor_idle (color [id]), 0, dx, dy);
      refresh      (x [id], y [id]);
     }.

.  doktor_handle_move_to
     {int dx;
      int dy;
      int max_d;
      int uu1;

      if ((cmd [id][1] == cmd_attack || 
          cmd [id][1] == cmd_sad    ||
          cmd [id][1] == cmd_fad) &&
           moving_goal [id] != none &&
           moving_id [id] == oid [moving_goal [id]])
         {gx [id][0] = x [moving_goal [id]];
          gy [id][0] = y [moving_goal [id]];
          uu1        = unit [gx [id][0]][gy [id][0]];
          if   (uu1 != none)
               max_d = i_max (2,(int) dist (x [uu1], y [uu1],x [id],y [id])/2);
          else max_d = 2;
         }
      else max_d = 5000;
      dir_dx_dy (dir [id], dx, dy);
      if      (at_goal)
              pop_order (id);
      else if (! move_to_possible && 
               ! players [color_player [color [id]]]->is_robot)
              {pop_order  (id);
               delay_wait (id);
              }
      else if (no_doktor_way)
              handle_no_way;
     }.

.  handle_no_way
     {if   (landscape [x_no_way][y_no_way] == land_water ||
            landscape [x_no_way][y_no_way] == land_sea   ||
            robot_waits_to_long                          ||
            landscape [x_no_way][y_no_way] == land_wall)
           new_order (id, cmd_idle, 0, 0);
      else {pop_order  (id);
            delay_wait (id);
           };
     }.

.  robot_waits_to_long
     (players [color_player [color [id]]]->is_robot && delay [id] > 5).

.  move_to_possible
     (land_properties [landscape [gx [id][0]][gy [id][0]]].walk_possible ||
      enter_ship                                                         ||
      landscape [gx [id][0]][gy [id][0]] == land_building).

.  at_goal
     ((x [id] == gx [id][0] && y [id] == gy [id][0]) ||
      (uu != none && type [uu] == object_ship1 && on_ship [id] == uu)).

.  no_doktor_way
    ! ((goal_free || far_away) && man_plan_path (id,0,max_d, false)).

.  goal_free
     (unit [gx [id][0]][gy [id][0]] == none ||
      enter_ship                            ||
      is_g_moving (unit [gx [id][0]][gy [id][0]])).

.  enter_ship 
      (uu != none && type [uu] == object_ship1).

.  uu unit [gx [id][0]][gy [id][0]].

.  far_away
     ((i_abs (x [id] - gx [id][0]) > 1) || (i_abs (y [id] - gy [id][0]) > 1)).

.  doktor_handle_steps
     {exec_step;
      handle_t;
     }.

.  handle_t
     {t [id]--;
      if (t [id] == 0)
         next_step;
     }.

.  next_step
     {t [id] = step_t;
      xpop (step [id]);
     }.

.  exec_step
     {if   (step [id][0] == step_over)
           doktor_step_over
      else doktor_step_somewhere;
     }.

.  doktor_step_somewhere
     {int dx;
      int dy;

      dir_dx_dy (step [id][0], dx, dy);
      man_step  (id, dx, dy);
     }. 

.  doktor_handle_wait
     {if   (gx [id][0] == 0)
           pop_order (id);
      else gx [id][0]--;
     }. 

.  doktor_step_over
     {pop_order (id);
      delay [id] = 3;
     }.

  }

void object_handler::doktor_sad (int id)
  {int eid;

   look_for_enemy;
   if   (eid != none)
        push_attack
   else push_order (id, cmd_wait, i_random (3, 10), 0);
 
.  look_for_enemy
     {double best_dist = DBL_MAX;

      eid = none;
      for (int i = 0; i < max_objects; i++)
        check_object;
     }.

.  check_object
     {if (nice_enemy)
         grab_it;
     }.

.  grab_it
     {eid       = i;
      best_dist = act_dist;
     }.

.  nice_enemy
     (! is_free [i]                                           &&
      ((color [i] == color [id] && health [i] < 100) ||
        color [i] != color [id] && type [i] == object_worker) &&
      type  [i] != object_mine                                && 
      type  [i] != object_zombi                               && 
      type  [i] != object_ship_zombi                          && 
      type  [i] != object_schrott                             && 
      center_dist < sad_radius                                &&
      act_dist    < best_dist).

.  act_dist
     dist (x [id], y [id], x [i], y [i]).

.  center_dist
     i_max (i_abs (gx [id][0] - x [i]), i_abs (gy [id][0] - y [i])).

.  push_attack      
     {push_order (id, cmd_heal, x [eid], y [eid]);
      attack_x_min [id] = gx [id][0] - sad_radius;
      attack_y_min [id] = gy [id][0] - sad_radius;
      attack_x_max [id] = gx [id][0] + sad_radius;
      attack_y_max [id] = gy [id][0] + sad_radius;
      in_formation [id] = false;
      moving_goal  [id] = eid;
      moving_id    [id] = oid [eid];
     }.

  }

void object_handler::doktor_attack (int id)
  {if   (at_goal)
        try_to_attack
   else try_to_move_to_goal;

.  at_goal
     (((i_abs (x [id]-gx [id][0]) < 2) && (i_abs (y [id]-gy [id][0]) < 2)) ||
      on_ship_target).

.  try_to_attack
     {int u = unit [gx [id][0]][gy [id][0]];

      if   (land_target || on_ship_target)
           perform_attack
      else suspend_attack;
     }.

.  land_target
     (u              != none             && 
      u              == moving_goal [id] && 
      moving_id [id] == oid [u]          &&
      type      [u]  != object_ship1).

.  on_ship_target
     (moving_goal [id] != none     &&
      ! is_free [moving_goal [id]] &&
      on_ship [id] != -1           &&
      on_ship [id] == on_ship [moving_goal [id]]).

.  perform_attack
     {push_order (id, cmd_hit, gx [id][0], gy [id][0]);
      t [id] = duration_hit;
     }.

.  try_to_move_to_goal
     {if   (out_of_range)
           {pop_order (id);
            moving_goal [id] = none;
           }
      else perform_move_to_steps;
     }.

.  perform_move_to_steps
     {int edx;
      int edy;

      speed [id] = speed_doktor;
      if   (direct_move (id, 1, edx, edy)) 
           perform_direct_move
      else push_order (id, cmd_move_to, gx [id][0], gy [id][0]);
     }.

.  perform_direct_move
     {step [id][0] = direction (edx, edy);
      step [id][1] = step_over;
      t    [id]    = step_t;
      push_order (id, cmd_perform_steps, 0, 0);
      age  [id]    = speed [id] - 1;
     }.

.  out_of_range
     (gx [id][0] < attack_x_min [id] || gx [id][0] > attack_x_max [id] ||
      gy [id][0] < attack_y_min [id] || gy [id][0] > attack_y_max [id]).

.  suspend_attack
     {if      (moving_goal [id] != none && 
               ! is_free [moving_goal [id]] &&
               moving_id [id] == oid [moving_goal [id]]     &&
               type [moving_goal [id]] != object_zombi      && 
               type [moving_goal [id]] != object_ship_zombi && 
               type [moving_goal [id]] != object_schrott    && 
               unit [gx [id][0]][gy [id][0]] != moving_goal [id])
               readjust_goal
      else    {pop_order (id);
               moving_goal [id] = none;
              };
     }.

.  readjust_goal
     {gx [id][0] = x [moving_goal [id]];
      gy [id][0] = y [moving_goal [id]];
     }.

  }

void object_handler::exec_doktor_hit (int id)
  {if      (t [id] == duration_hit) start_hit
   else if (t [id] == 0)            finish_hit
   else                             set_hit_pic;
   t [id]--;

.  start_hit
     {speed [id] = speed_doktor_hit;
      dir   [id] = fdir (gx [id][0] - x [id], gy [id][0] - y [id]);
     }.

.  finish_hit
     {int u = unit [gx [id][0]][gy [id][0]];
 
      if (land_target) 
         try_to_hit_unit;
      if (on_ship_target)
         try_to_hit_crew;
      pop_order  (id);
     }.

.  land_target
     (u              != none &&
      u              == moving_goal [id] && 
      moving_id [id] == oid [u] &&
      hight_ok).


.  hight_ok
     (i_abs (landhight [x [id]][y [id]] -
             landhight [gx [id][0]][gy [id][0]]) < 2).

.  on_ship_target
     (moving_goal [id] != none     &&
      ! is_free [moving_goal [id]] &&
      on_ship [id] != -1           &&
      on_ship [id] == on_ship [moving_goal [id]]).
    
.  try_to_hit_crew
     {u = moving_goal [id];
      try_to_hit_unit;
     }.

.  try_to_hit_unit
     {if       (color [u] == color [id])
               try_heal
      else if (color [u] != color [id]    &&
               type  [u] == object_worker &&
               players [color_player [color [id]]]->num_mans < max_num_mans)
              capture;
     }.

.  capture
     {players [color_player [color [id]]]->num_mans++;
      players [color_player [color [u]]] ->num_mans--;
      players [color_player [color [u]]]->sub_sun (x [id], y [id], vr [id]);
      color     [u] = color [id];
      players [color_player [color [id]]]->add_sun (x [id], y [id], vr [id]);
      is_marked [u] = false;
      version   [u]++;
      pop_order (id);
     }.

.  try_heal
     {if   (health [u] < 100 && u != id)
           {if   (on_ship [id])
                 health  [u] = i_min (100, health [u] + 20);
            else health  [u] = 100;
            version [u]++;
            if (on_ship [u] != -1)
               version [on_ship [u]]++;
           }
      else pop_order (id);
     }.

.  set_hit_pic
     {set_move_pic (id, pic_doktor_fight(color [id]) ,
                    6 - (t [id] - 1),
                    gx [id][0] - x [id],
                    gy [id][0] - y [id]);
      if (on_ship [id] == -1)
         refresh (x [id], y [id]);
     }.

  }

/*--- arrow ------------------------------------------------------------*/

int object_handler::create_arrow (int ax, int ay, int agx, int agy, int aid)
  {int id;

   id = create_object ();
   if (id != none)
      add_arrow_data;
   return id;

.  add_arrow_data
     {add_object_data;
      add_to_land;
     }.

.  add_object_data
     {strcpy (name [id], "arrow");
      type    [id]    = object_arrow;
      dir     [id]    = fdir (agx - ax, agy - ay);
      pic     [id]    = i_bound (pic_arrow, pic_arrow + dir [id], pic_arrow+7);
      x       [id]    = ax;
      y       [id]    = ay;
      ex      [id]    = ax;
      ey      [id]    = ay;
      gx      [id][0] = agx;
      gy      [id][0] = agy;
      wx      [id]    = x_center (ax);
      wy      [id]    = y_center (ay);
      cmd     [id][0] = cmd_perform_steps;
      t       [id]    = 0;
      home_id [id]    = aid;
      speed   [id]    = speed_arrow;
      buf     [id]    = landhight [ax][ay];
      power   [id]    = 0;
      if   (unit [ax][ay] != none && type [unit [ax][ay]] == object_ship1)
           {x  [id] += i_random (-1, 1);
            y  [id] += i_random (-1, 1);
            ex [id] =  x [id];
            ey [id] =  y [id];
            wx [id] =  x_center (x [id]);
            wy [id] =  y_center (y [id]);
           };
     }.

.  add_to_land
     {land_push (id, x [id], y [id], 0, 0);
      refresh   (x [id], y [id]);
     }.

  }

void object_handler::exec_arrow (int id)
  {if   (at_goal)
        handle_hit
   else handle_move;

.  at_goal
     (x [id] == gx [id][0] && y [id] == gy [id][0]).
     
.  handle_hit
     {int u = unit [x [id]][y [id]];

      if (u != none && (power [id] == 0))
         hit (home_id [id], u, power_arrow);
      remove_arrow;
     }.

.  handle_move
     {double dx  = x_center (gx [id][0]) - wx [id];
      double dy  = y_center (gy [id][0]) - wy [id];
      double dd  = d_max (d_abs (dx), d_abs (dy)) / 15.0;   
      int    dxx = (int) d_sign (dx);
      int    dyy = (int) d_sign (dy);
      int    xx;
      int    yy; 
     
      dx = d_abs (dx);
      dy = d_abs (dy);
      wx [id] += (int) (d_min (dx, dx / dd) * dxx);
      wy [id] += (int) (d_min (dy, dy / dd) * dyy);
      xx      =  x_grid (wx [id]);
      yy      =  y_grid (wy [id]);
      if (xx != x [id] || yy != y [id])
         enter_new_field;
      refresh (xx, yy, 1, 1);
     }.

.  enter_new_field 
     {land_pop  (id, x [id], y [id], 1, 1);
      land_pop  (id, x [id], y [id]);
      refresh   (x [id], y [id], 1, 1);
      land_push (id, xx, yy,  1, 1);
      refresh   (xx, yy, 1, 1);
      x [id] = xx;
      y [id] = yy;
      t [id]++;
      if (landhight [xx][yy] - i_max (1, landhight [ex [id]][ey [id]]) > 2)
         {gx    [id][0] = xx;
          gy    [id][0] = yy;
          power [id]    = 1;
         };
      if (! move_possible)
         remove_arrow;
     }.

.  move_possible
      (0 <= xx && xx < landscape_dx && 0 <= yy && yy < landscape_dy).

.  remove_arrow
     {int dx;
      int dy;

      dir_dx_dy     (dir [id], dx, dy);
      land_pop      (id, x [id], y [id]);
      land_pop      (id, x [id], y [id], 1, 1);
      refresh       (x [id], y [id], 1, 1);
      delete_object (id); 
     }.

  }

/*--- stone ------------------------------------------------------------*/

int object_handler::create_stone (int ax, int ay, int agx, int agy, int aid)
  {int id;

   id = create_object ();
   if (id != none)
      add_stone_data;
   return id;

.  add_stone_data
     {add_object_data;
      add_to_land;
     }.

.  add_object_data
     {strcpy (name [id], "stone");
      type    [id]    = object_stone;
      dir     [id]    = direction (agx - ax, agy - ay);
      pic     [id]    = pic_stone;
      x       [id]    = ax;
      y       [id]    = ay;
      gx      [id][0] = agx;
      gy      [id][0] = agy;
      ex      [id]    = ax;
      ey      [id]    = ay;
      wx      [id]    = x_center (ax);
      wy      [id]    = y_center (ay);
      cmd     [id][0] = cmd_perform_steps;
      t       [id]    = 0;
      home_id [id]    = aid;
      speed   [id]    = speed_stone;
      buf     [id]    = (int) (d_goal / 20.0);
      power   [id]    = 0;
     }.

.  d_goal
     dist (x_center (gx [id][0]), y_center (gy [id][0]), wx [id], wy [id]).

.  add_to_land
     {land_push (id, ax, ay, 0, 0);
      refresh   (ax, ay);
     }.

  }

void object_handler::exec_stone (int id)
  {set_pic;
   if   (at_goal)
        handle_hit
   else handle_move;
   t [id]++;

.  set_pic 
     {pic [id] = i_bound (pic_stone, 
                          pic_stone+6-i_min (6, i_abs (buf [id] - t [id])/2),
                          pic_stone + 6);
     }.

.  at_goal
     (x [id] == gx [id][0] && y [id] == gy [id][0]).
     
.  handle_hit
     {int u = unit [x [id]][y [id]];

      if      (u != none && power [id] == 0)
              hit (home_id [id], u, power_stone);
      else if (landscape [x [id]][y [id]] == land_wall)
              handle_wall_hit;
      remove_stone;
     }.

.  handle_wall_hit
     {if (i_random (1, 100) > 50)
         readjust_land (x [id], y [id], -1);
     }.

.  handle_move
     {double dx  = x_center (gx [id][0]) - wx [id];
      double dy  = y_center (gy [id][0]) - wy [id];
      double dd  = d_max (d_abs (dx), d_abs (dy)) / 10.0;   
      int    dxx = (int) d_sign (dx);
      int    dyy = (int) d_sign (dy);
      int    xx;
      int    yy; 

      dx      =  d_abs (dx);
      dy      =  d_abs (dy);
      wx [id] += (int) (d_min (dx, dx / dd) * dxx);
      wy [id] += (int) (d_min (dy, dy / dd) * dyy);
      xx      =  x_grid (wx [id]);
      yy      =  y_grid (wy [id]);
      if (xx != x [id] || yy != y [id])
         enter_new_field;
      refresh (xx, yy, 1, 1);
     }.

.  enter_new_field 
     {bool move_possible;
  
      land_pop  (id, x [id], y [id], 1, 1);
      land_pop  (id, x [id], y [id]);
      refresh   (x [id], y [id], 1, 1);
      land_push (id, xx, yy,  1, 1);
      refresh   (xx, yy, 1, 1);
      check_move_possible;
      x [id] = xx;
      y [id] = yy;
      t [id]++;
      if (! move_possible)
         remove_stone;
      if (landhight [xx][yy] - i_max (1, landhight [ex [id]][ey [id]]) > 2 &&
          (landscape [gx [id][0]][gy [id][0]] != land_wall ||
           landscape [xx][yy] == land_wall))
         {gx    [id][0] = xx;
          gy    [id][0] = yy;
          power [id]    = 1;
         };
     }.

.  check_move_possible
     {move_possible = (0 <= xx && xx < landscape_dx &&
                       0 <= yy && yy < landscape_dy);
     }.

.  remove_stone
     {int dx;
      int dy;

      dir_dx_dy        (dir [id], dx, dy);
      land_pop         (id, x [id], y [id]);
      land_pop         (id, x [id], y [id], 1, 1);
      refresh          (x [id], y [id], 1, 1);
      delete_object    (id); 
      create_explosion (x [id], y [id]);
     }.

  }

/*--- fighter ----------------------------------------------------------*/

bool object_handler::direct_move (int id, int range, int &dx, int &dy)
  {int xx;
   int yy; 
   int cnt;
   
   init;
   dx = i_sign (gx [id][0] - xx);
   dy = i_sign (gy [id][0] - yy);
   while (! at_goal)
     {try_step;
     };
   return true;

.  init
     {xx  = x [id];
      yy  = y [id];
      cnt = 0;
     }.

.  at_goal
     ((i_abs (xx - gx [id][0]) <= range) &&
      (i_abs (yy - gy [id][0]) <= range) &&
      can_attack).
   
.  can_attack
     (knight_can_attack || archer_can_attack ||
       cata_can_attack || trader_can_move).

.  knight_can_attack
     ((type [id] == object_pawn  ||
      type [id] == object_knight ||
      type [id] == object_doktor) && 
      (i_abs (landhight [xx][yy]-landhight [gx[id][0]][gy[id][0]]) < 2)).

.  trader_can_move
     (type [id] == object_trader &&
      i_abs (landhight [xx][yy]-landhight [gx[id][0]][gy[id][0]]) < 2 &&
      (unit [xx][yy] == none || unit [xx][yy] == id)).

.  archer_can_attack
     (type [id] == object_archer &&
      (landhight [gx[id][0]][gy[id][0]] - landhight [xx][yy]) < 3).

.  cata_can_attack
     (type [id] == object_cata).

.  try_step
     {int xn = xx + i_sign (gx [id][0] - xx);
      int yn = yy + i_sign (gy [id][0] - yy);

      if   (walk_ok && no_hole && no_trap && unit [xn][yn] == none )
           do_step
      else return false;
     }.

.  walk_ok
     land_properties [landscape [xn][yn]].walk_possible.

.  no_trap
     ! (landscape [xx][yy] == land_trap &&
        is_a_trap [xx][yy]              &&
        players [color_player [color [id]]]->is_robot).

.  no_hole
     (i_abs (landhight [xx][yy] - landhight [xn][yn]) < 2).

.  do_step
     {xx = xn;
      yy = yn;
     }.
         
  }

void object_handler::fighter_sad (int id, bool follow)
  {int eid;

   look_for_enemy;
   if   (eid != none)
        push_attack
   else delay_wait (id);

.  look_for_enemy
     {double best_dist = DBL_MAX;

      eid = none;
      for (int i = 0; i < max_objects; i++)
        check_object;
     }.

.  check_object
     {if (nice_enemy)
         grab_it;
     }.

.  grab_it
     {eid       = i;
      best_dist = act_dist;
     }.

.  nice_enemy
     (! is_free [i]                  &&
      color [i] != color [id]        &&
      type  [i] != object_mine       && 
      type  [i] != object_zombi      && 
      type  [i] != object_ship_zombi && 
      type  [i] != object_schrott    && 
      center_dist < sad_radius       &&
      act_dist    < best_dist).

.  act_dist
     dist (x [id], y [id], x [i], y [i]).

.  center_dist
     i_max (i_abs (gx [id][0] - x [i]), i_abs (gy [id][0] - y [i])).

.  push_attack      
     {push_order (id, cmd_attack, x [eid], y [eid]);
      if   (! follow)
           set_local_range
      else set_global_range;
      in_formation [id] = false;
      moving_goal  [id] = eid;
      moving_id    [id] = oid [eid];
     }.

.  set_local_range
     {attack_x_min [id] = gx [id][0] - sad_radius;
      attack_y_min [id] = gy [id][0] - sad_radius;
      attack_x_max [id] = gx [id][0] + sad_radius;
      attack_y_max [id] = gy [id][0] + sad_radius;
     }.

.  set_global_range
     {attack_x_min [id] = 0;
      attack_y_min [id] = 0;
      attack_x_max [id] = landscape_dx - 1;
      attack_y_max [id] = landscape_dy - 1;
     }.

  }

void object_handler::fighter_attack (int id)
  {bool at_goal;

   if   (moving_goal [id] == none)
        end_attack
   else action;

.  end_attack
     {pop_order (id);
     }.

.  action
     {check_at_goal;
      if   (at_goal)
           try_to_attack
      else try_to_move_to_goal;
     }.

.  check_at_goal
     {int dx = i_sign (x [moving_goal [id]] - x [id]);
      int dy = i_sign (y [moving_goal [id]] - y [id]);
      int gu = unit [x [id] + dx][y [id] + dy];

      at_goal = land_goal_ok || ship_goal_ok;
     }.

.  ship_goal_ok
     (on_ship [id] != -1 && 
      color [moving_goal [id]] != color [id] &&
      type [moving_goal [id]] == object_ship1 &&
      ship_on_side (x [on_ship [id]], y [on_ship [id]],
                    moving_goal [id], gx [id][0], gy [id][0])).

.  land_goal_ok
     (gu == moving_goal [id]                                &&
      (color [gu] != color [id] || is_building (type [gu])) &&
      landhight_ok).

.  landhight_ok
     (i_abs (landhight [x[id]][y[id]]-landhight [gx[id][0]][gy[id][0]]) < 2 ||
      landscape [gx[id][0]][gy[id][0]] == land_water || 
      landscape [gx[id][0]][gy[id][0]] == land_sea).

.  try_to_attack
     {int u  = unit [gx [id][0]][gy [id][0]];
      int tg;

      if (u != none)
         tg = type [u];
      if   (u != none                 && 
            u == moving_goal [id]     &&
            moving_id [id] == oid [u] &&
            tg != object_zombi        && 
            tg != object_ship_zombi   && 
            tg != object_mine         && 
            tg != object_schrott      && 
            tg != object_stone        && 
            tg != object_arrow)
           perform_attack
      else suspend_attack;
     }.

.  perform_attack
     {push_order (id, cmd_hit, gx [id][0], gy [id][0]);
      t [id] = duration_hit;
     }.

.  try_to_move_to_goal
     {bool is_near_by;
      int  nb_goal;

      check_near_by;
      if      (is_near_by) 
              attack_near_by
      else if (in_formation [id] || out_of_range)
              {pop_order (id);
               moving_goal [id] = none;
              }
      else    perform_move_to_steps;
     }.

.  check_near_by
     {is_near_by = false;
      if (sad && ! out_of_range)
         look_for_nb_goal;
     }.

.  look_for_nb_goal
     {int xmin = i_max (x [id] - 1, 0);
      int xmax = i_min (x [id] + 2, landscape_dx-1);
      int ymin = i_max (y [id] - 1, 0);
      int ymax = i_min (y [id] + 2, landscape_dy-1);

      for (int xn = xmin; xn < xmax; xn++)
        for (int yn = ymin; yn < ymax; yn++)
          check_nb_field;
     }.

.  check_nb_field
     {int e  = unit [xn][yn];
      int te;

      if (e != none)
         te = type [e];
      if (e != none                      &&
          ! is_free [e]                  && 
          color [e] != color [id]        && 
          te        != object_mine       &&
          te        != object_zombi      && 
          te        != object_ship_zombi && 
          te        != object_schrott)
         {is_near_by = true;
          nb_goal    = e;
          gx [id][0] = xn;
          gy [id][0] = yn;
         };
     }.

.  sad
     (cmd [id][1]==cmd_sad || cmd [id][2]==cmd_sad ||
      cmd [id][1]==cmd_fad || cmd [id][2]==cmd_fad).

.  attack_near_by
     {moving_goal [id] = nb_goal;
     }.

.  perform_move_to_steps
     {int edx;
      int edy;
      int u  = moving_goal [id];
      int te;

      if (u != none)
         te = type [u];
      if   (u != none &&
            moving_id [id] == oid [u] &&
            ! is_free [u]             &&
            te != object_zombi        && 
            te != object_ship_zombi   && 
            te != object_mine         && 
            te != object_schrott      && 
            te != object_stone        && 
            te != object_arrow)
           {set_to_m_goal;
            if   (direct_move (id, 1, edx, edy)) 
                 perform_direct_move
            else push_order (id, cmd_move_to, gx [id][0], gy [id][0]);
           }
      else suspend_attack;
     }.

.  set_to_m_goal
     {gx [id][0] = x [u];
      gy [id][0] = y [u];
     }.

.  perform_direct_move
     {step [id][0] = direction (edx, edy);
      step [id][1] = step_over;
      t    [id]    = step_t;
      push_order (id, cmd_perform_steps, 0, 0);
      age  [id]    = speed [id] - 1;
     }.

.  out_of_range
     (gx [id][0] < attack_x_min [id] || gx [id][0] > attack_x_max [id] ||
      gy [id][0] < attack_y_min [id] || gy [id][0] > attack_y_max [id]).

.  suspend_attack
     {int mg = moving_goal [id];
      int tg;

      if (mg != none)
         tg = type [mg];
      if   (mg != none                                         &&
            moving_id [id]                == oid [mg]          &&
            color [mg]                    != color [id]        &&
            ! is_free [mg]                                     && 
            tg                            != object_zombi      && 
            tg                            != object_ship_zombi && 
            tg                            != object_mine       && 
            tg                            != object_schrott    && 
            tg                            != object_stone      && 
            tg                            != object_arrow      && 
            unit [gx [id][0]][gy [id][0]] != mg)
           readjust_goal
      else {pop_order (id);
            moving_goal [id] = none;
           };
     }.

.  readjust_goal
     {gx [id][0] = x [moving_goal [id]];
      gy [id][0] = y [moving_goal [id]];
     }.

  }

void object_handler::hit (int id, int e, int power)
   {int amour;

    if      (! is_free [e] && type [e] == object_ship1)
            s [e]->hit (id, power);
    else if (! is_free [e])
            hit_man;

.   hit_man
     {calc_amour;
      health  [e] = i_max (0, health [e] - i_max (1, (power - amour)));
      version [e]++;
      if (color [e] != color [id])
         {ex     [e] = x [id]; 
          ey     [e] = y [id];
          atta_x [e] = x [id]; 
          atta_y [e] = y [id];
         };
      if      (cmd [e][0] == cmd_wait && color [e] != none)
              {pop_order (e);
               perhaps_urgent;
              }
      else if (cmd [e][0] == cmd_idle && color [e] != none)
              perhaps_urgent;
     }.

.  perhaps_urgent
     {int pno = color_player [color [e]];

      if (players [pno]->is_robot)
         players [pno]->rob->urgent = e;      
     }.

.  calc_amour
     {switch (type [e])
        {case object_knight        : amour = amour_knight;   break;
         case object_pawn          : amour = amour_pawn;     break;
         case object_scout         : amour = amour_scout;    break;
         case object_archer        : amour = amour_archer;   break;
         case object_doktor        : amour = amour_doktor;   break;
         case object_cata          : amour = amour_cata;     break;
         case object_worker        : amour = amour_worker;   break;
         case object_home          : amour = amour_building; break;
         case object_building_site : amour = amour_building; break;
         case object_site_docks    : amour = amour_building; break;
         case object_camp          : amour = amour_building; break;
         case object_market        : amour = amour_building; break;
         case object_tents         : amour = amour_building; break;
         case object_farm          : amour = amour_building; break;
         case object_mill          : amour = amour_building; break;
         case object_smith         : amour = amour_building; break;
         case object_docks         : amour = amour_docks;    break;
         case object_uni           : amour = amour_building; break;
         otherwise                 : amour = 0;              break;
        };
     }.

   }

void object_handler::exec_fighter_hit (int id)
  {if      (t [id] == duration_hit) start_hit
   else if (t [id] == 0)            finish_hit
   else                             set_hit_pic;
   t [id]--;

.  start_hit
     {int u = unit [gx [id][0]][gy [id][0]];
 
      if (u != none)
         try_to_hit_unit; 
     }.

.  try_to_hit_unit
     {if   (landhight_ok)
           exec_hit
      else wait_a_bit;
     }.

.  wait_a_bit
     {pop_order  (id);
      delay_wait (id);
     }.

.  landhight_ok
     (i_abs (i_max (0, landhight [x[id]][y[id]]) -
             i_max (0, landhight [gx[id][0]][gy[id][0]])) < 2).

.  exec_hit
     {int power;
      int dh = landhight [x [u]][y [u]] - landhight [x [id]][y [id]];

      calc_power;
      if (dh > 0)
         power = (int) ((double) power * 0.8);
       hit (id, u, power);
      dir   [id] = direction (x [u] - x [id], y [u] - y [id]);
      speed [id] = speed_hit;
      delay [id] = 3;
     }.

.  calc_power
     {switch (type [id]) 
        {case object_knight : power = power_knight; break;
         case object_pawn   : power = power_pawn;   break;
         case object_scout  : power = power_scout;  break;
        };
     }.

.  finish_hit
     {pop_order (id);
      switch (type [id]) 
        {case object_knight : speed [id] = speed_knight; break;
         case object_pawn   : speed [id] = speed_pawn;   break;
         case object_scout  : speed [id] = speed_scout;  break;
        };
     }.

.  set_hit_pic
     {switch (type [id]) 
        {case object_knight : set_move_pic (id,
                                            pic_knight_fight (color [id]),
                                            6 - (t [id] - 1),
                                            gx [id][0] - x [id],
                                            gy [id][0] - y [id]);
                              break;
         case object_pawn   : set_move_pic (id,
                                            pic_pawn_fight(color [id]) ,
                                            6 - (t [id] - 1),
                                            gx [id][0] - x [id],
                                            gy [id][0] - y [id]);
                              break;
        };
      if (on_ship [id] == -1)
         refresh (x [id], y [id]);
     }.

  }

/*--- building ---------------------------------------------------------*/

void object_handler::create_building_site (int type, 
                                           int x, 
                                           int y, 
                                           int color,
                                           int worker)

  {bool building_can_be_placed;
   int  p = color_player [color];

   check_num_mans;
   check_place;
   if (building_can_be_placed)
      create_site;
   any_building_event = true;

.  check_num_mans
     {if (players [p]->num_mans >= max_num_mans)
         handle_to_many_mans;
     }.

.  handle_to_many_mans
     {write (color, "Too many mans");
     }.

.  create_site
     {int id;

      if   (type == object_docks)
           id = create_building (x, y, object_site_docks,    0, 0, color);
      else id = create_building (x, y, object_building_site, 0, 0, color);
      dir         [id] = type;
      moving_goal [id] = worker;
      if (type == object_home)
         players [p]->town_hall_in_progress++;
      if (type == object_market)
         players [p]->market_in_progress++;
      players [p]->num_building_sites++;
     }.

.  check_place
     {int bdx;
      int bdy;

      calc_bdx_dy;
      building_can_be_placed = true;
      for (int xx = x; xx < x + bdx; xx++)
        for (int yy = y; yy < y + bdy; yy++)
          check_field;
     }.

.  calc_bdx_dy
      {if     (type == object_mine)
              {bdx = 1;
               bdy = 1;
              }
      else if (type == object_docks)
              {bdx = 3;   
               bdy = 3;
              }
      else    {bdx = 2;
               bdy = 2;
              };
     }.

.  check_field
     {if (unit [xx][yy] != none ||
          ! land_properties [landscape [xx][yy]].walk_possible)
         building_can_be_placed = false;
     }.

  }

int object_handler::create_building (int p_x,
                                     int p_y,
                                     int p_type,
                                     int p_money,
                                     int p_wood,
                                     int p_color)

  {int id;

   id = create_object ();
   if (id != none)
      add_building_data;
   return id;

.  add_building_data
     {add_object_data;
      add_to_land;
      if (p_color != none)
         incr_counters;
      if (p_type == object_home && p_color != none)
         readmin (p_color, p_money, p_wood, false);
      if (p_type == object_home  && p_color != none)
         players [color_player [p_color]]->town_hall_in_progress--;
      if (p_type == object_market  && p_color != none)
         players [color_player [p_color]]->market_in_progress--;
     }.

.  add_object_data
     {strcpy (name [id], building_name (p_type));
      color         [id]    = p_color;
      with_overview [id]    = true;
      is_marked     [id]    = false;
      type          [id]    = p_type;
      pic           [id]    = pic_town_hall;
      x             [id]    = p_x;
      y             [id]    = p_y;
      cmd           [id][0] = cmd_idle;
      t             [id]    = ticker;
      step          [id][0] = none;
      health        [id]    = 100;
      power         [id]    = 0;
      wood          [id]    = p_wood;
      money         [id]    = p_money;
      speed         [id]    = speed_home;
      version       [id]    = 0;
      vr            [id]    = vr_man + 3;
      set_limits;
      if (p_type == object_site_docks || p_type == object_docks)
         {dir  [id] = docks_dir (x [id], y [id]);
         };
      if (type [id] != object_building_site &&
          type [id] != object_site_docks    &&
          p_color   != none)
          players [color_player [p_color]]->add_sun (x [id], y [id], vr [id]);
      if (p_color != none)     
          players [color_player [p_color]]->cmd_refresh_forced = true;
     }.

.  set_limits
     {money_limit   [id]    = 10000;
      wood_limit    [id]    = 10000;
      if (type [id] == object_market)
       {money_limit [id] = 800;
        wood_limit  [id] = 800;
       };
     }.

.  add_to_land
     {int bdx;
      int bdy;

      calc_bdx_dy;
      for (int xx = 0; xx < bdx; xx++)
        for (int yy = 0; yy < bdy; yy++)
          set_field;
     }.

.  calc_bdx_dy
      {if     (type [id] == object_mine)
              {bdx = 1;
               bdy = 1;
              }
      else if (type [id] == object_docks || type [id] == object_site_docks)
              {bdx = 3;   
               bdy = 3;
              }
      else    {bdx = 2;
               bdy = 2;
              };
     }.

.  incr_counters
     {switch (p_type)
       {case object_camp  : players [color_player [p_color]]->num_camps++;
                            support [id] = max_knights_per_camp;
                            collect_knights;
                            break;
        case object_market: players [color_player [p_color]]->num_markets++;
                            support [id] = max_traders_per_market;
                            collect_traders;
                            break;
        case object_tents : players [color_player [p_color]]->num_tents++;
                            support [id] = max_scouts_per_tents;
                            collect_scouts;
                            break;
        case object_farm  : players [color_player [p_color]]->num_farms++;
                            break; 
        case object_mill  : players [color_player [p_color]]->num_mills++;
                            support [id] = max_archers_per_mill;
                            collect_archers;
                            break; 
        case object_smith : players [color_player [p_color]]->num_smiths++;
                            support [id] = max_catas_per_smith;
                            collect_catas;
                            break; 
        case object_docks : players [color_player [p_color]]->num_docks++;
                            break; 
        case object_uni   : players [color_player [p_color]]->num_unis++; 
                            support [id] = max_doktors_per_uni;
                            collect_doktors;
                            break;
        case object_home  : players [color_player[p_color]]->num_town_halls++; 
                            break;
       };
     }.

.  collect_doktors
     {for (int i = 0; i < max_objects && support [id] > 0; i++)
        if (is_homeless_doktor)
           grab_doktor;
     }.

.  grab_doktor
     {support [id]--;
      home_id [i] = id;
     }.

.  is_homeless_doktor
     (! is_free [i]              && 
      color [i] == color [id]    &&
      type  [i] == object_doktor &&
      ((home_id [i] == none && home_id [i] < max_objects)  || 
       is_free [home_id [i]] || type [home_id [i]] != object_uni)).

.  collect_archers
     {for (int i = 0; i < max_objects && support [id] > 0; i++)
        if (is_homeless_archer)
           grab_archer;
     }.

.  grab_archer
     {support [id]--;
      home_id [i] = id;
     }.

.  is_homeless_archer
     (! is_free [i]              && 
      color [i] == color [id]    &&
      type  [i] == object_archer &&
      ((home_id [i] == none && home_id [i] < max_objects)  || 
       is_free [home_id [i]] || type [home_id [i]] != object_mill)).

.  collect_catas
     {for (int i = 0; i < max_objects && support [id] > 0; i++)
        if (is_homeless_cata)
           grab_cata;
     }.

.  grab_cata
     {support [id]--;
      home_id [i] = id;
     }.

.  is_homeless_cata
     (! is_free [i]            && 
      color [i] == color [id]  &&
      type  [i] == object_cata &&
      ((home_id [i] == none && home_id [i] < max_objects)  || 
       is_free [home_id [i]] || (
       type [home_id [i]]!=object_smith && type [home_id [i]]!=object_ship1))).

.  collect_ships
     {for (int i = 0; i < max_objects && support [id] > 0; i++)
        if (is_homeless_ship)
           grab_ship;
     }.

.  grab_ship
     {support [id]--;
      home_id [i] = id;
     }.

.  is_homeless_ship
     (! is_free [i]             && 
      color [i] == color [id]   &&
      type  [i] == object_ship1 &&
      ((home_id [i] == none && home_id [i] < max_objects)  || 
       is_free [home_id [i]] || type [home_id [i]] != object_docks)).

.  collect_knights
     {for (int i = 0; i < max_objects && support [id] > 0; i++)
        if (is_homeless_knight)
           grab_knight;
     }.

.  grab_knight
     {support [id]--;
      home_id [i] = id;
     }.

.  is_homeless_knight
     (! is_free [i]              && 
      color [i] == color [id]    &&
      type  [i] == object_knight &&
      ((home_id [i] == none && home_id [i] < max_objects)  || 
       is_free [home_id [i]] ||
       type [home_id [i]] != object_camp)).

.  collect_traders
     {for (int i = 0; i < max_objects && support [id] > 0; i++)
        if (is_homeless_trader)
           grab_trader;
     }.

.  grab_trader
     {support [id]--;
      home_id [i] = id;
     }.

.  is_homeless_trader
     (! is_free [i]              && 
      color [i] == color [id]    &&
      type  [i] == object_trader &&
      ((home_id [i] == none && home_id [i] < max_objects)  || 
       is_free [home_id [i]] || type [home_id [i]] != object_market)).

.  collect_scouts
     {for (int i = 0; i < max_objects && support [id] > 0; i++)
        if (is_homeless_scout)
           grab_scout;
     }.

.  grab_scout
     {support [id]--;
      home_id [i] = id;
     }.

.  is_homeless_scout
     (! is_free [i]              && 
      color [i] == color [id]    &&
      type  [i] == object_scout &&
      ((home_id [i] == none && home_id [i] < max_objects)  || 
       is_free [home_id [i]] || type [home_id [i]] != object_tents)).

.  set_field
     {unit      [x [id]+xx][y [id]+yy] = id;
      landscape [x [id]+xx][y [id]+yy] = land_building;
      if      (p_type == object_docks)
              landpic [x [id]+xx][y [id]+yy]=docks_pic      (dir [id],
                                                             xx,
                                                             yy,
                                                             health [id]);
      else if (p_type == object_site_docks)
              landpic [x [id]+xx][y [id]+yy]=docks_site_pic (dir [id],
                                                             xx,
                                                             yy,
                                                             health [id]);
      else    landpic [x [id]+xx][y [id]+yy]=building_pic   (p_type,
                                                             xx,
                                                             yy,
                                                             health [id]);
      if (p_color != none)
         refresh (x [id] + xx, y [id] + yy);
     }.

  }

/*--- refresh ----------------------------------------------------------*/

void object_handler::refresh (int lx, int ly)
  {int u = unit [lx][ly];

   for (int i = 0; i < num_players; i++)
     show_one_player;
/*
   shown [u] = qticker;
*/
  
.  show_one_player
     {if (should_be_shown)
         perform_show;
     }.

.  perform_show
     {players [i]->show (lx, ly);  
     }.

.  should_be_shown
      (players [i]->active).

  }

void object_handler::refresh (int lx, int ly, int dx, int dy)
  {refresh (lx, ly, dx, dy, 2, 2);
  }

void object_handler::refresh (int lx, int ly, int dx, int dy, int nx, int ny)
  {for (int sx = 0; sx < nx; sx++)
     for (int sy = 0; sy < ny; sy++)
       refresh (lx + dx * sx, ly + dy * sy);
  }

/*--- stack  -----------------------------------------------------------*/

void object_handler::pop (int stack [stack_size])
  {for (int i = 0; i < stack_size - 1; i++)
     stack [i] = stack [i+1];
  }

void object_handler::push (int m, int stack [stack_size])
  {for (int i = stack_size - 1; i > 0; i--)
     stack [i] = stack [i-1];
   stack [0] = m;
  }

void object_handler::xpop (int stack [stack_size*10])
  {for (int i = 0; i < stack_size*10 - 1; i++)
     stack [i] = stack [i+1];
  }

void object_handler::xpush (int m, int stack [stack_size*10])
  {for (int i = stack_size*10 - 1; i > 0; i--)
     stack [i] = stack [i-1];
   stack [0] = m;
  }

/*--- fields -----------------------------------------------------------*/

int object_handler::x_center (int lx)
  {return (lx * pic_dx);
  }

int object_handler::y_center (int ly)
  {return (ly * pic_dy); 
  }

int object_handler::x_grid (int wx)
  {return (wx / pic_dx);
  }

int object_handler::y_grid (int wy)
  {return (wy / pic_dy);
  }

/*--- move pictures ----------------------------------------------------*/

void object_handler::set_move_pic (int id, int base_pic, int d, int dx, int dy)
  {if   (type [id] == object_trader)
        set_full_dir
   else set_main_dir;

.  set_main_dir
     {if      (dy < 0) pic [id] = base_pic +      d;
      else if (dy > 0) pic [id] = base_pic + 10 + d;
      else if (dx < 0) pic [id] = base_pic + 30 + d;
      else             pic [id] = base_pic + 20 + d;
     }.

. set_full_dir
     {switch (direction (dx, dy))
        {case 0 : pic [id] = base_pic      + d; break;    
         case 1 : pic [id] = base_pic + 35 + d; break;    
         case 2 : pic [id] = base_pic + 30 + d; break;    
         case 3 : pic [id] = base_pic + 15 + d; break;    
         case 4 : pic [id] = base_pic + 10 + d; break;    
         case 5 : pic [id] = base_pic + 25 + d; break;    
         case 6 : pic [id] = base_pic + 20 + d; break;    
         case 7 : pic [id] = base_pic +  5 + d; break;   
        };
     }. 

  }

void object_handler::set_ship_pic (int id, int base_pic, int d, int dx, int dy)
  {switch (direction (dx, dy))
    {case 0 : pic [id] = base_pic      + d; break;    
     case 1 : pic [id] = base_pic + 35 + d; break;    
     case 2 : pic [id] = base_pic + 30 + d; break;    
     case 3 : pic [id] = base_pic + 15 + d; break;    
     case 4 : pic [id] = base_pic + 10 + d; break;    
     case 5 : pic [id] = base_pic + 25 + d; break;    
     case 6 : pic [id] = base_pic + 20 + d; break;    
     case 7 : pic [id] = base_pic +  5 + d; break;   
    };
  }
  
/*--- order  -----------------------------------------------------------*/

void object_handler::push_order (int id, int order, int p1, int p2)
  {perhaps_trace;
   push (order, cmd [id]);
   push (p1,    gx  [id]);
   push (p2,    gy  [id]);
   version [id]++;

.  perhaps_trace
     {
/*
      printf ("pu %d %d %d %d\n", id, order, p1, p2);
*/
     }.

  }

void object_handler::pop_order (int id)
  {if (cmd [id][0] != cmd_die)
      perform_pop;

.  perform_pop
     {perhaps_trace;
      pop (cmd [id]);
      pop (gx  [id]);  
      pop (gy  [id]);
      version [id]++;
     }.

.  perhaps_trace
     {
/*       
      printf ("po %d %d %d %d\n", id, cmd [id][0], gx [id][0], gy [id][0]);
*/
     }.

  }

void object_handler::trace_orders (int id)
  {printf ("--- %d ----- \n", id);
   for (int i = 0; i < stack_size && cmd [id][i] != cmd_idle; i++)
     printf ("   %d %d %d \n", cmd [id][i], gx [id][i], gy [id][i]);
   printf ("------------\n");
  }

bool object_handler::can_support (int id)
   {if  (support [id] <= 0)
         {write (color [id], "Too many mans");
          return false;
         }
    else return true;
   }

bool object_handler::can_built (int id, int x, int y, int cmd, bool is_robot)
  {return can_built (id, x, y, x, y, cmd, is_robot);
  }

bool object_handler::can_built (int  id,
                                int  x0,
                                int  y0,
                                int  x,
                                int  y, 
                                int  cmd,
                                bool is_robot)

  {switch (cmd)
     {case cmd_construct    :
      case cmd_built_camp   : 
      case cmd_built_farm   : 
      case cmd_built_market : 
      case cmd_built_tents  : 
      case cmd_built_home   : 
      case cmd_built_mill   : 
      case cmd_built_smith  : 
      case cmd_built_uni    : handle_building; break;
      case cmd_built_docks  : handle_docks;    break;
      default               : return false;    break;
     };

.  handle_docks
     {bool building_can_be_placed;

      check_coast;
      return building_can_be_placed;
     }.

.  check_coast
     {building_can_be_placed = true;
      check_place_flat;
      if (out_of_field)
         building_can_be_placed = false;
      if (building_can_be_placed)
         check_any_water;
     }.

.  out_of_field
     (x0 < 1 || y0 < 1 || x0 > landscape_dx - 3 || y0 > landscape_dy - 3).

.  check_place_flat
     {if   (is_robot)
           check_robot_flat
      else check_player_flat;
     }.

.  check_robot_flat
     {for (int xx = x0; xx < x0 + 3; xx++)
        for (int yy = y0; yy < y0 + 4; yy++)
          check_docks_field;
      if (! building_can_be_placed)
         check_again;
     }.

.  check_again
     {building_can_be_placed = true;
      for (int xx = x0; xx < x0 + 4; xx++)
        for (int yy = y0; yy < y0 + 3; yy++)
          check_docks_field;
     }.

.  check_player_flat
     {for (int xx = x0; xx < x0 + 3; xx++)
        for (int yy = y0; yy < y0 + 3; yy++)
          check_docks_field;
     }.

.  check_any_water
     {int xs;
      int ys;
      int dx;
      int dy;
      int dd;

      building_can_be_placed = false;
      xs = x0 - 1; ys = y0    ; dx = 0; dy = 1; dd = -1; check;
      xs = x0    ; ys = y0 - 1; dx = 1; dy = 0; dd = -1; check;
      xs = x0    ; ys = y0 + 3; dx = 1; dy = 0; dd =  1; check;
      xs = x0 + 3; ys = y0    ; dx = 0; dy = 1; dd =  1; check;      
     }. 

.  check
     {bool water = true;

      if   (dx != 0)
           check_dx
      else check_dy;
      building_can_be_placed |= water; 
     }.

.  check_dx
     {for (int xw = xs; xw < xs + 3 && dx != 0; xw += dx)
        for (int i = 0; i < 3; i++)
            if (! land_properties [landscape [xw][ys + i * dd]].is_water)
               water = false;
     }.

.  check_dy
     {for (int yw = ys; yw < ys + 3 && dy != 0; yw += dy)
        for (int i = 0; i < 3; i++)
            if (! land_properties [landscape [xs + i * dd][yw]].is_water)
               water = false;
     }.

.  handle_building
     {bool building_can_be_placed;

      check_place;
      return building_can_be_placed;
     }.

.  check_place
     {building_can_be_placed = true;
      for (int xx = x0; xx < x0 + 2; xx++)
        for (int yy = y0; yy < y0 + 2; yy++)
          check_field;
     }.

.  check_field
     {if (xx                 < 1                   ||
          yy                 < 1                   ||  
          xx                 > landscape_dx - 3    ||
          yy                 > landscape_dy - 3    ||
          unit      [xx][yy] != none               ||
          landhight [xx][yy] != landhight [x0][y0] ||
          ! land_properties [landscape [xx][yy]].walk_possible)
         building_can_be_placed = false;
     }.

.  check_docks_field
     {if (xx                 < 1                   ||
          yy                 < 1                   ||  
          xx                 > landscape_dx - 3    ||
          yy                 > landscape_dy - 3    ||
          unit      [xx][yy] != none               ||
          landhight [xx][yy] != landhight [x0][y0] ||
          landhight [xx][yy] != 1                  ||
          ! land_properties [landscape [xx][yy]].walk_possible)
         building_can_be_placed = false;
     }.

   }

bool object_handler::attack_possible (int id, int x, int y)
  {int u = unit [x][y];

   if      (u != none)                return attack_ok;
   else if (type [id] == object_cata) return true;
   else                               return false;

.  attack_ok
     (color [u] != color [id] || is_building (type [u])).

  }

void object_handler::new_order (int id, int order, int p1, int p2)
  {bool perform_steps_was_running;
   bool is_idle;
   bool price_ok;

   delay [id] = 3;
   check_price_ok;
   if (price_ok)
      store_new;

.  store_new
     {clear_order_stack;
      push_new_order;
      perhaps_push_perform_steps;
     }.

.  clear_order_stack
     {perform_steps_was_running = false;
      is_idle                   = (cmd [id][0] == cmd_idle);
      while (cmd [id][0] != cmd_idle && cmd [id][0] != cmd_die)
        {clear_cmd;
        };
     }.

.  clear_cmd
     {perform_steps_was_running |= (cmd [id][0] == cmd_perform_steps);
      pop_order (id);
     }.

.  check_price_ok
     {is_idle  = (cmd [id][0] == cmd_idle);
      switch (order)
        {case cmd_heap          : price_ok = readmin (color [id],
                                                      - price_dig, 
                                                      - wood_dig, true);       
                                  break;
         case cmd_dig           : price_ok = readmin (color [id],
                                                      - price_heap, 
                                                      - wood_heap, true);
                                  break;
         case cmd_dig_trap      : price_ok = readmin (color [id],
                                                      - price_trap, 
                                                      - wood_trap, true);
                                  break;
         case cmd_train_worker  : price_ok = is_idle          &&
                                             readmin (color [id],
                                                      - price_worker, 
                                                      0, false);
                                  break;
         case cmd_train_trader  : price_ok = is_idle          &&
                                             readmin (color [id],
                                                      - price_trader, 
                                                      - wood_trader, true);
                                  break;
         case cmd_train_knight  : price_ok = can_support (id) &&
                                             is_idle          &&
                                             readmin (color [id],
                                                      - price_knight, 
                                                      - wood_knight, false);
                                  break;
         case cmd_train_pawn    : price_ok = is_idle          &&
                                             readmin (color [id],
                                                      - price_pawn, 
                                                      - wood_pawn, false);
                                  break;
         case cmd_train_scout   : price_ok = is_idle          &&
                                             readmin (color [id],
                                                      - price_scout, 
                                                      - wood_scout, true);
                                  break;
         case cmd_train_cata    : price_ok = can_support (id) &&
                                             is_idle          &&
                                             readmin (color [id],
                                                      - price_cata, 
                                                      - wood_cata, false);
                                  break;
         case cmd_train_archer  : price_ok = can_support (id) &&
                                             is_idle          &&
                                             readmin (color [id],
                                                      - price_archer, 
                                                      - wood_archer, false);
                                  break;
         case cmd_train_doktor  : price_ok = can_support (id) &&
                                             is_idle          &&
                                             readmin (color [id],
                                                      - price_doktor, 
                                                      - wood_doktor, false);
                                  break;
         case cmd_built_camp    : price_ok = can_built (id,
                                                        p1,
                                                        p2,
                                                        cmd_built_camp) &&
                                             readmin (color [id],
                                                      - price_camp,
                                                      - wood_camp, false);
                                  break;
         case cmd_built_ship    : price_ok = readmin (color [id],
                                                      - price_ship1,
                                                      - wood_ship1, false);
                                  break;
         case cmd_built_bship   : price_ok = can_support (id) &&
                                             readmin (color [id],
                                                      - price_ship2,
                                                      - wood_ship2, false);
                                  break;
         case cmd_built_market  : price_ok = can_built (id, 
                                                        p1,
                                                        p2,
                                                        cmd_built_market) &&
                                             readmin (color [id],
                                                      - price_market,
                                                      - wood_market, false);
                                  break;
         case cmd_built_tents   : price_ok = can_built (id,
                                                        p1,
                                                        p2,
                                                        cmd_built_tents) &&
                                             readmin (color [id],
                                                      - price_tents,
                                                      - wood_tents, false);
                                  break;
         case cmd_built_home    : price_ok =  can_built (id,
                                                        p1,
                                                        p2,
                                                        cmd_built_home) &&
                                              readmin (color [id],
                                                      - price_home,
                                                      - wood_home, false);
                                  break;
         case cmd_built_farm    : price_ok = can_built (id,
                                                        p1,
                                                        p2,
                                                        cmd_built_farm) &&
                                             readmin (color [id],
                                                      - price_farm,
                                                      - wood_farm, false);
                                  break;
         case cmd_built_mill    : price_ok = can_built (id,
                                                        p1,
                                                        p2,
                                                        cmd_built_mill) &&
                                             readmin (color [id],
                                                      - price_mill,
                                                      - wood_mill, false);
                                  break;
         case cmd_built_smith   : price_ok = can_built (id,
                                                        p1,
                                                        p2,
                                                        cmd_built_smith) &&
                                             readmin (color [id],
                                                      - price_smith,
                                                      - wood_smith, false);
                                  break;
         case cmd_built_docks   : price_ok = can_built (id,
                                                        p1,
                                                        p2,
                                                        cmd_built_docks) &&
                                             readmin (color [id],
                                                      - price_docks,
                                                      - wood_docks, false);
                                  break;
         case cmd_built_uni     : price_ok = can_built (id,
                                                        p1,
                                                        p2,
                                                        cmd_built_uni) &&
                                             readmin (color [id],
                                                      - price_uni,
                                                      - wood_uni, false);
                                  break;
         case cmd_attack        : price_ok = attack_possible (id, p1, p2);
                                  break;
         default                : price_ok = true; 
                                  break;
        };
     }.

.  push_new_order
     {if (order != cmd_heap_row && order != cmd_dig_row)
         push_order (id, order, p1, p2);
      store_aditional_params;
      interrupted [id] = false;
     }.

.  store_aditional_params
     {switch (order)
        {case cmd_harvest      : get_harvest_type;        break;
         case cmd_dig          : get_dig_params;          break;
         case cmd_heap         : get_heap_params;         break;
         case cmd_dig_row      : get_dig_row_params;      break;
         case cmd_heap_row     : get_heap_row_params;     break;
         case cmd_train_worker : get_train_worker_params; break;
         case cmd_train_pawn   : get_train_worker_params; break;
         case cmd_train_scout  : get_train_worker_params; break;
         case cmd_train_archer : get_train_worker_params; break;
         case cmd_train_knight : get_train_worker_params; break;
         case cmd_train_cata   : get_train_worker_params; break;
         case cmd_train_doktor : get_train_worker_params; break;
         case cmd_guard        : add_guard_move;          break;
         case cmd_sad          : get_sad_params;          break;
         case cmd_enter        : get_attack_params;       break;
         case cmd_attack       : get_attack_params;       break;
         case cmd_heal         : get_attack_params;       break;
         case cmd_built_camp   : get_built_camp;          break;
         case cmd_built_market : get_built_market;        break;
         case cmd_built_tents  : get_built_tents;         break;
         case cmd_built_farm   : get_built_farm;          break;
         case cmd_built_home   : get_built_home;          break;
         case cmd_built_mill   : get_built_mill;          break;
         case cmd_built_smith  : get_built_smith;         break;
         case cmd_built_docks  : get_built_docks;         break;
         case cmd_built_uni    : get_built_uni;           break;
         case cmd_move_to      : perhaps_new_home;        break;
        };
      }.

.  perhaps_new_home
     {if (type [id] == object_worker && 
          unit [p1][p2] != none &&
          type [unit [p1][p2]] == object_home &&
          color [id] == color [unit [p1][p2]])
         home_id [id] = unit [p1][p2];
     }.

.  get_sad_params
     {moving_goal  [id] = none;
      in_formation [id] = false;
      }.

.  get_attack_params
     {moving_goal  [id] = unit [p1][p2];
      if (objects->type [id] == object_cata && zombi_attack)
         moving_goal [id] = none;
      if (moving_goal [id] != none)
         moving_id [id] = oid [unit [p1][p2]];
      in_formation [id] = false;
      attack_x_min [id] = 0;
      attack_y_min [id] = 0;
      attack_x_max [id] = landscape_dx;
      attack_y_max [id] = landscape_dy;
      }.

.  zombi_attack
     (unit [p1][p2] != none && 
      (objects->type [unit [p1][p2]] == object_zombi ||
       objects->type [unit [p1][p2]] == object_schrott)).

.  add_guard_move
     {push_order   (id, cmd_move_to, p1, p2);
     }.

.  get_built_camp
     {create_building_site (object_camp, p1, p2, color [id], id);
      pop_order            (id);
      push_order           (id, cmd_harvest, p1, p2);
      harvest_type [id] = harvest_built;
      version      [id] = -1;
     }.

.  get_built_market
     {create_building_site (object_market, p1, p2, color [id], id);
      pop_order            (id);
      push_order           (id, cmd_harvest, p1, p2);
      harvest_type [id] = harvest_built;
      version      [id] = -1;
     }.

.  get_built_tents
     {create_building_site (object_tents, p1, p2, color [id], id);
      pop_order            (id);
      push_order           (id, cmd_harvest, p1, p2);
      harvest_type [id] = harvest_built;
      version      [id] = -1;
     }.

.  get_built_farm
     {create_building_site (object_farm, p1, p2, color [id], id);
      pop_order            (id);
      push_order           (id, cmd_harvest, p1, p2);
      harvest_type [id] = harvest_built;
      version      [id] = -1;
     }.

.  get_built_home
     {create_building_site (object_home, p1, p2, color [id], id);
      pop_order            (id);
      push_order           (id, cmd_harvest, p1, p2);
      harvest_type [id] = harvest_built;
      version      [id]= -1;
     }.

.  get_built_mill
     {create_building_site (object_mill, p1, p2, color [id], id);
      pop_order            (id);
      push_order           (id, cmd_harvest, p1, p2);
      harvest_type [id] = harvest_built;
      version      [id] = -1;
     }.

.  get_built_smith
     {create_building_site (object_smith, p1, p2, color [id], id);
      pop_order            (id);
      push_order           (id, cmd_harvest, p1, p2);
      harvest_type [id] = harvest_built;
      version      [id] = -1;
     }.

.  get_built_docks
     {create_building_site (object_docks, p1, p2, color [id], id);
      pop_order            (id);
      push_order           (id, cmd_harvest, p1, p2);
      harvest_type [id] = harvest_built;
      version      [id] = -1;
     }.

.  get_built_uni
     {create_building_site (object_uni, p1, p2, color [id], id);
      pop_order            (id);
      push_order           (id, cmd_harvest, p1, p2);
      harvest_type [id] = harvest_built;
      version [id]= -1;
     }.

.  get_train_worker_params
     {power [id] = 0;
     }.

.  get_dig_params
     {harvest_type [id] = harvest_dig;
     }.

.  get_heap_params
     {harvest_type [id] = harvest_heap;
     }.

.  get_dig_row_params
     {int n_order = cmd_dig;
 
      push_orders;
      harvest_type [id] = harvest_dig;
     }.

.  get_heap_row_params
     {int n_order = cmd_heap;

      push_orders;
      harvest_type [id] = harvest_heap;
     }.

.  push_orders
     {int i   = 0; 
      int ddx = i_sign (x [id] - p1);
      int ddy = i_sign (y [id] - p2);

      if (ddx == 0) ddx = 1;
      if (ddy == 0) ddy = 1;
      for (int xx = p1; any_x_step && i < 20; xx += ddx)
        for (int yy = p2; any_y_step && i < 20; yy += ddy)
          try_to_push_suborder;
     }.

.  any_x_step   ((ddx < 0 && x [id] <= xx) || (ddx > 0 && x [id] >= xx)).
.  any_y_step   ((ddy < 0 && y [id] <= yy) || (ddy > 0 && y [id] >= yy)).

.  try_to_push_suborder
     {if (readmin (color [id], - price_heap, - wood_heap, true))
         push_suborder;
     }.

.  push_suborder
     {i++;
      if (i == 1)
         push_order (id, cmd_move_to, xx, yy);   
      push_order (id, n_order, xx, yy);
     }.

.  get_harvest_type
     {if   (lp.is_forest)
           harvest_type [id] = harvest_wood;
      else harvest_type [id] = harvest_gold;
     }. 

.  perhaps_push_perform_steps
     {if (perform_steps_was_running)
         {push_order (id, cmd_perform_steps, 0, 0);
          step [id][1] = step_over;
         };  
     }.

.  lp    land_properties [ll].
.  ll    landscape       [p1][p2].

  }

void check_d (int &d, int h, int x, int y)
  {if (0 <= x && x < landscape_dx && 0 <= y && y < landscape_dy) 
      d = i_max (d, h - landhight [x][y]);
  }

/*--- land readjust ----------------------------------------------------*/
 
void object_handler::readjust_land (int x, int y, int dh)
  {set_new_hight;
   readjust_fields;
   check_water;

.  set_new_hight
     {landhight [x][y] += dh;
      if (landhight [x][y] <= -2)
         {landscape [x][y] = land_water;
          landpic   [x][y] = land_water;
          refresh (x, y);
         };
      if (not_on_water && dh != 0)
         landscape [x][y] = land_mud;
     }.

.  not_on_water
     ((! land_properties [landscape [x][y]].is_water) || landhight [x][y] > 0).

.  readjust_fields
     {for (int xx = i_max (0, x-1); xx < i_min (x+2, landscape_dx); xx++)
        for (int yy = i_max (0, y-1); yy < i_min (y+2, landscape_dy); yy++)
          readjust_field;
     }.

.  readjust_field
     {if (dh != 0 && landscape [xx][yy] == land_stump)
         {landscape [xx][yy] = land_grass;
          landpic   [xx][yy] = land_grass;
         };
      if (landscape [xx][yy] == land_field)
         readjust_grow;
      if ((! on_water || landhight [xx][yy] > 0) && 
         land_properties [landscape [xx][yy]].with_hl)
         perform_readjust;
     }.

.  readjust_grow
     {int h = landhight [xx][yy];

      if (! grown_ok)
         set_to_mud;
     }.

.  grown_ok
     (can_grow (xx-1, yy,   h) && 
      can_grow (xx+1, yy,   h) && 
      can_grow (xx,   yy+1, h) && 
      can_grow (xx,   yy-1, h)).

.  set_to_mud
     {landscape [xx][yy] = land_mud;
     }. 

.  on_water
     (land_properties [landscape [xx][yy]].is_water).

.  perform_readjust
     {int land_pic;
      int dd;

      get_dd;
      get_land_pic;
      landpic   [xx][yy] = land_pic + land_profile (xx, yy, i_bound (1,dd,2));
      if (landscape [xx][yy] != land_trap)
         landscape [xx][yy] = land_pic;
      refresh (xx, yy);
     }.

.  get_land_pic
     {if   (dd > 2 && landscape [xx][yy] != land_water)
           landoverlay [xx][yy][0] = land_pali + 
                                     land_profile (xx, yy, i_bound (1, dd, 3));
      else landoverlay [xx][yy][0] = none;
      if      (dd > 1)
              land_pic = land_wall;
      else if (landscape [xx][yy] == land_wall)
              land_pic = land_mud;
      else if (landscape [xx][yy] == land_trap)
              land_pic = land_grass;
      else    land_pic = landscape [xx][yy];
      if      (dd > 1 && landscape )
              landoverlay [xx][yy][1] = land_step + 
                                        land_profile (xx, yy,i_bound (1,dd,1));
      else    landoverlay [xx][yy][1] = none;
     }.

.  get_dd
     {int h = landhight [xx][yy];

      dd = 0;
      check_d (dd, h, xx+1, yy  );
      check_d (dd, h, xx  , yy+1);
      check_d (dd, h, xx-1, yy  );
      check_d (dd, h, xx  , yy-1);
     }.       

.  check_water
     {if (landhight [x][y] <= 0)
         perform_water_check;
     }.

.  perform_water_check
     {for (int xx = xmin; xx < xmax; xx++)
        for (int yy = ymin; yy < ymax; yy++)
          check_neighbor;
     }.

.  check_neighbor
     {if (land_properties [landscape [xx][yy]].is_water)
         {create_water (x, y);
          break;
         };
     }.

.  xmin  i_max (x - 1, 0).
.  xmax  i_min (x + 2, landscape_dx).
.  ymin  i_max (y - 1, 0).
.  ymax  i_min (y + 2, landscape_dy).

  }
     
bool object_handler::readmin (int  n_color,
                              int  d_money,
                              int  d_wood,
                              bool anyway)

  {if   (players [color_player [n_color]]->num_mans >= max_num_mans &&
         ! anyway)
        {write (n_color, "Too many mans");
         return false;
        };
   if   (players [color_player [n_color]]->money + d_money < 0)
        {write (n_color, "Need more gold");
         return false;
        };
   if   (players [color_player [n_color]]->wood  + d_wood  < 0)
        {write (n_color, "Need more wood");
         return false;
        };
   ok;

.  ok
     {players [color_player [n_color]]->money   += d_money;
      players [color_player [n_color]]->wood    += d_wood;
      write (n_color, "Ok i'll do it");
      return true;
     }.

  }


void object_handler::write (int color, char msg [])
  {players [color_player [color]]->write (msg);
  }

bool object_handler::max_diff (int x, int y, int h)
  {int hh;
  
   get_hh;
   return (hh < h);

.  get_hh
     {hh = 0;
      for (int dx = -1; dx <= 1; dx++)
        for (int dy = -1; dy <= 1; dy++)
          if ((dx == 0 || dy == 0) && inside)
             get_h;
     }.

.  get_h
     {hh = i_max (hh, landhight [x][y] - landhight [x + dx][y + dy]);
     }.

.  inside
     (0 <= x + dx && x + dx < landscape_dx &&
      0 <= y + dy && y + dy < landscape_dy).

  }

bool object_handler::min_diff (int x, int y, int h)
  {int hh;
  
   get_hh;
   return (hh < h);

.  get_hh
     {hh = 0;
      for (int dx = -1; dx <= 1; dx++)
        for (int dy = -1; dy <= 1; dy++)
          if ((dx == 0 || dy == 0) && inside)
             get_h;
     }.

.  get_h
     {hh = i_max (hh, landhight [x + dx][y + dy] - landhight [x][y]);
     }.

.  inside
     (0 <= x + dx && x + dx < landscape_dx &&
      0 <= y + dy && y + dy < landscape_dy).

  }

int object_handler::diff (int x, int y)
  {int hh = 0;
  
   get_hh;
   return hh;

.  get_hh
     {hh = 0;
      for (int dx = -1; dx <= 1; dx++)
        for (int dy = -1; dy <= 1; dy++)
          if ((dx == 0 || dy == 0) && inside)
             get_h;
     }.

.  get_h
     {hh = i_max (hh,
                  i_max (0, landhight [x + dx][y + dy] - landhight [x][y]));
     }.

.  inside
     (0 <= x + dx && x + dx < landscape_dx &&
      0 <= y + dy && y + dy < landscape_dy).

  }

int object_handler::abs_diff (int x, int y)
  {int hh = 0;
  
   get_hh;
   return hh;

.  get_hh
     {hh = 0;
      for (int dx = -1; dx <= 1; dx++)
        for (int dy = -1; dy <= 1; dy++)
          if ((dx == 0 || dy == 0) && inside)
             get_h;
     }.

.  get_h
     {hh = i_max (hh, i_abs (landhight [x + dx][y + dy] - landhight [x][y]));
     }.

.  inside
     (0 <= x + dx && x + dx < landscape_dx &&
      0 <= y + dy && y + dy < landscape_dy).

  }

void object_handler::push_hd (int x, int y)
  {if (num_hd < max_hd)
      perform_push;

.  perform_push
     {for (int xx = i_max (0, x-1); xx < i_min (landscape_dx-1, x+1); xx++)
        for (int yy = i_max (0, y-1); yy < i_min (landscape_dy-1, y+1); yy++)
          if (num_hd < max_hd)
             push;
     }.

.  push
     {hd_x [num_hd] = xx;
      hd_y [num_hd] = yy;
      num_hd++;
     }.

  }