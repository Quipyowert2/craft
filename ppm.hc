/*======================================================================*/
/*= CHANGES AND UPDATES                                                =*/
/*======================================================================*/
/*= date   person file       subject                                   =*/
/*=--------------------------------------------------------------------=*/
/*=                                                                    =*/
/*= 111094 hua    ppm.hc     created                                   =*/
/*=                                                                    =*/
/*======================================================================*/

#include "stdio.h"
#include "string.h"

#include "io.h"
#include "paramreader.h"
#include "errorhandling.h"
#include "ppm.h"


struct conv 
   {char b0; 
    char b1;
    char b2;
    char b3;
   };

union conv_data
  {conv a;
   int  b;
  };

ppm::ppm (int pdx, int pdy, int r, int g, int b)
  {set_status;
   alloc_data;
   init_data;
 
.  set_status
     {dx       = pdx;
      dy       = pdy;
      is_cache = false;
     }.

.  alloc_data
     {r_data = new int [dx * dy];
      g_data = new int [dx * dy];
      b_data = new int [dx * dy];
     }.

.  init_data
     {for (int i = 0; i < dx * dy; i++) 
        {r_data [i] = r;
         g_data [i] = g;
         b_data [i] = b;
        };
     }.

  }

ppm::ppm (ppm *p)
  {copy_status;
   alloc_data;
   copy_data;
 
.  copy_status
     {dx       = p->dx;
      dy       = p->dy;
      is_cache = false;
     }. 

.  alloc_data
     {r_data = new int [dx * dy];
      g_data = new int [dx * dy];
      b_data = new int [dx * dy];
     }.

.  copy_data
     {for (int i = 0; i < dx * dy; i++) 
        {r_data [i] = p->r_data [i];
         g_data [i] = p->g_data [i];
         b_data [i] = p->b_data [i];
        };
     }.

  }

ppm::ppm (char name [], bool with_cache)
  {FILE *data;
   bool is_bin;

   init_cache;
   open_data;
   get_size;
   alloc_data;
   read_pixels;
   fclose (data);

.  init_cache
     {is_cache     = with_cache;
      cache_loaded = false;
     }.

.  open_data
     {char f_name [128];

      strcpy (f_name, name);
      f_open (data, f_name, "r");
     }.

.  get_size
    {char type   [128]; 
     int  color;
     char buffer [1024];

     get_a_line;
     sscanf (buffer, "%s", type);
     check_type;
     get_a_line;
     sscanf (buffer, "%d %d", &dx, &dy);
     get_a_line;
     sscanf (buffer, "%d", &color);
    }.

.  check_type
     {if      (strcmp (type, "P3") == 0)
              is_bin = false;
      else if (strcmp (type, "P6") == 0)
              is_bin = true;
      else    errorstop (4, "PPM", "invalid magic number");
     }.

.  get_a_line
     {f_getline (data, buffer, 1024);
      while (buffer [0] == '#')
        {f_getline (data, buffer, 1024);
        };
     }.

.  alloc_data
     {r_data = new int [dx * dy];
      g_data = new int [dx * dy];
      b_data = new int [dx * dy];
      cache  = new int [dx * dy];
     }.

.  read_pixels
     {if   (is_bin)
           read_bin_pixels
      else read_plain_pixels;
     }.

.  read_plain_pixels
     {for (int y = 0; y < dy; y++)
        for (int x = 0; x < dx; x++)
          read_pixel; 
     }.

.  read_pixel
     {fscanf (data, "%d %d %d",
              &r_data [ind (x, y)],
              &g_data [ind (x, y)],
              &b_data [ind (x, y)]);
     }.

.  read_bin_pixels
     {for (int y = 0; y < dy; y++)
        for (int x = 0; x < dx; x++)
          read_bin_pixel; 
     }.

.  read_bin_pixel
     {conv_data c;

      c.b    = 0;
      c.a.b0 = fgetc (data); r_data [ind (x, y)] = c.b;
      c.a.b0 = fgetc (data); g_data [ind (x, y)] = c.b;
      c.a.b0 = fgetc (data); b_data [ind (x, y)] = c.b;
     }.

  }

ppm::~ppm ()
  {delete (r_data);
   delete (g_data);
   delete (b_data);
   if (is_cache)
      delete (cache);
  }


void ppm::save (char name [])
  {FILE *f;

   open_f;
   write_header;
   write_size;
   write_data;
   fclose (f);

.  open_f
     {f_open (f, name, "w");
     }.

.  write_header
     {fprintf (f, "P6\n");
     }.

.  write_size
     {fprintf (f, "%d %d\n", dx, dy);
      fprintf (f, "255\n");
     }.

.  write_data
     {for (int y = 0; y < dy; y++)
        write_line;
     }.

.  write_line
     {conv_data c;

      for (int x = 0; x < dx; x++)
        {c.b = r_data [ind (x, y)]; fputc (c.a.b3, f);
         c.b = g_data [ind (x, y)]; fputc (c.a.b3, f);
         c.b = b_data [ind (x, y)]; fputc (c.a.b3, f);
        };
     }.

  }

void ppm::rgb (int x, int y, int &r, int &g, int &b)
  {if (x < dx && y < dy)
      return_data;

.  return_data
     {r = r_data [ind (x, y)];
      g = g_data [ind (x, y)];
      b = b_data [ind (x, y)];
     }.

  }

void ppm::set (int x, int y, int r, int g, int b)
  {r_data [ind (x, y)] = r;
   g_data [ind (x, y)] = g;
   b_data [ind (x, y)] = b;
  }

void ppm::show (win *w, int wx, int wy)
  {if   (is_cache)
        show_with_cache
   else show_without_cache

.  show_with_cache
     {perhaps_load_cache;
      for (int x = 0; x < dx; x++)
         for (int y = 0; y < dy; y++)
           show_cache_pixel;
     }.

.  perhaps_load_cache
     {if (! cache_loaded) 
         perform_load_cache;
     }.

.  perform_load_cache
     {for (int x = 0; x < dx; x++)
        for (int y = 0; y < dy; y++)
          load_pixel;
      cache_loaded = true;
     }.

.  load_pixel
     {int i = ind (x, y);

      cache [i] = w->win_color (r_data [i], g_data [i], b_data [i]);
     }.    

.  show_cache_pixel
     {w->set_color (cache [ind (x, y)]);
      w->pixel     (wx + x, wy + y);
     }.

.  show_without_cache
     {for (int x = 0; x < dx; x++)
        for (int y = 0; y < dy; y++)
          show_pixel;
      w->tick       ();
     }.
 
.  show_pixel
     {int i = ind (x, y);

      w->set_color (r_data [i], g_data [i], b_data [i]);
      w->pixel     (wx + x, wy + y);
     }.    

  }

void ppm::get_map (win *w, Pixmap &image)
  {w->create_map (image, dx, dy);
   for (int x = 0; x < dx; x++)
     for (int y = 0; y < dy; y++)
       show_pixel;

.  show_pixel
     {int i = ind (x, y);

      w->set_color (r_data [i], g_data [i], b_data [i]);
      w->pixel     (image, x, y);
     }.    

  }

void ppm::show (win *w,
                int wx, int wy, int wdx, int wdy,
                int x0, int y0, int scale)
  
  {int yy = wy;

   w->function (GXcopy);
   perhaps_load_cache;
   for (int y = y0; y < dy && yy < wdy; y++)
     {draw_line; 
      yy += scale;
     };
 
.  perhaps_load_cache
     {if (! cache_loaded) 
         perform_load_cache;
     }.

.  perform_load_cache
     {for (int x = 0; x < dx; x++)
        for (int y = 0; y < dy; y++)
          load_pixel;
      cache_loaded = true;
     }.

.  load_pixel
     {int i = ind (x, y);

      cache [i] = w->win_color (r_data [i], g_data [i], b_data [i]);
     }.    

.  draw_line
     {int xx = wx;  
 
      for (int x = x0; x < dx && xx < wdx; x++)
        {draw_pixel; 
         xx += scale; 
        };
     }.

.  draw_pixel
     {int i = ind (x, y);

      if   (is_cache)
           w->set_color (cache [i]);
      else w->set_color (r_data [i], g_data [i], b_data [i]);
      for (int py = yy; py < yy + scale; py++)
        for (int px = xx; px < xx + scale; px++)
          w->pixel (px, py);
     }.

  }

int ppm::ind (int x, int y)
  {if   (0 <= x && x < dx && 0 <= y && y <= dy)
        return y * dx + x;
   else handle_error;

.  handle_error
     {printf    ("(x,y) out of range %d %d\n", x, y);
      errorstop (1, "PPM", "out of range");
     }.

  }

bool ppm::equal (ppm *p, int x, int y)
  {int ra;
   int ga;
   int ba;
   int rb;
   int gb;
   int bb;
   
      rgb (x, y, ra, ga, ba);
   p->rgb (x, y, rb, gb, bb);
   return (ra == rb && ga == gb && ba == bb);
  }


void copy (ppm *dest, ppm *src)
  {check_size;
   perform_copy;

.  check_size
     {if (dest->dx != src->dx || dest->dy != src->dy)
         errorstop (1, "ppm", "incompatible types at copy\n");
     }. 

.  perform_copy
     {for (int i = 0; i < src->dx * src->dy; i++) 
        {dest->r_data [i] = src->r_data [i];
         dest->g_data [i] = src->g_data [i];
         dest->b_data [i] = src->b_data [i];
        };
     }.

  }
