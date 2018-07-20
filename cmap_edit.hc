#include "dial.h"
#include "cmap.h"
#include "cmap_selector.h"
#include "file_selector.h"
#include "cmap_edit.h"
#include "bool.h"
#include "win.h"
#include "masks.h"
#include "xbm.h"
#include "ppm.h"

#define edit_dx  800
#define edit_dy  800
#define cmd_dx   300
#define cmd_dy   400
#define x_pic    8
#define y_pic    8

#define colors_dx 386
#define colors_dy 30
#define color_dx  6
#define color_dy  28
#define color_x   1
#define color_y   1
#define max_color 64

#define pic_dx   200
#define pic_dy   200
#define pic_x    10
#define pic_y    10

#define bresize_x  10
#define bresize_y  20 
#define bflip_x    10
#define bflip_y    50
#define breplace_x 10
#define breplace_y 80
#define boverlay_x 10
#define boverlay_y 110
#define bmark_x    200
#define bmark_y    300


#define bload_x    10
#define bload_y   140
#define bsave_x    10
#define bsave_y   170
#define bsaveas_x  10
#define bsaveas_y 200
#define bimport_x  10
#define bimport_y 230 
#define bsplit_x   10
#define bsplit_y  260 
#define bpaste_x   10
#define bpaste_y  290 
#define bquit_x    10
#define bquit_y   320 


#define bleft_x     60
#define bleft_y    100
#define bright_x   120
#define bright_y   100
#define bup_x       90
#define bup_y       70
#define bdown_x     90
#define bdown_y    130
#define brotate_x   90
#define brotate_y  100
#define brotateh_x 150
#define brotateh_y 100

#define colors_x  110
#define colors_y  200
#define colors_d  40
#define colors_tx 110
#define colors_ty 180
#define colors_td 20



cmap_edit::cmap_edit ()
  {
  }

cmap_edit::cmap_edit (char map_name [])
   {store_params;
    init_status;
    load_map;
    open_cmd_win;
    open_map_win;
    open_picture;
    init_omap;
    exec_show;
    show_color_table;
    show_colors;
    open_buttons;
 
.  init_omap
     {for (int x = 0; x < 5; x++)
        for (int y = 0; y < 5; y++)
          omap [x][y] = true;
      }.

.  load_map 
     {if   (f_exists (complete (name, ".cmap")))
           load ();
      else open_new_map;
      if (dx > 100 || dy > 100)
         {pixel_dx = 1;
          pixel_dy = 1;
         };
     }.

.  open_new_map
     {exec_resize;
      fill_initial;
     }.

.  fill_initial
     {for (int x = 0; x < max_map_dx; x ++)
        for (int y = 0; y < max_map_dy; y++)
          act_map = white;
     }.

.  exec_resize
     {dx = 16;
      dy = 16;
     }.

.  store_params
     {strcpy (name, map_name);
     }.

.  init_status
     {changed    = false;
      fg_color   = 0;
      bg_color   = max_colors-1;
      last_color = fg_color;
      t_color    = 12;
      last_x     = 0;
      last_y     = 0;
      xcross     = -1;
      xcross     = -1;
      pixel_dx   =  6;
      pixel_dy   =  6;
      is_mark    = false;
      d_is_mark  = false;
     }.

.  show_colors
     {show_bg_color;
      show_colors_frame;
      show_fg_color;
      show_t_color;
      cmd_win->tick ();
     }.

.  show_colors_frame
     {cmd_win->set_color (black);
      cmd_win->line      (colors_x, colors_y, 
                           colors_x + colors_d, colors_y);
      cmd_win->line      (colors_x, colors_y, 
                           colors_x, colors_y + colors_d);
      cmd_win->line      (colors_x + colors_d, colors_y + colors_d, 
                           colors_x + colors_d, colors_y);
      cmd_win->line      (colors_x + colors_d, colors_y + colors_d, 
                           colors_x, colors_y + colors_d);
     }.

.  show_bg_color
     {cmd_win->set_color (bg_color);
      cmd_win->fill      (colors_x, colors_y, colors_d, colors_d);
     }.

.  show_fg_color
     {cmd_win->set_color (fg_color);
      cmd_win->fill      (colors_x + colors_d / 4, 
                           colors_y + colors_d / 4,
                           colors_d / 2, colors_d / 2);
     }.

.  show_t_color
     {cmd_win->set_color (t_color);
      cmd_win->fill      (colors_tx, colors_ty, colors_td, colors_td);
     }.

.  open_buttons
     {bquit    = new button (cmd_win, "/quit",   bquit_x,   bquit_y);
      bsplit   = new button (cmd_win, "/split",  bsplit_x,  bsplit_y);
      bload    = new button (cmd_win, "/load",   bload_x,   bload_y);
      bimport  = new button (cmd_win, "/import", bimport_x, bimport_y);
      bsave    = new button (cmd_win, "/save",   bsave_x,   bsave_y);
      bsaveas  = new button (cmd_win, "/saveas", bsaveas_x, bsaveas_y);
      bresize  = new button (cmd_win, "/resize", bresize_x, bresize_y);
      bflip    = new button (cmd_win, "/flip",   bflip_x,   bflip_y);
      breplace = new button (cmd_win, "/replace",breplace_x,breplace_y);
      boverlay = new button (cmd_win, "/overlay",boverlay_x,boverlay_y);
      bpaste   = new button (cmd_win, "/paste",  bpaste_x,  bpaste_y);
      brotate  = new button (cmd_win, "/rotate", brotate_x, brotate_y);
      brotateh = new button (cmd_win, "/rotateh",brotateh_x,brotateh_y);
      bleft    = new button (cmd_win, "/left",   bleft_x,   bleft_y);
      bright   = new button (cmd_win, "/right",  bright_x,  bright_y);
      bup      = new button (cmd_win, "/up",     bup_x,     bup_y);
      bdown    = new button (cmd_win, "/down",   bdown_x,   bdown_y);
      d_mark   = new dial   (cmd_win, "mark", 60, bmark_x, bmark_y, d_is_mark);
     }.

.  show_color_table
     {open_color_table;
      for (int i = 0; i < max_color; i++)
        show_one_color;
     }.

.  show_one_color
     {color_table->set_color (i);
      color_table->fill      (x_color, y_color, color_dx-1, color_dy);
     }.

.  x_color  color_x + i * color_dx.
.  y_color  color_y.

.  open_color_table
     color_table = new win ("cmap_colors","",
                            by_fix,by_fix,colors_dx,colors_dy).
.  open_picture 
     {picture = new win ("camp_pic", "", by_fix, by_fix, pic_dx, pic_dy);
     }.

.  open_cmd_win
     {cmd_win = new win ("cmap_edit","",by_fix,by_fix,cmd_dx,cmd_dy);
      frame (cmd_win);
     }.

.  open_map_win
     {map_win = new win ("cmap_map", "", by_fix, by_fix, 
                         dx * (pixel_dx+1) + 60, dy * (pixel_dy+1) + 60);
      map_win->clear ();
      map_win->tick  ();
     }.

.  perhaps_init
     {
     }.

.  exec_show
     {for (int y = 0; y < dy; y++)
        for (int x = 0; x < dx; x++)
          show_pixel;
      map_win->tick ();
      picture->tick ();
     }.

.  show_pixel
     {map_win->set_color (act_map);
      map_win->fill      (act_x_pos, act_y_pos, pixel_dx, pixel_dy);
      picture->set_color (act_map);
      picture->pixel     (pic_x + x, pic_y + y);
      for (int ppx = 1; ppx <= pixel_dx; ppx++)
        for (int ppy = 1; ppy <= pixel_dx; ppy++)
          if (omap [ppx][ppy])
              picture->pixel (pic_x * 2 + x + ppx * dx,
                              pic_y * 2 + y + ppy * dy);
     }.

.  act_map     map [x][y].
.  act_x_pos   x_pic + x * (pixel_dx+1).
.  act_y_pos   y_pic + y * (pixel_dy+1).

  }

cmap_edit::~cmap_edit ()
  {perhaps_save;
   delete (bquit);
   delete (bsplit);
   delete (bload);
   delete (bimport);
   delete (bsave);
   delete (bsaveas);
   delete (bresize);
   delete (bflip);
   delete (breplace);
   delete (boverlay);
   delete (bpaste);
   delete (brotate);
   delete (brotateh);
   delete (bleft);
   delete (bright);
   delete (bup);
   delete (bdown);
   delete (map_win);
   delete (cmd_win);
   delete (picture);
   delete (color_table);
  
.  perhaps_save
     {if (changed && yes ("Save changes"))
        save ();
     }.

  }

void cmap_edit::load ()
  {load_map;
   perhaps_load_mask;
 
.  load_map
     {FILE *f;

      open_f;
      read_size;
      read_data;
      fclose (f);
     }.

.  open_f
     {f_open (f, complete (name, ".cmap"), "r");
     }.

.  read_size
     {int d;

      fscanf (f, "%d %d %d %d", &d, &dx, &dy, &t_color);
     }.

.  read_data
     {for (int y = 0; y < dy; y++)
        for (int x = 0; x < dx; x++)
          fscanf (f, "%d", &map [x][y]);
     }.

.  perhaps_load_mask
     {if (f_exists (complete (name, ".xbm")))
         load_mask;
     }.

.  load_mask
     {xbm *xb;

      xb = new xbm (complete (name, ".xbm"));
      for (int x = 0; x < dx; x++)
        for (int y = 0; y < dy; y++)
          check_bit;
     }.

.  check_bit
     {int b;
 
      xb->bit (x, y, b);
      if (! b)
         map [x][y] = t_color;
     }.

  }

void cmap_edit::save_as (char new_name [])
  {save_as (new_name, 0, 0, dx, dy);
  }

void cmap_edit::save ()
  {save_as (name, 0, 0, dx, dy);
  }
 
void cmap_edit::save_as (char new_name [], int x0, int y0, int sdx, int sdy)
  {store_name;
   save_map;
   clear_old_mask;
   perhaps_save_mask;

.  store_name
     {strcpy (name, new_name);
     }.

.  save_map
     {FILE *f;

      open_f;
      write_size;
      write_data;
      fclose (f);
     }.

.  open_f
     {f_open (f, complete (name, ".cmap"), "w");
     }.

.  write_size
     {fprintf (f, "0 %d %d %d\n", sdx, sdy, t_color);
     }.

.  write_data
     {for (int y = y0; y < y0 + sdy; y++)
        write_line;
     }.

.  write_line
     {for (int x = x0; x < x0 + sdx; x++)
        fprintf (f, "%d ", map [x][y]);
      fprintf (f, "\n");
     }.

.  clear_old_mask
     {char cmd [128];
 
      sprintf (cmd, "rm %s", complete (name, ".xbm"));
      system  (cmd);
     }.

.  perhaps_save_mask
     {bool is_mask;

      check_mask;
      if (is_mask)
         save_mask;
     }.
            
.  check_mask
     {is_mask = false;
      for (int x = x0 ; x < x0 + sdx; x++)
        for (int y = y0; y < y0 + sdy; y++)
          if (map [x][y] == t_color)
             is_mask = true;
     }. 

.  save_mask
     {xbm *xb;

      xb = new xbm (sdx, sdy);
      fill_xb;
      write_xb;
     }.

.  fill_xb
     {for (int x = x0; x < x0 + sdx; x++)
        for (int y = y0; y < y0 + sdy; y++)
          xb->set (x - x0, y - y0, (map [x][y] != t_color));
     }.

.  write_xb
     {xb->save (complete (name, ".xbm"));
     }.

  }

void cmap_edit::rotate (int orig [max_map_dx][max_map_dy],
                        int rot  [max_map_dx][max_map_dy],
                        int x0,
                        int y0,
                        int x1, 
                        int y1)

  {int x;
   int y;

   for (x = x0; x <= x1; x++)
     {rot [x][y0] = orig [x0][y1-x+x0];
     };
   for (y = y0; y <= y1; y++)
     {rot [x1][y] = orig [y][y0];
     };
   for (x = x1; x >= x0; x--)
     {rot [x][y1] = orig [x1][y1-x+x0];
     };
   for (y = y1; y > y0; y--)
     {rot [x0][y] = orig [y][y1];
     };
  }

void cmap_edit::edit (bool &was_quit)
  {init_edit;
   perform_cmd;

.  init_edit
     {was_quit = false;
     }.

.  perform_cmd
     {cmd_win->mark_mouse ();
      map_win->mark_mouse ();
      check_quit;
      check_split;
      check_load;
      check_import;
      check_save;
      check_resize;
      check_flip;
      check_replace;
      check_overlay;
      check_paste;
      check_rotate;
      check_color_change;         
      check_pixel_change; 
      check_left;
      check_right;
      check_up;
      check_down;
      check_omap;
      check_mark;
      cmd_win->scratch_mouse ();   
      map_win->scratch_mouse ();
     }.

.  check_mark
     {if (d_mark->eval (d_is_mark))
         {clear_cross;
          is_mark = d_is_mark;
          show_cross;
         };
     }.

.  check_omap
     {int xm;
      int ym;
      int b;

      picture->mark_mouse ();
      if (picture->mouse (xm, ym, b))
         load_omap;
      picture->scratch_mouse ();
     }.

.  load_omap
     {char name [128];

      xm = (xm - pic_x * 2) / dx;
      ym = (ym - pic_y * 2) / dy;
      if   (cmap_sel (name, ".cmap"))
           show_map
      else omap [xm][ym] = true;
      exec_show;
     }.

.  show_map
     {cmap *c = new cmap (picture, name);

      c->show (pic_x * 2 + xm * dx,  pic_y * 2 + ym * dy);
      omap [xm][ym] = false;
      delete (c);
     }.

.  check_pixel_change
     {int xm;
      int ym;
      int button;

      map_win->tick ();
      if   (map_win->is_mouse (xm,ym,button) && button_press && within_pixels) 
           handle_pixel_change
      else show_pos;
     }.

.  show_pos
     {xm = (xm - x_pic) / (pixel_dx + 1);
      ym = (ym - y_pic) / (pixel_dy + 1);
      if (xcross != -1)
         clear_cross;
      xcross = xm;
      ycross = ym;
      show_cross;
      picture->tick ();
     }.

.  clear_cross
     {for (int x = i_max (0, xcross - 1); x <= i_min (dx-1, xcross+1); x++)
        for (int y = i_max (0, ycross - 1); y <= i_min (dy-1, ycross+1); y++)
          if (is_mark)
             {picture->set_color (map [x][y]);
              picture->pixel (pic_x*2+x+2*dx, pic_y*2+y+2*dy);
             };
     }.

.  show_cross
     {picture->set_color (black);
      for (int x = i_max (0, xcross - 1); x <= i_min (dx-1, xcross+1); x++)
        for (int y = i_max (0, ycross - 1); y <= i_min (dy-1, ycross+1); y++)
          if ((x != xcross || y != ycross) && is_mark)
             picture->pixel (pic_x*2+x+2*dx, pic_y*2+y+2*dy);
     }.

.  button_press
     (button == button1press ||
      button == button2press ||
      button == button3press).
   
.  within_pixels
     (x_pic <= xm && xm <= dx * (pixel_dx+1) + x_pic &&
      y_pic <= ym && ym <= dy * (pixel_dy+1) + y_pic).

.  handle_pixel_change
     {int new_color;
      int d;

      get_c_color;
      get_x_y;
      if   (button == button2press)
           handle_fill
      else handle_dot;
      changed    = true;
      last_x     = xm;
      last_y     = ym;
      last_color = new_color;
      map_win->tick ();
      picture->tick ();
     }.

.  handle_fill
     {int x0;
      int y0;
      int xe;
      int ye;
      int xp = xm;
      int yp = ym;

      calc_bounds;
      new_color = last_color;
      for (xm = x0; xm <= xe; xm++)
        for (ym = y0; ym <= ye; ym++)
          handle_dot;
      xm = xp; ym = yp;
     }.

.  calc_bounds
     {x0 = i_min (xm, last_x); xe = i_max (xm, last_x);
      y0 = i_min (ym, last_y); ye = i_max (ym, last_y);
     }.

.  handle_dot
     {int x = xm;
      int y = ym;

      act_map = new_color;
      show_pixel;
     }.

.  get_x_y
     {map_win->mouse (d, d, xm, ym, button);
      xm = (xm - x_pic) / (pixel_dx + 1);
      ym = (ym - y_pic) / (pixel_dy + 1);
     }.
 
.  get_c_color
     {if (button == button1press)
           new_color = fg_color;
      else new_color = bg_color;
     }.

.  check_color_change
     {int xm;
      int ym;
      int button;
      int d;

      color_table->tick ();
      if (color_table->mouse (d, d, xm, ym, button))
         handle_color_change;
     }.

.  handle_color_change
     {int new_color;

      get_new_color;
      if (button == button1press) fg_color = new_color;
      if (button == button2press) handle_t_change;
      if (button == button3press) bg_color = new_color;
      show_colors;
     }.

.  handle_t_change
     {for (int x = 0; x < dx; x++)
        for (int y = 0; y < dy; y++)
          if (act_map == t_color)
             new_t_pixel;
      t_color = new_color;
     }.

.  new_t_pixel
     {int x = xm;
      int y = ym;

      act_map = new_color;
      show_pixel;
     }.

.  get_new_color
     {new_color = (xm-color_x) / color_dx;
     }.

.  check_quit
     {if (bquit->eval ())
         handle_quit;
     }.

.  handle_quit
     {bquit->press (true);
      was_quit = true;
     }.

.  check_resize
     {if (bresize->eval ())
         handle_resize;
     }.

.  handle_resize
     {bresize->press (true);
      perform_init;
      exec_show;
      bresize->press (false);
     }.

.  check_flip
     {if (bflip->eval ())
         handle_flip;
     }.

.  handle_flip
     {bflip->press (true);
      flip_lr ();
      exec_show;
      bflip->press (false);
     }.

.  check_replace
     {if (breplace->eval ())
         handle_replace;
     }.

.  handle_replace
     {breplace->press (true);
      for (int x = 0; x < dx; x++)
        for (int y = 0; y < dy; y++)
          if (map [x][y] == fg_color)
             map [x][y] = bg_color;
      exec_show;
      breplace->press (false);
     }.

.  check_overlay
     {if (boverlay->eval ())
         handle_overlay;
     }.

.  handle_overlay
     {char new_name [128];

      boverlay->press (true);
      if   (cmap_sel (new_name, ".cmap"))
           overlay (new_name);
      exec_show;
      boverlay->press (false);
     }.

.  check_paste
     {if (bpaste->eval ())
         handle_paste
     }.

.  handle_paste
     {char new_name [128];

      bpaste->press (true);
      if   (cmap_sel (new_name, ".cmap"))
           paste (new_name, last_x, last_y);
      exec_show;
      bpaste->press (false);
     }.

.  perform_init
     {printf ("Enter size (dx, dy) :\n");
      scanf  ("%d %d", &dx, &dy);
      if (dx > 100 || dy > 100)
         {pixel_dx = 1;
          pixel_dy = 1;
         };
     }.

.  check_left
     {if (bleft->eval ())
         handle_left;
     }.

.  handle_left
     {bleft->press (true);
      perform_left;
      exec_show;
      bleft->press (false);
     }.
  
.  perform_left
     {int x;
      int y;

      for (x = 0; x < dx-1; x++)
        for (y = 0; y < dy; y++)
          act_map_pixel = map [x+1][y];
      x = dx-1;
      for (y = 0; y < dy; y++)
        act_map_pixel = bg_color;
     }.

.  check_right
     {if (bright->eval ())
         handle_right;
     }.

.  handle_right
     {bright->press (true);
      perform_right;
      exec_show;
      bright->press (false);
     }.

.  perform_right
     {int x;
      int y;

      for (x = dx-1; x > 0; x--)
        for (y = 0; y < dy; y++)
          act_map_pixel = map [x-1][y];
      x = 0;
      for (y = 0; y < dy; y++)
        act_map_pixel = bg_color;
     }.

.  check_up
     {if (bup->eval ())
         handle_up;
     }.

.  handle_up
     {bup->press (true);
      perform_up;
      exec_show;
      bup->press (false);
     }.

.  perform_up
     {int x;
      int y;

      for (x = 0; x < dx; x++)
        for (y = 0; y < dy-1; y++)
          act_map_pixel = map [x][y+1];
      y = 0;
      for (x = 0; x < dx; x++)
        act_map_pixel = bg_color;
     }.

.  check_down
     {if (bdown->eval ())
         handle_down;
     }.

.  handle_down
     {bdown->press (true);
      perform_down;
      exec_show;
      bdown->press (false);
     }.

.  perform_down
     {int x;
      int y;

      for (x = 0; x < dx; x++)
        for (y = dy-1; y > 0; y--)
          act_map_pixel = map [x][y-1];
      y = dy-1;
      for (x = 0; x < dx; x++)
        act_map_pixel = bg_color;
     }.

.  check_rotate
     {if (brotate->eval ())
         handle_rotate;
      if (brotateh->eval ())
         handle_rotateh;
     }.

.  handle_rotateh
     {brotateh->press (true);
      rotate_rh ();
      exec_show;
      brotateh->press (false);
     }.

.  handle_rotate
     {brotate->press (true);
      perform_rotate;
      exec_show;
      brotate->press (false);
     }.

.  perform_rotate
     {int orig [800][800];
      int rot  [800][800];

      changed = true;
      grab_orig;
      calc_rot;
      load_map;
     }.

.  calc_rot
     {for (int i = 0; i < i_min (dx/2, dy/2); i++)
        rotate (orig, rot, i, i, dx - i - 1, dy - i - 1);
     }.

.  grab_orig
     {for (int x = 0; x < dx; x++)
        for (int y = 0; y < dy; y++)
          orig [x][y] = act_map_pixel;
     }.

.  load_map
     {for (int x = 0; x < dx; x++)
        for (int y = 0; y < dy; y++)
          act_map_pixel = rot [x][y];
     }.

.  check_load
     {if (bload->eval ())
         handle_load;
     }.

.  handle_load
     {char new_name [128];

      bload->press (true);
      perhaps_save;
      if (cmap_sel (new_name, ".cmap"))
         perform_load;
      bload->press (false);
     }.

.  perform_load
     {strcpy (name, new_name);
      load   ();
      exec_show;
     }.

.  check_import
     {if (bimport->eval ())
         handle_import;
     }.

.  handle_import
     {char new_name [128];

      bimport->press (true);
      perhaps_save;
      get_new_name;
      if (strlen (new_name) > 0)
         perform_import;
      bimport->press (false);
     }.

.  perform_import
     {ppm *p;

      p = new ppm (new_name);
      for (int x = 0; x < dx; x++)
        for (int y = 0; y < dy; y++)
          import_pixel;
      delete (p);
      exec_show;
     }.

.  import_pixel
     {int r;
      int g;
      int b;

      p->rgb (x, y, r, g, b);      
      map [x][y] = picture->win_color (r, g, b);
     }.

.  perhaps_save
     {if (changed && yes ("Save changes"))
        save ();
     }.

.  check_split
     {if (bsplit->eval ())
         handle_split;
     }.

.  handle_split
     {char new_name [128];
      int  sdx;
      int  sdy;
      int  no;

      bsplit->press (true);
      get_new_name;
      get_sdx_sdy;
      if (file_should_be_saved)
         split (sdx, sdy, new_name, no);
      bsplit->press (false);
     }.

.  get_sdx_sdy
     {printf ("sdx sdy no :");
      scanf  ("%d %d %d", &sdx, &sdy, &no);
     }.

.  check_save
     {if (bsave->eval ())
         handle_save;
      if (bsaveas->eval ())
         handle_saveas;
     }.

.  handle_saveas
     {char new_name [128];

      bsaveas->press (true);
      get_new_name;
      if (file_should_be_saved)
         save_as (new_name);
      changed = false;
      bsaveas->press (false);
     }.

.  file_should_be_saved
     (strlen (new_name) > 0 &&
     (! f_exists (complete (new_name, ".cmap")) || yes ("overwrite"))).

.  get_new_name
     {file_selector *f;

      sprintf (new_name, "%s/", getenv ("PWD"));
      f = new file_selector ("cmapsave", by_fix, by_fix, new_name, false);
      while (! f->eval (new_name))
        {
        };
      delete (f);
     }.

.  handle_save
     {bsave->press (true);
      save         ();
      changed = false;
      bsave->press (false);
     }.

.  show_colors
     {show_bg_color;
      show_colors_frame;
      show_fg_color;
      show_t_color;
      cmd_win->tick ();
     }.

.  show_colors_frame
     {cmd_win->set_color (black);
      cmd_win->line      (colors_x, colors_y, 
                       colors_x + colors_d, colors_y);
      cmd_win->line      (colors_x, colors_y, 
                       colors_x, colors_y + colors_d);
      cmd_win->line      (colors_x + colors_d, colors_y + colors_d, 
                       colors_x + colors_d, colors_y);
      cmd_win->line      (colors_x + colors_d, colors_y + colors_d, 
                           colors_x, colors_y + colors_d);
     }.

.  show_bg_color
     {cmd_win->set_color (bg_color);
      cmd_win->fill      (colors_x, colors_y, colors_d, colors_d);
     }.

.  show_fg_color
     {cmd_win->set_color (fg_color);
      cmd_win->fill      (colors_x + colors_d / 4, 
                          colors_y + colors_d / 4,
                          colors_d / 2, colors_d / 2);
     }.

.  show_t_color
     {cmd_win->set_color (t_color);
      cmd_win->fill      (colors_tx, colors_ty, colors_td, colors_td);
     }.

.  exec_show
     {for (int y = 0; y < dy; y++)
        for (int x = 0; x < dx; x++)
          show_pixel;
      map_win->tick ();
      picture->tick ();
     }.

.  show_pixel
     {map_win->set_color (act_map_pixel);
      map_win->fill      (act_x_pos, act_y_pos, pixel_dx, pixel_dy);
      picture->set_color (act_map_pixel);
      picture->pixel     (pic_x + x, pic_y + y);
      for (int ppx = 1; ppx < 5; ppx++)
        for (int ppy = 1; ppy < 5; ppy++)
          if (omap [ppx][ppy])
             picture->pixel (pic_x * 2 + x + ppx * dx,
                             pic_y * 2 + y + ppy * dy);
     }.

.  act_map_pixel map  [x][y].
.  act_map       map  [xm][ym].

.  act_x_pos     x_pic + x * (pixel_dx+1).
.  act_y_pos     y_pic + y * (pixel_dy+1).

  }

void cmap_edit::flip_ud ()
  {int b [dx][dy];

   exec_flip;
   store_result;

.  exec_flip
     {for (int x = 0; x < dx; x++)
        for (int y = 0; y < dy; y++)   
          b [x][dy-y-1] = map [x][y];
     }.

.  store_result
     {for (int x = 0; x < dx; x++)
        for (int y = 0; y < dy; y++)
          map [x][y] = b [x][y];
     }.
       
  }

void cmap_edit::flip_lr ()
  {int b [dx][dy];

   exec_flip;
   store_result;

.  exec_flip
     {for (int x = 0; x < dx; x++)
        for (int y = 0; y < dy; y++)   
          b [dx-x-1][y] = map [x][y];
     }.

.  store_result
     {for (int x = 0; x < dx; x++)
        for (int y = 0; y < dy; y++)
          map [x][y] = b [x][y];
     }.
       
  }

void cmap_edit::recolor (int n)
  {for (int x = 0; x < dx; x++)
     for (int y = 0; y < dy; y++)
       exec_recolor;

.  exec_recolor
     {if   (n == 0)
           recolor_red
      else recolor_cyan;
     }.

.  recolor_red
     {switch (map [x][y])
         {case 21 : map [x][y] = 1;          break;
          case 22 : map [x][y] = 2;          break;
          case 23 : map [x][y] = 3;          break;
          case 24 : map [x][y] = 4;          break;
          case 25 : map [x][y] = 4;          break;
          default : map [x][y] = map [x][y]; break;
         };
     }.

.  recolor_cyan
     {switch (map [x][y])
         {case 21 : map [x][y] = 36;         break;
          case 22 : map [x][y] = 37;         break;
          case 23 : map [x][y] = 38;         break;
          case 24 : map [x][y] = 39;         break;
          case 25 : map [x][y] = 40;         break;
          default : map [x][y] = map [x][y]; break;
         };
     }.

  }

void cmap_edit::colorize (int ddx, int ddy, int c, int n)
  {int xx [500];
   int yy [500];
   int num = 0;


   if   (ddx == 0)
        handle_ddy
   else handle_ddx;

.  handle_ddy
     {for (int i = 0; i < n; i++)
        pixel_ddy;
     }.

.  pixel_ddy
     {int x;
      int y;

      rnd;
      while (!((ddy > 0 && y < ddy) || (ddy < 0 && y > dy + ddy)))
        {rnd;
        };
      light_pixel;
     }.

.  handle_ddx
     {for (int i = 0; i < n; i++)
        pixel_ddx;
     }.

.  pixel_ddx
     {int x;
      int y;

      rnd;
      while (!((ddx > 0 && x < ddx) || (ddx < 0 && x > dx + ddx))) 
        {rnd;
        };
      light_pixel;
     }.

.  light_pixel
     {int r;
      int g;
      int b;
      int cnt = 1;

      if    (map [x][y] < 52)
            map [x][y] = i_bound (0, map [x][y] - i_sign (c), 63);
      else  map [x][y] = i_bound (0, map [x][y] + i_sign (c), 63);
      xx [num] = x;
      yy [num] = y;
      num++;
     }.

.  rnd
     {bool in_list;

      get_xy;
      check_list;
      while (in_list)
        {get_xy;
         check_list;
        };
     }.

.  get_xy
     {x = i_random (0, dx-1);
      y = i_random (0, dy-1);
     }.

.  check_list
     {in_list = true;
      for (int j = 0; j < num; j++)  
        if (xx [j] == x && yy [j] == y)
           break;
      in_list = false;
     }.

  }

void cmap_edit::colorize (int ddx, int ddy)
  {if   (ddx == 0)
        handle_ddy
   else handle_ddx;

.  handle_ddy
     {int ymin;
      int ymax;

      get_y_minmax;
      for (int x = 0; x < dx; x++)
        for (int y = ymin; y < ymax; y++)
          light_pixel;
     }.

.  get_y_minmax
     {if   (ddy > 0)
           {ymin = 0;
            ymax = ddy;
           }
      else {ymin = dy + ddy;
            ymax = dy;
           };
     }.

.  handle_ddx
     {int xmin;
      int xmax;

      get_x_minmax;
      for (int x = xmin; x < xmax; x++)
        for (int y = 0; y < dy; y++)
          light_pixel;
     }.

.  get_x_minmax
     {if   (ddx > 0)
           {xmin = 0;
            xmax = ddx;
           }
      else {xmin = dx + ddx;
            xmax = dx;
           };
     }.

.  light_pixel
     {int r;
      int g;
      int b;
      int cnt = 1;

      if    (map [x][y] < 52)
            map [x][y] = i_bound (0, map [x][y] - i_sign (ddx + ddy), 61);
      else  map [x][y] = i_bound (0, map [x][y] + i_sign (ddx + ddy), 61);
     }.

  }

void cmap_edit::rotate_r ()
  {int orig [800][800];
   int rot  [800][800];

   grab_orig;
   calc_rot;
   load_map;

.  calc_rot
     {for (int i = 0; i < i_min (dx/2, dy/2); i++)
        rotate (orig, rot, i, i, dx - i - 1, dy - i - 1);
     }.

.  grab_orig
     {for (int x = 0; x < dx; x++)
        for (int y = 0; y < dy; y++)
          orig [x][y] = map [x][y];
     }.

.  load_map
     {for (int x = 0; x < dx; x++)
        for (int y = 0; y < dy; y++)
          map [x][y] = rot [x][y];
     }.

  }

void cmap_edit::rotate_rh ()
  {int orig [100][100];
   int rot  [100][100];

   grab_orig;
   calc_rot;
   load_map;

.  calc_rot
     {int x0 = dx / 2;
      int y0 = dy / 2;

      for (int x = 0; x < dx; x++)
        for (int y = 0; y < dy; y++)
          rotate_point;
     }.

.  rotate_point
     {point r = ::rotate (new_point (x, y, 0),
                          new_line  (new_point (x0, y0, 0),
                                     new_point (x0, y0, 10)),
                          45);
      vector v;
      int    xx;
      int    yy;


      v  = new_vector (new_point (x0, y0, 0), r) * 0.9;
      r  = new_point (x0, y0, 0) + v;
      if   (r.x - (int) r.x > 0.5)
           xx = (int) r.x + 1;
      else xx = (int) r.x;
      if   (r.y - (int) r.y > 0.5)
           yy = (int) r.y + 1;
      else yy = (int) r.y;
      if (0 <= xx && xx < dx && 0 <= yy && yy < dy)
         rot [xx][yy] = orig [x][y];

     }.

.  grab_orig
     {for (int x = 0; x < dx; x++)
        for (int y = 0; y < dy; y++)
          {orig [x][y] = map [x][y];
           rot  [x][y] = t_color;
          };
     }.

.  load_map
     {for (int x = 0; x < dx; x++)
        for (int y = 0; y < dy; y++)
          map [x][y] = rot [x][y];
     }.

  }

void cmap_edit::overlay (char name [])
  {int o_map [max_map_dx][max_map_dy];
   int dxx;
   int dyy;

   read_o_map;
   perform_overlay;

.  perform_overlay
     {for (int x = 0; x < dx; x++)
        for (int y = 0; y < dy; y++)
          if (map [x][y] == t_color)
             overlay_pixel;
     }.

.  overlay_pixel
     {map [x][y] = o_map [x % dxx][y % dyy];
     }.

.  read_o_map
     {int  version;
      int  bg;
      FILE *f;

      open_image_file;
      read_dx_dy;
      read_pixels;
      fclose (f);
     }.

.  open_image_file
     {char i_file_name [256];

      f_open (f, complete (name, ".cmap"), "r");
     }.

.  read_dx_dy
     {int d;

      fscanf (f, "%d %d %d %d", &version, &dxx, &dyy, &bg);
     }.

.  read_pixels
     {for (int y = 0; y < dyy; y++)
        for (int x = 0; x < dxx; x++) 
          read_pixel;
     }.

.  read_pixel
     {fscanf (f, "%d", &o_map [x][y]);
     }.   

  }

void cmap_edit::paste (char name [], int x0, int y0)
  {int o_map [max_map_dx][max_map_dy];
   int dxx;
   int dyy;

   read_o_map;
   perform_overlay;

.  perform_overlay
     {for (int x = 0; x < dxx; x++)
        for (int y = 0; y < dyy; y++)
          if (map [x0+x][y0+y] == t_color)
             overlay_pixel;
     }.

.  overlay_pixel
     {map [x0+x][y0+y] = o_map [x][y];
     }.

.  read_o_map
     {int  version;
      int  bg;
      FILE *f;

      open_image_file;
      read_dxx_dyy;
      read_pixels;
      fclose (f);
     }.

.  open_image_file
     {char i_file_name [256];

      f_open (f, complete (name, ".cmap"), "r");
     }.

.  read_dxx_dyy
     {int d;

      fscanf (f, "%d %d %d %d", &version, &dxx, &dyy, &bg);
     }.

.  read_pixels
     {for (int y = 0; y < dyy; y++)
        for (int x = 0; x < dxx; x++) 
          read_pixel;
     }.

.  read_pixel
     {fscanf (f, "%d", &o_map [x][y]);
     }.   

  }

void cmap_edit::set_to_ppm (char map_name [], char ppm_name [])
  {ppm *p;
   win *w;

   open_ppm;
   open_map;
   copy_data;
   delete (p);
   delete (w);

.  open_ppm
     {p = new ppm (ppm_name);
     }.

.  open_map
     {w = new win ("lala", "", 10, 10, 10, 10);

      strcpy (name, map_name);
      dx      = p->dx;
      dy      = p->dy;
      t_color = -1;
     }.

.  copy_data
     {for (int x = 0; x < dx; x++)
        for (int y = 0; y < dy; y++)
          import_pixel;
     }.

.  import_pixel
     {int r;
      int g;
      int b;

      p->rgb (x, y, r, g, b);      
      map [x][y] = w->win_color (r, g, b);
     }.

  }

void cmap_edit::split (int sdx, int sdy, char name [], int no)
  {int cnt = no;

   for (int y = 0; y < dy-1; y += sdy)
     for (int x = 0; x < dx-1; x += sdx)
       get_subpic;

.  get_subpic
     {char f_name [128];

      sprintf (f_name, "%s.%d", name, cnt++);
      save_as (f_name, x, y, sdx, sdy);
     }.

  }
 