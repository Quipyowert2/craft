#include "win.h"
#include "sound.h"
#include "xmath.h"
#include "cmap_edit.h"
#include "cmap_selector.h"
#include "craft_def.h"
#include "craft.h"


double         robo_power;
double         robo_agress;

int            min_rland_dx;
int            min_rland_dy;
int            max_rland_dx;
int            max_rland_dy;

int            speed_stag;
int            speed_worker;
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
  {perhaps_usage;
   perform_edit;

.  perhaps_usage
     {if (num_params < 2)
         usage;
     }.

.  usage
     {printf ("ppm2cmap <ppm name> <cmap name>\n");
      exit   (1);
     }.

.  perform_edit
     {cmap_edit *e;

      e = new cmap_edit ();
      e->set_to_ppm (shell_params [2], shell_params [1]);
      e->save       ();
    }.

  }