#include "morph_edit.h"

main (int num_params, char *shell_params [])
  {if   (is_usage)
        usage
   else perform_morph;

.  usage
     {printf ("morph  <regions> <orig> <dest>\n");
      exit   (0);
     }.

.  is_usage
     (num_params < 3).

.  perform_morph
     {morph_edit *me;
      bool       is_quit = false;

      open_edit;
      perform_edit;
      delete (me);
     }.

.  open_edit 
     {me = new morph_edit (shell_params [1],
                           shell_params [2],
                           shell_params [3]);
     }.

.  perform_edit
     {while (! is_quit)
        {me->eval (is_quit);
        };
     }.  

  }
