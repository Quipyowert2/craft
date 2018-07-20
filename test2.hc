#include "morph.h"
#include "win.h"
#include "sound.h"
#include "xmath.h"
#include "xbm.h"

main (int num_params, char *shell_params [])
  {xbm *xb;

   xb = new xbm ("tt.xbm");
   for (int y = 0; y < xb->dy; y++)
     {for (int x = 0; x < xb->dx; x++)
        {print_bit;
        };
      printf ("\n");
     };
   ack ();
   xb->save ("lala.xbm");
   delete (xb);

.  print_bit
     {int b;

      xb->bit (x, y, b);
      if   (b)
           printf ("I");
      else printf (".");
     }.
 
  } 