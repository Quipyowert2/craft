#include <stdio.h>
#include <stdlib.h>

#include "violation.h"

void __array_bounds_violation (char const *file_name,
                               int  line_number,
			       char const *array_name,
                               int  upper_bound,
			       char const *index_name,
                               int  bad_index)

 {printf ("%s (cc=%d,hc=", file_name, line_number);
  fflush (stdout);
  print_hc;
  printf (") : %s [%s == %d] out of [0..%d]\n",
          array_name,
          index_name,
          bad_index,
          upper_bound);
  abort ();

.  print_hc
     {char cmd [128];

      sprintf (cmd, "cc2hc %s %d", file_name, line_number);
      system  (cmd);
     }.

  }
