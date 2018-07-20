#include "win.h"

main (int num_params, char *shell_params [])
  {FILE *f;

   open_f;
   print_params;
   print_input;
   fclose (f);

.  open_f
     {f_open (f, "/home/hua/xyz", "w");
     }.

.  print_params
     {for (int i = 0; i < num_params; i++)
        fprintf (f, "<%s>\n", shell_params [i]);
     }.

.  print_input
     {int  l = atoi (getenv ("CONTENT_LENGTH"));
      char c;
      
      for (int i = 0; i < l; i++)
        {c = getchar ();
         fprintf (f, "%c", c);
        };
      fprintf (f, "\n");
     }.

  }