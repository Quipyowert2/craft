/*======================================================================*/
/*= CHANGES AND UPDATES                                                =*/
/*======================================================================*/
/*= date   person file       subject                                   =*/
/*=--------------------------------------------------------------------=*/
/*=                                                                    =*/
/*= 111094 hua    xbm.hc     created                                   =*/
/*=                                                                    =*/
/*======================================================================*/

#include "string.h"
#include "stdio.h"

#include "errorhandling.h"
#include "xbm.h"
#include "xstring.h"
#include "io.h"
#include "paramreader.h"

xbm::xbm (char name [])
  {FILE *xbm_data;

   open_data;
   get_size;
   alloc_data;
   read_pixels;
   fclose (xbm_data);

.  open_data
     {char f_name [128];

      strcpy (f_name, name);
      f_open (xbm_data, f_name, "r");
     }.

.  get_size
    {char d [128];

     fscanf (xbm_data, "%s %s %d", d, d, &dx);
     fscanf (xbm_data, "%s %s %d", d, d, &dy);
     skip_line;
     skip_line;
    }.

.  skip_line
     {while (fgetc (xbm_data) != '\n')
        {
        };
     }.

.  alloc_data
     {data = new int [dx * dy];
     }.

.  read_pixels
     {int b;

      for (int y = 0; y < dy; y++)
        for (int x = 0; x < dx; x++)
          read_pixel; 
     }.

.  read_pixel
     {perhaps_get_b;
      data [ind (x, y)] = b_on (b, x % 8);
     }.

.  perhaps_get_b
     {char c;

      if (x % 8 == 0)
         get_new_b;
     }. 

.  get_new_b
     {char bb [128];

      fscanf (xbm_data, "%s", bb);
      b = hextoint (substring (bb, 2));
     }.

  }

xbm::xbm (int bdx, int bdy)
  {store_size;
   alloc_data;

.  store_size
    {dx = bdx;
     dy = bdy;
    }.

.  alloc_data
     {data = new int [dx * dy];
     }.

  }

xbm::~xbm ()
  {delete (data);
  }

void xbm::save (char name [])
  {FILE *f;

   open_f;
   write_size;
   write_data;
   write_tail;
   fclose (f);

.  open_f
     {f_open (f, name, "w");
     }.

.  write_size
     {fprintf (f, "#define x_width %d\n", dx);
      fprintf (f, "#define x_height %d\n", dy);
      fprintf  (f, "static char x_bits[] = {");
     }.

.  write_tail 
     {fprintf (f, "};");
     }.

.  write_data
     {int c = 0;
      int b = 0;
      int x;
      int y;

      for (y = 0; y < dy; y++)
        for (x = 0; x < dx; x++)
          {write_byte;
           perhaps_flush_last_byte;
          };
     }.

.  perhaps_flush_last_byte
     {if (! on_byte && x == dx-1)
         flush_byte;
     }.

.  write_byte
     {perhaps_flush;
      if (data [ind (x, y)])
          b = b_set (b, x % 8);
     }.

.  perhaps_flush
     {if (on_byte && ! (x == 0))
         flush_byte;
     }.

.  on_byte
     ((x % 8) == 0).

.  flush_byte
     {if (! (x == 8 && y == 0))
         fprintf (f, ", ");
      if (c % 12 == 0)
         fprintf (f, "\n");      c++;
      fprintf (f, "0x%s", inttohex (b)); 
      b = 0;
     }.

  }

void xbm::bit (int x, int y, int &b)
  {b = data [ind (x, y)];
  }

void xbm::set (int x, int y, int b)
  {data [ind (x, y)] = b;
  }

int xbm::ind (int x, int y)
  {return y * dx + x;
  }


