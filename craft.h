#ifndef craft_h
#define craft_h

#include "craft_def.h"
#include "object_handler.h"

class player;
class object_handler;

extern double         robo_power;
extern double         robo_agress;

extern int            q_step;

extern int            min_rland_dx;
extern int            max_rland_dx;
extern int            min_rland_dy;
extern int            max_rland_dy;

extern int            speed_stag;
extern int            speed_worker;
extern int            speed_trader;
extern int            speed_knight;
extern int            speed_pawn;
extern int            speed_scout;
extern int            speed_archer;
extern int            speed_home;
extern int            speed_farm;
extern int            speed_farm_exec;
extern int            speed_zombi;
extern int            speed_schrott;
extern int            speed_swim;
extern int            speed_water;
extern int            speed_hit;
extern int            speed_building_zombi;
extern int            speed_archer_hit;
extern int            speed_cata;
extern int            speed_cata_load;
extern int            speed_explosion;
extern int            speed_doktor;
extern int            speed_doktor_hit;
extern int            speed_general;
extern int            speed_trap;
extern int            speed_arrow;
extern int            speed_stone;
extern int            speed_ship1;
extern int            speed_ship2;
extern int            speed_ship_zombi;

extern char           land_name [128];

extern int            ilid        [max_land_dx][max_land_dy];
extern int            landscape   [max_land_dx][max_land_dy];
extern int            landhight   [max_land_dx][max_land_dy];
extern int            landpic     [max_land_dx][max_land_dy];
extern int            landoverlay [max_land_dx][max_land_dy][2];
extern int            unit        [max_land_dx][max_land_dy];
extern int            upic        [max_land_dx][max_land_dy][8];
extern int            landscape_dx;
extern int            landscape_dy;
extern int            landscale;
extern int            olandscale;

extern int            color_player [max_cols];
extern int            player_color [max_players];
extern bool           paused       [max_players];
extern char           p_name       [max_players][128];
extern int            num_paused;

extern int            ticker;
extern int            rest_time;
extern int            full_time;

extern bool           is_water_world;
extern bool           is_suny;
extern bool           is_battle;
extern bool           is_self;
extern bool           is_rnd_land;

extern land_prop      land_properties [max_land_types]; 

extern object_handler *objects;

extern player         *players [max_players];
extern int            num_players;
extern int            active [max_players];

extern char           host  [max_players][128];
extern char           name  [max_players][128];
extern double         speed [max_players];           

#endif
