#include "stdlib.h"
#include "cry.h"

void cry (char *func_name)
  {printf ("\n Error : calling dummy virtual function (%s)\n", func_name);
   exit   (1);
 }
