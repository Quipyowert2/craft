#ifndef multi_dial_h
#define multi_dial_h

/*======================================================================*/
/*= CHANGES AND UPDATES                                                =*/
/*======================================================================*/
/*= date   person file         subject                                 =*/
/*=--------------------------------------------------------------------=*/
/*=                                                                    =*/
/*= 060794 hua    multi_dial.h created                                 =*/
/*=                                                                    =*/
/*======================================================================*/

#include "bool.h"
#include "buttons.h"
#include "getline.h"
#include "win.h"
#include "dial.h"

#define max_multi_dial_buttons 50

class multi_dial
  {public :

     win  *w;
     char title      [128];
     dial *d_buttons [max_multi_dial_buttons];
     char b_title    [max_multi_dial_buttons][128];
     bool values     [max_multi_dial_buttons];
     int  num_buttons;
     bool is_history;
  
     int  max_b_title_dx;

   multi_dial  (char name    [], 
                char buttons [],
                bool used_history = true);

   ~multi_dial ();

   void save    (char name []);
   void load    (char name []);

   bool eval    ();
   bool pressed (int bno);
   bool press   (int bno, bool mode);

   bool get_cmd (char cmds [], int &p, char cmd []);

 };

#endif
