#include "morph.h"

main (int num_params, char *shell_params [])
  {if   (is_usage)
        usage
   else perform_morph;

.  usage
     {printf ("morph <orig> <dest> <background><regions><num_steps>\n");
      exit   (0);
     }.

.  is_usage
     (num_params < 5).

.  perform_morph
     {morph (shell_params [1],
             shell_params [2],
             shell_params [3],
             shell_params [4],
       atoi  (shell_params [5]));
     }.

  }
