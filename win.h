#ifndef win_h
#define win_h

/*======================================================================*/
/*= CHANGES AND UPDATES                                                =*/
/*======================================================================*/
/*= date   person file       subject                                   =*/
/*=--------------------------------------------------------------------=*/
/*=                                                                    =*/
/*= 050293 hua    win.h      added enable                              =*/
/*=                                                                    =*/
/*= 110293 hua    win.h      added set_color                           =*/
/*=                                                                    =*/
/*======================================================================*/

/*======================================================================*/
/*                                                                      */
/* Includes                                                             */
/*                                                                      */
/*======================================================================*/
 
#include "stdlib.h"
#include "stdio.h"
#include "string.h"
#include "X11/Xlib.h"
#include "X11/Xutil.h"
#include "X11/cursorfont.h"

#include "io.h"
#include "bool.h"
#include "xmath.h"
#include "table.h"
#include "paramreader.h"

/*----------------------------------------------------------------------*/
/*  mouse modes                                                         */
/*----------------------------------------------------------------------*/

#define button1press    1
#define button2press    2
#define button3press    3
#define button1release -1
#define button2release -2
#define button3release -3
#define nobutton       -999

/*----------------------------------------------------------------------*/
/* colors                                                               */
/*----------------------------------------------------------------------*/

#define white        0
#define red          1
#define red1         2
#define red2         3
#define red3         4
#define red4         5
#define sienna       6
#define sienna1      7
#define sienna2      8
#define sienna3      9
#define sienna4     10
#define yellow      11
#define yellow1     12
#define yellow2     13
#define yellow3     14
#define yellow4     15
#define green       16
#define green1      17
#define green2      18
#define green3      19
#define green4      20
#define blue        21
#define blue1       22
#define blue2       23
#define blue3       24
#define blue4       25
#define slategray   26
#define slategray1  27
#define slategray2  28
#define slategray3  29
#define slategray4  30
#define darkgreen   31
#define seagreen    32
#define seagreen1   33
#define seagreen2   34
#define seagreen3   35
#define cyan        36
#define cyan1       37
#define cyan2       38
#define cyan3       39
#define cyan4       40
#define purple      41
#define purple1     42
#define purple2     43
#define purple3     44
#define purple4     45
#define gold        46
#define gold1       47
#define gold2       48
#define gold3       49
#define gold4       50
#define gray        51
#define gray10      52
#define gray20      53
#define gray30      54
#define gray40      55
#define gray50      56
#define gray60      57
#define gray70      58
#define gray80      59
#define gray90      60
#define gray100     61
#define navyblue    62
#define black       63

/*----------------------------------------------------------------------*/
/* FONTS                                                                */
/*----------------------------------------------------------------------*/

#define win_default_font  "-misc-*-*-*-*-*-*-*-*-*-*-*-*-*"

/*----------------------------------------------------------------------*/
/* ROUTINES bitmap size information (deklarations)                      */
/*----------------------------------------------------------------------*/

bool bitmap_size (char name [], int &dx, int &dy);

/*----------------------------------------------------------------------*/
/* ROUTINES text size information (deklarations)                        */
/*----------------------------------------------------------------------*/

void text_size (char s [], char font [], int &dx, int &dy, int &num_of_lines);

/*----------------------------------------------------------------------*/
/* Default Handler (deklarations)                                       */
/*----------------------------------------------------------------------*/

#define default_win_param_file_name "/home/hua/craft/.windefaults"

extern bool        win_handler_init;
extern paramreader *win_defaults;

int   win_default_i (int param, char default_name []);
int   win_default_i (char default_name []);
int   win_default_c (int param, char default_name []);
int   win_default_c (char default_name []);
char *win_default_s (char default_name []);
int   win_color     (char color_name   []);

/*----------------------------------------------------------------------*/
/* CLASS polyline (deklarations)                                        */
/*----------------------------------------------------------------------*/

#define max_poly_points 20

class polyline
  {public :

     int    n;
     XPoint p [max_poly_points];

          polyline  ();
          ~polyline ();

     void add       (int x, int y);
     void close     ();

  };

/*----------------------------------------------------------------------*/
/* CLASS win (deklarations)                                             */
/*----------------------------------------------------------------------*/

#define max_mouse_events 16
#define max_colors       64
#define by_user          -1
#define by_fix           -2
#define by_default       -3
#define keybuf_size      256

class win
  {public :

     Colormap      cmap;
     Display       *mydisplay;
     Window        mywindow;
     int           myscreen;
     GC            mygc;		
     unsigned long myforeground;
     unsigned long mybackground;
     XSizeHints    *myhint;
     XFontStruct   *font_info;

     long          event_mask;
     bool          is_enable;
     bool          is_alien;
     bool          with_fix;
     char          name [128];
     int           open_x;
     int           open_y;
     int           open_dx;
     int           open_dy;
     int           w_dx;
     int           w_dy;

     int           last_best_color;

     unsigned long last_pixel;
     int           last_r;
     int           last_g;
     int           last_b;
     bool          is_last_pixel;

     static char   fix_name [128];
     static char   fix_dir  [128];
     static bool   fix_initialized;

     int           colors  [max_colors];
     int           color_r [max_colors];
     int           color_g [max_colors];
     int           color_b [max_colors];
     int           num_colors;

     char          inbuffer   [keybuf_size];
     int           keybuffer  [keybuf_size];
     char          cntlbuffer [keybuf_size][32];
     int           keycount;
     int           act_key;
     int           press_cnt;

     bool          mouse_inside;
     int           mouse_x;
     int           mouse_y;

     bool          mouse_press [3];
     int           mouse_ex    [max_mouse_events];
     int           mouse_ey    [max_mouse_events];
     int           mouse_event [max_mouse_events];
     int           mouse_eid   [max_mouse_events];
     int           num_mouse_events;
     int           event_mark;
     int           event_id;

          win  (char title []);

          win  (char title [],
                char host  [],
                int  x,
                int  y, 
                int  dx,
                int  dy,
                bool enable        = true,
                bool resize_enable = false);
          win  (win  *parent,
                char title [],
                char host  [],
                int  x,
                int  y, 
                int  dx,
                int  dy,
                bool enable        = true,
                bool resize_enable = false);  
          ~win ();

     void   iconify          ();
     void   fix              ();
     void   fix_pos          (int &x,  int &y);
     void   fix_size         (int &dx, int &dy);
     void   set_cursor       (char name []);
     void   set_cursor       (int cursor);
     void   set_color        (int r, int g, int b);
     void   win_rgb          (int color, int &r, int &g, int b);
     int    win_color        (int r, int g, int b);
     void   set_color        (int color);
     void   set_background   (int color);
     void   function         (int func);
     void   shift            (int x1, int y1, int x2, int y2, int dx, int dy);
     void   pixel            (int x, int y);
     void   pixel            (Pixmap p, int x, int y);
     void   line             (int x1, int y1, int x2, int y2);
     void   box              (int x1, int y1, int x2, int y2);
     void   fill             (int x1, int y1, int dx, int dy);
     void   move             (int x,  int y,  int x1, int y1, int dx, int dy);
     bool   on               ();
     bool   mouse            (int &x, int &y, int &button);
     bool   mouse            (int &x, int &y, int &ex, int &ey, int &button);
     bool   mouse_is_pressed (int button);
     bool   is_mouse         (int &xe, int &ye, int &button);
     void   mark_mouse       ();
     void   scratch_mouse    ();
     void   clear            ();
     void   set_font         (char name []);
     void   text_size        (char string [], int &dx, int &dy);
     void   write            (int x, int y, char   string []);
     void   write            (int x, int y, double d);
     void   write            (int x, int y, int    i);
     void   set_clip         (int x, int y, int dx, int dy);
     void   show_map         (int x, int y, char name []);
     void   show_map         (int x, int y, Pixmap m, int dx, int dy);
     void   show_map         (int x, int y,
                              int s_x, int s_y, Pixmap m, int dx, int dy);
     void   show_map         (int x, int y, Pixmap m, int dx, int dy, 
                              Pixmap mask, int clip_x, int clip_y);
     void   show_map         (int x, int y, Pixmap m, int dx, int dy, 
                              Pixmap mask);
      void show_map          (Pixmap m,
                              Pixmap mask,
                              int    x_source,
                              int    y_source,
                              int    x_screen,
                              int    y_screen,
                              int    dx,
                              int    dy, 
                              int    x_mask,
                              int    y_mask);
     void   load_map         (char name [], Pixmap &m, int &dx, int &dy);
     void   store_map        (char name [], int x, int y, int dx, int dy);
     void   store_map        (Pixmap &p, int x, int y, int dx, int dy);
     void   store_map        (Pixmap &p, int x, int y, int dx, int dy,
                              Pixmap mask);
     void   create_map       (Pixmap &p, int dx, int dy);
     void   delete_map       (Pixmap &p);
     void   sync             ();
     void   idle             (bool mode);
     char   inchar           ();
     char   inchar           (int &key);
     char   inchar           (int &key, char *cntl);
     int    getkey           ();
     int    x                ();
     int    y                ();
     int    dx               ();
     int    dy               ();
     void   tick             (bool just_raised);
     void   tick             ();
     void   alloc_color      (char name [], int no);
     void   create_color_map ();
     void   draw             (polyline *p);
     void   fill             (polyline *p);
     void   xsync            ();

     Window grab             (Display *dsp, Window wnd, char name []);

     void   get_image        (XImage *&i, int x, int y, int dx, int dy);
     void   put_image        (XImage *i, int x, int y, int dx, int dy);
     void   get_color        (XImage *i, int x, int y, int &r, int &g, int &b);
     void   set_pixel        (XImage *i, int x, int y, int color);
     void   ppm              (char file_name [], int x, int y, int dx, int dy);

 };

#endif
