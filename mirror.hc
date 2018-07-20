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
  {for (int i = from; i <= to; i++)
     mirror_pic;

.  from  atoi (shell_params [2]).
.  to    atoi (shell_params [3]).

.  mirror_pic
     {mirror_d;
      mirror_l;
      mirror_r;
     }.

.  mirror_d
     {cmap_edit *m;

      open_d;
      perform_d;
      save_d;
      delete (m);
     }.

.  open_d
     {char name [128];

      sprintf (name, "%s.%d.cmap", shell_params [1], i);
      m = new cmap_edit (name);
     }.

.  perform_d
     {m->flip_ud ();
      m->flip_lr ();
     }.

.  save_d
     {char name [128];

      sprintf    (name, "%s.%d.cmap", shell_params [1], i+10);
      m->save_as (name);
     }.

.  mirror_r
     {cmap_edit *m;

      open_r;
      perform_r;
      save_r;
      delete (m);
     }.

.  open_r
     {char name [128];

      sprintf (name, "%s.%d.cmap", shell_params [1], i);
      m = new cmap_edit (name);
     }.

.  perform_r
     {m->rotate_r ();
     }.

.  save_r
     {char name [128];

      sprintf    (name, "%s.%d.cmap", shell_params [1], i+20);
      m->save_as (name);
     }.

.  mirror_l
     {cmap_edit *m;

      open_l;
      perform_l;
      save_l;
      delete (m);
     }.

.  open_l
     {char name [128];

      sprintf (name, "%s.%d.cmap", shell_params [1], i);
      m = new cmap_edit (name);
     }.

.  perform_l
     {m->rotate_r ();
      m->flip_ud  ();
      m->flip_lr  ();
     }.

.  save_l
     {char name [128];

      sprintf    (name, "%s.%d.cmap", shell_params [1], i+30);
      m->save_as (name);
     }.

  }
