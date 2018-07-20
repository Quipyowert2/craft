#ifndef colortans_h
#define colortans_h


class color_trans
  {public :

   int translate [256];

   color_trans  ();
   ~color_trans ();

   void add     (int c1, int c2);
   int  trans   (int c);

 };

#endif
