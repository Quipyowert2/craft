#include "win.h"
#include "cmap.h"
#include "masks.h"
#include "player.h"
#include "craft_def.h"
#include "object_handler.h"
#include "land.h"
#include "timer.h"
#include "xstring.h"
#include "setupedit.h"

double         robo_power;

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
char           p_name       [max_players][128];
int            num_paused;

int            ticker;

bool           is_battle;
bool           is_self;
bool           is_suny;
bool           is_rnd_land;

land_prop      land_properties [max_land_types]; 

object_handler *objects;

player         *players [max_players];
int            num_players;

char           host [max_players][128];
char           name [max_players][128];

timer *t;

/*--- main ------------------------------------------------------------------*/

main (int num_params, char *shell_params [])
  {edit_setup *x;
   bool quit = false;

   x = new edit_setup ("gotland", 10000);
   while (! quit)
     {x->eval (quit);
     };
   delete (x);
  }