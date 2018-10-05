
#include "cmap.h"
#include "xbm.h"
 
cmap::cmap (win *w_i, const char name_i [], bool preload, bool smart_load)
  {w              = w_i;
   is_mask        = false;
   is_loaded      = false;
   is_color_trans = false;
   strcpy (name, name_i);
   if (preload)
      load (smart_load);
  }

cmap::~cmap ()
  {if (is_loaded)
      perform_delete;

.  perform_delete
     {w->delete_map (image);
      if (is_mask)
         w->delete_map (mask);
     }.

  }

void cmap::set_color_trans (color_trans *t)
  {ct             = t;
   is_color_trans = true;
  }

void cmap::load (bool smart)
  {load_image;
   perhaps_load_mask;
   is_loaded = true;

.  load_image
     {FILE *f;

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

      fscanf (f, "%d %d %d %d", &d, &dx, &dy, &d);
     }.

.  read_pixels
     {Pixmap back;

      w->function  (GXcopy);
      draw_pixels;
     }.

.  draw_pixels
     {int last_c = -1;

      w->create_map (image, dx, dy);
      for (int y = 0; y < dy; y++)
        for (int x = 0; x < dx; x++) 
          read_pixel;
     }.

.  read_pixel
     {int c;

      fscanf       (f, "%d", &c);
      if (is_color_trans)
         c = ct->trans (c);
      if (c != last_c)
         {w->set_color (c);
          last_c = c;
         };
      w->pixel     (image, x, y);
     }.

.  read_pixmap 
     {w->store_map (image, 0, 0, dx, dy);
     }.

.  perhaps_load_mask
     {if (f_exists (complete (name, ".xbm")))
         load_mask;
     }.

.  load_mask
     {unsigned int d1;
               int d;

      XReadBitmapFile (w->mydisplay, w->mywindow,
                       complete (name, ".xbm"),
                       &d1, &d1, &mask, &d, &d);
      is_mask = true;
     }.

  }

void cmap::show (int x, int y, int xclip, int yclip)
  {show (x, y, 0, 0, xclip, yclip);
  }

void cmap::showd (int x, int y, int xclip, int yclip, int dx, int dy)
  {if (! is_loaded)
      load ();
   w->show_map (x, y, image, dx, dy, mask, xclip, yclip);
  }

void cmap::show (int x, int y, int src_x, int src_y, int xclip, int yclip)
  {if (! is_loaded)
      load ();
   if   (is_mask)
        w->show_map (x, y, image, dx, dy, mask, xclip, yclip);
   else w->show_map (x, y, src_x, src_y, image, dx, dy);
  }

void cmap::show (int x,     int y,     int max_x, int max_y,
                 int src_x, int src_y, int xclip, int yclip)

  {if (! is_loaded)
      load ();
   if   (is_mask)
        w->show_map (x, y, image,
                     i_max (0, i_min (max_x - x, dx)),
                     i_max (0, i_min (max_y - y, dy)),
                     mask, xclip, yclip);
   else w->show_map (x, y, src_x, src_y, image,
                     i_max (0, i_min (max_x - x, dx)),
                     i_max (0, i_min (max_y - y, dy)));
  }

void cmap::show (int x, int y)
  {show (x, y, x, y);
  }

void cmap::fill (int x, int y, int fdx, int fdy)
  {for (int x0 = x; x0 < fdx; x0 += dx - (x0 % dx))
     for (int y0 = y; y0 < fdy; y0 += dy- (y0 % dy))
       {w->show_map (x0, y0,
                     x0 % dx, y0 % dy, image,
                     i_min (fdx - x0, dx - (x0 % dx)),
                     i_min (fdy - y0, dy - (y0 % dy)));
       };
  }
