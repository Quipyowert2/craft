#include "well.h"
#include "masks.h"
#include "craft_def.h"

well::well (int fdx, int fdy)
  {dx = fdx;
   dy = fdy;
  }

well::well (well *w)
  {dx = w->dx;
   dy = w->dy;
   for (int x = 0; x < dx; x++)
     for (int y = 0; y < dy; y++)
       f [x][y] = w->f [x][y];
  }

well::~well ()
  {
  }

void well::init ()
  {for (int x = 0; x < dx; x++)
     for (int y = 0; y < dy; y++)
       if   (land_is_free)
            f [x][y] = 0;
       else f [x][y] = no_pot;

.  land_is_free
     (landscape [x][y] == land_stump ||        
      landscape [x][y] == land_mud   ||        
      landscape [x][y] == land_grass ||        
      landscape [x][y] == land_field).
          
  }

void well::set (int x, int y, int v)
  {if (inside)
      f [x][y] = v;
 
.  inside
     (0 <= x && x < dx && 0 <= y && y < dy).

  }

void well::add (int x, int y, int v)
  {if (inside)
      f [x][y] += v;

.  inside
     (0 <= x && x < dx && 0 <= y && y < dy).

  }

int well::ff (int x, int y)
  {return f [x][y];
  }

bool well::prop (int decent)
  {bool any_change = false;

   check_f;
   return any_change;

.  check_f
     {for (int x = 0; x < dx; x++)
        for (int y = 0; y < dy; y++)
          if (f [x][y] != no_pot)
             check_cell;
     }.

.  check_cell
     {int p = 0;

      get_p;
      if (p > 0 && p > f [x][y])
         set_new;
     }.

.  get_p
     {for (int xx = i_max (0, x-1); xx < i_min (dx-1, x+2); xx++)
        for (int yy = i_max (0, y-1); yy < i_min (dy-1, y+2); yy++)
          if (f [xx][yy] != no_pot)
             p = i_max (p, f [xx][yy]);
      p -= decent;
     }.

.  set_new
     {any_change = true;
      f [x][y]   = i_max (f [x][y], p); 
     }.

  }

void well::show (char title [], win *&w)
  {open_w;
   show_f;

.  open_w
     {w = new win (title, "", by_fix, by_fix, dx * 4, dy * 4);
     }.

.  show_f
     {int f_min;
      int f_max;

      get_min_max;
      show_cells;
     }.

.  get_min_max
     {f_min = INT_MAX;
      f_max = 0;
      for (int x = 0; x < dx; x++)
        for (int y = 0; y < dy; y++)
          if (f [x][y] != no_pot && f [x][y] > 0)
             {f_min = i_min (f_min, f [x][y]);
              f_max = i_max (f_max, f [x][y]);
             };
     }.

.  show_cells
     {double scale = 60.0 / (double) (f_max - f_min);

      for (int x = 0; x < dx; x++)
        for (int y = 0; y < dy; y++)
          show_cell;
     }. 

.  show_cell
     {int xx = x * 4;
      int yy = y * 4;

      set_c;
      w->fill (xx, yy, 4, 4);
      w->tick ();
     }.

.  set_c
     {if      (f [x][y] == 0)        w->set_color (white);
      else if (f [x][y] == no_pot)   w->set_color (red);
      else if (f [x][y] == path_pot) w->set_color (black);
      else if (f [x][y] < 0)         w->set_color (14);
      else                           w->set_color (cc);
     }.

.  cc
     60 - (int) (((double) f [x][y] - (double) f_min) * scale).

  }

void well::renorm ()
  {int min;

   get_min;
   exec_renorm;

.  get_min
     {min = INT_MAX;
      for (int x = 0; x < dx; x++)
        for (int y = 0; y < dy; y++)
          if (f [x][y] != no_pot)
             min = i_min (min, f [x][y]);
     }.

.  exec_renorm
     {for (int x = 0; x < dx; x++)
        for (int y = 0; y < dy; y++)
          if (f [x][y] != no_pot)
             f [x][y] = f [x][y] - min;
     }.
          
  }

void well::climb (int x, int y)
  {int  xx;
   int  yy;
   int  p;
   bool another_step;
   
   to_start;
   while (another_step)
     {climb_step;
     };

.  to_start
     {xx           = x;
      yy           = y;
      another_step = true; 
     }.

.  climb_step
     {int xn;
      int yn;

      another_step = false;
      p            = f [xx][yy];
      f [xx][yy]   = path_pot;
      for (int dxx = -1; dxx < 2; dxx++)
        for (int dyy = -1; dyy < 2; dyy++)
          check_field;
      if (another_step)
         {xx = xn;
          yy = yn;
         };
     }.

.  check_field
     {if (0 <= fx && fx < dx && 0 <= fy && fy < dy &&
          ff != no_pot && ff != path_pot && ff > p)
         grab_new_point;  
     }.

.  grab_new_point
     {xn           = fx;   
      yn           = fy;
      p            = ff;
      another_step = true;
     }.

.  ff f [fx][fy].
.  fx (xx + dxx).
.  fy (yy + dyy).

  }

int well::climb (int x, int y, well *but, int &xt, int &yt)
  {int  xx;
   int  yy;
   int  p;
   bool another_step;
   bool fp [dx][dy];
   int  max_but;
   
   to_start;
   init_fp;
   gen_fp;
   get_path;
   return max_but;

.  get_path
     {to_start;
      while (another_step)
        {climb_fp;
        };
      xt = xx;
      yt = yy;
     }.

.  climb_fp
     {int xn;
      int yn;
      int best_f = f [xx][yy];

      another_step = false;
      p            = f [xx][yy];
      f [xx][yy]   = path_pot;
      max_but      = i_max (max_but, but->f [xx][yy]);
      for (int dxx = -1; dxx < 2; dxx++)
        for (int dyy = -1; dyy < 2; dyy++)
          check_fp_field;
      if (another_step)
         {xx = xn;
          yy = yn;
         };
     }.
 
.  check_fp_field
     {if (0<=fx && fx<dx && 0<=fy && fy<dy && fp [fx][fy] && ff > best_f)
         grab_new_fp_point;  
     }.

.  grab_new_fp_point
     {xn           = fx;   
      yn           = fy;
      best_f       = ff;
      another_step = true;
     }.

.  gen_fp
     {while (another_step)
       {climb_step;
       };
     }.

.  init_fp
     {for (int x = 0; x < dx; x++)
        for (int y = 0; y < dy; y++)
          fp [x][y] = false;
     }.

.  to_start
     {xx           = x;
      yy           = y;
      another_step = true; 
      max_but      = 0;
     }.

.  climb_step
     {int xn;
      int yn;
      int best_but = INT_MAX;

      another_step = false;
      p            = f [xx][yy];
      fp [xx][yy]  = true;
      for (int dxx = -1; dxx < 2; dxx++)
        for (int dyy = -1; dyy < 2; dyy++)
          check_field;
      if (another_step)
         {xx = xn;
          yy = yn;
         };
     }.

.  check_field
     {if (0 <= fx && fx < dx && 0 <= fy && fy < dy &&
          ff != no_pot && ff != path_pot && ff > p &&
          ! fp [fx][fy] && but->f [fx][fy] < best_but)
         grab_new_point;  
     }.

.  grab_new_point
     {xn           = fx;   
      yn           = fy;
      best_but     = but->f [fx][fy];
      another_step = true;
     }.

.  ff f [fx][fy].
.  fx (xx + dxx).
.  fy (yy + dyy).

  }

void add (well *a, well *b, well *&c)
  {c = new well (a->dx, a->dy);
   c->init ();
   for (int x = 0; x < a->dx; x++)
     for (int y = 0; y < a->dy; y++)
       if (a->f [x][y] != no_pot)
          c->f [x][y] = a->f [x][y] + b->f [x][y];
  } 

void sub (well *a, well *b, well *&c)
  {c = new well (a->dx, a->dy);
   c->init ();
   for (int x = 0; x < a->dx; x++)
     for (int y = 0; y < a->dy; y++)
       if (a->f [x][y] != no_pot)
          c->f [x][y] = a->f [x][y] - b->f [x][y];
  } 

