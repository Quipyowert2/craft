#ifndef lru_h
#define lru_h

/*======================================================================*/
/*= CHANGES AND UPDATES                                                =*/
/*======================================================================*/
/*= date   person file       subject                                   =*/
/*=--------------------------------------------------------------------=*/
/*=                                                                    =*/
/*= 031193 hua    lru.h      created                                   =*/
/*=                                                                    =*/
/*======================================================================*/

#define no_lru_remove -1
#define nil_ptr       -1

#include "bool.h"

class lru
  {public :

   int  *pred;
   int  *suc;
   int  size;
   
   int  cand;
   int  fresh;
   int  free;


        lru    (int size);
        ~lru   ();

   void dump      ();
   void clear     ();
   void remove    (int  id);
   void access    (int  id);
   int  add       (bool &with_remove);
   int  candidate (bool &with_remove);
   int  freshest  (int  no);

 };

#endif

