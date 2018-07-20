/*======================================================================*/
/*= CHANGES AND UPDATES                                                =*/
/*======================================================================*/
/*= date   person file       subject                                   =*/
/*=--------------------------------------------------------------------=*/
/*=                                                                    =*/
/*= 031193 hua    lru.hc     created                                   =*/
/*=                                                                    =*/
/*======================================================================*/

#include "lru.h"
#include "stdio.h"

lru::lru (int l_size)
  {size = l_size;
   pred = new int [size];
   suc  = new int [size];
   clear ();
  }

lru::~lru ()
  {delete (pred);
   delete (suc);
  }

void lru::dump ()
  {dump_free;
   dump_used;

.  dump_free
     {int e = free;

      printf ("--- free - %d ---------------------------- \n", free);
      while (e != nil_ptr)
        {printf ("   %-4d %-4d %-4d\n", e, suc [e], pred [e]);
         e = suc [e];
        };
     }.

.  dump_used
     {int e = fresh;

      printf ("--- used - %d - %d ------------------------- \n", fresh, cand);
      while (e != nil_ptr)
        {printf ("   %-4d %-4d %-4d\n", e, suc [e], pred [e]);
         e = suc [e];
        };
     }.

  }

void lru::clear ()
  {cand  = nil_ptr;
   fresh = nil_ptr;
   free  = 0;
   for (int i = 0; i < size; i++)
     {suc  [i] = i+1;
      pred [i] = i-1;
     };
   suc  [size-1] = nil_ptr;
   pred [0]      = nil_ptr;
  }


void lru::remove (int id)
  {remove_from_queue;
   add_to_free;

.  remove_from_queue
     {if   (cand == id) 
           cand = pred [id];
      else pred [suc  [id]] = pred [id];
      if  (fresh == id)
           fresh = suc [id];
      else suc  [pred [id]] = suc  [id];
     }.

.  add_to_free
     {suc  [id]   = free;
      pred [free] = id;
      pred [id]   = nil_ptr;
      free        = id;
     }.

  }
  
void lru::access (int id)
  {if (id != fresh)
      perform_access;

.  perform_access
     {remove_from_queue;
      to_top;
     }.

.  to_top
     {if (fresh != id)
         {suc [id]     = fresh;
          pred [fresh] = id;
          pred [id]    = nil_ptr;
          fresh        = id;
         };
     }.
          
.  remove_from_queue
     {if   (cand == id) 
           cand = pred [id];
      else pred [suc  [id]] = pred [id];
      if  (fresh == id)
           fresh = suc [id];
      else suc  [pred [id]] = suc  [id];
    }.

  }
   
int lru::add (bool &with_remove)
  {int e;

   if   (free != nil_ptr)
        grab_free_row
   else recycle_row;
   return e;

.  grab_free_row
     {e            = free;
      free         = suc [e];
      suc  [e]     = fresh;
      pred [e]     = nil_ptr;
      pred [fresh] = e;
      fresh        = e;
      with_remove  = false;
      if (cand == nil_ptr)
         cand = e;
     }.

.  recycle_row
     {e           = cand;
      with_remove = true;
      access (e);
     }.

  }

int lru::candidate (bool &with_remove)
  {with_remove = (free == nil_ptr);
   return cand;
  }

int lru::freshest (int no)
  {int e = fresh;

   for (int i = 0; e != nil_ptr && i < no; i++)
     {e = suc [e];
     };
   return e;
  }


