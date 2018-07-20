/*======================================================================*/
/*= CHANGES AND UPDATES                                                =*/
/*======================================================================*/
/*= date   person file               subject                           =*/
/*=--------------------------------------------------------------------=*/
/*=                                                                    =*/
/*= 260493 hua    collist.hc         created                           =*/
/*=                                                                    =*/
/*======================================================================*/

__unbounded__
  {
#include "stdlib.h"
#include "string.h"
  }

#include "collist.h"

collist::collist (char list [])
  {int pos;
   int prev = 0;

   num_cols = 0;
   for (pos = 0; pos < strlen (list); pos++)
     perhaps_symbol_end;
   handle_symbol_end;
  
.  perhaps_symbol_end
     if (list [pos] = ',')
        handle_symbol_end.

.  handle_symbol_end
     if (pos > prev)
        grab_sym.

.  grab_sym
     {char sym [128];

      strncpy (sym, &list [prev], pos-prev-1);
      col_no [num_cols++] = atoi (sym);
      prev = pos + 1;
     }. 

  }

collist::~collist ()
  {
  }

int collist::num ()
  {return num_cols;
  }

int collist::col (int i)
  {return col_no [i];
  }
