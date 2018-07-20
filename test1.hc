#include "morph.h"
#include "win.h"
#include "sound.h"
#include "xmath.h"

main (int num_params, char *shell_params [])
  {win *w;
   XImage *i;
   XImage *i1;

   w = new win ("lala", "", 10, 10, 400, 400);
   w->line (0, 0, 400, 400);
   w->line (0, 400, 400, 0);
w->tick ();
ack ();
   w->get_image (i, 20, 20,20, 20);
   w->get_image (i1, 100, 200, 20, 20);

for (int x = 10; x < 15; x++)
  for (int y = 10; y < 15; y++)
    w->set_pixel (i1, x, y, red);

ack ();
   for (int j = 0; j < 1000; j++)
     {scroll_down;
      scroll_up;
     };
 ack ();
 delete (w);

.  scroll_down
     {for (int x = 0; x < 19; x++)
        for (int y = 0; y < 19; y++)
          w->put_image (i, x * 20, y * 20, 20, 20);
      w->tick ();
     }.

.  scroll_up
     {for (int x = 0; x < 19; x++)
        for (int y = 0; y < 19; y++)
          w->put_image (i1, x * 20, y * 20, 20, 20);
      w->tick ();
     }.

  } 