#include "win.h"
#include "sound.h"
#include "xmath.h"
#include "cmap_edit.h"
#include "cmap_selector.h"
#include "craft_def.h"
#include "craft.h"

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

int            full_time;
int            rest_time;
int            ticker;

bool           is_self;
bool           is_suny;
bool           is_water_world;

land_prop      land_properties [max_land_types]; 

object_handler *objects;

player         *players [max_players];
int            num_players;
int            active [max_players];

char           host  [max_players][128];
char           name  [max_players][128];
double         speed [max_players];           




main (int num_params, char *shell_params [])
  {char name [256];

   get_name;
   perform_edit;

.  get_name
     {if   (num_params < 2)
           name_via_selector
      else strcpy (name, shell_params [1]);
     }.

.  name_via_selector
     {strcpy (name, "");
     }.

.  perform_edit
     {cmap_edit *e;
      bool      quit;

      e    = new cmap_edit (name);
      quit = false;
      while (! quit)
        {e->edit (quit);
        };
      delete (e);
    }.

  }
