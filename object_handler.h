#ifndef object_handler_h
#define object_handler_h

#include "craft_def.h"
#include "bool.h"
#include "robot.h"

#define stack_size  100

#define max_subalterns 30
#define max_hd         200

class robot;
class ship;

class object_handler
  {public :

   int  shown         [max_objects];
   ship *s            [max_objects];
   int  on_ship       [max_objects];
   int  oid           [max_objects];  
   int  moving_id     [max_objects];
   bool trace         [max_objects];
   bool trapped       [max_objects];
   char name          [max_objects][stack_size];
   int  type          [max_objects];
   int  color         [max_objects];
   bool with_overview [max_objects];
   int  free          [max_objects];
   bool is_free       [max_objects];
   int  pic           [max_objects];
   int  spic          [max_objects][4];
   int  x             [max_objects];
   int  y             [max_objects];
   int  wx            [max_objects];
   int  wy            [max_objects];
   int  gx            [max_objects][stack_size];
   int  home_id       [max_objects];
   int  gy            [max_objects][stack_size];
   int  moving_goal   [max_objects];
   int  dir           [max_objects];
   int  cmd           [max_objects][stack_size];
   int  t             [max_objects];
   int  age           [max_objects];
   int  step          [max_objects][stack_size * 10];
   bool is_marked     [max_objects];
   int  power         [max_objects];
   int  wood          [max_objects];
   int  money         [max_objects];
   int  health        [max_objects];
   int  speed         [max_objects];
   int  version       [max_objects];
   int  harvest_type  [max_objects];
   bool interrupted   [max_objects];
   int  support       [max_objects];
   int  atta_x        [max_objects];
   int  atta_y        [max_objects];
   int  ex            [max_objects];
   int  ey            [max_objects];
   int  buf           [max_objects];
   int  delay         [max_objects];
   int  vr            [max_objects];
   int  act_cursor;
   bool in_formation  [max_objects];
   int  attack_x_min  [max_objects];
   int  attack_y_min  [max_objects];
   int  attack_x_max  [max_objects];
   int  attack_y_max  [max_objects];
   bool master        [max_objects];
   int  idle_attack_r [max_objects];

   int  money_limit   [max_objects];
   int  wood_limit    [max_objects];

   robot *rob         [max_objects];
   bool with_rob      [max_objects];


   int  num_arrows;
   int  x_no_way;
   int  y_no_way;
   int  dist_no_way;

   int  hd_x         [max_hd];
   int  hd_y         [max_hd];
   int  num_hd;

   bool fresh_pot;
   
   int  subalterns    [max_objects][max_subalterns];

   bool any_building_event;

   int  is_a_trap     [max_land_dx][max_land_dy];

   int  px            [max_land_dx * max_land_dy];
   int  py            [max_land_dx * max_land_dy];
   int  f             [max_land_dx][max_land_dy];
   int  fv            [max_land_dx][max_land_dy];
   int  pv;

/*
   int  fx;
   int  fy;
*/

   int  first_free;
   int  ticker;
   int  qticker;
     
   object_handler            ();
  ~object_handler            ();

  int  create_object         ();
  void delete_object         (int id);
  bool any_object            (int oid, int type, int color, int &id);

  void exec                  (int id);
  void exec                  ();

  void kill_unit             (int id);

  int  create_worker         (int p_x, int p_y, int p_color, int home);
  void exec_worker           (int id);
  void worker_harvest        (int id);
  void worker_hack           (int id);
  void worker_upgrade        (int id);

  int  create_trader         (int p_x, int p_y, int p_color, int home);
  void exec_trader           (int id);
  void trader_trade          (int id);
  void trader_exec_trade     (int id);

  int  create_msg            (int p_x, int p_y, int speacker, char msg []);
  void exec_msg              (int id);
  void delete_msg            (int id);
  void exec_talk             (int id);

  void setup_trap            (int id);
  int  create_trap           (int p_x, int p_y);
  void exec_trap             (int id);

  void exec_home             (int id);

  void exec_mine             (int id);

  void exec_camp             (int id);

  void exec_mill             (int id);

  void exec_uni              (int id);

  void exec_smith            (int id);

  void exec_docks            (int id);

  void exec_market           (int id);

  void exec_tents            (int id);

  void exec_building_site    (int id);

  bool can_walk_to           (int oid, int dist, int x, int y);

  void ship_step             (int id, int dx, int dy);
  void man_step              (int id, int dx, int dy);
  bool man_plan_path         (int  id,
                              int  min_dist,
                              bool probe);
  bool man_plan_path         (int  id,
                              int  min_dist,
                              int  max_n, 
                              bool probe);
  void man_plan_path         (int  id,
                              int  &cand,
                              int  x,
                              int  y,
                              int  dir,
                              bool is_ship);

  void refresh               (int x, int y);
  void refresh               (int x, int y, int dx, int dy);
  void refresh               (int x, int y, int dx, int dy, int nx, int ny);

  int  create_water          (int p_x, int p_y);
  void exec_water            (int id);

  void exec_farm             (int id);

  int  create_knight         (int  p_x, 
                              int  p_y,
                              int  p_color,
                              int  home_no,
                              bool is_master = false);

  void exec_knight           (int id);

  int  create_pawn           (int p_x, int p_y, int p_color);
  void exec_pawn             (int id);
  void pawn_upgrade          (int id);

  int  create_scout          (int p_x, int p_y, int p_color, int home);
  void exec_scout            (int id);
  void scout_exec_hide       (int id);

  int  create_archer         (int p_x, int p_y, int p_color, int home_no);
  void exec_archer           (int id);

  int  create_doktor         (int  p_x, 
                              int  p_y, 
                              int  p_color,
                              int  home_no,
                              bool is_master = false);

  void doktor_sad            (int id);
  void exec_doktor           (int id);

  void doktor_attack         (int id);
  void exec_doktor_hit       (int id);

  int  create_cata           (int p_x, int p_y, int p_color, int home_no);
  void exec_cata             (int id);
  void exec_cata_load        (int id);

  int  create_arrow          (int ax, int ay, int agx, int agy, int id);
  void exec_arrow            (int id);

  int  create_stone          (int ax, int ay, int agx, int agy, int id);
  void exec_stone            (int id);

  void archer_attack         (int id);
  void archer_sad            (int id, bool follow);
  void exec_archer_hit       (int id);

  void fighter_attack        (int id);
  void fighter_sad           (int id, bool follow);
  void exec_fighter_hit      (int id);
  void hit                   (int id, int e, int power);

  int  create_zombi          (int id);
  void exec_zombi            (int id);

  int  create_ship_zombi     (int id);
  void exec_ship_zombi       (int id);

  int  create_schrott        (int id);
  void exec_schrott          (int id);

  int  create_explosion      (int xp, int yp);
  void exec_explosion        (int id);

  int  create_building_zombi (int id);
  void exec_building_zombi   (int id);

  int  create_swim           (int id);
  void exec_swim             (int id);

  void create_building_site  (int type, int x, int y, int color, int worker);
  
  void destroy_building      (int id);

  int create_building        (int p_x, 
                              int p_y,
                              int type,
                              int money, 
                              int wood,
                              int color);
  
  int  create_ship           (int  p_x,
                              int  p_y,
                              int  p_color, 
                              int  p_dir,
                              bool with_cata);
  void exec_ship             (int id);
  void ship_attack           (int id);
  void ship_enter            (int id);
  void push                  (int m, int stack [stack_size]);
  void pop                   (int stack [stack_size]);
  void xpush                 (int m, int stack [stack_size * 10]);
  void xpop                  (int stack [stack_size * 10]);
  int  x_center              (int lx);
  int  y_center              (int ly);
  int  x_grid                (int wx);
  int  y_grid                (int wy);
  void set_move_pic          (int id, int base, int d, int dx, int dy);
  void set_ship_pic          (int id, int base, int d, int dx, int dy);
  void new_order             (int id, int order, int p1, int p2);
  void push_order            (int id, int order, int p1, int p2);
  void pop_order             (int id);
  void trace_orders          (int id);
  void readjust_land         (int x, int y, int dh);
  bool readmin               (int color, int d_money, int d_wood, bool anyway);
  bool can_support           (int id);
  bool can_built             (int id, int x0, int y0,
                              int x, int y, int cmd, bool is_robot = false);
  bool can_built             (int id, int x, int y, int cmd,
                              bool is_robot = false);
  bool attack_possible       (int id, int x, int y);
  void write                 (int color, const char msg []);
  bool direct_move           (int id, int range, int &dx, int &dy);
  bool max_diff              (int x, int y, int h);
  bool min_diff              (int x, int y, int h);
  int  diff                  (int x, int y);
  int  abs_diff              (int x, int y);
  void delay_wait            (int id);

  void push_hd               (int x, int y);
  };

  double dist                (int x1, int y1, int x2, int y2);


#endif
