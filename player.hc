#include "player.h"
#include "masks.h"
#include "object_handler.h"
#include "craft.h"
#include "masks.h"
#include "land.h"
#include "menu.h"
#include "building.h"
#include "robot.h"
#include "ship.h"
#include "xstring.h"

#define cur_point_to        2
#define cur_point_to_unit   24
#define cur_point_to_master 80
#define cur_point_to_other  34
#define cur_focus           2 

#define w_craft_dx  1016
#define w_craft_dy  740
#define w_land_dx   720
#define w_land_dy   720
#define w_status_dx 200
#define w_status_dy 738
#define w_inform_dx 300
#define w_inform_dy 60
#define w_unit_dx   80
#define w_unit_dy   140
#define w_msg_dx    100
#define w_msg_dy    30

player::player (int    pno,
                char   l_name [],
                char   l_host [],
                int    l_color, 
                double g_speed,
                bool   p_robot) 

  {store_params;
   init_status;
   if   (! is_robot)
        open_windows
   else init_rob;
  
.  init_rob
     {rob        = new robot (l_color, pno);
      bonus      = robo_power;
      grow_speed = robo_power;
      money      = 1000;
     }.

.  open_windows
     {init_sun_cnt;
      open_w_craft;
      open_w_land;
      open_w_status;
      open_w_inform;
      open_w_admin;
      open_w_overview;
      open_w_pause;
      open_w_unit;
      open_w_msg;
      load_pictures;
      open_quit;
      perhaps_open_debug;
     }.

.  open_w_msg
     {w_msg = new win     (w_craft, "msg", host, 0,
                           w_craft_dy - w_msg_dy, w_msg_dx, w_msg_dy);
      g_msg = new getline ("msg", w_msg, message, 1, 1,
                           w_msg_dx-2, w_msg_dy-2, false, false, true);
     }.

.  open_w_craft
     {w_craft = new win  ("craft", host, 0, 0, w_craft_dx, w_craft_dy);
      w_craft->set_color (gray80);
      w_craft->fill      (0, 0, w_craft_dx, w_craft_dy);      
      w_craft->tick      ();
     }. 

.  open_w_unit
     {w_unit = new win (w_craft, "craft_units", host,
                        w_craft_dx - w_land_dx - w_status_dx - w_unit_dx,
                        w_craft_dy - w_inform_dy - w_unit_dy,
                        w_unit_dx, w_unit_dy);
      w_unit->set_color (gray80);
      w_unit->fill      (0, 0, w_unit_dx, w_unit_dy);      
      b_unit_s [0] = new button (w_unit, "/units", 10, 10);
      b_unit_s [1] = new button (w_unit, "/units", 10, 40);
      b_unit_s [2] = new button (w_unit, "/units", 10, 70);
      b_unit_s [3] = new button (w_unit, "/units", 10, 100);
      b_unit_l [0] = new button (w_unit, "/unitl", 40, 10);
      b_unit_l [1] = new button (w_unit, "/unitl", 40, 40);
      b_unit_l [2] = new button (w_unit, "/unitl", 40, 70);
      b_unit_l [3] = new button (w_unit, "/unitl", 40, 100);
      w_unit->tick ();
      act = 0;  
     }.

.  init_sun_cnt
     {for (int x = 0; x < max_land_dx; x++)
        for (int y = 0; y < max_land_dy; y++)
          sun_cnt [x][y] = 0;
     }.

.  load_pictures
     {load_pics (); 
     }.

.  store_params
     {strcpy (name, l_name);
      strcpy (host, l_host);
      color = l_color;
      p_no  = pno;
     }.

.  init_status
     {num_cmds              = 0;
      running_cmd           = none;
      money                 = 1000;
      wood                  = 1000;
      food                  = 250;
      master_dead           = false;
      num_man               = 0;
      is_robot              = p_robot;
      last_money            = -1;
      last_wood             = -1;
      last_food             = -100;
      last_num_mans         = -1;
      num_mans              = 0;
      num_town_halls        = 0;
      num_farms             = 0;
      num_markets           = 0;
      num_tents             = 0;
      num_camps             = 0;
      num_mills             = 0;
      num_smiths            = 0;
      num_docks             = 0;
      num_unis              = 0;
      num_building_sites    = 0;
      num_marked [0]        = 0;
      num_marked [1]        = 0;
      num_marked [2]        = 0;
      num_marked [3]        = 0;
      num_marked [4]        = 0;
      num_marked_ships [0]  = 0;
      num_marked_ships [1]  = 0;
      num_marked_ships [2]  = 0;
      num_marked_ships [3]  = 0;
      num_marked_ships [4]  = 0;
      any_kill              = false;
      cmd_refresh_forced    = false;
      bonus                 = 1;
      grow_speed            = g_speed;
      town_hall_in_progress = 0;
      market_in_progress    = 0;
      last_mx               = -1;
      last_my               = -1;
      last_unit             = -1;
      on_unit               = false;
      act_cursor            = cur_point_to;
      active                = true;
      is_dial               = false;
      act                   = 0;
      extra_mark_dx         = 0;
      extra_mark_dy         = 0;
      strcpy (message, "Ups");
      if (is_robot) 
         {money = 5000;
          wood  = 5000;
          food  = 1000;
         };
     }.

.  open_w_pause
     {char f_name [256];

      sprintf (f_name, "pause_%s", name);
      w_pause = new win (w_craft, f_name, host,
                         0,  w_craft_dy - w_inform_dy - w_unit_dy - 
                         (num_players*25 + 28),
                         100,num_players*25 + 28);
      w_pause->set_color (gray80);
      w_pause->fill      (0, 0, 100,num_players*25 + 28);      
      for (int i = 0; i < num_players; i++)
        {sprintf (f_name, "%6s", p_name [i]);
         p_button  [i] = new button (w_pause, f_name, 14, 14 + i * 25); 
         p_pressed [i] = false;
        };
     }.

.  open_w_land
     {char f_name [256];

      sprintf (f_name, "craft_land_%s", name);
      w_land = new win (w_craft,name, host, 
                        w_craft_dx - w_land_dx,
                        0,
                        w_land_dx, w_land_dy);
      wdx    = w_land_dx;
      wdy    = w_land_dy;
      x0     = 0;
      y0     = 0;
     }.

.  open_w_overview
     {char f_name [256];

      sprintf (f_name, "craft_overview_%s", name);
      w_overview = new win (w_craft,
                            f_name,
                            host,
                            0,
                            0,
                            landscape_dx * olandscale,
                            landscape_dy * olandscale); 
      w_overview->set_color (black);
      w_overview->fill      (0, 0,
                             landscape_dx * olandscale,
                             landscape_dy * olandscale); 
     }.

.  open_w_status
     {char f_name [256];

      sprintf (f_name, "craft_status_%s", name);
      w_status = new win (w_craft,
                          f_name,
                          host, 
                          w_craft_dx - w_land_dx - w_status_dx, 0,
                          w_status_dx, w_status_dy);
      w_status->set_color (gray80);
      w_status->fill      (0, 0, w_status_dx, w_status_dy);
     }.

.  open_w_inform
     {char f_name [256];

      sprintf (f_name, "craft_inform_%s", name);
      w_inform = new win (w_craft, f_name, host,
                          0,
                          w_craft_dy - w_inform_dy,
                          w_craft_dx - w_land_dx - w_status_dx, w_inform_dy);
      w_inform->set_color (gray80);
      w_inform->fill      (0, 0, w_inform_dx, w_inform_dy);
/*
      w_inform->set_font ("-misc-*-*-*-*-*-8-*-*-*-*-*-*-*");
*/
      for (int i = 0; i < 3; i++)
        strcpy (msgs [i], "");
      write   ("Your order ?");
     }.

.  open_w_admin
     {char f_name [256];
      w_land->set_clip  (0, 0, 1000, 1000);
      w_land->set_color (gray80);
      w_land->fill      (0 , 720, 800, 800);
     }.

.  open_quit
     {b_quit  = new button (w_status, "quit", 90, 640);
     }.

.  perhaps_open_debug
     {is_debug = false;
      debug_on = false;
      if (strcmp (l_name, "hua") == 0 && (1 == 0))
         {b_debug = new button (w_status, "debg", 90, 670);
          is_debug = true;
         };
     }.

  }

void player::initial_display ()
  {show                ();
   show_overview       ();
   show_overview_frame (true);
   if (! is_robot)
      {w_land    ->tick ();
       w_overview->tick ();
      };
  }

player::~player ()
  {
  }

void player::deactivate ()
  {if (! is_robot)
      perform_delete;
   active = false;
 
.  perform_delete
     {delete_units;
      delete_pics;
      delete_cmds;
      delete (b_quit);
      delete (w_land);
      delete (w_overview);
/*
      delete (w_admin);
*/
      delete (w_status);
      delete (w_inform);
      delete (w_pause);
      delete (w_unit);
      delete (w_craft);
     }.

.  delete_units
     {for (int i = 0; i < max_objects; i++)
        if (! objects->is_free [i] && objects->color [i] == color)
           delete_object;
     }.

.  delete_object
     {switch (objects->type [i])
        {case object_home          : 
         case object_building_site : 
         case object_camp          : 
         case object_farm          : 
         case object_market        : 
         case object_tents         : 
         case object_mill          : 
         case object_smith         : 
         case object_docks         : 
         case object_uni           : objects->create_building_zombi (i); 
                                     break;
         case object_knight        :
         case object_trader        :
         case object_archer        : 
         case object_pawn          : 
         case object_scout         : 
         case object_cata          : 
         case object_doktor        : objects->create_zombi (i); 
                                     break;
         case object_worker        : objects->new_order (i, cmd_idle, 0, 0); 
                                     break;
         case object_ship1         : objects->create_ship_zombi (i); 
                                     break;
        };
     }.

.  delete_cmds
     {for (int i = 0; i < num_cmds; i++)
        if (cmd_active [i])
           delete (cmds [i]);
      if (is_debug)
         delete (b_debug);
     }.

.  delete_pics
     {for (int i = 0; i < max_pics; i++)
        if (pic_used [i])
           {delete (pics      [i]);
            delete (ship_pics [i]);
           };
     }.

  }

void player::load_pics ()
  {FILE *pic_catalog;
   int  pno;

   open_pic_catalog;
   init_color_trans;
   init;
   while (another_pic)
     load_pic;
   fclose (pic_catalog);

.  init
     {for (int i = 0; i < max_pics; i++)
        pic_used [i] = false;
     }.

.  open_pic_catalog
     {f_open (pic_catalog, pic_cata_name, "r");
     }.

.  another_pic
     fscanf (pic_catalog, "%d", &pno) != EOF.

.  load_pic
     {char pic_name [128];

      sprintf (pic_name, "%s.%d.cmap", pic_names, pno);
      if   (pno < 1000)
           add_objects
      else add_man;
     }.

.  add_objects
     {pics      [pno] = new cmap (w_land,   pic_name, false, true);
      ship_pics [pno] = new cmap (w_status, pic_name, false, true);
      pic_used  [pno] = true;
     }.

.  add_man
     {for (int m = 0; m < num_players; m++)
        {set_man;
        };
     }.

.  set_man
     {char pic_name [128];

      sprintf (pic_name, "%s.%d.cmap", pic_names, pno);
      pics      [mno] = new cmap (w_land,   pic_name, false, true);
      ship_pics [mno] = new cmap (w_status, pic_name, false, true);
      pic_used  [mno] = true;
      pics      [mno]->set_color_trans (ct [m]);
      ship_pics [mno]->set_color_trans (ct [m]);
     }.

.  mno  (pno + m * max_pics_per_player).

.  init_color_trans
     {for (int m = 0; m < num_players; m++)
        {set_trans;
        };
     }.

.  set_trans
     {ct [m] = new color_trans ();
      if (m == 1)
         {ct [m]->add (21, 1);
          ct [m]->add (22, 2);
          ct [m]->add (23, 2);
          ct [m]->add (24, 3);
          ct [m]->add (25, 4);
         };	     
      if (m == 2)    
         {ct [m]->add (21, 41);
          ct [m]->add (22, 42);
          ct [m]->add (23, 43);
          ct [m]->add (24, 44);
          ct [m]->add (25, 45);
         };	     
		     
      if (m == 3)    
         {ct [m]->add (21, 7);
          ct [m]->add (22, 8);
          ct [m]->add (23, 9);
          ct [m]->add (24, 6);
          ct [m]->add (25, 10);
         };
     }.

  }
 
void player::show ()
  {if (! is_robot)
      perform_show;

.  perform_show
     {for (int x = x0; x < max_x; x++)
        for (int y = y0; y < max_y; y++)
          show (x, y);
     }.

.  max_x  i_min (landscape_dx, (x0 + (wdx / pic_dx))).
.  max_y  i_min (landscape_dy, (y0 + (wdy / pic_dy))).

  }

void player::show_int (int lx, int ly, int i)
  {if (! is_robot)
      perform_show;

.  perform_show
     {int  wx = (lx - x0) * pic_dx;
      int  wy = (ly - y0) * pic_dy;
      char s [128];

      if   (i == INT_MAX)
           strcpy  (s, "M");
      else sprintf (s, "%d", i);
      w_land->set_color (black);
      w_land->write     (wx + 4 , wy + 16, s);
      w_land->tick      ();    
     }.

   }

void player::show (int lx, int ly, bool extra_mark)
  {show (lx, ly, lx, ly, extra_mark);
  }

void player::show (int lx0, int ly0, int lx, int ly, bool extra_mark)
  {if (! is_robot && inside)
      perform_show;

.  inside 
     (0 <= lx && lx < landscape_dx && 0 <= ly && ly < landscape_dy).

.  perform_show
     {if   (sunny)
           show_field
      else show_black; 
     }.

.  sunny
     (! is_suny || sun_cnt [lx][ly] > 0).

.  show_field
     {int wx = (lx - x0) * pic_dx;
      int wy = (ly - y0) * pic_dy;
      int uu = unit [lx][ly];

      show_land;
      show_upics;
      perhaps_extra_mark;
      show_overview (lx, ly);  
    }.

.  perhaps_extra_mark
     {if (extra_mark && running_cmd != none)  
         show_extra_mark;
     }. 
   
.  show_extra_mark
     {if   (objects->can_built (marked [act][0],
                                lx0,ly0,lx,ly,cmd_code [running_cmd]))
           pics [pic_extra_mark]  ->show (wx, wy);
      else pics [pic_extra_mark+1]->show (wx, wy);
     }.

.  show_black
     {int wx = (lx - x0) * pic_dx;
      int wy = (ly - y0) * pic_dy;

      pics [0]->show (wx, wy);
     }.

.  show_land
     {int l = landpic [lx][ly];

      if   (0 <= l && l < max_pics && pic_used [l])
           show_land_pic
      else {printf ("shit %d %d %d\n", lx, ly, l);
            pics [1]->show (wx, wy);
           };
     }.
   
.  show_land_pic
     {int ll;

      pics [l]->show (wx, wy);
      for (int i = 0; i < 2; i++)
        {ll = landoverlay [lx][ly][i];
         if (ll != none)
            pics [ll]->show (wx, wy);
        };
     }.

.  show_upics
     {for (int p = 0; p < 8; p++)
        perhaps_show_upics;
     }.

.  perhaps_show_upics
     {int u = upic [lx][ly][p];

      if (u != none && ly - y0 < 24)
         show_upic;
     }. 

.  show_upic
     {if   (! (0 <= u_pic && u_pic < max_pics && pic_used [u_pic]))
           {printf ("oh yeah %d %d %d\n", lx, ly, u_pic);
            pics [1]->show (u_wx, u_wy, wx, wy);
           };
      if   (is_msg)
           show_msg
      else show_normal_upic;
     }.

.  is_msg
     (objects->type [u] == object_msg && ! objects->is_free [u]).

.  show_msg
     {int wwx = (objects->x [u] - x0) * pic_dx;
      int wwy = (objects->y [u] - y0) * pic_dy;

      pics [pic_msg]    ->show (wwx,              wwy, wwx,              wwy);
      pics [pic_msg + 1]->show (wwx + pic_dx,     wwy, wwx + pic_dx,     wwy);
      pics [pic_msg + 2]->show (wwx + 2 * pic_dx, wwy, wwx + 2 * pic_dx, wwy);
      w_land->set_color        (black);
      w_land->set_background   (white);
      if   (strlen (msg) > 10)
           two_msgs
      else single_msg;
     }.

.  single_msg
     {w_land->write (wwx + 10, wwy + pic_dy - 10, msg);
     }.

.  two_msgs
     {w_land->write (wwx + 10, wwy + pic_dy - 19, substring (msg, 0, 10));
      w_land->write (wwx + 10, wwy + pic_dy -  5, substring (msg, 10, strlen (msg)));
     }.

.  msg   objects->name [u].

.  show_normal_upic
     {if   (0 <= u_pic && u_pic < max_pics && pic_used [u_pic])
           show_unit  
      else {printf ("ushit %d %d %d\n", lx, ly, u_pic);
            pics [1]->show (u_wx, u_wy, wx, wy);
           };
      perhaps_show_mark;
     }.

.  show_unit
     {int uu = unit [lx][ly];

      if      (is_hidden_scout) show_scout_pic
      else if (is_ship)         show_ship_pic
      else                      show_normal_pic;
     }.

.  is_hidden_scout 
     (p                   <  1            &&  
      uu                  != none         &&
      objects->type  [uu] == object_scout &&
      objects->color [uu] != color        && 
      objects->wood  [uu] == 1).
           
.  is_ship
     (p                  <  1    &&
      uu                 != none &&
      objects->type [uu] == object_ship1).

.  show_ship_pic
     {int x_source = wx - u_wx;
      int y_source = wy - u_wy;
      int x_screen = wx;
      int y_screen = wy;
      int dx       = pic_dx;
      int dy       = pic_dy;

      if (! pics [u_pic]->is_loaded)
         pics [u_pic]->load ();
      if (x_source < 0)
         {dx       += x_source;
          x_screen -= x_source;
          x_source  = 0;
         };
      if (y_source < 0)
         {dy       += y_source;
          y_screen -= y_source;
          y_source  = 0;
         };
      if (x_source + dx > 90)
         {dx -= (x_source + dx) - 90;
         };
      if (y_source + dy > 90)
         {dy -= (y_source + dy) - 90;
         };
      w_land->show_map (pics [u_pic]->image,
                        pics [u_pic]->mask,
                        x_source,
                        y_source,
                        x_screen,
                        y_screen,
                        dx,
                        dy,
                        u_wx,
                        u_wy);


     }.

.  show_normal_pic
     {pics [u_pic]->show (u_wx, u_wy, wx, wy);
/*
players [0]->show_int (lx, ly, u_pic);
*/
     }.

.  show_scout_pic
     {pics [land_bush]->show (u_wx, u_wy, wx, wy);  
     }.

.  perhaps_show_mark 
     {if (objects->is_marked [u])
         handle_m;
     }.

.  handle_m
     {if (objects->color [u] == color)
         {if   (u == marked [act][0])
               show_main_mark (u, u_wx, u_wy);
          else show_mark      (u, u_wx, u_wy);
         };
     }.

.  u_pic  objects->pic [u].
.  u_wx   (objects->wx  [u] - x0 * pic_dx).
.  u_wy   (objects->wy  [u] - y0 * pic_dy).

  } 

void player::show_main_mark (int u, int wx, int wy)
  {if (! is_robot)
      perform_show;

.  perform_show
     {if   (objects->type [u] == object_ship1)
           show_ship_mark
      else show_man_mark;
     }.

.  show_man_mark
     {w_land->set_color (red);
      w_land->box       (wx, wy, wx + pic_dx-1, wy + pic_dy-1);
      w_land->line      (wx, wy+5, wx+5, wy);
      w_land->line      (wx, wy+4, wx+4, wy);
      w_land->line      (wx, wy+3, wx+3, wy);
      w_land->line      (wx, wy+2, wx+2, wy);
     }.

.  show_ship_mark
     {perform_show_ship_mark;
     }.

.  perform_show_ship_mark
     {w_land->set_color (red);
      w_land->box       (wx, wy, wx + pic_dx*3-1, wy + pic_dy*3-1);
      w_land->line      (wx, wy+5, wx+5, wy);
      w_land->line      (wx, wy+4, wx+4, wy);
      w_land->line      (wx, wy+3, wx+3, wy);
      w_land->line      (wx, wy+2, wx+2, wy);
     }.

  }

void player::show_mark (int u, int wx, int wy)
  {if (! is_robot)
      perform_show;

.  perform_show
     {if   (objects->type [u] == object_ship1)
           show_ship_mark
      else show_man_mark;
     }.

.  show_man_mark
     {w_land->set_color (red);
      w_land->box       (wx, wy, wx + pic_dx-1, wy + pic_dy-1);
     }.

.  show_ship_mark
     {w_land->set_color (red);
      w_land->box       (wx, wy, wx + pic_dx*3-1, wy + pic_dy*3-1);
     }.

  }

void player::show_overview ()
  {if (! is_robot)
      perform_show;

.  perform_show
     {for (int x = 0; x < landscape_dx; x++)
        for (int y = 0; y < landscape_dy; y++)
          show_overview (x, y);
     }.

  }

void player::show_overview (int lx, int ly)
  {if (! is_robot && inside)
      perform_show;

.  inside 
     (0 <= lx && lx < landscape_dx && 0 <= ly && ly < landscape_dy).

.  perform_show
     {if   (sunny || at_mine)
           show_field
      else show_black;
     }.

.  at_mine
     (unit [lx][ly] != none && objects->type [unit [lx][ly]] == object_mine).

.  sunny
     (! is_suny || sun_cnt [lx][ly] > 0).

.  show_black
     {int xx = lx * olandscale;
      int yy = ly * olandscale;

      w_overview->set_color (58);
      w_overview->pixel     (xx,   yy);
     }.

.  show_field
     {int xx     = lx * olandscale;
      int yy     = ly * olandscale;
      int obj_id = unit [lx][ly];
 
      show_landscape;
      show_objects;
     }.

.  show_landscape
     {int o_color;

      get_color;
      w_overview->set_color (o_color);
      w_overview->pixel     (xx,   yy);
     }.

.  get_color
     {if   (at_building && objects->type [obj_id] != object_mine)
           o_color = objects->color [obj_id];
      else o_color = actual_overview_color;
     }.

.  at_building
     (obj_id != none && is_building (objects->type [obj_id])).

.  actual_overview_color
     land_properties [landscape [lx][ly]].overview_color.

.  show_objects
     {int obj_id = unit [lx][ly];

      if (obj_id != none && ! is_hidden_scout)
         perform_object_show;
     }.

.  is_hidden_scout 
     (obj_id                  != none         &&
      objects->type  [obj_id] == object_scout &&
      objects->color [obj_id] != color        && 
      objects->wood  [obj_id] == 1).

.  perform_object_show
     {if (objects->with_overview [obj_id])
         show_obj_color;
     }.

.  show_obj_color
     {int o_color = objects->color [obj_id];

      if (o_color == blue)
         o_color = 12;
      if (objects->type [obj_id] == object_mine)
         o_color = 0;
      w_overview->set_color (o_color);
      w_overview->pixel     (xx,   yy);
     }.

  }

void player::show_overview_frame (int lx, int ly)
  {if (! is_robot)
      perform_show;

.  perform_show
     {int xx = lx * olandscale;
      int yy = ly * olandscale;

      w_overview->set_color (white);
      w_overview->pixel     (xx, yy);
     }.

  }

void player::show_overview_frame (bool is_display)
  {if (! is_robot)
      perform_show;

.  perform_show
     {if   (is_display)
           perform_display
      else perform_clear;
     }.

.  perform_display
     {for (int x = x0; x < x0 + dxx; x++)
        {show_overview_frame (x, y0);
         show_overview_frame (x, y0 + dyy-1);
        };
      for (int y = y0; y < y0 + dyy-1; y++)
        {show_overview_frame (x0,         y);
         show_overview_frame (x0 + dxx-1, y);
        };
     }.
 
.  perform_clear
     {for (int x = x0; x < x0 + dxx; x++)
        {show_overview (x, y0);
         show_overview (x, y0+dyy-1);
        };
      for (int y = y0; y < y0 + dyy; y++)
        {show_overview (x0,       y);
         show_overview (x0+dxx-1, y);
        };
     }.

.  dxx (wdx / pic_dx).
.  dyy (wdy / pic_dy).

  }

int player::point_to (int mx, int my)
  {if      (unit [mx][my] != none)
           return unit [mx][my];
   else if (anything_on_land (mx, my))
           look_up_unit
   else    return none;

.  look_up_unit
     {int id           = none;
      double best_dist = DBL_MAX;
      double d;

      for (int i = 0; i < max_objects; i++)
        if (! objects->is_free [i] && near_by)
           check_object;
      return id;
     }.

.  near_by
     ((d = dist (objects->x [i], objects->y [i], mx, my)) < best_dist).

.  check_object
     {switch (objects->type [i])
        {case object_worker        :
         case object_knight        : 
         case object_trader        : 
         case object_home          :
         case object_mine          :
         case object_building_site :
         case object_camp          :
         case object_farm          :
         case object_market        :
         case object_tents         :
         case object_mill          :
         case object_smith         :
         case object_docks         :
         case object_uni           :
         case object_msg           :
         case object_archer        :
         case object_pawn          :
         case object_scout         :
         case object_ship1         :
         case object_cata          :
         case object_doktor        : grab_it; break;
        };
     }.

.  grab_it
     {id        = i;
      best_dist = d;
     }.

  }

void player::get_cmds (bool &is_quit,
                       int  &num,
                       int  cmd    [max_marked],
                       int  cmd_id [max_marked],
                       int  cmd_x  [max_marked],
                       int  cmd_y  [max_marked])

  {if (! is_robot)
      perform_get;

.  perform_get
     {int d;

      init;
      handle_msg;
      handle_color_info;
      handle_marking;
      handle_cmds;
      handle_overview_move;
      handle_quit;
      handle_admin;
      handle_pause;
      if (w_unit->is_mouse (d, d, d))
         handle_units;
      handle_ship;
      finish;
     }.

.  handle_msg
     {g_msg->eval ();
      if (strlen (message) > 20)
         strcpy (message, substring (message, 0, 19));
      g_msg->refresh ();
     }.

.  handle_ship
     {int u = marked [act][0];

      if (u != none && objects->type [u] == object_ship1)
         {if  (objects->is_marked [u]) 
              get_ship_cmds
         else {refresh_ship;
               objects->s [u]->unshow (color);
               num_marked_ships [act]--;
              };
         };
     }.

.  get_ship_cmds
     {if   (num_marked_ships [act] == 1)
           objects->s [u]->eval ();
      else objects->s [u]->unshow (color);
     }.

.  handle_units
     {int i;

      for (i = 0; i < 4; i++)
        if (b_unit_s [i]->eval ())
           handle_new_unit_store;
      for (i = 0; i < 4; i++)
        if (b_unit_l [i]->eval ())
           handle_new_unit_load;
     }.

.  handle_unit1_s
     {int i = 0;
      handle_new_unit_store;
     }.

.  handle_unit2_s
     {int i = 1;
      handle_new_unit_store;
     }.

.  handle_unit3_s
     {int i = 2;
      handle_new_unit_store;
     }.

.  handle_unit4_s
     {int i = 3;
      handle_new_unit_store;
     }.

.  handle_unit1_l
     {int i = 0;
      handle_new_unit_load;
     }.

.  handle_unit2_l
     {int i = 1;
      handle_new_unit_load;
     }.

.  handle_unit3_l
     {int i = 2;
      handle_new_unit_load;
     }.

.  handle_unit4_l
     {int i = 3;
      handle_new_unit_load;
     }.

.  handle_new_unit_store
     {i++;
      num_marked       [i] = num_marked       [act];
      num_marked_ships [i] = num_marked_ships [act];
      marked_version   [i] = marked_version   [act];
      release_unit_buttons;
      b_unit_s [i-1]->press (true);
      for (int j = 0; j < num_marked [act]; j++)
        marked [i][j] = marked [act][j];
     }.

.  handle_new_unit_load
     {i++;
      unall_marked;
      num_marked       [act] = num_marked       [i];
      num_marked_ships [act] = num_marked_ships [i];
      marked_version   [act] = marked_version   [i];
      release_unit_buttons;
      b_unit_l [i-1]->press (true);
      for (int j = 0; j < num_marked [act]; j++)
        marked [act][j] = marked [i][j];
      do_remarking;
      clear_status ();
      if (num_marked [act] > 0)
         focus (objects->x [marked [act][0]], objects->y [marked [act][0]]);
      if      (num_marked [act] == 1)
              show_status  (marked [act][0], true);
      else if (num_marked [act] > 1)
              adjust_cmds ();
     }.

.  release_unit_buttons
     {int k;

      for (k = 0; k < 4; k++)
        b_unit_s [k]->press (false);
      for (k = 0; k < 4; k++)
        b_unit_l [k]->press (false);
     }.
     
.  unall_marked
     {for (int m = 0; m < num_marked [act]; m++)
        {single_unmarking;
        };
     }.

.  single_unmarking
     {int u = marked [act][m];

      if (!objects->is_free [u]                &&
          objects->color [u] == color          &&
          objects->type  [u] != object_zombi   && 
          objects->type  [u] != object_schrott && 
          objects->type  [u] != object_arrow   && 
          objects->type  [u] != object_stone)
         {objects->is_marked [u] = false;
          if (objects->type [u] == object_ship1)
             {refresh_ship;
              objects->s [u]->unshow (color);
             };
          show (objects->x [u], objects->y [u]);
         };
     }. 

.  refresh_ship
     {for (int xa = 0; xa < 3; xa++)
        for (int ya = 0; ya < 3; ya++)
          show (objects->x [u]+xa, objects->y [u]+ya);
     }.

.  do_remarking
     {for (int m = 0; m < num_marked [act]; m++)
        {single_remarking;
        };
     }.

.  single_remarking
     {int u = marked [act][m];
      int mi;

      if   (!objects->is_free [u]                &&
            objects->color [u] == color          &&
            objects->type  [u] != object_zombi   && 
            objects->type  [u] != object_schrott && 
            objects->type  [u] != object_arrow   && 
            objects->type  [u] != object_stone)
           {objects->is_marked [u] = true;
            show (objects->x [u], objects->y [u]);
           }
      else {mi = m;
            perform_remove;  
            m--;
           };
     }. 

.  handle_pause
     {w_pause->mark_mouse ();
      w_pause->tick       ();
      if (p_button [p_no]->eval ())
         {paused [p_no] = true;
          num_paused++;
         };
      w_pause->scratch_mouse ();
     }.

.  handle_color_info
     {if (w_land->on ())
         check_color_info;
     }.

.  check_color_info 
     {int xe;
      int ye;
      int b;
      int mx;
      int my;
      int u;

      w_land->is_mouse (xe, ye, b);
      calc_mx_my;
      u = point_to (mx, my);
      if (coords_valid && (u != last_unit || mx != last_mx || my != last_my))
         {perhaps_extra_mark;
          exec_color_info;
         };
     }.

.  coords_valid
     (0 <= mx && mx <= landscape_dx && 0 <= my && my <= landscape_dy).

.  perhaps_extra_mark
     {if (extra_mark_dx > 0)
         handle_extra_mark;
     }.

.  handle_extra_mark
     {for (int yy = extra_y; yy < extra_y + extra_mark_dy; yy++)
        for (int xx = extra_x; xx < extra_x + extra_mark_dx; xx++)
          show (xx, yy);
      extra_x = mx;
      extra_y = my;
      for (int yy = extra_y; yy < extra_y + extra_mark_dy; yy++)
        for (int xx = extra_x; xx < extra_x + extra_mark_dx; xx++)
          show (mx, my, xx, yy, true);
     }. 

.  exec_color_info
     {bool was_on_unit = on_unit;

      if  (u != none && objects->type [u] == object_msg)
          objects->t [u] = 0;
      on_unit = (u != none && 
                 objects->type  [u]  != object_msg   &&
                 (objects->type  [u]  != object_scout ||
                  objects->wood  [u]  == 0            ||
                  objects->color [u]  == color));
      if      (on_unit)     show_unit_color
      else if (was_on_unit) clear_unit_color;
      last_unit = u;
      last_mx   = mx;
      last_my   = my;
     }.

.  show_unit_color
     {if   (objects->color [u] == color)
           show_own_color
      else act_cursor = cur_point_to_other;
      w_land->set_cursor (act_cursor);
      }.

.  show_own_color
      {if   (objects->master [u])
            act_cursor = cur_point_to_master;
       else act_cursor = cur_point_to_unit;
      }.

.  clear_unit_color
     {act_cursor = cur_point_to;
      w_land->set_cursor (act_cursor);
    }.

.  handle_admin
     {if (money != last_money)
         show_money;
      if (wood != last_wood)
         show_wood;
      if (num_mans != last_num_mans)
         show_num_mans;
      food = d_bound (0.0, food, max_food);
      if (d_abs (food - last_food) > 1.0 || food <= 0.0)
         show_food;
     }.

.  show_money
     {char a [128];

      if   (money < last_money)
           w_status->set_color (red);
      else w_status->set_color (black);  
      sprintf        (a, "Gold : %5d ", money);
      w_status->set_background (gray80);
      w_status->write          (30, 680, a);
      last_money = money;
     }.

.  show_wood
     {char a [128];

      if   (wood < last_wood)
           w_status->set_color (red);
      else w_status->set_color (black);  
      sprintf        (a, "Wood : %5d ", wood);
      w_status->set_background (gray80);
      w_status->write          (30, 696, a);
      last_wood = wood;
     }.

.  show_food
     {char a [128];

      if   (food < last_food)
           w_status->set_color (red);
      else w_status->set_color (black);  
      sprintf        (a, "Food : %5d  ", (int) food);
      w_status->set_background (gray80);
      w_status->write          (30, 712, a);
      last_food = food;
     }.

.  show_num_mans
     {char a [128];

      if   (num_mans < last_num_mans)
           w_status->set_color (red);
      else w_status->set_color (black);  
      sprintf        (a, "Men  : %5d ", num_mans);
      w_status->set_background (gray80);
      w_status->write          (30, 728, a);
      last_num_mans = num_mans;
     }.

.  init
     {w_land    ->mark_mouse (); 
      w_land    ->tick       ();
      w_overview->mark_mouse ();
      w_overview->tick       ();
      w_status  ->mark_mouse ();
      w_status  ->tick       ();
      w_unit    ->mark_mouse ();
      w_unit    ->tick       ();
     }.

.  finish
     {w_land    ->scratch_mouse ();
      w_overview->scratch_mouse ();
      w_status  ->scratch_mouse ();
      w_unit    ->scratch_mouse ();
     }.

.  handle_cmds
     {num = 0;
      handle_cmd_buttons;
      if (running_cmd != none)
         handle_cmd_params;
      handle_dials;
     }.

.  handle_dials
     {if (is_dial)
         read_limits;
     }.

.   read_limits
     {int m0 = marked [act][0];

      w_limit->eval (objects->wood_limit  [m0]);
      m_limit->eval (objects->money_limit [m0]);
      if (limit_zero->eval ())
         handle_limit_press;
     }.

.  handle_limit_press
     {if   (objects->money_limit [m0] != 0 || objects->wood_limit [m0] != 0)
           {objects->money_limit [m0] = 0;
            objects->wood_limit  [m0] = 0;
            limit_zero->press ();
           }
      else {objects->money_limit [m0] = 10000;
            objects->wood_limit  [m0] = 10000;
            limit_zero->press (false);
           };
      w_limit->set (objects->wood_limit  [m0]);
      m_limit->set (objects->money_limit [m0]);
     }.

.  handle_cmd_buttons
     {char cc [2];

      cc [1] = 0;
      if      ((cc [0] = w_land->inchar ()) != 0)
              handle_key_cmd
      else if (w_status->is_mouse (d, d, d))
              check_buttons;
     }.


.  handle_key_cmd
     {switch (cc [0])
        {case '1'  : handle_unit1_s; break;
         case '2'  : handle_unit2_s; break;
         case '3'  : handle_unit3_s; break;
         case '4'  : handle_unit4_s; break;
         case '5'  : handle_unit1_l; break;
         case '6'  : handle_unit2_l; break;
         case '7'  : handle_unit3_l; break;
         case '8'  : handle_unit4_l; break;
         default   : men_cmd;        break;
        };
     }.

.  men_cmd
     {for (int c = 0; c < num_cmds; c++)
        if (cmd_char [c] == cc [0])
           {handle_cmd_button;
            break;
           };
     }.
 
.  check_buttons
     {for (int c = 0; c < num_cmds; c++)
        check_button;
     }.

.  check_button
     {if (cmd_active [c] && cmds [c]->eval ())
         {handle_cmd_button;
          break;
         };
     }.

.  handle_cmd_button
     {if (running_cmd != none)
         cancel_cmd;
      switch (cmd_code [c])
        {case cmd_sail         : 
         case cmd_move_to      : 
         case cmd_enter        :
         case cmd_concentrate  : 
         case cmd_trade        :
         case cmd_hide         :
         case cmd_attack       : 
         case cmd_sad          : 
         case cmd_fad          : 
         case cmd_heal         : 
         case cmd_command      : 
         case cmd_const_wall   : 
         case cmd_dig          : 
         case cmd_dig_trap     :
         case cmd_heap         : 
         case cmd_guard        :
         case cmd_dig_row      : 
         case cmd_heap_row     : get_x_y_param; break;
         case cmd_built_camp   : 
         case cmd_built_farm   : 
         case cmd_built_market : 
         case cmd_built_tents  : 
         case cmd_built_home   : 
         case cmd_built_mill   : 
         case cmd_built_smith  : 
         case cmd_built_docks  : 
         case cmd_built_uni    : get_x_y_built; break;
         case cmd_harvest      : get_x_y_param; break;
         case cmd_built_ship   :
         case cmd_built_bship  :
         case cmd_upgrade      :
         case cmd_train_worker : 
         case cmd_train_knight : 
         case cmd_train_cata   : 
         case cmd_train_archer : 
         case cmd_train_trader : 
         case cmd_train_doktor : 
         case cmd_train_scout  : 
         case cmd_talk         :
         case cmd_train_pawn   : store_cmd;     break;
         case cmd_stop         : handle_stop;   break;
         case cmd_idle         : handle_idle;   break;
        };
     }.

.  get_x_y_built
     {if   (cmd_code [c] == cmd_built_docks)
           set_extra_mark (3, 3);
      else set_extra_mark (2, 2);
      get_x_y_param;
     }.

.  handle_stop
     {cmds [c]->press (true);
      w_status->tick ();
      running_cmd = cmd_stop;
      store_short_cmd;
      running_cmd = none;
      cmds [c]->press (false);
     }.

.  handle_idle
     {cmds [c]->press (true);
      w_status->tick ();
      running_cmd = cmd_idle;
      store_short_cmd;
      running_cmd = none;
      cmds [c]->press (false);
     }.

.  store_cmd
     {cmds [c]->press (true);
      running_cmd = cmd_code [c];
      store_short_cmd;
      running_cmd = none;
      cmds [c]->press (false);
     }.

.  store_short_cmd
     {for (int m = 0; m < num_marked [act]; m++)
        store_short_unit_cmd;
     }.

.  store_short_unit_cmd
     {cmd    [m] = running_cmd;
      cmd_id [m] = marked [act][m];
      cmd_x  [m] = none;
      cmd_y  [m] = none;
      num++;
     }.

.  get_x_y_param
     {running_cmd = c;
      w_land->set_cursor (cur_focus);
      act_cursor = cur_focus;
      last_mx = -1;
      cmds [running_cmd]->press (true);
     }.

.  handle_cmd_params
     {int xe;
      int ye;
      int b;

      if (w_land->is_mouse (xe, ye, b))
         check_store_or_abort;
     }.

.  check_store_or_abort
     {if      (submit_pressed)
              store_cmd_params
      else if (cancel_pressed)
              cancel_cmd;
      land_skip_left;
      set_extra_mark (0, 0);
     }.

.  cancel_pressed
     (b == button3press).

.  submit_pressed
     (b == button1press).

.  store_cmd_params
     {int  mx;
      int  my;
      bool pos_ok;

      calc_mx_my;
      check_pos_ok;
      if (pos_ok)
         grab_pos;
      land_skip_left;
     }.

.  check_pos_ok
     {switch (cmd_code [running_cmd])
       {case cmd_attack : look_for_enemy;       break;
        case cmd_trade  : look_for_trade_point; break;
        default         : look_at_field;        break;
       };
     }.

.  look_for_trade_point
     {pos_ok = (landscape [mx][my] == land_t_gold ||
                landscape [mx][my] == land_t_wood);
     }.

.  look_for_enemy
     {int u = point_to (mx, my);

      pos_ok = objects->type [marked [act][0]] == object_cata ||
               ship_goal_ok                                   ||
               (u                 != none         && 
                objects->type [u] != object_zombi && 
                objects->type [u] != object_building_zombi);
      if (pos_ok && u != none)
         {mx = objects->x [u];
          my = objects->y [u];
         };
     }.

.  ship_goal_ok
     (objects->type [marked [act][0]] == object_ship1 &&
      objects->s    [marked [act][0]]->num_cata ()> 0 && 
      landscape     [mx][my] == land_wall).

.  look_at_field
     {pos_ok = true;
     }.

.  grab_pos
     {store_unit_cmds;
      if (cmd_active [running_cmd])
         cmds [running_cmd]->press (false);
      perhaps_release;
      running_cmd = none;
      w_land->set_cursor (cur_point_to);
      act_cursor  = cur_point_to;
      last_mx     = -1;
     }.

.  perhaps_release
     {switch (cmd_code [running_cmd])
        {case cmd_built_camp   : 
         case cmd_built_farm   : 
         case cmd_built_market : 
         case cmd_built_tents  : 
         case cmd_built_home   : 
         case cmd_built_mill   : 
         case cmd_built_smith  : 
         case cmd_built_docks  : 
         case cmd_built_uni    : release_all_marked; break;
        };
     }.

.  store_unit_cmds
     {for (int m = 0; m < num_marked [act]; m++)
        store_unit_cmd;
     }.

.  store_unit_cmd
     {cmd    [m] = cmd_code [running_cmd];
      cmd_id [m] = marked [act][m];
      cmd_x  [m] = mx;
      cmd_y  [m] = my;
      if (cmd [m] == cmd_move_to)
         {cmd_x [m] -= (objects->x[marked[act][0]]-objects->x[marked[act][m]]);
          cmd_y [m] -= (objects->y[marked[act][0]]-objects->y[marked[act][m]]);
         };
      if (cmd [m] == cmd_concentrate)
         handle_concentrate;
      if (cmd [m] == cmd_attack &&
          (objects->type [cmd_id [m]] == object_doktor ||
           objects->type [cmd_id [m]] == object_worker))
         cmd [m] = cmd_idle;

      if (objects->cmd [cmd_id [m]][0] == cmd_entered && cmd [m] == cmd_sail)
         {cmd   [m] = cmd_entered; 
          cmd_x [m] = objects->gx [cmd_id [m]][0];
          cmd_y [m] = objects->gy [cmd_id [m]][0];
         };
      num++;
     }.

.  handle_concentrate
     {if   (objects->type [cmd_id [m]] == object_ship1)
           cmd [m] = cmd_idle;
      else cmd [m] = cmd_move_to;
     }. 

.  land_skip_left
     {int d;

      while (w_land->mouse (d, d, d))
        {};
     }.

.  handle_marking
     {int xe;
      int ye;
      int b;

      if (running_cmd == none && w_land->is_mouse (xe, ye, b))
         handle_mark_event;
      perhaps_restatus;
     }.

.  handle_mark_event
     {if      (is_new_marking) try_to_mark_new
      else if (is_add_marking) try_to_add_mark
      else if (is_center)      center_screen;
      land_skip_left;
     }.

.  is_new_marking
     (b == button1press).

.  is_add_marking
     (b == button2press).

.  is_center
     (b == button3press).

.  center_screen
     {int nx;
      int ny;
      int mx;
      int my;

      calc_mx_my;
      nx = i_bound (0, mx - (wdx / pic_dx) / 2, max_x);
      ny = i_bound (0, my - (wdy / pic_dy) / 2, max_y);
      if (any_change)
         perform_overview_move;
     }.

.  cancel_cmd
     {if (cmd_active [running_cmd])
         cmds [running_cmd]->press (false);
      running_cmd = none;
      w_land->set_cursor (cur_point_to);
      act_cursor  = cur_point_to;
      last_mx     = -1;
      land_skip_left;
     }.

.  perhaps_restatus
     {int uu = marked [act][0];

      if      (num_marked [act] == 1 && marked_killed)
              {num_marked       [act] = 0; 
               num_marked_ships [act] = 0;
               clear_status ();
              };
      if      (num_marked [act] == 1 && 
               marked_version [act] < objects->version [marked [act][0]])
               show_status (marked [act][0], false);
      else if (num_marked [act] == 1 &&
               marked_version [act] > objects->version [marked [act][0]])
              {clear_status ();
               show_status  (marked [act][0], true);
              };
      if      (num_marked [act] > 1 && any_kill)
              handle_group_marking;
      if      (cmd_refresh_forced)
              perform_cmd_refresh;
     }.

.  perform_cmd_refresh
     {clear_status ();
      if      (num_marked [act] > 1)
              adjust_cmds ();
      else if (num_marked [act] > 0)
              show_status (marked [act][0], true);
      cmd_refresh_forced = false;
     }.

.  marked_killed
     (objects->type [uu] != object_mine && 
      (objects->is_free [uu]                      ||
       objects->color [uu] != color               ||
       objects->type  [uu] == object_zombi        || 
       objects->type  [uu] == object_ship_zombi   || 
       objects->type  [uu] == object_schrott      || 
       objects->type  [uu] == object_arrow        || 
       objects->type  [uu] == object_stone)).

.  handle_group_marking
     {for (int mi = 0; mi < num_marked [act]; mi++)
        {check_g_member;
        };
      any_kill = false;
     }.

.  check_g_member
     {int u = marked [act][mi];

      if (objects->is_free [u]                      ||
          objects->color [u] != color               ||
          objects->type  [u] == object_zombi        || 
          objects->type  [u] == object_ship_zombi   || 
          objects->type  [u] == object_schrott      || 
          objects->type  [u] == object_arrow        || 
          objects->type  [u] == object_stone)
         perform_remove;     
     }.

.  try_to_add_mark
     {int mx;
      int my;

      calc_mx_my;
      handle_mark_toggle;
      land_skip_left;
     }.

.  handle_mark_toggle
     {int u = point_to (mx, my);

      if (u != none)
         handle_m;
     }.

.  handle_m
     {if   (objects->color [u]==color && objects->type [u]!=object_mine)
           perform_toggle
      else write_ower;
     }.

.  write_ower
     {clear_status ();
      show_status  (u, true);
      if (objects->type [u] == object_ship1)   
         status_a_ship;
     }.   

.  status_a_ship
     {int oc = objects->color [u];

      objects->color [u]       = color;
      objects->s [u]->show (30, 330);
      objects->s [u]->is_shown = false;
      objects->color [u]       = oc;
    }.

.  perform_toggle
     {bool allready_marked;
      int  mi;    

      marked_version [act] = INT_MAX;
      if (num_marked [act] > 0 &&
          objects->type [marked [act][0]] == object_mine)
         release_all_marked;         
      check_allready_marked;
      if      (allready_marked)
              remove_from_marked
      else if (num_marked [act] < max_marked)
              add_to_marked;
      if (num_marked [act] > 1)
         adjust_cmds ();
     }.

.  check_allready_marked
     {allready_marked = false;
      for (mi = 0; mi < num_marked [act]; mi++)
        if (marked [act][mi] == u)
           {allready_marked = true;
            break;
           };
     }.

.  remove_from_marked
     {perform_remove;
      if (num_marked [act] == 1)
         {clear_status ();
          show_status  (marked [act][0], true);
         };
      if (num_marked [act] == 0)
         clear_status ();
     }.

.  perform_remove
     {objects->is_marked [u] = false;
      if (objects->type[u] == object_ship1)
         {refresh_ship;
          objects->s [u]->unshow (color);
          num_marked_ships [act]--;
         };
       show (objects->x [u], objects->y [u]);
       for (int j = mi; j < num_marked [act]-1; j++)
         marked [act][j] = marked [act][j+1];
      num_marked [act]--;
     }.

.  add_to_marked
     {marked [act][num_marked [act]] = u;
      if (objects->type [u] == object_ship1)
         num_marked_ships [act]++;
      objects->is_marked [u]         = true;
      num_marked [act]++;
      show         (objects->x [u], objects->y [u]);
      clear_status ();
      adjust_cmds ();
     }.

.  try_to_mark_new
     {int mx;
      int my;

      calc_mx_my;
      perhaps_release_old_mark;
      perhaps_set_new_mark;
      land_skip_left;
     }.

.  perhaps_release_old_mark
     {if (num_marked [act] > 0)
         release_all_marked;
     }.

.  release_all_marked
     {for (int m = 0; m < num_marked [act]; m++)
        if (! objects->is_free [marked [act][m]])
           release_marked_obj;
      num_marked [act] = 0;
     }.

.  release_marked_obj
     {int u = marked [act][m];

      objects->is_marked [u] = false;
      if (objects->type[u] == object_ship1)
         {refresh_ship;
          objects->s [u]->unshow (color);
         };
      show (objects->x [u], objects->y [u]);
      marked [act][m] = none;
      clear_status (); 
     }.

.  perhaps_set_new_mark
     {int u = point_to (mx, my);

      if (u != none)
         handle_mn;
     }.

.  handle_mn
     {if  (objects->color [u] == color || objects->type [u] == object_mine)
           set_new_mark
      else write_ower;
     }.

.  set_new_mark
     {marked [act][num_marked [act]] = u;
      marked_version [act]           = objects->version [u];
      objects->is_marked [u]         = true;
      num_marked [act]               = 1;
      if (objects->type [u] == object_ship1)
         num_marked_ships [act] = 1;
      show         (objects->x [u], objects->y [u]);
      clear_status ();
      show_status  (marked [act][0], true);
     }.

.  calc_mx_my
     {mx = xe / pic_dx + x0;
      my = ye / pic_dy + y0;
      mx = i_bound (0, mx, landscape_dx - 1);
      my = i_bound (0, my, landscape_dy - 1);
     }.

.  handle_quit
     {if (b_quit->eval ())
         handle_quit_pressed;
      if (is_debug && b_debug->eval ())
         {};
     }.

.  handle_quit_pressed
     {b_quit->press (true);
      is_quit = yes (w_craft, host, "realy quit, coward");
      b_quit->press (false);
     }.
 
.  handle_scrollers
     {int xe;
      int ye;
      int b;

      if (w_land->is_mouse (xe, ye, b) && scroller_event)
         handle_scroller;
      }.

.  scroller_event
     (b == button3press).

.  handle_scroller
     {int xx;
      int yy;

      w_land->mouse (xe, ye, xx, yy, b);
      if (xe <= pic_dx)       handle_left;
      if (xe >= wdx - pic_dx) handle_right;
      if (ye <= pic_dy)       handle_up;
      if (ye >= wdy - pic_dy) handle_down;
     }.

.  handle_left
     {show_overview_frame (false);
      x0 = i_max (0, x0 - 10);
      show                ();
      show_overview_frame (true);
     }.

.  handle_right
     {show_overview_frame (false);
      x0 = i_min (max_x, x0 + 10);
      show                ();
      show_overview_frame (true);
     }.

.  handle_up
     {show_overview_frame (false);
      y0 = i_max (0, y0 - 10);
      show                ();
      show_overview_frame (true);
     }.

.  handle_down
     {show_overview_frame (false);
      y0 = i_min (max_y, y0 + 10);
      show                ();
      show_overview_frame (true);
     }.

.  handle_overview_move
     {int xe;
      int ye;
      int b;

      if (w_overview->is_mouse (xe, ye, b))
         handle_overview;
     }.

.  handle_overview
     {int xx;
      int yy;
      int bb;
      int nx;
      int ny;

      get_mouse;
      nx = i_bound (0, (xx / olandscale) - (wdx / pic_dx) / 2, max_x);
      ny = i_bound (0, (yy / olandscale) - (wdy / pic_dy) / 2, max_y);
      if (any_change)
         perform_overview_move;
     }.

.  any_change
     (nx != x0 || ny != y0).

.  perform_overview_move
     {show_overview_frame (false);
      x0 = nx;
      y0 = ny;
      show                ();
      show_overview_frame (true);
     }.

.  get_mouse
     {while (w_overview->is_mouse (xe, ye, b))
        {w_overview->mouse (xe, ye, xx, yy, bb);
        };
     }.

.  max_x  (landscape_dx - (wdx / pic_dx)).
.  max_y  (landscape_dy - (wdy / pic_dy)).

   } 

void player::mark (int id, bool mode)
  {if (objects->is_marked [id] != mode)
      perform_remarking;

.  perform_remarking
     {objects->is_marked [id] = mode;
      if   (mode)
           handle_add
      else handle_remove;
     }.

.  handle_add
     {marked     [act][num_marked [act]] = id;
      num_marked [act]++;
      if (objects->type [id] == object_ship1)
         num_marked_ships [act]++;
     }.

.  handle_remove
     {int i;

      get_i;
      for (int j = i; j < num_marked [act]-1; j++)
        {marked [act][j] = marked [act][j+1];
        };
      if (objects->type [id] == object_ship1)
         num_marked_ships [act]--;
     }.

.  get_i
     {for (i = 0; i < num_marked [act]; i++)
        if (marked [act][i] == id)
           break;
     }.

  } 

void player::focus (int xx, int yy)
  {int nx;
   int ny;
   
   nx = i_bound (0, xx - (wdx / pic_dx) / 2, max_x);
   ny = i_bound (0, yy - (wdy / pic_dy) / 2, max_y);
   if (any_change)
      perform_overview_move;

.  any_change
     (nx != x0 || ny != y0).

.  perform_overview_move
     {show_overview_frame (false);
      x0 = nx;
      y0 = ny;
      show                ();
      show_overview_frame (true);
     }.

.  max_x  (landscape_dx - (wdx / pic_dx)).
.  max_y  (landscape_dy - (wdy / pic_dy)).

  }

void player::tick ()
  {if (! is_robot)
      w_land->tick ();
  }

int player::x_center (int lx)
  {return (lx * pic_dx);
  }

int player::y_center (int ly)
  {return (ly * pic_dy);
  }

void player::show_percent (int x, int y, int dx, int dy, int p, char title [])
  {if (! is_robot)
      perform_show;

.  perform_show
     {int l1 = (int) ((double) dx * double (p) / 100.0);
      int l2 = dx - l1;

      w_status->set_color (green4);
      w_status->fill      (x, y, l1, dy);
      if (l2 != 0)
         {w_status->set_color (gray80);
          w_status->fill      (x + l1, y, dx - l1, dy);
          w_status->set_color (black);
          w_status->line      (x + l1, y + dy-1, x + dx, y + dy-1);
         };
      w_status->set_color (black);
      w_status->write     (x + dx + 10, y + dy, title);
     }.

  }

void player::clear_percent (int x, int y, int dx, int dy)
  {if (! is_robot)
      perform_show;

.  perform_show
     {w_status->set_color (gray80);
      w_status->fill      (10, y, 160, dy);
     }.

  }

void player::clear_status ()
  {if (! is_robot)
      perform_show;

.  perform_show
     {clear_cmds;
      w_status->set_color (gray80);
      w_status->fill      (10, 10, 180, 630);
      if (is_dial)
         close_dial;
     }.

.  close_dial
     {delete (m_limit);
      delete (w_limit);
      delete (limit_zero);
      is_dial = false;
     }.

.  clear_cmds
     {for (int i = 0; i < num_cmds; i++)
        if (cmd_active [i])
           {delete (cmds [i]);
            cmd_active [i] = false;
           }
      num_cmds = 0;
     }.

  }

void player::push_cmd (char name [], int code, char c, int a_price, int a_wood)
  {cmds       [num_cmds] = new button (w_status, name, x_cmd, y_cmd);
   cmd_code   [num_cmds] = code;
   cmd_char   [num_cmds] = c;
   cmd_active [num_cmds] = true;
   strcpy (bname [num_cmds], name);
   perhaps_write_price;
   num_cmds++;
   if (num_cmds >= 20)
      {printf ("Oh shit\n");
       exit   (1);
      };

.  perhaps_write_price
     {if (a_price != 0 || a_wood != 0)
         write_price;
     }.

.  write_price
     {char p [128];

      sprintf             (p, "%d", a_price);
      w_status->set_color (gold3);
      w_status->write     (x_cmd + 100, y_cmd + 16, p);
      sprintf             (p, "%d", a_wood);
      w_status->set_color (green4);
      w_status->write     (x_cmd + 130, y_cmd + 16, p);
     }.

.  x_cmd  20.
.  y_cmd  140 + num_cmds * 24.

  }

bool supports (int type, int c)
  {switch (type)
     {case object_worker        : worker;        break;
      case object_knight        : knight;        break;
      case object_trader        : trader;        break;
      case object_home          : home;          break;
      case object_mine          : mine;          break;
      case object_building_site : building_site; break;
      case object_camp          : camp;          break;
      case object_farm          : farm;          break;
      case object_market        : market;        break;
      case object_tents         : tents;         break;
      case object_mill          : mill;          break;
      case object_smith         : smith;         break;
      case object_docks         : docks;         break;
      case object_uni           : uni;           break;
      case object_archer        : archer;        break;
      case object_pawn          : pawn;          break;
      case object_scout         : scout;         break;
      case object_ship1         : ship1;         break;
      case object_cata          : cata;          break;
      case object_doktor        : doktor;        break;
      default                   : return false;  break;   
     };       

.  worker
     {return (c == cmd_move_to      || 
              c == cmd_talk         ||
              c == cmd_attack       ||
              c == cmd_concentrate  ||
              c == cmd_dig          ||
              c == cmd_dig_trap     ||
              c == cmd_heap         ||
              c == cmd_dig_row      ||
              c == cmd_heap_row     ||
              c == cmd_harvest      ||
              c == cmd_upgrade      ||
              c == cmd_built_home   ||
              c == cmd_built_camp   ||
              c == cmd_built_farm   ||
              c == cmd_built_market ||
              c == cmd_built_tents  ||
              c == cmd_built_mill   ||
              c == cmd_built_smith  ||
              c == cmd_built_uni    ||
              c == cmd_built_docks  ||
              c == cmd_idle);
     }.

.  trader
     {return (c == cmd_move_to      || 
              c == cmd_talk         ||
              c == cmd_concentrate  ||
              c == cmd_trade        ||
              c == cmd_idle);
     }.

.  knight
     {return (c == cmd_move_to ||
              c == cmd_talk         ||
              c == cmd_concentrate ||
              c == cmd_attack  ||
              c == cmd_guard   ||
              c == cmd_sad     ||
              c == cmd_fad     ||
              c == cmd_idle);
     }.

.  home   
    {return (c == cmd_train_worker ||
             c == cmd_train_pawn   ||
             c == cmd_idle);
    }.

.  mine 
    {return false;
    }.
 
.  building_site  
    {return false;
    }. 

.  camp
    {return (c == cmd_train_knight ||
             c == cmd_idle);
    }.

.  farm
    {return false;
    }.

.  market
    {return (c == cmd_train_trader ||
             c == cmd_idle);
    }.

.  tents
    {return (c == cmd_train_scout ||
             c == cmd_idle);
    }.

.  mill
    {return (c == cmd_train_archer ||
             c == cmd_idle);
    }.

.  smith
    {return (c == cmd_train_cata ||
             c == cmd_idle);
    }.

.  docks
    {return (c == cmd_built_ship  ||
             c == cmd_built_bship ||
             c == cmd_idle);
    }.

.  uni
    {return (c == cmd_train_doktor ||
             c == cmd_idle);
    }.

.  archer
     {return (c == cmd_move_to ||
              c == cmd_talk         ||
              c == cmd_concentrate ||
              c == cmd_attack  ||
              c == cmd_sad     ||
              c == cmd_fad     ||
              c == cmd_guard   ||
              c == cmd_idle);
     }.

.  pawn
     {return (c == cmd_move_to ||
              c == cmd_talk         ||
              c == cmd_concentrate ||
              c == cmd_attack  ||
              c == cmd_guard   ||
              c == cmd_fad     ||
              c == cmd_sad     ||
              c == cmd_idle);
     }.

.  scout
     {return (c == cmd_move_to     ||
              c == cmd_talk         ||
              c == cmd_concentrate ||
              c == cmd_hide        ||
              c == cmd_idle);
     }.

.  ship1
     {return (c == cmd_sail   ||
              c == cmd_attack ||
              c == cmd_enter  ||
              c == cmd_idle);
     }.

.  cata
     {return (c == cmd_move_to ||
              c == cmd_talk         ||
              c == cmd_concentrate ||
              c == cmd_attack  ||
              c == cmd_fad     ||
              c == cmd_sad     ||
              c == cmd_guard   ||
              c == cmd_idle);
     }.

.  doktor
     {return (c == cmd_move_to     ||
              c == cmd_talk         ||
              c == cmd_attack      ||
              c == cmd_concentrate ||
              c == cmd_heal        ||
              c == cmd_guard       ||
              c == cmd_sad         ||
              c == cmd_fad         ||
              c == cmd_idle);
     }.

  }

void player::adjust_cmd (int cmd, char c, char name [])
  {bool is_ok = true;

   check_units;
   if (is_ok)
      add_c;

.  check_units 
     {for (int m = 0; m < num_marked [act]; m++)
        check_cmds;   
     }.

.  check_cmds
     {if (! objects->is_free [marked [act][m]])
         handle_unit;
     }.

.  handle_unit
     {int id = marked [act][m];

      is_ok &= supports (objects->type [id], cmd);
     }.

.  add_c
     {push_cmd (name, cmd, c, 0, 0);
     }. 

  }

void player::adjust_cmds ()
  {clear_status ();
   adjust_cmd (cmd_move_to,     'm', "Move       ");
   adjust_cmd (cmd_sail,        's', "Sail       ");
   adjust_cmd (cmd_enter,       'e', "Enter      ");
   adjust_cmd (cmd_concentrate, 'c', "Concentrate");
   adjust_cmd (cmd_attack,      'a', "Attack     ");
   adjust_cmd (cmd_sad,         's', "S & d      ");
   adjust_cmd (cmd_fad,         'f', "F & d      ");
   adjust_cmd (cmd_harvest,     'r', "haRvest    ");
   adjust_cmd (cmd_trade,       'j', "trade J    ");
   adjust_cmd (cmd_guard,       'd', "guarD      ");
   adjust_cmd (cmd_heal,        't', "casT       ");
   adjust_cmd (cmd_idle,        'i', "idle       ");
  }

void player::show_status (int id, bool is_first_time)
  {if (! is_robot)
      perform_show;

.  perform_show
     {if   (id == none)
           handle_multi_status
      else handle_single_status;
     }.

.  handle_multi_status
     {if (is_first_time)
         show_commands;
     }.

.  handle_single_status
     {get_version;
      show_name;
      show_status_data;
      if (is_first_time && objects->color [id] == color)
         show_commands;
     }.

.  get_version
     {marked_version [act] = objects->version [id];
     }.

.  show_name
     {w_status->set_color (black);
      w_status->write     (30, 30, objects->name [id]);
     }.

.  show_status_data
     {if (objects->type [id] != object_mine)
         show_health;
      switch (objects->type [id])
        {case object_worker        : 
         case object_knight        : 
         case object_trader        : 
         case object_pawn          : 
         case object_scout         : 
         case object_archer        : 
         case object_doktor        : 
         case object_cata          : show_man_status;    break;
         case object_home          : show_home_status;   break;
         case object_farm          : show_farm_status;   break;
         case object_market        : show_market_status; break;
         case object_tents         : show_tents_status;  break;
         case object_camp          : show_camp_status;   break;
         case object_uni           : show_uni_status;    break;
         case object_mill          : show_mill_status;   break;
         case object_smith         : show_smith_status;  break;
         case object_docks         : show_docks_status;  break;
         case object_building_site : show_train_status;  break;
         case object_site_docks    : show_train_status;  break;
         case object_mine          : show_mine_status;   break;
         case object_ship1         : show_ship_status;   break;
        };
     }.

.  show_farm_status
     {char msg [128];

      sprintf             (msg, 
                           "Grows : %f    ",
                           (double) objects->power [id] * power_per_field);
      w_status->set_color (black);
      w_status->write     (30, 120, msg);
     }.

.  show_mine_status
     {show_gold;
     }.

.  show_home_status
     {show_task;
     }.

.  show_market_status
     {show_task;
      show_suport_status;
     }.

.  show_tents_status
     {show_task;
      show_suport_status;
     }.

.  show_mill_status
     {show_task;
      show_suport_status;
     }.

.  show_uni_status
     {show_task;
      show_suport_status;
     }.

.  show_smith_status
     {show_task;
      show_suport_status;
     }.

.  show_docks_status
     {show_task;
     }.

.  show_ship_status
     {if (objects->color [id] == color)
         objects->s [id]->show (30, 330);
     }.

.  show_camp_status
     {show_task;
      show_suport_status;
     }.

.  show_suport_status
     {if (objects->color [id] == color)
         display_free;
     }.

.  display_free
     {char msg [128];

      sprintf             (msg, "Free : %d    ", objects->support [id]);
      w_status->set_color (black);
      w_status->write     (30, 120, msg);
      if (objects->type [id] != object_tents)
         show_limits;
     }.

.  show_limits
     {if (objects->color [id] == color)
         display_limits;
     }.

.  display_limits
     {is_dial= true;
      w_limit= new dial(w_status, "wood",
                        40, 12, 300,
                        0, objects->wood_limit[id], 
                        10000,100,false,80,false, 1000);
      m_limit= new dial(w_status, "gold",
                        40, 12, 330,
                        0, objects->money_limit[id],
                        10000,100,false,80,false, 1000);
      limit_zero= new button (w_status, "0", 166, 300);
      if (objects->money_limit [id] == 0 &&
          objects->wood_limit  [id] == 0)
         limit_zero->press ();
     }.

.  show_task
     {switch (objects->cmd [id][0])
        {case cmd_train_worker : 
         case cmd_train_knight : 
         case cmd_train_archer : 
         case cmd_train_trader : 
         case cmd_train_doktor : 
         case cmd_train_pawn   : 
         case cmd_built_ship   :
         case cmd_built_bship  :
         case cmd_train_scout  : 
         case cmd_train_cata   : show_train_status; break;
         case cmd_idle         : show_idle;         break;
        };
     }.

.  show_train_status
     {show_percent (30, 90, 100, 6, objects->power [id], "done");
     }.

.  show_idle
     {clear_percent (12, 80, 100, 30);
     }.

.  show_treasury
     {show_gold;
      show_wood;
     }.

.  show_gold
     {char msg [128];

      sprintf             (msg, "Gold   : %d", objects->money [id]);
      w_status->set_color (gold3);
      w_status->write     (40, 100, msg);
     }.

.  show_wood
     {char msg [128];

      sprintf             (msg, "Lumber : %d", objects->wood [id]);
      w_status->set_color (green4);
      w_status->write     (40, 120, msg);
     }.

.  show_man_status
     {show_health;
      show_treasury;
     }.
  
.  show_health
     {show_percent (30, 70, 100, 6, objects->health [id], "health");
     }.

.  show_commands
     {switch (objects->type [id])
        {case object_worker : show_worker_cmds; break;
         case object_home   : show_home_cmds;   break;
         case object_market : show_market_cmds; break;
         case object_tents  : show_tents_cmds;  break;
         case object_camp   : show_camp_cmds;   break;
         case object_mill   : show_mill_cmds;   break;
         case object_uni    : show_uni_cmds;    break;
         case object_smith  : show_smith_cmds;  break;
         case object_docks  : show_docks_cmds;  break;
         case object_knight : show_knight_cmds; break;
         case object_trader : show_trader_cmds; break;
         case object_pawn   : show_pawn_cmds;   break;
         case object_scout  : show_scout_cmds;  break;
         case object_ship1  : show_ship_cmds;   break;
         case object_archer : show_archer_cmds; break;
         case object_doktor : show_doktor_cmds; break;
         case object_cata   : show_archer_cmds; break;
        };
     }.

.  show_home_cmds
     {push_cmd ("Worker", cmd_train_worker, 'w', price_worker, 0);
      push_cmd ("Pawn  ", cmd_train_pawn,   'p', price_pawn,   wood_pawn);
      push_cmd ("Idle  ", cmd_idle,         'i', 0,            0);
     }.

.  show_market_cmds
     {push_cmd ("Idle    ", cmd_idle,         'i', 0,            0);
     }.

.  show_tents_cmds
     {push_cmd ("Idle    ", cmd_idle,         'i', 0,            0);
     }.

.  show_mill_cmds
     {push_cmd ("Archer", cmd_train_archer, 'a', price_archer, wood_archer);
      push_cmd ("Idle  ", cmd_idle,         'i', 0,            0);
     }.

.  show_uni_cmds
     {push_cmd ("Scientist", cmd_train_doktor, 's', price_doktor, wood_doktor);
      push_cmd ("Idle     ", cmd_idle,         'i', 0,            0);
     }.

.  show_smith_cmds
     {push_cmd ("Catapult", cmd_train_cata, 'c', price_cata, wood_cata);
      push_cmd ("Idle    ", cmd_idle,       'i', 0,            0);
     }.

.  show_docks_cmds
     {push_cmd ("Ship  ", cmd_built_ship,  's', price_ship1, wood_ship1);
/*
      push_cmd ("Battle", cmd_built_bship, 'b', price_ship2, wood_ship2);
*/
      push_cmd ("Idle  ", cmd_idle,        'i', 0,           0);
     }.

.  show_camp_cmds
     {push_cmd ("Knight", cmd_train_knight, 'k', price_knight, wood_knight);
      push_cmd ("Idle  ", cmd_idle,         'i', 0,            0);
     }.

.  show_worker_cmds
     {bool any_built_cmd;

      check_built_cmd;
      if   (any_built_cmd)
           push_worker_built
      else push_worker_none_built;
     }.

.  check_built_cmd
     {any_built_cmd = ((objects->cmd         [id][2] == cmd_harvest  ||
                        objects->cmd         [id][1] == cmd_harvest  ||
                        objects->cmd         [id][0] == cmd_harvest) &&
                       objects->harvest_type [id]    == harvest_built);
     }.

.  push_worker_built
     {push_cmd ("Interrupt", cmd_idle,   'i',     0,           0);
      push_cmd ("  built  ", cmd_idle,   ' ',     0,           0);
     }.

.  push_worker_none_built
     {push_cmd ("Move       ", cmd_move_to,     'm', 0,           0);
      push_cmd ("Concentrate", cmd_move_to,     'c', 0,           0);
      push_cmd ("Dig        ", cmd_dig,         'd', price_dig,   wood_dig);
      push_cmd ("Heap       ", cmd_heap,        'h', price_heap,  wood_heap);
      push_cmd ("diG to     ", cmd_dig_row,     'g', price_dig,   wood_dig);
      push_cmd ("heaP to    ", cmd_heap_row,    'p', price_heap,  wood_heap);
      push_cmd ("trAp       ", cmd_dig_trap,    'a', price_trap,  wood_trap);
      push_cmd ("haRvest    ", cmd_harvest,     'r', 0,           0);
      if   (num_town_halls < 1)
           push_cmd ("T-hall     ",cmd_built_home,'t', price_home,wood_home);
      else pawn_built_more;
      if   (num_markets > 0)
           push_cmd ("merchaNt   ",cmd_upgrade ,'n', price_trader,wood_trader);
      push_cmd ("Talk (/)   ", cmd_talk,        '/', 0,           0); 
      push_cmd ("Idle       ", cmd_idle,        'i', 0,           0);
     }.

.  pawn_built_more
    {if ((num_town_halls < 2 && town_hall_in_progress == 0) ||
         (is_water_world && num_town_halls < 4))
        push_cmd ("T-hall     ", cmd_built_home, 't', price_home,  wood_home);
     push_cmd ("Knight Camp", cmd_built_camp,   'k',price_camp,  wood_camp);
     push_cmd ("Farm       ", cmd_built_farm,   'f',price_farm,  wood_farm); 
     if   (num_markets < 1 && market_in_progress == 0)
     push_cmd ("markEt     ", cmd_built_market, 'e',price_market,wood_market); 
     push_cmd ("fort (q)   ", cmd_built_tents, 'q',price_tents,wood_tents); 
     push_cmd ("miLl       ", cmd_built_mill,   'l',price_mill,  wood_mill); 
     push_cmd ("Smith      ", cmd_built_smith,  's',price_smith, wood_smith);
     push_cmd ("docks (;)  ", cmd_built_docks,  ';',price_docks, wood_docks);
     push_cmd ("Uni        ", cmd_built_uni,    'u',price_uni,   wood_uni);
    }.

.  show_trader_cmds
     {push_cmd ("Move       ", cmd_move_to,     'm', 0,           0);
      push_cmd ("Concentrate", cmd_move_to,     'c', 0,           0);
      push_cmd ("trade J    ", cmd_trade,       'j', 0,           0);
      push_cmd ("Talk (/)   ", cmd_talk,        '/', 0,           0); 
      push_cmd ("Idle       ", cmd_idle,        'i', 0,           0);
     }.

.  show_knight_cmds
     {push_cmd ("Move       ", cmd_move_to,     'm', 0,           0);
      push_cmd ("Concentrate", cmd_move_to,     'c', 0,           0);
      push_cmd ("Attack     ", cmd_attack,      'a', 0,           0);
      push_cmd ("S & d      ", cmd_sad,         's', 0,           0);
      push_cmd ("F & d      ", cmd_fad,         'f', 0,           0);
      push_cmd ("guarD      ", cmd_guard,       'd', 0,           0);
      push_cmd ("Talk (/)   ", cmd_talk,        '/', 0,           0); 
      push_cmd ("Idle       ", cmd_idle,        'i', 0,           0);
     }.

.  show_pawn_cmds
     {push_cmd ("Move       ", cmd_move_to,     'm', 0,           0);
      push_cmd ("Concentrate", cmd_move_to,     'c', 0,           0);
      push_cmd ("Attack     ", cmd_attack,      'a', 0,           0);
      push_cmd ("S & d      ", cmd_sad,         's', 0,           0);
      push_cmd ("F & d      ", cmd_fad,         'f', 0,           0);
      push_cmd ("guarD      ", cmd_guard,       'd', 0,           0);
      if   (num_tents > 0)
        push_cmd ("scOut      ",cmd_upgrade ,'o', price_scout,wood_scout);
      push_cmd ("Talk (/)   ", cmd_talk,        '/', 0,           0); 
      push_cmd ("Idle       ", cmd_idle,        'i', 0,           0);
     }.

.  show_scout_cmds
     {push_cmd ("Move       ", cmd_move_to,     'm', 0,           0);
      push_cmd ("Concentrate", cmd_move_to,     'c', 0,           0);
      push_cmd ("Hide (A)   ", cmd_hide,        'a', 0,           0);
      push_cmd ("Talk (/)   ", cmd_talk,        '/', 0,           0); 
      push_cmd ("Idle       ", cmd_idle,        'i', 0,           0);
     }.

.  show_ship_cmds
     {w_status->set_color (30);
      w_status->fill      ( 10, 130, 170, 70);
      w_status->set_color (black);
      w_status->write     (120, 160, "Ship"); 

      w_status->set_color (29);
      w_status->fill      ( 10, 200, 170,120);
      w_status->set_color (black);
      w_status->write     (120, 230, "Crew"); 

      push_cmd ("Ship to    ", cmd_sail,        's', 0,           0);
      push_cmd ("Idle       ", cmd_idle,        'i', 0,           0);

      push_cmd ("Talk (/)   ", cmd_talk,        '/', 0,           0); 
      push_cmd ("Concentrate", cmd_concentrate, 'c', 0,           0);
      push_cmd ("Attack     ", cmd_attack,      'a', 0,           0);
      push_cmd ("Enter      ", cmd_enter,       'e', 0,           0);    
      push_cmd ("Idle       ", cmd_idle,        'i', 0,           0);
     }.

.  show_archer_cmds
     {push_cmd ("Move       ", cmd_move_to,     'm', 0,           0);
      push_cmd ("Concentrate", cmd_move_to,     'c', 0,           0);
      push_cmd ("Attack     ", cmd_attack,      'a', 0,           0);
      push_cmd ("S & d      ", cmd_sad,         's', 0,           0);
      push_cmd ("F & d      ", cmd_fad,         'f', 0,           0);
      push_cmd ("guarD      ", cmd_guard,       'd', 0,           0);
      push_cmd ("Talk (/)   ", cmd_talk,        '/', 0,           0); 
      push_cmd ("Idle       ", cmd_idle,        'i', 0,           0);
     }.

.  show_doktor_cmds
     {push_cmd ("Move       ", cmd_move_to,   'm', 0,           0);
      push_cmd ("Concentrate", cmd_move_to,   'c', 0,           0);
      push_cmd ("casT       ", cmd_heal,      't', 0,           0);
      push_cmd ("cAst all   ", cmd_sad,       'a', 0,           0);
      push_cmd ("guarD      ", cmd_guard,     'd', 0,           0);
      push_cmd ("Talk (/)   ", cmd_talk,        '/', 0,           0); 
      push_cmd ("Idle       ", cmd_idle,      'i', 0,           0);
     }.

.  show_cata_cmds
     {push_cmd ("Move       ", cmd_move_to,     'm', 0,           0);
      push_cmd ("Concentrate", cmd_move_to,     'c', 0,           0);
      push_cmd ("Attack     ", cmd_attack,      'a', 0,           0);
      push_cmd ("S & d      ", cmd_sad,         's', 0,           0);
      push_cmd ("D & d      ", cmd_fad,         'f', 0,           0);
      push_cmd ("guarD      ", cmd_guard,       'd', 0,           0);
      push_cmd ("Talk (/)   ", cmd_talk,        '/', 0,           0); 
      push_cmd ("Idle       ", cmd_idle,        'i', 0,           0);
     }.
 
  }

void player::inform (char msg [])
  {if (! is_robot)
      perform_show;

.  perform_show
     {ack (msg);
     }.

  }

void player::write (char msg [])
  {
  }

/*
void player::write (char msg [])
  {if (! is_robot)
      perform_show;

.  perform_show
     {strcpy (msgs [0], msgs [1]);
      strcpy (msgs [1], msgs [2]);
      strcpy (msgs [2], msg);
  
      w_inform->set_color      (gray80);
      w_inform->set_background (gray80);
      w_inform->fill           (0, 0, 300, 60);
      w_inform->set_color      (red);
      for (int i = 0; i < 3; i++)
        w_inform->write (1, i * 15 + 20, msgs [i]);
      w_inform->tick ();
     }.

  }
*/

void player::edit ()
  {menu *edit_men;
   int  act;
   bool quit;
   int  last_x;
   int  last_y;

   init_edit;
   perform_edit;
   finish_edit;

.  init_edit
     {open_edit_men;
      act       = land_grass;
      quit      = false;
      last_x    = 0;
      last_y    = 0;
     }.

.  open_edit_men
     {edit_men = new menu ("edit_men",
                           by_fix,
                           by_fix,
                           "grass:water:bush:wood:mine:+:-:home:save:quit:");
      edit_men->press (0);
     }.

.  finish_edit
     {delete (edit_men);
     }.
     
.  perform_edit
     {while (! quit)
        {edit_cycle;
        };
     }.

.  edit_cycle
     {init;
      handle_cmds;
      handle_click;
      handle_scrollers;
      handle_overview_move;
      finish;
     }.

.  init
     {w_land    ->mark_mouse (); 
      w_land    ->tick       ();
      w_overview->mark_mouse ();
      w_overview->tick       ();
     }.

.  finish
     {w_land    ->scratch_mouse ();
      w_overview->scratch_mouse ();
     }.

.  handle_cmds
     {int cmd;

      if ((cmd = edit_men->eval ()) != no_menu_request)
         exec_cmd;
     }.

.  exec_cmd
     {edit_men->release ();
      set_button;
      switch (cmd)
        {case 0 : act = land_grass; break;
         case 1 : act = land_water; break;
         case 2 : act = land_bush ; break;
         case 3 : act = land_wood ; break;
         case 4 : act = 1001;       break;
         case 5 : act = 1002;       break;
         case 6 : act = 1003;       break;
         case 7 : act = 1004;       break;
         case 8 : handle_save;      break;
         case 9 : quit = true;      break;
        };
     }.

.  set_button
     {if (cmd < 8)
         set_buttons;
     }.

.  set_buttons
     {release_buttons;
      edit_men->press (cmd);
     }.

.  release_buttons
     {for (int i = 0; i < 8; i++)
        edit_men->release (i);
     }.

.  handle_save
     {save_land (land_name);
     }.

.  handle_click
     {int xe;
      int ye;
      int b;

      if (w_land->is_mouse (xe, ye, b) && click_event)
         handle_click_event;
      if (w_land->is_mouse (xe, ye, b) && fill_event)
         handle_fill_event;
      }.

.  click_event
     (b == button1press).

.  fill_event
     (b == button2press).

.  handle_fill_event
     {int mx;
      int my;
      int xa;
      int ya;

      calc_mx_my;
      xa = mx;
      ya = my;
      for (mx = i_min (last_x, xa); mx <= i_max (last_x, xa); mx++)
        for (my = i_min (last_y, ya); my <= i_max (last_y, ya); my++)
          if (mx != last_x || my != last_y)
             fill_field;
      land_skip_left;
     }.

.  fill_field
     {switch (act)
        {case land_grass : set_grass; break;
         case land_water : set_water; break;
         case land_bush  : set_bush;  break;
         case land_wood  : set_wood;  break;
         case 1001       : set_mine;  break;
         case 1002       : set_plus;  break;
         case 1003       : set_minus; break;
         case 1004       : set_home;  break;
        };
      objects->readjust_land (mx, my, 0);
      objects->refresh       (mx, my);
     }.

.  handle_click_event
     {int mx;
      int my;

      calc_mx_my;
      last_x = mx;
      last_y = my;
      switch (act)
        {case land_grass : set_grass; break;
         case land_water : set_water; break;
         case land_bush  : set_bush;  break;
         case land_wood  : set_wood;  break;
         case 1001       : set_mine;  break;
         case 1002       : set_plus;  break;
         case 1003       : set_minus; break;
         case 1004       : set_home;  break;
        };
      objects->readjust_land (mx, my, 0);
      objects->refresh       (mx, my);
      land_skip_left;
     }.

.  land_skip_left
     {int d;

      w_land->mouse (d, d, d);
     }.

.  set_grass
     {check_field;
      landscape [mx][my] = land_grass;
      landpic   [mx][my] = land_grass;
     }.

.  set_water
     {if (landhight [mx][my] <= 0)
         {check_field;
          landscape [mx][my] = land_water;
          landpic   [mx][my] = land_water;
         };
     }.

.  set_bush
     {check_field;
      landscape [mx][my] = land_bush;
      landpic   [mx][my] = land_bush;
     }.

.  set_wood
     {check_field;
      landscape [mx][my] = land_wood;
      landpic   [mx][my] = land_wood;
     }.

.  check_field
     {int u = point_to (mx, my);

      if (u != none)
         {objects->destroy_building (u);
          objects->delete_object    (u);
         };
     }.

.  set_mine
     {check_field;
      objects->create_building (mx, my, object_mine, 10000, 0 , none);
     }.

.  set_home
     {check_field;
      objects->create_building (mx, my, object_home, 10000, 0 , none);
     }.

.  set_plus
     {objects->readjust_land (mx, my, 1);
     }.

.  set_minus
     {objects->readjust_land (mx, my, -1);
     }.

.  calc_mx_my
     {mx = xe / pic_dx + x0;
      my = ye / pic_dy + y0;
      mx = i_bound (0, mx, landscape_dx - 1);
      my = i_bound (0, my, landscape_dy - 1);
     }.

.  handle_scrollers
     {int xe;
      int ye;
      int b;

      if (w_land->is_mouse (xe, ye, b) && scroller_event)
         handle_scroller;
      }.

.  scroller_event
     (b == button3press).

.  handle_scroller
     {int xx;
      int yy;

      w_land->mouse (xe, ye, xx, yy, b);
      if (xe <= pic_dx)       handle_left;
      if (xe >= wdx - pic_dx) handle_right;
      if (ye <= pic_dy)       handle_up;
      if (ye >= wdy - pic_dy) handle_down;
     }.

.  handle_left
     {show_overview_frame (false);
      x0 = i_max (0, x0 - 1);
      show                ();
      show_overview_frame (true);
     }.

.  handle_right
     {show_overview_frame (false);
      x0 = i_min (max_x, x0 + 1);
      show                ();
      show_overview_frame (true);
     }.

.  handle_up
     {show_overview_frame (false);
      y0 = i_max (0, y0 - 1);
      show                ();
      show_overview_frame (true);
     }.

.  handle_down
     {show_overview_frame (false);
      y0 = i_min (max_y, y0 + 1);
      show                ();
      show_overview_frame (true);
     }.

.  handle_overview_move
     {int xe;
      int ye;
      int b;

      if (w_overview->is_mouse (xe, ye, b))
         handle_overview;
     }.

.  handle_overview
     {int xx;
      int yy;
      int bb;
      int nx;
      int ny;

      get_mouse;
      nx = i_bound (0, (xx / 2) - (wdx / pic_dx) / 2, max_x);
      ny = i_bound (0, (yy / 2) - (wdy / pic_dy) / 2, max_y);
      if (any_change)
         perform_overview_move;
     }.

.  any_change
     (nx != x0 || ny != y0).

.  perform_overview_move
     {show_overview_frame (false);
      x0 = nx;
      y0 = ny;
      show                ();
      show_overview_frame (true);
     }.

.  get_mouse
     {while (w_overview->is_mouse (xe, ye, b))
        {w_overview->mouse (xe, ye, xx, yy, bb);
        };
     }.

.  max_x  (landscape_dx - (wdx / pic_dx)).
.  max_y  (landscape_dy - (wdy / pic_dy)).

  }
   
void player::add_sun (int lx, int ly, int r)
  {if (is_suny && ! is_robot && active)
      perform_sun;

.  perform_sun
     {for (int x = i_max (0, lx-r); x <= i_min (landscape_dx-1, lx+r); x++)
        for (int y = i_max (0, ly-r); y <= i_min (landscape_dy-1, ly+r); y++)
          set;
     }.

.  set
     {sun_cnt [x][y]++;
      if (sun_cnt [x][y] == 1)
         {show          (x, y);
          show_overview (x, y);
         };
     }.

  }

void player::sub_sun (int lx, int ly, int r)
  {if (is_suny && ! is_robot && active)
      perform_sun;

.  perform_sun
     {for (int x = i_max (0, lx-r); x <= i_min (landscape_dx-1, lx+r); x++)
        for (int y = i_max (0, ly-r); y <= i_min (landscape_dy-1, ly+r); y++)
          set;
     }.

.  set
     {sun_cnt [x][y]--;
      if (sun_cnt [x][y] == 0)
         {show          (x, y);
          show_overview (x, y);
         };
     }.

  }

void player::move_sun (int lx, int ly, int dx, int dy, int r)
  {if   (dx != 0) 
        {move_sun_d (lx, ly, dx,  0, r);
         if (dy != 0) 
             move_sun_d (lx + dx, ly,  0, dy, r);
        }
   else if (dy != 0) 
        move_sun_d (lx, ly,  0, dy, r);

  }
       
void player::move_sun_d (int lx, int ly, int dx, int dy, int r)
  {if (is_suny && ! is_robot && active)
      perform_sun;

.  perform_sun
     {int ix = i_sign (dx); 
      int iy = i_sign (dy);

      perform_sub;
      perform_add;
     }.

.  perform_sub
     {if (iy != 0) sub_y;
      if (ix != 0) sub_x;
     }.

.  sub_y
     {int y = ly - (r * iy);
  
      if (0 <= y && y <= landscape_dy-1)
         perform_sub_y;
     }.

.  perform_sub_y
     {for (int x = i_max (0, lx-r); x <= i_min (landscape_dx-1, lx+r); x++)
        {sub;
        };
     }.

.  sub_x
     {int x = lx - (r * ix);

      if (0 <= x && x <= landscape_dx-1)
         perform_sub_x;
     }.

.  perform_sub_x
     {for (int y = i_max (0, ly-r); y <= i_min (landscape_dy-1, ly + r); y++)
        {sub;
        };
     }.

.  sub
     {sun_cnt [x][y]--;
      if (sun_cnt [x][y] == 0)
         {show          (x, y);
          show_overview (x, y);
         };
     }.

.  perform_add
     {if (iy != 0) add_y;
      if (ix != 0) add_x;
     }.

.  add_y
     {int y = ly + ((r+1) * iy);

      if (0 <= y && y <= landscape_dy-1)
         perform_add_y;
     }.

.  perform_add_y
     {for (int x=i_max (0, lx-(r)); x<=i_min (landscape_dx-1, lx+(r)); x++)
        {add;
        };
     }.

.  add_x
     {int x = lx + ((r+1) * ix);

      if (0 <= x && x <= landscape_dx-1)
         perform_add_x;
     }.

.  perform_add_x
     {for (int y=i_max (0, ly-(r)); y<=i_min (landscape_dy-1, ly+(r)); y++)
        {add;
        };
     }.

.  add
     {sun_cnt [x][y]++;
      if (sun_cnt [x][y] == 1)
         {show          (x, y);
          show_overview (x, y);
         };
     }.

  }

void player::handle_pause ()
  {update_buttons;
   handle_own;

.  update_buttons
     {for (int i = 0; i < num_players; i++)
        {if (p_pressed [i] != paused [i])
            redisplay_button;
        };
     }.

.  redisplay_button
     {p_button [i]->press (paused [i]);
      p_pressed [i] = paused [i];
     }.

.  handle_own
     {w_pause->mark_mouse ();
      w_pause->tick       ();
      if (p_button [p_no]->eval ())
         {paused    [p_no] = ! paused [p_no];
          p_pressed [p_no] = paused   [p_no];
          p_button  [p_no]->press (paused [p_no]);
          if   (p_pressed [p_no])
               num_paused++;
          else num_paused--;
         };
      w_pause->scratch_mouse ();
     }.

  }

void player::set_extra_mark (int dx, int dy)
  {if      (dx == 0 && extra_mark_dx != 0)  switch_off
   else if (dx != 0 && extra_mark_dx == 0)  switch_on;

.  switch_off
     {for (int yy = extra_y; yy < extra_y + extra_mark_dy; yy++)
        for (int xx = extra_x; xx < extra_x + extra_mark_dx; xx++)
          show (xx, yy);
      extra_mark_dx = dx;
      extra_mark_dy = dy;
     }.

.  switch_on
     {extra_mark_dx = dx;
      extra_mark_dy = dy;
      extra_x       = last_mx;
      extra_y       = last_my;
      for (int yy = extra_y; yy < extra_y + extra_mark_dy; yy++)
        for (int xx = extra_x; xx < extra_x + extra_mark_dx; xx++)
          show (extra_x, extra_y, xx, yy, true);
     }. 

  }
