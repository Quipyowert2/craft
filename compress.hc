/*======================================================================*/
/*= CHANGES AND UPDATES                                                =*/
/*======================================================================*/
/*= date   person file        subject                                  =*/
/*=--------------------------------------------------------------------=*/
/*=                                                                    =*/
/*= 111094 hua    compress.hc created                                  =*/
/*=                                                                    =*/
/*======================================================================*/

#include "xfile.h"
#include "compress.h"



#define indicator_raw  0
#define indicator_same 1


compress::compress ()
  {snr = 0;
  }

compress::~compress ()
  {
  }

char *compress::frame_name (char postfix [])
  {static char r [128];

   sprintf (r, "%s%04d.%s", name, snr, postfix);
   return r;
  }
   
void compress::encode (char fname [])
  {store_params;
   start_message;
   open_f;
   init_encode;
   next_frame;
   while (another_frame)
     {encode_frame;
      next_frame;
     };
   fclose (f);
   finish_message;

.  another_frame
     f_exists (frame_name ("pcx")).

.  open_f
     {char f_name [128];

      sprintf (f_name, "%s.hz", name);
      f = fopen (f_name, "w");
     }.

.  store_params
     {strcpy (name, fname);
     }.

.  start_message
     {printf ("start encoding %s\n", name);
     }.

.  finish_message
     {printf ("encoding %s finished, %d frames encoded\n", name, snr);
     }.

.  init_encode
     {convert_frame;
      printf ("       %s\n", frame_name (""));
      act = new ppm (frame_name ("ppm"));
      store_initial_ppm;
      delete_ppm;
     }.

.  store_initial_ppm
     {int r;
      int g;
      int b;

      bprintf (f, 4, act->dx);
      bprintf (f, 4, act->dy);
      bprintf (f, 1, indicator_raw);
      bprintf (f, 4, act->dx * act->dy);
      for (int y = 0; y < act->dy; y++)
        for (int x = 0; x < act->dx; x++)
          {act->rgb (x, y, r, g, b);
           bprintf  (f, 1, r);
           bprintf  (f, 1, g);
           bprintf  (f, 1, b);
          };
     }.

.  next_frame
     {snr++;
     }.

.  convert_frame
     {char cmd [256];
      char n1  [128];
      char n2  [128];

      strcpy  (n1, frame_name ("pcx"));
      strcpy  (n2, frame_name ("ppm"));
      sprintf (cmd, "pcxtoppm %s > %s", n1, n2);
      system  (cmd);
     }.

.  delete_ppm
     {char cmd [256];

      sprintf (cmd, "rm %s", frame_name ("ppm"));
      system  (cmd);
     }.

.  encode_frame
     {ppm *frame;

      get_frame;
      encode_pixels;
      delete_ppm;
      delete (frame);
     }.

.  get_frame
     {printf ("       %s\n", frame_name (""));
      convert_frame;
      frame = new ppm (frame_name ("ppm"));
     }.

.  encode_pixels
     {bool is_same;
      int  x_start;
      int  y_start;
      int  cnt;

      begin_first_sequence;
      for (int y = 0; y < act->dy; y++)
        for (int x = 0; x < act->dx; x++)
          encode_pixel;
      finish_sequence;
     }.

.  begin_first_sequence
     {is_same = act->equal (frame, 0, 0);
      x_start = 0;
      y_start = 0;
      cnt     = 0;
     }.

.  encode_pixel
     {if   (is_same)
           handle_same_seq
      else handle_raw_seq;
     }.

.  handle_same_seq
     {if   (act->equal (frame, x, y))
           cnt++;
      else finish_seq;
     }.

.  handle_raw_seq
     {if   (act->equal (frame, x, y))
           finish_seq
      else cnt++;
     }.

.  finish_seq
     {finish_sequence;
      start_new_sequence;
     }.

.  finish_sequence
     {if (cnt != 0)
         store_sequence;
     }.

.  start_new_sequence
     {is_same = act->equal (frame, x, y);
      x_start = x;
      y_start = y;
      cnt     = 1;
     }.

.  store_sequence
     {if   (is_same)
           store_same_seq
      else store_raw_seq;
     }.

.  store_same_seq
     {bprintf (f, 1, indicator_same);
      bprintf (f, 4, cnt);
     }.

.  store_raw_seq
     {store_raw_header;
      store_raw_data;
     }.

.  store_raw_header
     {bprintf (f, 1, indicator_raw);
      bprintf (f, 4, cnt);
     }.

.  store_raw_data
     {int yy = y_start;
 
      for (int xx = x_start; act->dx && cnt-- > 0; xx++)
        store_pixel;
      for (yy = y_start+1; cnt > 0; yy++)
        for (int xx = 0; xx < act->dx && cnt-- > 0; xx++)
          store_pixel;
     }.

.  store_pixel
     {int r;
      int g;
      int b;

      act->rgb (xx, yy, r, g, b);
      bprintf  (f, 1, r);
      bprintf  (f, 1, g);
      bprintf  (f, 1, b);
     }.

  }

void compress::decode (char fname [])
  {int  dx;
   int  dy;
   int  byte_cnt;
   int  size;
   int  cmd;
   bool another_cmd;

   store_params;
   start_message;
   open_f;
   init_decode;
   while (another_cmd)
     {exec_cmd;
      get_cmd;
     };
   fclose (f);
   flush_frame;
   validate_size;
   finish_message;

.  start_message
     {printf ("start decoding %s\n", name);
     }.

.  finish_message
     {printf ("decoding %s finished, %d frames decoded\n", name, snr);
     }.

.  open_f
     {char f_name [128];

      sprintf (f_name, "%s.hz", name);
      f_open (f, f_name, "r");
     }.

.  validate_size
     {if (end_of_page)
         handle_wrong_size;
     }.

.  end_of_page
     (byte_cnt != page_size).

.  handle_wrong_size
     {printf ("!!! WARNING !!! .hz file is corrupted\n");   
     }.

.  page_size
     (dx * dy).

.  store_params
     {strcpy (name, fname);
     }.

.  init_decode
     {another_cmd = bscanf (f, 4, dx);
      another_cmd = bscanf (f, 4, dy);
      snr         = 0;
      byte_cnt    = 0;
      open_new_frame;
      get_cmd;
     }.

.  open_new_frame
     {act = new ppm (dx, dy, 0, 0, 0);
     }.

.  get_cmd
     {another_cmd = bscanf (f, 1, cmd);
      another_cmd = bscanf (f, 4, size);
     }.

.  exec_cmd
     {if      (byte_cnt == page_size)           
              flush_frame
      if      (cmd == indicator_raw)  get_raw_sequence
      else if (cmd == indicator_same) get_same_sequence;
     }.

.  flush_frame
     {printf    ("       %s\n", frame_name ("pcx"));
      act->save (frame_name ("ppm"));
      convert_to_pcx;
      byte_cnt = 0;
      snr++;
     }.

.  convert_to_pcx 
     {char cmd [256];
      char n1  [128];
      char n2  [128];

      strcpy  (n1, frame_name ("ppm"));
      strcpy  (n2, frame_name ("pcx"));
      sprintf (cmd, "ppmtopcx %s > %s", n1, n2);
      system  (cmd);
      sprintf (cmd, "rm %s", n1);
      system  (cmd);
     }.

.  get_same_sequence
     {byte_cnt += size;
     }.

.  get_raw_sequence
     {for (int i = 0; i < size; i++)
        get_pixel;
     }.

.  get_pixel
     {int r;
      int g;
      int b;

      bscanf   (f, 1, r);
      bscanf   (f, 1, g);
      bscanf   (f, 1, b);
      act->set (px, py, r, g, b);
      byte_cnt++;
     }.

.  px   (byte_cnt % dx).
.  py   (byte_cnt / dx).

  } 

