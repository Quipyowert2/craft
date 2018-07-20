#include "stdio.h"

#include "ship.h"
#include "player.h"
#include "object_handler.h"

ship::ship (int id)
  {myid           = id;
   num_man        = 0;
   capa           = 12;
   should_refresh = false;
   is_shown       = false;
   with_master    = true;
   is_idle        = true;
  }

ship::~ship ()
  {
  }

void ship::show (int wx, int wy)
  {int pno = color_player [objects->color [myid]];

   px       = wx;
   py       = wy;
   is_shown = true;
   for (int i = 0; i < capa; i++)
     refresh (i);
   x_cap  = px;
   y_cap  = py + 5 * (pic_dy + 8);
   x_crew = px + pic_dx + 2;
   y_crew = py + 5 * (pic_dy + 8);
   players [pno]->ship_pics [pic_captain_on]->show (x_cap,  y_cap);   
   players [pno]->ship_pics [pic_crew_on]   ->show (x_crew, y_crew);   
   players [pno]->w_status->tick ();
  } 

void ship::unshow (int color)
  {if (objects->color [myid] == color)
      is_shown = false;
  }

void ship::refresh (int i)
  {int pno = color_player [objects->color [myid]];

   if (is_shown)
      perform_show;

.  perform_show
    {template;
     if (i < num_man && unit [i] != none)
        show_unit;
     players [pno]->w_status->tick ();
     }.

.  template
     {if   (i == 0 && with_master)
           ww->set_color (gray80);
      else ww->set_color (gray60);
      ww->function  (GXcopy);
      ww->fill      (xx, yy-6, pic_dx, pic_dy+6);
     }.

.  show_unit
     {players [pno]->ship_pics [u_pic [i]]->show (xx, yy);
      if (objects->is_marked [unit [i]])
         {ww->set_color (red);
          ww->box       (xx, yy, xx + pic_dx-1, yy + pic_dy-1);
         };
      show_state;
     }.

.  show_state
     {ww->set_color (black);
      ww->fill      (xx, yy-6, pic_dx-1, 6);
      if      (hh < 25) ww->set_color (red);
      else if (hh < 50) ww->set_color (yellow);
      else              ww->set_color (green);
      ww->fill (xx+2, yy - 5, bar_dx, 4);
     }.

.  bar_dx
     (int) ((double) (pic_dx - 4) / 100.0 * (double)(hh)).

.  hh  objects->health [unit [i]].
.  ww  players [pno]->w_status.

.  xx  ((i % 3) * (pic_dx+2) + px).
.  yy  ((i / 3) * (pic_dy+8) + py).

  }

bool ship::enter (int id)
  {if (num_man < capa)
      perform_enter;

.  perform_enter
     {int x;
      int y;
      int pno = color_player [objects->color [myid]];

      unit  [num_man] = id;
      u_pic [num_man] = objects->pic [id];
      players [pno]->mark (id, false);
      num_man++;      
      should_refresh  = true;
     }.

  }

bool ship::leave (int id)
  {int i;

   get_i;
   if   (i < num_man)
        perform_remove
   else return false;

.  perform_remove
     {remove_from_field;
      remove_from_mans;
      should_refresh = true;
      return true;
     }.

.  remove_from_field
     {unit [i] = none;
     }.

.  remove_from_mans
     {for (int j = i; j < num_man - 1; j++)
        {u_pic [j] = u_pic [j+1];
         unit  [j] = unit  [j+1];
        };
      num_man--;
     }.
      
.  get_i
     {for (i = 0; i < num_man; i++)
        if (unit [i] == id)
            break;
     }.

  }

void ship:: eval ()
  {int xe;
   int ye;
   int b;
   int pno = color_player [objects->color [myid]];

   perhaps_reshow;
   perhaps_refresh;
   if      (players [pno]->w_status->is_mouse (xe, ye, b) && inside)
           handle_eval
   else if (players [pno]->w_status->is_mouse (xe, ye, b) && on_cap)
           handle_cap
   else if (players [pno]->w_status->is_mouse (xe, ye, b) && on_crew)
           handle_crew
   else    return;

.  on_cap
    (x_cap <= xe && xe <= x_cap + pic_dx &&
     y_cap <= ye && ye <= y_cap + pic_dy).

.  on_crew
    (x_crew <= xe && xe <= x_crew + pic_dx &&
     y_crew <= ye && ye <= y_crew + pic_dy).
     
.  perhaps_reshow
     {for (int i = 0; i < num_man; i++)
        if (objects->pic [unit [i]] != u_pic [i])
           {u_pic [i] = objects->pic [unit [i]];
            refresh (i);
           };
     }.

.  perhaps_refresh
     {if (should_refresh)
         show (px, py);
      should_refresh = false;
     }.

.  inside
     (px <= xe && xe <= px + 3 * (pic_dx + 2) &&   
      py <= ye && ye <= py + 4 * (pic_dy + 8)).

.  handle_eval
     {int d;
      int ind;

      players [pno]->w_status->mouse (d, d, xe, ye, b);
      get_ind;
      if (ind < num_man )
         handle_event;
     }.

.  get_ind
      {ind = capa + 3; 
       for (int i = 0; i < num_man; i++)
        if (xe >= xx && xe <= xx + pic_dx && ye >= yy && ye <= yy + pic_dy)
           {ind = i;
            break;
           };
     }.

.  xx  ((i % 3) * (pic_dx + 2) + px).
.  yy  ((i / 3) * (pic_dy + 8) + py).

.  handle_event
     {int pno = color_player [objects->color [myid]];

      if      (b == button1press) handle_mark_first
      else if (b == button2press) handle_mark_toggle
     }.

.  handle_mark_first
     {handle_unmark;
      players [pno]->mark (unit [ind], true);
      refresh (ind);
     }.

.  handle_mark_toggle
     {players [pno]->mark (unit [ind], ! objects->is_marked [unit [ind]]);
      refresh (ind);
     }.

.  handle_unmark
     {for (int i = 0; i < num_man; i++)
        {players [pno]->mark (unit [ind], false);
         refresh (i);
        };
     }.

.  handle_cap
     {int d;

      players [pno]->w_status->mouse (d, d, xe, ye, b);
      if (b == button1press && num_man > 0)
         {players [pno]->mark (unit [0], ! objects->is_marked [unit [0]]);
          refresh (0);
         }; 
     }.

.  handle_crew
     {int d;

      players [pno]->w_status->mouse (d, d, xe, ye, b);
      if (b == button1press && num_man > 0)
         handle_crew_marking;
     }.

.  handle_crew_marking
     {for (int i = 1; i < num_man; i++)
        {players [pno]->mark (unit [i], ! objects->is_marked [unit [i]]);
         refresh (i);
        };
     }.

  }

void ship::move (int dx, int dy)
  {for (int i = 0; i < num_man; i++)
     move_man;

.  move_man
     {int id = unit [i];

      objects->x  [id] += dx;
      objects->y  [id] += dy;
      objects->wx [id] = objects->x_center (objects->x [id]);
      objects->wy [id] = objects->y_center (objects->y [id]);
     }.

  }

void ship::hit (int idh, int power)
  {if   (on_the_ship)
        perform_ship_hit
   else perform_man_hit;

.  on_the_ship
     num_man ==  0 || i_random (0, 100) > 90.

.  perform_man_hit
     {int i;
      int id;

      get_i;
      id = unit [i];
      if (0 <= id && id < max_objects && object_should_be_hit)
         handle_obj;
     }.

.  object_should_be_hit
     (! objects->is_free [id]                 &&
      objects->type [id] != object_zombi      &&
      objects->type [id] != object_ship_zombi && 
      objects->type [id] != object_schrott).

.  handle_obj
     {objects->hit (idh, id, power);
      refresh (i);
      if (objects->health [id] <= 0)
         {leave (id);
          if (i == 0)
             with_master = false;
         };
     }.

.  get_i
     {choose_any;
     }.

/*
     {bool any_man = false;

      check_healer;
      if (! any_man) check_cata;
      if (! any_man) choose_any;
     }.
*/

.  check_healer
     {for (i = 0; i < num_man; i++)
        if (objects->type [unit [i]] == object_doktor)
           {any_man = true;
            break;
           };
     }.

.  check_cata
     {for (i = 0; i < num_man; i++)
        if (objects->type [unit [i]] == object_cata)
           {any_man = true;
            break;
           };
     }.

.  choose_any
     {i = i_random (0, num_man-1);
/*
      i = i_random (0, i_min (3, num_man-1));
*/
     }.

.  perform_ship_hit
     {int pno = color_player [objects->color [myid]];

      objects->health  [myid] -= i_max (1, power - amour_ship1);
      objects->version [myid]++;
      if (objects->health [myid] <= 0)
         sink_ship;
     }.

.  sink_ship
     {objects->new_order (myid, cmd_die, 0, 0);
     }.

  }

bool ship::empty ()
  {for (int i = 0; i < num_man; i++)
     check_u;
   return true;

.  check_u
     {int u = objects->type [unit [i]];
     
      if (u != object_schrott && u != object_zombi)
         return false;
     }.
  }

bool ship::no_fighter ()
  {if   (empty ())
        return true;
   else check_mans;

.  check_mans
     {for (int i = 0; i < num_man; i++)
        check_man;
      return true;
     }.

.  check_man
     {int t = objects->type [unit [i]];

      if (t == object_cata   ||
          t == object_archer ||
          t == object_pawn   ||
          t == object_knight)
         return false;
     }. 

  }

void ship::get_crew (int &n_worker, int &n_fighter, int &n_healer)
  {n_worker  = 0;
   n_fighter = 0;
   n_healer  = 0;
   for (int i = 1; i < num_man; i++)
     switch (objects->type [unit [i]])
        {case object_worker : n_worker++;  break;
         case object_pawn   :
         case object_knight :
         case object_archer :
         case object_cata   : n_fighter++; break;
         case object_doktor : n_healer++;  break;
        };
  }

int ship::num_cata ()
  {int n_cata = 0;

   for (int i = 1; i < num_man; i++)
     if (objects->type [unit [i]] == object_cata)
        n_cata++;
   return n_cata;
  }

bool ship_on_side (int xs, int ys, int ide, int xe, int ye)
  {if   (ide == none)
        return false;
   if   (objects->type [ide] == object_ship1)
        handle_ship_to_ship
   else handle_ship_to_man;

.  handle_ship_to_ship
     {if (i_abs (xe - xs) > 3) return false;
      if (i_abs (ye - ys) > 3) return false;
      return true;
     }.

.  handle_ship_to_man
     {if (xe < xs && i_abs (xe - xs) > 1) return false;
      if (ye < ys && i_abs (ye - ys) > 1) return false;
      if (i_abs (xe - xs) > 3)            return false;
      if (i_abs (ye - ys) > 3)            return false;
      return true;
     }.

  }
