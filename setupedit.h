#ifndef setupedit_h
#define setupedit_h

class edit_setup
  {public :

   int    money;
   int    num   [5];
   int    price [5];
   int    s;
   win    *w;
   button *incr [5];
   button *decr [5];
   button *quit;
   button *cancel;

   edit_setup  (char host [], int money);
   ~edit_setup ();

   void eval (bool &quit, int num [5]);

 };

#endif


