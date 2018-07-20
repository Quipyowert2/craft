#ifndef history_h
#define history_h

#include "buttons.h"

#define history_size         20
#define history_entry_length 256

class history
  {public:

   char     name [128];

   int      num_entries; 
   char     entry [history_size][history_entry_length];
   button   *cancel_button;

   history        (char   name [],
                   button *cancel = 0);
   ~history       ();

   void load      ();
   void save      ();

   void push      (char s []);
   char *select   (int x, int y, int dx, int dy); 
   char *top      ();

  }; 

#endif

