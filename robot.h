#ifndef robot_h
#define robot_h

#include "bool.h"
#include "win.h"
#include "cmap.h"
#include "buttons.h"
#include "craft.h"
#include "craft_def.h"
#include "menu.h"
#include "field.h"
#include "ilfield.h"

class field;
class ilfield;

#define doing_nothing  0
#define doing_wall     1
#define doing_attack   2
#define doing_conc     3
#define doing_excave   4 

#define max_heap_requires 10
#define max_trap_requires 50

class robot
  {public :

   int o;
   int cnt;
   int color;
   int pno;

   int  num_pawns;
   int  num_lumber_jacks;
   int  num_miners;
   int  num_workers;
   int  num_building_sites;
   int  num_ships;
   int  num_knights;
   int  num_archers;
   int  num_traders;
   int  num_catas;
   int  num_doktors;
   int  num_attack;
   int  num_hasar;
   int  num_running;
   bool is_first;

   int  num_heapies_required;
   int  heap_x          [max_heap_requires];
   int  heap_y          [max_heap_requires];
   int  heap_run_x      [max_heap_requires];
   int  heap_run_y      [max_heap_requires];
   int  heap_run_worker [max_heap_requires];
   int  num_heap_run;

   int  just_finished;
   int  need_a_captain;
   int  captain_isle;

   int  num_trapies_required;
   int  trap_x          [max_trap_requires];
   int  trap_y          [max_trap_requires];
   int  trap_run_x      [max_trap_requires];
   int  trap_run_y      [max_trap_requires];
   int  trap_run_worker [max_trap_requires];
   int  num_trap_run;

   bool sea_map         [max_land_dx][max_land_dy];

   int  tnr;

   int  x_market;
   int  y_market;

   int  x_forti;
   int  y_forti;

   int  xtp [30];
   int  ytp [30];
   int  ntp;

   int  need_a_healer;

   int  wood_tp;
   int  gold_tp;

   int  n_pawns;
   int  n_workers;
   int  n_lumber_jacks;
   int  n_miners;
   int  n_building_sites;
   int  n_ships;
   int  n_knights;
   int  n_traders;
   int  n_archers;
   int  n_catas;
   int  n_doktors;
   int  n_attack;
   int  n_running;

   int  doing  [max_objects];
   int  dir    [max_objects];

   bool should_construct;
   bool should_to_ship;

   int  last_x;
   int  last_y;

   int  h_cnt  [2];
   int  h_mine [2];
   int  h_x    [2];
   int  h_y    [2];

   int     s_crew_worker  [max_objects];
   int     s_crew_fighter [max_objects];
   int     s_crew_healer  [max_objects];
   int     s_last_enter   [max_objects];
   int     s_last_cnt     [max_objects];
   int     s_dest         [max_objects];
   int     crew_worker;
   int     crew_fighter;
   int     crew_healer;
   int     last_enter;
    
   bool    to_ship;

   int     last_ilf_update;
   ilfield *ilf;
   field   *f;
   field   *pf;
   field   *ppf;
   bool    f_init;
   int     urgent;
   int     urgent_1;

   robot               (int my_color, int my_pno);
   ~robot              ();

   void  eval          ();

   bool need_another_worker (int il);

   void move_a_bit     ();

   void move_to_ship   (int o);
   void worker_to_ship (int o);

   void handle_camp    ();
   void handle_docks   ();
   void handle_smith   ();
   void handle_uni     ();
   void handle_mill    ();
   void handle_trader  ();
   void handle_pawn    ();
   void handle_archer  ();
   void handle_cata    ();

   bool  can_walk_to   (int reason, 
                        int id,
                        int x, 
                        int y,
                        int dist = 1,
                        bool force = true);
   int   dh            (int x, int y); 

   void  clean_mid     (int o);
   void  set_mid       (int o, int x, int y, int m); 
   int   home_id       (int o);

   bool robo_can_built (int o, int x, int y);

   void check_f        (int x, int y, int dx, int dy);

   void check_any_wall (int x0, int y0, int xm , int ym,
                        int &wx, int &wy, bool &any_wall);

   bool look_for_dock_place (int &x, int &y);
   bool look_for_dock_place (int &x, int &y, double dx, double dy);

   bool isle_goal           (int o, int isle, int &xg, int &yg);
   bool enter_goal          (int o, int &xg, int &yg);
   int  isle                (int x, int y);

 };

#endif
