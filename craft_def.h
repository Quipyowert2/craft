#ifndef craft_def_h
#define craft_def_h

#include "bool.h"

#define max_land_dx 400
#define max_land_dy 400
#define max_pics    30000

#define max_players 4

#define max_cols    100

#define none        -1

#define max_objects         400
#define max_land_types      5000
#define max_pics_per_player 6000

#define pic_cata_name "hcraft/pic_cata_new"
#define pic_names     "hcraft/pic"
#define info_name     "hcraft/infos"

#define pic_dx             30
#define pic_dy             30

#define cmd_idle           0
#define cmd_move_to        1
#define cmd_perform_steps  2
#define cmd_dig            3
#define cmd_harvest        4
#define cmd_stop           5
#define cmd_wait           6
#define cmd_hack           7
#define cmd_construct      8
#define cmd_heap           9
#define cmd_train_worker   10
#define cmd_built_camp     11
#define cmd_built_farm     12
#define cmd_built_mill     13
#define cmd_built_smith    14
#define cmd_built_uni      15
#define cmd_built_home     16
#define cmd_attack         17
#define cmd_train_knight   18
#define cmd_hit            19
#define cmd_train_archer   20
#define cmd_train_pawn     21
#define cmd_train_cata     22
#define cmd_load           23
#define cmd_die            24
#define cmd_train_doktor   25
#define cmd_heal           26
#define cmd_sad            27 
#define cmd_const_wall     28
#define cmd_command        29
#define cmd_concentrate    30
#define cmd_fad            31
#define cmd_heap_row       32
#define cmd_dig_row        33
#define cmd_setup_trap     34
#define cmd_dig_trap       35
#define cmd_guard          36
#define cmd_train_trader   37
#define cmd_trade          39
#define cmd_built_market   40
#define cmd_exec_trade     41
#define cmd_upgrade        42
#define cmd_train_scout    43
#define cmd_built_tents    44
#define cmd_hide           45
#define cmd_sail           46
#define cmd_built_docks    47
#define cmd_built_ship     48
#define cmd_built_bship    49
#define cmd_enter          50
#define cmd_entered        51
#define cmd_talk           52 

#define land_stump         10
#define land_bush          11
#define land_wood          12 
#define land_mud           20
#define land_grass         40
#define land_water         60
#define land_sea           61
#define land_wall          80
#define land_field         100
#define land_pali          110
#define land_building      105
#define land_step          130
#define land_trap          150
#define land_t_wood        160
#define land_t_gold        170

#define pic_captain_on     180
#define pic_captain_off    181
#define pic_crew_on        182
#define pic_crew_off       183
#define pic_msg            190

#define pic_max_land       500

#define pic_extra_mark       5
#define pic_trap           150
#define pic_town_hall      500
#define pic_mine           510
#define pic_building_site  520
#define pic_camp           530
#define pic_farm           540
#define pic_mill           550
#define pic_smith          560
#define pic_uni            570
#define pic_building_zombi 580
#define pic_market         590
#define pic_tents          600

#define xpic_worker_idle   1200
#define xpic_worker_move   1300 
#define xpic_worker_work   1400
#define xpic_worker_sack   2200
#define xpic_worker_wood   2300

#define xpic_knight_idle   1500
#define xpic_knight_move   1600 
#define xpic_knight_fight  1700

#define xpic_pawn_idle     1900
#define xpic_pawn_move     2000 
#define xpic_pawn_fight    2100

#define xpic_archer_idle   2400
#define xpic_archer_move   2500
#define xpic_archer_fight  2600

#define pic_arrow          2700

#define xpic_cata_idle     2800
#define xpic_cata_move     2900
#define xpic_cata_fight    3000

#define pic_stone          3100

#define xpic_doktor_idle   3200
#define xpic_doktor_move   3300
#define xpic_doktor_fight  3400

#define xpic_zombi         1800
#define xpic_swim          1804
#define pic_schrott        3500

#define xpic_trader_idle   3600
#define xpic_trader_move   3700
#define xpic_trader_gold   3800
#define xpic_trader_wood   3900

#define xpic_scout_idle    4000
#define xpic_scout_move    4100 
#define xpic_scout_hide    4200

#define xpic_ship1_idle    4400
#define xpic_ship1_empty   4500
#define xpic_ship1_move    4600 
#define xpic_ship_zombi    4800  
#define xpic_ship_on_dock  5100

#define xpic_ship2_idle    5200
#define xpic_ship2_empty   5300
#define xpic_ship2_move    5400

#define pic_docks          5000
#define pic_docks_built    4900

#define xspeed_stag           5
#define xspeed_worker         12
#define xspeed_trader         50
#define xspeed_knight         8
#define xspeed_pawn           8
#define xspeed_scout          8
#define xspeed_archer         9
#define xspeed_home           10
#define xspeed_farm           500
#define xspeed_zombi          10
#define xspeed_schrott        10
#define xspeed_swim           10
#define xspeed_water          50 
#define xspeed_hit            8
#define xspeed_building_zombi 10
#define xspeed_archer_hit     15
#define xspeed_cata           15
#define xspeed_cata_load      100
#define xspeed_explosion      5
#define xspeed_doktor         7
#define xspeed_doktor_hit     10
#define xspeed_general        300
#define xspeed_trap           200
#define xspeed_arrow          4
#define xspeed_stone          3
#define xspeed_ship1          15
#define xspeed_ship2          10
#define xspeed_ship_zombi     60


#define duration_hit         8

#define sad_radius           5

#define object_worker         1
#define object_knight         2
#define object_home           3
#define object_mine           4
#define object_building_site  5
#define object_water          6
#define object_camp           7
#define object_farm           8
#define object_mill           9
#define object_smith          10
#define object_uni            11
#define object_zombi          12
#define object_swim           13
#define object_building_zombi 14
#define object_archer         15
#define object_pawn           16
#define object_arrow          17
#define object_cata           18
#define object_stone          19
#define object_explosion      20
#define object_doktor         21
#define object_schrott        22
#define object_trap           23
#define object_trader         24
#define object_market         25
#define object_scout          26
#define object_tents          27
#define object_ship1          28
#define object_ship_zombi     29
#define object_docks          30
#define object_site_docks     31
#define object_msg            32

#define trade_wood            1
#define trade_gold            2

#define harvest_dx         3
#define harvest_dy         3

#define harvest_wood       0
#define harvest_gold       1
#define harvest_dig        2
#define harvest_heap       3
#define harvest_built      4

#define wood_per_harvest   100
#define money_per_harvest  100

#define max_power_per_farm 20
#define power_per_field    0.5
#define max_food           1000

#define price_trap         20
#define wood_trap          6
#define price_dig          5
#define wood_dig           2
#define price_heap         5
#define wood_heap          2

#define price_worker       400
#define price_pawn         200
#define wood_pawn            1
#define price_scout        400
#define wood_scout           1
#define price_knight       400
#define wood_knight          5
#define price_archer       500
#define wood_archer         60
#define price_camp         1000
#define wood_camp          600
#define price_farm         100
#define wood_farm          200
#define price_mill         1500
#define wood_mill          600
#define price_smith        3000
#define wood_smith         600
#define price_uni          800
#define wood_uni           400
#define price_cata         1000
#define wood_cata          200
#define price_doktor       400
#define wood_doktor        100
#define price_home         0
#define wood_home          0
#define price_trader       400
#define wood_trader        50
#define price_market       1000
#define wood_market        500
#define price_tents        1000
#define wood_tents         500
#define price_ship1        600
#define wood_ship1         500
#define price_ship2        2400
#define wood_ship2         500
#define price_docks        1200
#define wood_docks         600
#define amour_docks        95 

#define guard_range        7
#define scope_cata         8
#define scope_archer       7

#define power_knight       50
#define amour_knight       15

#define power_arrow        30

#define power_stone        100

#define power_trap         80

#define amour_archer       5

#define amour_doktor       0
#define power_doktor       5

#define amour_cata         20

#define power_pawn         25
#define amour_pawn         10

#define power_scout        0
#define amour_scout        1

#define amour_worker        0
#define amour_building     25 

#define power_trader        0
#define amour_trader       20

#define amour_ship1        98


#define max_knights_per_camp   10
#define max_archers_per_mill   8
#define max_catas_per_smith    2
#define max_ships_per_dock     1
#define max_doktors_per_uni    5
#define max_traders_per_market 10
#define max_scouts_per_tents   4

#define max_marked           50

#define max_num_mans         70

#define vr_man               7

struct land_prop
  {int  overview_color;
   int  wood;
   int  money;
   bool walk_possible;
   bool with_hl;
   bool is_forest;
   bool is_grass;
   bool is_dig;
   bool is_water;
   bool can_grow;
  };

#endif
