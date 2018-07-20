#include "win.h"
#include "cmap.h"
#include "masks.h"
#include "player.h"
#include "craft_def.h"
#include "object_handler.h"
#include "land.h"
#include "cmap_edit.h"

main (int num_params, char *shell_params [])
  {cmap_edit *m;
   int       h = 1;

   x1; h++;
   x2; h++;
   x3; h++;
   x4; h++;
   x5; h++;
   x6; h++;
   x7; h++;
   x8; h++;
   x9; h++;
   x10;h++;
   x11;h++;
   x12;h++;
   x13;h++;
   x14;h++;
   x15;h++;

.  x1
     {open_d;
      perform_x1;
      save_d;
      delete (m);
     }.
.  x2
     {open_d;
      perform_x2;
      save_d;
      delete (m);
     }.
.  x3
     {open_d;
      perform_x3;
      save_d;
      delete (m);
     }.
.  x4
     {open_d;
      perform_x4;
      save_d;
      delete (m);
     }.
.  x5
     {open_d;
      perform_x5;
      save_d;
      delete (m);
     }.
.  x6
     {open_d;
      perform_x6;
      save_d;
      delete (m);
     }.
.  x7
     {open_d;
      perform_x7;
      save_d;
      delete (m);
     }.
.  x8
     {open_d;
      perform_x8;
      save_d;
      delete (m);
     }.
.  x9
     {open_d;
      perform_x9;
      save_d;
      delete (m);
     }.
.  x10
     {open_d;
      perform_x10;
      save_d;
      delete (m);
     }.
.  x11
     {open_d;
      perform_x11;
      save_d;
      delete (m);
     }.
.  x12
     {open_d;
      perform_x12;
      save_d;
      delete (m);
     }.
.  x13
     {open_d;
      perform_x13;
      save_d;
      delete (m);
     }.
.  x14
     {open_d;
      perform_x14;
      save_d;
      delete (m);
     }.
.  x15
     {open_d;
      perform_x15;
      save_d;
      delete (m);
     }.

.  open_d
     {char name [128];

      sprintf (name, "%s.%d.cmap", shell_params [1], atoi (shell_params [2]));
      m = new cmap_edit (name);
     }.

.  save_d
     {char name [128];

      sprintf    (name,"%s.%d.cmap",shell_params [1],atoi(shell_params [2])+h);
      m->save_as (name);
     }.

.  perform_x1 {t; }.
.  perform_x2 {t; l; }.
.  perform_x3 {l;}.
.  perform_x4 {l;b;}.
.  perform_x5 {b;}.
.  perform_x6 {r; b;}.
.  perform_x7 {r;}.
.  perform_x8 {r;t;}.

.  perform_x9  {l; t; r;}.
.  perform_x10 {t; l; b;}.
.  perform_x11 {l; b; r;}.
.  perform_x12 {t; r; b;}.

.  perform_x13 {l; r; }.
.  perform_x14 {t; b; }.
.  perform_x15 {l; r; b; t;}.

.  r {m->colorize (-dd, 0);m->colorize (-dd, 0);}.
.  l {m->colorize (dd,  0);m->colorize (dd,  0);}.
.  t {m->colorize (0,  dd);m->colorize (0,  dd);}.
.  b {m->colorize (0, -dd);m->colorize (0, -dd);}.

.  dd atoi (shell_params [3]).

  }