#ifndef ship_h
#define ship_h

#include "bool.h"
#include "win.h"
#include "cmap.h"
#include "buttons.h"
#include "craft.h"
#include "dial.h"

class ship
  {public :

   int  dx;
   int  dy;
   int  px;
   int  py;
   int  capa;
   int  myid;

   int  x_cap;
   int  y_cap;
   int  x_crew;
   int  y_crew;

   int  u_pic   [14];
   int  unit    [14]; 
   int  num_man;
   bool should_refresh;
   bool is_shown;
   bool with_master;
   bool is_idle;

   ship                 (int id);
   ~ship                ();

   void refresh         (int i);
   void refresh_captain ();
   void refresh_crew    ();
   bool enter           (int id);
   bool leave           (int id);
   void move            (int dx, int dy);
   void eval            ();
   void hit             (int id, int power);
   void show            (int wx, int wy);
   void unshow          (int color);
   bool empty           ();
   bool no_fighter      ();
   void get_crew        (int &n_worker, int &n_fighter, int &n_healer);
   int  num_cata        ();       

 };

bool ship_on_side (int xs, int ys, int ide, int xe, int ye);

#endif
