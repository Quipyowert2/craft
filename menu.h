/*======================================================================*/
/*= CHANGES AND UPDATES                                                =*/
/*======================================================================*/
/*= date   person file       subject                                   =*/
/*=--------------------------------------------------------------------=*/
/*=                                                                    =*/
/*= 050293 hua    menu.h     added enable                              =*/
/*=                                                                    =*/
/*= 130793 smieja menu.h     added demo & info modes                   =*/
/*=                                                                    =*/
/*======================================================================*/

/*======================================================================*/
/*                                                                      */
/* Includes                                                             */
/*                                                                      */
/*======================================================================*/
 
#ifndef menu_h
#pragma interface
#define menu_h

#include "stdio.h"
#include "string.h"

#include "win.h"

#include "io.h"
#include "bool.h"
#include "xmath.h"

/*----------------------------------------------------------------------*/
/* CLASS menu (deklarations)                                            */
/*----------------------------------------------------------------------*/

#define no_menu_request      -1
#define text_dx              14
#define text_dy              20
#define border_dx             3
#define border_dy             3

#define max_buttons          40
#define max_menu_groups      20
#define std_menu_group        0

#define men_font             "-misc-*-*-*-*-*-*-*-*-*-*-*-*-*"

/*--- meue groups ------------------------------------------------------*/

#define mgroup_surgeon 1
#define mgroup_demo    2
#define mgroup_info    3

#define m_pull_down 0
#define m_pop_up    1

class menu
  {public:

     static bool manager_init;
     static bool group_enabled [max_menu_groups];

     win  *w;

     int  group;
     char button_dir [128];
     char name       [128];
     char cmds       [max_buttons][128];
     int  tdx        [max_buttons];
     int  tdy        [max_buttons];
     bool is_pressed [max_buttons];
     bool is_open;
     bool is_press;
     int  mode;

     int  c_border_light;
     int  c_border_dark;
     int  c_background;
     int  c_foreground;

     int  button_dx;
     int  button_dy;
     int  num_buttons;
     int  pressed_button;
     int  last_mouse_button;

     bool icon_mode;

     int  x;
     int  y;
     int  dx;
     int  dy;
  

      menu ();
      menu (const char name [],
            int  x,
            int  y,
            const char cmds [],
            int  wmode = m_pop_up,
            int  menu_group = std_menu_group);

     ~menu (); 

     void open         ();
     void close        ();
     void tick         ();
     void enable       (int group, bool mode);
     int  eval         (bool repeat = false);
     int  mouse_button ();
     void press        (int no);
     void release      ();
     void release      (int no);
     void write        (int m_no, char string [], bool pressed = false);
     bool get_cmd      (const char cmds [], int &p, char cmd []);
     
  };

#endif

