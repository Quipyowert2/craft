#include "cmap_edit.h"
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
int            speed_scout;
int            speed_ship_zombi;
int            speed_ship1;



char           land_name [128];

int            landscape   [max_land_dx][max_land_dy];
int            landhight   [max_land_dx][max_land_dy];
int            landpic     [max_land_dx][max_land_dy];
int            landoverlay [max_land_dx][max_land_dy][2];
int            landscape_dx;
int            landscape_dy;
int            landscale;

int            unit      [max_land_dx][max_land_dy];
int            upic      [max_land_dx][max_land_dy][8];

int            color_player [max_cols];
int            player_color [max_players];
bool           paused       [max_players];
double         p_speed      [max_players];
char           p_name       [max_players][128];
int            num_paused;

int            full_time;
int            rest_time;
int            ticker;

bool           is_battle;
bool           is_self;
bool           is_suny;

land_prop      land_properties [max_land_types]; 

object_handler *objects;

player         *players [max_players];
int            num_players;

char           host  [max_players][128];
char           name  [max_players][128];
double         speed [max_players];           


main (int num_params, char *shell_params [])
  {if   (num_params < 2)
        usage
   else do_it;

.  usage
     {printf ("\nsplit <orig><dest><from><to><incr><dx><dy>\n");
      exit   (0);
     }.

.  do_it
     {for (int i = from; i <= to; i += incr)
        split_pic;
     }.

.  split_pic
     {cmap_edit *m;

      open_d;
      perform_d;
      delete (m);
     }.

.  open_d
     {char name [128];

      sprintf (name, "%s.%d.cmap", orig, i);
      m = new cmap_edit (name);
     }.

.  perform_d
     {m->split (dx, dy, dest, i);
     }.

.  orig  shell_params [1].
.  dest  shell_params [2].
.  from  atoi (shell_params [3]).
.  to    atoi (shell_params [4]).
.  incr  atoi (shell_params [5]).
.  dx    atoi (shell_params [6]).
.  dy    atoi (shell_params [7]).

  }
