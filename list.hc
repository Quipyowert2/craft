/*======================================================================*/
/*= CHANGES AND UPDATES                                                =*/
/*======================================================================*/
/*= date   person file       subject                                   =*/
/*=--------------------------------------------------------------------=*/
/*=                                                                    =*/
/*= 270694 hua    list.hc    created                                   =*/
/*=                                                                    =*/
/*======================================================================*/

#include "list.h"
#include "errorhandling.h"


list list (int e)
  {return (empty_list () + e);
  }

list empty_list ()
  {list l;

   l.num          = 0;
   l.is_universal = false;
   return l;
  }

list universal_list ()
  {list l;

   l.num          = 0;
   l.is_universal = true;
   return l;
  }

void copy (list &l, list r)
  {l.num          = r.num;
   l.is_universal = r.is_universal;
   for (int i = 0; i < r.num; i++)
     l.elem [i] = r.elem [i];
  }

void print (list l)
  {if   (l.is_universal)
        print_universal_list
   else print_elem_list;

.  print_universal_list
     {printf ("\\ universal \\");
     }.

.  print_elem_list
     {printf ("//");
      for (int i = 0; i < l.num; i++)
        print_elem;
      printf ("//");
     }.

.  print_elem
     {perhaps_seperator;
      printf ("%d", l.elem [i]);
     }.

.  perhaps_seperator
     {if (i != 0)
         printf (",");
     }.

  }

list operator + (list l, int e)
  {list r;

   r = empty_list ();
   for (int i = 0; i < l.num; i++)
     {add_elem;
     };
   add_e;
   return r;

.  add_elem
     {if (l.elem [i] != e)
         perform_add;
     }.

.  perform_add
     {r.elem [r.num++] = l.elem [i];
     }.

.  add_e
     {r.elem [r.num++] = e;
     }.

  }

list operator - (list l, int e)
   {list r;

   r = empty_list ();
   for (int i = 0; i < l.num; i++)
     {add_elem;
     };
   return r;

.  add_elem
     {if (l.elem [i] != e)
         perform_add;
     }.

.  perform_add
     {r.elem [r.num++] = l.elem [i];
     }.

  }

bool operator % (int e, list l)
  {if   (l.is_universal)
        return true;
   else search_e;

.  search_e
     {for (int i = 0; i < l.num; i++)
        if (l.elem [i] == e)
           return true;
      return false;
     }.

  }  


   
