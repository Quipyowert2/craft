/*======================================================================*/
/*                                                                      */
/* Routines for ppm file access                                         */
/*                                                                      */
/*======================================================================*/

#include "ppm_handler.h"
#include "xfile.h"

bool ppm_size (char name [], int &dx, int &dy, int &color)
  {if   (f_exists (name))
        get_size
   else return false;

.  get_size
     {FILE *f;
      char type [128]; 

      f = fopen (name, "r");
      fscanf (f, "%s %d %d %d", type, &dx, &dy, &color);
      fclose (f);
      return (strcmp (type, "P6") == 0);
     }.

  }
