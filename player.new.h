#ifndef player_h
#define player_h

#include "bool.h"
#include "win.h"
#include "cmap.h"
#include "buttons.h"
#include "craft.h"
#include "dial.h"

class player
  {public :

   win    *w_craft;
   win    *w_land;
   win    *w_overview;
   win    *w_status;
   win    *w_admin;
   win    *w_inform;
   win    *w_pause;
   win    *w_unit;

   int    wdx;
   int    wdy;

   int    x0; 
   int    y0;

   int    marked [5][max_marked];
   int    marked_version [5];
   int    act;

   int    sun_cnt [max_land_dx][max_land_dy];

   bool   active;
   bool   any_kill;
   bool   cmd_refresh_forced;

   int    landscape_scale;
    
   bool   is_robot;
   int    last_time; 

   bool   show_ship;

   int    num_man;
   int    money;
   int    wood;
   double food;

   double bonus;
   double grow_speed;
   bool   master_dead;
   int    num_town_halls;
   int    num_farms;
   int    num_markets;
   int    num_tents;
   int    num_camps;
   int    num_mills;
   int    num_smiths;
   int    num_docks;
   int    num_unis;
   int    num_mans;
   int    num_building_sites;

   int    last_s_id;
   int    last_s_qticker;

   int    town_hall_in_progress;
 
   int    last_num_mans;
   int    last_money;
   int    last_wood;
   double last_food;

   int    last_mx;
   int    last_my;
   int    last_unit;
   bool   on_unit;
   int    act_cursor;

   int    num_marked       [5];
   int    num_marked_ships [5];

   int    color;

   char   name [128];
   char   host [128];
   int    p_no;

   bool   pic_used   [max_pics];
   cmap   *pics      [max_pics];
   cmap   *ship_pics [max_pics];

   bool   debug_on;
   bool   is_debug;
   button *b_debug;
   button *b_quit;
   button *b_unit_s  [5];
   button *b_unit_l  [5];
   button *cmds      [20];
   int    cmd_code   [20];
   bool   cmd_active [20];
   char   cmd_char   [20];
   int    num_cmds;
   char   bname      [20][32];
   int    running_cmd;
   dial   *w_limit;
   dial   *m_limit;
   button *limit_zero;
   bool   is_dial;
   int    extra_mark_dx;
   int    extra_mark_dy;
   int    extra_x;
   int    extra_y;
   
   robot  *rob;

   char   msgs [3][128];

   char   talk_buffer [128];

   bool   p_pressed [max_players];
   button *p_button [max_players];

 
   player                   (int    i,
                             char   name [],
                             char   host [], 
                             int    color, 
                             double g_speed,
                             bool   robot = false);

   ~player                  ();

   void deactivate          ();
     
   void initial_display     (); 
   
   void edit                ();

   void inform              (char msg []);
   void write               (char msg []);

   void load_pics           ();

   void show                ();
   void show                (int lx, int ly, bool extra_mark = false);
   void show                (int  lx0,
                             int  ly0,
                             int  lx,
                             int  ly,
                             bool extra_mark = false);
   void show_int            (int lx, int ly, int i);
   void show_mark           (int u,  int wx, int wy);
   void show_main_mark      (int u,  int wx, int wy);

   void show_overview       ();
   void show_overview       (int lx, int ly);
   void show_overview_frame (int lx, int ly);
   void show_overview_frame (bool is_display);

   void focus               (int nx, int ny);

   int  point_to            (int mx, int my);

   void get_cmds            (bool &is_quit,
                             int  &num,
                             int  cmd    [max_marked],
                             int  cmd_id [max_marked],
                             int  cmd_x  [max_marked],
                             int  cmd_y  [max_marked]);
   void tick                ();

   int  x_center            (int lx);
   int  y_center            (int ly);

   void show_percent        (int x,int y,int dx,int dy,int p,char title []);
   void clear_percent       (int x,int y,int dx,int dy);
   void clear_status        ();
   void show_status         (int id, bool is_first_time);

   void push_cmd            (char name [], 
                             int  code, 
                             char c, 
                             int  price, 
                             int  wood);
   void adjust_cmd          (int cmd, char c, char name []);
   void adjust_cmds         ();

   void talk                (char from [], char msg []);

   void add_sun             (int lx, int ly, int r);
   void sub_sun             (int lx, int ly, int r);
   void move_sun            (int lx, int ly, int dx, int dy, int r);
   void move_sun_d          (int lx, int ly, int dx, int dy, int r);

   void handle_pause        ();

   void mark                (int id, bool mode);

   void set_extra_mark      (int dx, int dy);

 };

#endif
