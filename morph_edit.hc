
#include "masks.h"
#include "morph_edit.h"
#include "objects.h"

#define mb_point     0
#define mb_triangle  1
#define mb_shade     2 
#define mb_save      3
#define mb_quit      4 

#define max_win_size 500

bool inside_d (triangle t, point p)
  {double av01v02 = angle (v01, v02);
   double av10v12 = angle (v10, v12);
   double s       = 0.2;

   return p == t.p0 || p == t.p1 || p == t.p2 || angle_ok;

.  angle_ok 
    (angle (v0p, v01) <= av01v02 + s &&   
     angle (v0p, v02) <= av01v02 + s &&
     angle (v1p, v10) <= av10v12 + s &&   
     angle (v1p, v12) <= av10v12 + s).

.  v01  new_vector (t.p0, t.p1).
.  v02  new_vector (t.p0, t.p2).
.  v12  new_vector (t.p1, t.p2).
.  v10  new_vector (t.p1, t.p0).
.  v0p  new_vector (t.p0, p).
.  v1p  new_vector (t.p1, p).

  }
 
morph_edit::morph_edit (char m_name    [],   
                        char orig_name [],
                        char dest_name [])

  {store_state;
   init_tables;
   open_men;
   init_modes;
   open_ppms;
   open_wins;
   create_cursor;
   show_ppms;
   load (name);
   init_marks;
   show_marks;

.  init_marks
     {mark [0] = -1;
      mark [1] = -1;
      mark [2] = -1;
     }.

.  show_marks
     {invert_marks ();
     }.

.  create_cursor
     {on_dest     = false;
      on_orig     = false;
      is_shade    = false;
      point_color = black;
      scale [0]   = 1;
      scale [1]   = 1;
      x0    [0]   = 0;
      y0    [0]   = 0;
      x0    [1]   = 0;
      y0    [1]   = 0;
     }.

.  init_modes
     {point_mode    = true;
      point_grabbed = false;
      num_marks     = 0;
      focus         = -1;
      men->press (mb_point);
     }.

.  open_men
     {men = new menu ("morph_edit", by_fix, by_fix,
                      "/medit_point:;
                      ;medit_triangle:;
                      ;medit_shade:;
                      ;medit_save:;
                      ;medit_quit:");
     }.

.  init_tables
     {num_points    = 0;
      num_triangles = 0;
     }.

.  store_state
     {strcpy (name, m_name);
     }.

.  open_ppms
     {orig = new ppm (orig_name, true);
      dest = new ppm (dest_name, true);
     }.

.  open_wins
     {w_orig = new win ("Morph_orig", "",
                        by_fix, by_fix, 
                        i_min (max_win_size, orig->dx),
                        i_min (max_win_size, orig->dy));
      w_dest = new win ("Morph_dest", "",
                        by_fix, by_fix,
                        i_min (max_win_size, dest->dx),
                        i_min (max_win_size, dest->dy));
     }.

.  show_ppms
     {orig->show (w_orig, 0, 0, w_orig->dx (), w_orig->dy (),
                  x0 [0], y0 [0], scale [0]);
      dest->show (w_dest, 0, 0, w_dest->dx (), w_dest->dy (),
                  x0 [1], y0 [1], scale [1]);
     }.

  }      

morph_edit::~morph_edit ()
  {delete (orig);
   delete (dest);
   delete (w_orig);
   delete (w_dest);
   delete (men);
  }

void morph_edit::save (char name [])
  {FILE *f;

   open_f;
   perform_save;
   fclose (f);
   is_saved = true;

.  open_f
     {f_open (f, name, "w");
     }.

.  perform_save
     {for (int i = 0; i < num_triangles; i++) 
        if (! t_free [i])
           save_triangle;
     }.
 
.  save_triangle
     {fprintf (f, "%d %d %d %d %d %d %d %d %d %d %d %d\n",
               (int) p [0][t [i][0]].x,
               (int) p [0][t [i][0]].y,
               (int) p [0][t [i][1]].x,
               (int) p [0][t [i][1]].y,
               (int) p [0][t [i][2]].x,
               (int) p [0][t [i][2]].y,
               (int) p [1][t [i][0]].x,
               (int) p [1][t [i][0]].y,
               (int) p [1][t [i][1]].x,
               (int) p [1][t [i][1]].y,
               (int) p [1][t [i][2]].x,
               (int) p [1][t [i][2]].y);
     }.

  }
   
void morph_edit::load (char name [])
  {if   (! f_exists (name))
        new_morph
   else old_morph;

.  new_morph
     {printf ("New Morph %s created\n", name);
     }.

.  old_morph
     {FILE *f;

      open_f;
      perform_load;
      fclose (f);
      is_saved = false;
     }.

.  open_f
     {f_open (f, name, "r");
     }.

.  perform_load
     {bool another_region = true;

      while (another_region)
        load_region;
     }.

.  load_region
     {float p [12];

      another_region = (fscanf (f, "%f %f %f %f %f %f %f %f %f %f %f %f",
                                & p [0],  & p [1],
                                & p [2],  & p [3],
                                & p [4],  & p [5],
                                & p [6],  & p [7],
                                & p [8],  & p [9],
                                & p [10], & p [11]) != EOF);
      if (another_region)        
         add_triangle (add_point (new_point (p [0],  p [1],  0),
                                  new_point (p [6],  p [7],  0)),
                       add_point (new_point (p [2],  p [3],  0),
                                  new_point (p [8],  p [9],  0)),
                       add_point (new_point (p [4],  p [5],  0),
                                  new_point (p [10], p [11], 0)));
     }.
     
  }
 
void morph_edit::eval (bool &is_quit)
  {handle_menu;
   handle_edit;

.  handle_edit
     {int button;
      char cmd;

      handle_cursor (w_orig, 0, on_orig, button, cmd);
      if (on_orig)
         edit_action (w_orig, orig, 0, button, cmd);
      handle_cursor (w_dest, 1, on_dest, button, cmd);
      if (on_dest)
         edit_action (w_dest, dest, 1, button, cmd);
     }.

.  handle_menu
     {int cmd = men->eval ();

      is_quit = false;
      switch (cmd)
        {case mb_point    : handle_point;    break;
         case mb_triangle : handle_triangle; break;
         case mb_shade    : handle_shade;    break;
         case mb_save     : handle_save;     break;
         case mb_quit     : handle_quit;     break;
        };
     }.

.  handle_shade
     {men->release ();
      men->press   (mb_shade);
      is_shade = true;
      invert_marks ();
      while (men->eval ()!= mb_shade)
        {
        };
      men->release ();
      men->release (mb_shade);
      orig->show (w_orig,
                  0, 0,w_orig->dx (),w_orig->dy (),x0 [0],y0 [0], scale [0]);
      dest->show (w_dest,
                  0, 0,w_dest->dx (),w_dest->dy (),x0 [1],y0 [1], scale [1]);
      is_shade = false;
      invert_marks ();
     }. 

.  handle_point
     {men->release ();
      men->release (mb_triangle);
      men->press   (mb_point);
      point_mode = true;
     }.

.  handle_triangle
     {men->release ();
      men->release (mb_point);
      men->press   (mb_triangle);
      point_mode = false;
     }.
   
.  handle_save
     {men->release ();
      men->press   (mb_save);
      save         (name);
      men->release (mb_save);
     }.

.  handle_quit
     {men->release ();
      men->press   (mb_quit);
      is_quit = true;
      validate_save;
      men->release (mb_quit);
     }.

.  validate_save
     {if (! is_saved && yes ("Save changes before exit ?"))
         handle_save;
     }.

  }

void morph_edit::edit_action (win *w, ppm *pm, int wno, int button, char cmd)
  {if   (point_mode)
        handle_point_edit
   else handle_triangle_edit;
   handle_cmd;

.  handle_cmd
     {if (cmd == '+') handle_zoom_in;
      if (cmd == '-') handle_zoom_out;
      if (cmd == 'c') handle_center;
      if (cmd == ' ') handle_unmark_all;
      if (cmd == 'f') perform_triangle_to_front;
      if (cmd == 'b') perform_triangle_to_back;
      if (cmd == 'd') change_point_color;
     }.

.  change_point_color
     {invert_marks ();
      point_color = (point_color + 1) % 64;
      printf ("%d\n", point_color);
      invert_marks ();
     }.

.  handle_unmark_all
     {invert_marks ();
      num_marks = 0;
      for (int i = 0; i < num_points; i++)
        p_marked [i] = false;
      mark [0] = -1;
      mark [1] = -1;
      mark [2] = -1;
      invert_marks ();
     }.

.  handle_center
     {x0    [wno] = i_max (0, cx - (w->dx () / scale [wno] / 2)); 
      y0    [wno] = i_max (0, cy - (w->dy () / scale [wno] / 2)); 
      if (x0 [wno] + w->dx () / scale [wno] > pm->dx)
         x0 [wno] = pm->dx - (w->dx () / scale [wno]);
      if (y0 [wno] + w->dy () / scale [wno] > pm->dy)
         y0 [wno] = pm->dy - (w->dy () / scale [wno]);
      reshow_ppm;
     }.

.  handle_zoom_in
     {if (scale [wno] < 16)
         perform_zoom_in;
     }.

.  perform_zoom_in
     {scale [wno] *= 2;
      x0    [wno] = i_max (0, cx - (w->dx () / scale [wno] / 2)); 
      y0    [wno] = i_max (0, cy - (w->dy () / scale [wno] / 2)); 
      if (x0 [wno] + w->dx () / scale [wno] > pm->dx)
         x0 [wno] = pm->dx - (w->dx () / scale [wno]);
      if (y0 [wno] + w->dy () / scale [wno] > pm->dy)
         y0 [wno] = pm->dy - (w->dy () / scale [wno]);
      reshow_ppm;
     }.

.  handle_zoom_out
     {if (scale [wno] > 1)
         perform_zoom_out;
     }.

.  perform_zoom_out
     {scale [wno] /= 2;
      x0    [wno] = i_max (0, cx - (w->dx () / scale [wno] / 2)); 
      y0    [wno] = i_max (0, cy - (w->dy () / scale [wno] / 2)); 
      if (x0 [wno] + w->dx () / scale [wno] > pm->dx)
         x0 [wno] = pm->dx - (w->dx () / scale [wno]);
      if (y0 [wno] + w->dy () / scale [wno] > pm->dy)
         y0 [wno] = pm->dy - (w->dy () / scale [wno]);
      reshow_ppm;
     }.

.  reshow_ppm
      {invert_marks ();
       pm->show (w,0,0,w->dx (),w->dy (),x0 [wno],y0 [wno],scale [wno]);
       invert_marks ();
      }.

.  handle_point_edit
     {handle_focus;
      if  (w->mouse_is_pressed (0)) 
           handle_move_point
      else point_grabbed = false;
      if   (button == button2press) 
           handle_create_point;
      if   (button == button3press)
           handle_delete_point;
     }.

.  handle_focus
     {int pno;

      if   (on_point (cx, cy, wno, pno))
           perhaps_new_focus
      else perhaps_no_focus;
     }.

.  perhaps_new_focus
     {if (focus != pno)
         {invert_marks ();
          focus = pno;
          invert_marks ();
         };
     }.

.  perhaps_no_focus
     {if (focus != -1)
         {invert_marks ();
          focus = -1;
          invert_marks ();
         };
     }.
   
.  handle_move_point
     {if (point_grabbed || on_point (cx, cy, wno, grabbed_pno))
         perform_move;
     }.

.  perform_move
     {point_grabbed = true;
      if (cx != p [wno][grabbed_pno].x || cy !=  p [wno][grabbed_pno].y)
         shift_point; 
     }.

.  shift_point
     {invert_marks ();
      p [wno][grabbed_pno].x = cx;
      p [wno][grabbed_pno].y = cy;
      invert_marks ();
     }.

.  handle_create_point
     {invert_marks ();
      add_point    (new_point (cx, cy, 0), new_point (cx, cy, 0));
      invert_marks ();
     }.

.  handle_delete_point
     {int pno;
      
      if (on_point (cx, cy, wno, pno))
         perform_delete;
     }.

.  perform_delete
     {invert_marks ();
      delete_point (pno);
      invert_marks ();
     }.

.  handle_triangle_edit
     {if (button == button1press) handle_mark_invert;
      if (button == button2press) handle_triangle_create;
      if (button == button3press) handle_triangle_delete;
     }.

.  handle_mark_invert
     {int pno;

      if (on_point (cx, cy, wno, pno))
         perform_invert;
     }.

.  perform_invert
     {if      (p_marked [pno]) 
              switch_off_mark
      else if (num_marks < 3)
              switch_on_mark;
     }.

.  switch_off_mark
     {invert_marks ();
      p_marked [pno] = false;
      free_mark (pno);
      num_marks--;
      invert_marks ();
     }.

.  switch_on_mark
     {invert_marks ();
      p_marked [pno] = true;
      alloc_mark   (pno);
      num_marks++;
      invert_marks ();
     }.

.  handle_triangle_create 
     {if (num_marks == 3)
         perform_triangle_create;
     }.

.  perform_triangle_create
     {invert_marks ();
      add_triangle (mark [0], mark [1], mark [2]);
      invert_marks ();
     }.

.  handle_triangle_delete 
     {if (num_marks == 3)
         perform_triangle_delete;
     }.

.  perform_triangle_delete
     {invert_marks ();
      look_up_triangles;
      invert_marks ();
     }.

.  look_up_triangles
     {for (int i = 0; i < num_triangles; i++)
        if (! t_free [i])
           check_triangle;
     }.

.  check_triangle
     {if (same_triangle)
         delete_triangle (i);
     }. 

.  perform_triangle_to_back
     {invert_marks ();
      look_up_back_triangles;
      invert_marks ();
     }.

.  look_up_back_triangles
     {for (int i = 0; i < num_triangles; i++)
        if (! t_free [i])
           check_back_triangle;
     }.

.  check_back_triangle
     {if (same_triangle)
         to_back (i);
     }. 

.  perform_triangle_to_front
     {invert_marks ();
      look_up_front_triangles;
      invert_marks ();
     }.

.  look_up_front_triangles
     {for (int i = 0; i < num_triangles; i++)
        if (! t_free [i])
           check_front_triangle;
     }.

.  check_front_triangle
     {if (same_triangle)
         to_front (i);
     }. 

.  same_triangle
     (t [i][0] == mark [0] || t [i][1] == mark [0] || t [i][2] == mark [0]) &&
     (t [i][0] == mark [1] || t [i][1] == mark [1] || t [i][2] == mark [1]) &&
     (t [i][0] == mark [2] || t [i][1] == mark [2] || t [i][2] == mark [2]).

  }

void morph_edit::handle_cursor (win  *w,
                                int  wno,
                                bool &on_flag,
                                int  &button,
                                char &cmd)

  {bool is_on;

   w->tick ();
   is_on = w->on     ();
   cmd   = w->inchar ();
   if      (on_flag && is_on)   handle_move
   else if (on_flag && ! is_on) handle_leave
   else if (! on_flag && is_on) handle_enter;

.  handle_move
     {int mx;
      int my;
      int d;

      w->mouse (mx, my, button);
      mx = px (wno, mx);
      my = py (wno, my);
      if (cx != mx || cy != my)
         {invert_cursor (w);
          cx = mx;
          cy = my;
          invert_cursor (w);
         };
     }.

.  handle_enter
     {int mx;
      int my;
      int d;

      on_flag = true;
      w->mouse (mx, my, button);
      mx      = px (wno, mx);
      my      = py (wno, my);
      cx      = mx;
      cy      = my;
      invert_cursor (w);
     }.

.  handle_leave
     {on_flag = false;
      invert_cursor (w);
      cx      = -1;
      cy      = -1;
     }.
 
  }

void morph_edit::invert_cursor (win *w)
  {
  }

/*
  {w->function  (GXxor);
   w->set_color (red);
   w->line      (cx, 0, cx, w->dy ());
   w->line      (0, cy, w->dx (), cy);
   w->tick      ();
  }
*/

int morph_edit::add_point (point po, point po1)
  {int pp = pno (po, po1);

   if   (pp == -1)
        perform_add
   else return pp;

.  perform_add
     {int index;
 
      get_index;
      add_data;
      return index;
     }.

.  get_index
     {try_to_recycle;
      if (! p_free [index] || index >= num_points)
         grab_new_p;
     }.

.  try_to_recycle
     {for (index = 0; index < num_points; index++)
        if (p_free [index])
           break;
     }.

.  grab_new_p
     {index = num_points++;  
      if (num_points == max_points) 
         errorstop (2, "MORPH EDIT", "too many points");
     }.

.  add_data
     {p        [0][index] = po;
      p        [1][index] = po1;
      p_free   [index]    = false;
      p_marked [index]    = false;
     }.

  }

void morph_edit::delete_point (int pno)
  {p_free   [pno] = true;
   if (p_marked [pno])
      num_marks--;
   p_marked [pno] = false;
   delete_from_triangles;

.  delete_from_triangles
     {for (int i = 0; i < num_triangles; i++)
        if (! t_free [i])
           check_triangle;
     }.

.  check_triangle
     {if (in_triangle)
         delete_triangle (i);
     }.

.  in_triangle
     (t [i][0] == pno || t [i][1] == pno || t [i][2] == pno).
 
  }

bool morph_edit::on_point (int cx, int cy, int wno, int &pno)
  {for (pno = 0; pno < num_points; pno++)
     if (! p_free [pno] && dist (p [wno][pno], new_point (cx, cy, 0)) < 3)
        return true;
   return false;
  }

int morph_edit::pno (point po, point po1)
  {for (int i = 0; i < num_points; i++)
     if (! p_free [i] && p [0][i] == po && p [1][i] == po1)
        return i;
   return -1;
  }

int morph_edit::add_triangle (int p1, int p2, int p3)
  {check_existing_triangles;
   create_new_triangle;

.  check_existing_triangles
     {for (int i = 0; i < num_triangles; i++) 
        if (! t_free [i])
           check_t;
     }.

.  check_t
     {if (same_triangle)
         return i;
     }.

.  same_triangle
     (t [i][0] == p1 || t [i][1] == p1 || t [i][2] == p1) &&
     (t [i][0] == p2 || t [i][1] == p2 || t [i][2] == p2) &&
     (t [i][0] == p3 || t [i][1] == p3 || t [i][2] == p3).

.  create_new_triangle
     {int index;

      get_index;
      perform_add;
      return index;
     }.

.  get_index
     {try_to_recycle;
      if (! t_free [index] || index >= num_triangles)
         grab_new_t;
     }.

.  try_to_recycle
     {for (index = 0; index < num_triangles; index++)
        if (t_free [index])
           break;
     }.

.  grab_new_t
     {index = num_triangles++;  
      if (num_triangles == max_triangles) 
         errorstop (1, "MORPH EDIT", "too many regions");
     }.

.  perform_add
     {t      [index][0] = p1;
      t      [index][1] = p2;
      t      [index][2] = p3;
      t_free [index]    = false;
     }.

  }   

void morph_edit::delete_triangle (int tno)
  {t_free [tno] = true;
  }

void morph_edit::to_back (int tno)
  {int tt [3];

   get_t;
   shift_ts;
   insert_at_back;

.  get_t 
     {tt [0] = t [tno][0];
      tt [1] = t [tno][1];
      tt [2] = t [tno][2];
     }.

.  shift_ts
     {for (int i = tno; i > 0; i--)
        {t [i][0]   = t [i-1][0];
         t [i][1]   = t [i-1][1];
         t [i][2]   = t [i-1][2];
         t_free [i] = t_free [i-1];
        };
     }.

.  insert_at_back
     {t [0][0]   = tt [0];
      t [0][1]   = tt [1];
      t [0][2]   = tt [2];
      t_free [0] = false;
     }. 

  }

void morph_edit::to_front (int tno)
  {int tt [3];

   get_t;
   shift_ts;
   insert_at_back;

.  get_t 
     {tt [0] = t [tno][0];
      tt [1] = t [tno][1];
      tt [2] = t [tno][2];
     }.

.  shift_ts
     {for (int i = tno; i < num_triangles-1; i++)
        {t [i][0]   = t [i+1][0];
         t [i][1]   = t [i+1][1];
         t [i][2]   = t [i+1][2];
         t_free [i] = t_free [i+1];
        };
     }.

.  insert_at_back
     {t [num_triangles-1][0]   = tt [0];
      t [num_triangles-1][1]   = tt [1];
      t [num_triangles-1][2]   = tt [2];
      t_free [num_triangles-1] = false;
     }. 

  }

void morph_edit::invert_marks ()
  {invert_marks (w_orig, 0);
   invert_marks (w_dest, 1);
  }

void morph_edit::invert_marks (win *w, int wno)
  {set_mode;
   invert_points;
   invert_triangles;
   invert_shades;

.  set_mode
     {w->function  (GXxor);
      w->set_color (point_color);
     }.

.  invert_shades
     {if (is_shade)
         perform_shade_inversion;
     }.

.  perform_shade_inversion
     {for (int i = 0; i < num_triangles; i++)
        if (! t_free [i])
           invert_triangle_shade;
      w->tick ();
     }.

.  invert_triangle_shade
     {point    pmin; 
      point    pmax;
      triangle mreg = act_triangle;
    
      w->function  (GXcopy);
      w->set_color (blue);
      hull (mreg, pmin, pmax);
      for (int x = (int) pmin.x; x <= (int) pmax.x; x++)
        for (int y = (int) pmin.y; y <= (int) pmax.y; y++)
          if (inside_d (mreg, new_point (x, y, 0)))
             shade_pixel;
      w->set_color (red);
      w->line (xx (wno, xp0), yy (wno, yp0), xx (wno, xp1), yy (wno, yp1));
      w->line (xx (wno, xp0), yy (wno, yp0), xx (wno, xp2), yy (wno, yp2));
      w->line (xx (wno, xp1), yy (wno, yp1), xx (wno, xp2), yy (wno, yp2));
      w->set_color (blue);
     }.

.  act_triangle
     new_triangle (p [wno][t [i][1]], p [wno][t [i][0]], p [wno][t [i][2]]).

.  shade_pixel
     {w->fill (xx (wno, x), yy (wno, y), scale [wno], scale [wno]);
     }.

.  invert_points
     {for (int i = 0; i < num_points; i++)
        if (! p_free [i])
           invert_point;
     }.

.  invert_triangles
     {init;
      draw_lines;
     }.

.  init
     {num_l = 0;
     }.

.  draw_lines
     {for (int i = 0; i < num_triangles; i++)
        if (! t_free [i])
           invert_triangle;
     }.

.  invert_point
     {w->box (xx (wno, xp - 2),
              yy (wno, yp - 2),
              xx (wno, xp + 2),
              yy (wno, yp + 2));
      perhaps_show_mark;
      perhaps_show_focus;
     }.

.  perhaps_show_focus
     {if (i == focus)
         show_focus;
     }.

.  show_focus
     {w->box (xx (wno, xp - 4),
              yy (wno, yp - 4),
              xx (wno, xp + 4),
              yy (wno, yp + 4));
     }.

.  perhaps_show_mark
     {if (p_marked [i])
         show_mark;
     }.

.  show_mark
     {w->line (xx (wno, xp-4),
               yy (wno, yp),
               xx (wno, xp+4),
               yy (wno, yp));
      w->line (xx (wno, xp),
               yy (wno, yp-4),
               xx (wno, xp),
               yy (wno, yp+4));
     }.

.  invert_triangle
     {if (w_line (t [i][0], t [i][1]))
         w->line (xx (wno, xp0),
                  yy (wno, yp0),
                  xx (wno, xp1),
                  yy (wno, yp1));
      if (w_line (t [i][0], t [i][2]))
         w->line (xx (wno, xp0),
                  yy (wno, yp0),
                  xx (wno, xp2),
                  yy (wno, yp2));
      if (w_line (t [i][1], t [i][2]))
         w->line (xx (wno, xp1),
                  yy (wno, yp1),
                  xx (wno, xp2), 
                  yy (wno, yp2));
     }.

.  xp0  (int) p [wno][t [i][0]].x.
.  yp0  (int) p [wno][t [i][0]].y.
.  xp1  (int) p [wno][t [i][1]].x.
.  yp1  (int) p [wno][t [i][1]].y.
.  xp2  (int) p [wno][t [i][2]].x.
.  yp2  (int) p [wno][t [i][2]].y.

.  xp  (int) p [wno][i].x.
.  yp  (int) p [wno][i].y.

  } 
   
void morph_edit::alloc_mark (int pno)
  {if      (mark [0] == -1) mark [0] = pno;
   else if (mark [1] == -1) mark [1] = pno;
   else if (mark [2] == -1) mark [2] = pno;
  }
      
void morph_edit::free_mark (int pno)
  {if (mark [0] == pno) mark [0] = -1;
   if (mark [1] == pno) mark [1] = -1;
   if (mark [2] == pno) mark [2] = -1;
  }

bool morph_edit::w_line (int p1, int p2)
  {check_lines;
   add_new;

.  check_lines
     {for (int i = 0; i < num_l; i++)
        if (same_line)
           return false;
     }.

.  same_line
     (l [i][0] == p1 && l [i][1] == p2) || (l [i][0] == p2 && l [i][1] == p1).

.  add_new
     {l [num_l][0] = p1;
      l [num_l][1] = p2;
      num_l++;
      return true;
     }.

  }

int morph_edit::xx (int wno, int x)
  {return ((x - x0 [wno]) * scale [wno]);
  }

int morph_edit::yy (int wno, int y)
  {return ((y - y0 [wno]) * scale [wno]);
  }

int morph_edit::px (int wno, int x)
  {return (x / scale [wno]) + x0 [wno];
  }

int morph_edit::py (int wno, int y)
  {return (y / scale [wno]) + y0 [wno];
  }
