#include "win.h"
#include "cmap.h"
#include "masks.h"
#include "player.h"
#include "craft_def.h"
#include "object_handler.h"
#include "land.h"
#include "xfile.h"

char           land_name [128];

int            landscape [max_land_dx][max_land_dy];
int            landhight [max_land_dx][max_land_dy];
int            landpic   [max_land_dx][max_land_dy];
int            landscape_dx;
int            landscape_dy;

int            unit      [max_land_dx][max_land_dy];
int            upic      [max_land_dx][max_land_dy][8];

int            color_player [max_cols];
int            player_color [max_players];

int            ticker;

bool           is_battle;

land_prop      land_properties [max_land_types]; 

object_handler *objects;

player         *players [max_players];
int            num_players;

char           host [max_players][128];
char           name [max_players][128];

/*--- main ------------------------------------------------------------------*/

void init_craft (int  anz_players,
                 char host [max_players][128],
                 char name [max_players][128])

  {store_params;
   init_ticker;
   load_land_props ();
   load_land       (land_name);
   init_land_units ();
   load_troups;
   init_players;
   load_units      (land_name);

.  init_ticker
     {ticker = 0;
     }.

.  store_params
     {num_players = anz_players;
     }.

.  init_players
     {for (int i = 0; i < num_players; i++)
        {if (i == 0) players [i] = new player (name [i], host [i], red);
         if (i == 1) players [i] = new player (name [i], host [i], blue);
        };
      color_player [red]  = 0;
      color_player [blue] = 1;
      player_color [0]    = red;
      player_color [1]    = blue;
      players [0]->initial_display ();
     }.

.  load_troups
     {objects = new object_handler ();
     }.

  }

void finish_craft ()
  {for (int i = 0; i < num_players; i++)
     delete (players [i]);
   delete (objects);
  }

void set_initial_objects ()
  {
  }

main (int num_params, char *shell_params [])
  {init_players;
   set_initial_objects ();
   if   (is_new)
        gen_new
   else perform_edit;
   finish_craft ();

.  perform_edit
     {init_craft (num_params / 2, host, name);
      players [0]->edit ();
     }.

.  is_new
     ! f_exists (complete (land_name, ".land")).

.  gen_new
     {int dx;
      int dy;

      get_dx_dy;
      new_land (land_name, dx, dy);
     }.

.  get_dx_dy
     {printf ("dx dy :\n");
      scanf  ("%d %d", &dx, &dy);
     }.

.  init_players
     {get_params;
      strcpy (land_name, shell_params [1]);
     }.

.  get_params
     {if   (num_params < 3)
           hua_shortcut
      else analyse_cmd_line;
     }.

.  hua_shortcut
     {strcpy (host [0], "gotland");
      strcpy (name [0], "hua");
      num_params = 2;
     }.

.  analyse_cmd_line
     {for (int i = 0; i < num_params/2; i++)
        {strcpy (name [i], shell_params [i * 2 + 1]);
         strcpy (host [i], shell_params [i * 2 + 2]);
        };
     }.

.  exec_craft
     {bool quit = false;

      while (! quit)
        cycle;
     }.

.  cycle
     {read_cmds;
      exec_objects;
      check_over;
     }.

.  read_cmds
     {for (int i = 0; i < num_players; i++)
        read_player_cmd;
     }.

.  read_player_cmd 
     {int cmd [max_marked];
      int x   [max_marked];
      int y   [max_marked];
      int id  [max_marked];
      int num;

      players [i]->get_cmds (quit, num, cmd, id, x, y);
      perhaps_exec_player_cmd;
     }.

.  perhaps_exec_player_cmd
     {for (int i = 0; i < num; i++)
        exec_player_cmd;
     }.

.  exec_player_cmd
     {objects->new_order (id [i], cmd [i], x [i], y [i]);
     }.

.  exec_objects
     {for (int i = 0; i < 3; i++)
        objects->exec ();
     }.

.  check_over
     {for (int i = 0; i < num_players; i++)
        if (players [i]->num_mans <= 0)
           handle_game_over;
     }.

.  handle_game_over
     {char msg [128];

      sprintf (msg, "%s lost all his man\n", name [i]);
      for (int i = 0; i < num_players; i++)
        players [i]->inform (msg);
      quit = true;
     }.

  }