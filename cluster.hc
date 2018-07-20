
#include "cluster.h"
#include "craft.h"


cluster::cluster (char name [])
  {init_params;
   load_params;
   num_members = 0;

.  init_params
     {for (int i = 0; i < max_types; i++)
        anz [i] = 0;
     }.

.  load_params
     {FILE *f;
      int  type;

      f_open (f, complete (name, ".cluster"), "r"); 
      while (another_record)
        {read_record;
        };
      fclose (f);
    }.

.  read_record
     {fscanf (f, "%d", &anz [type]); 
     }.

.  another_record
    (fscanf (f, "%d", &type) != EOF).

  }

cluster::~cluster ()
  {
  }

int cluster::match (int own_color)
  {int  m_anz   [max_types];
   int  rest;
   int  size;
   bool grabbed [max_objects];

   init;
   pick_up;
   return (size - rest);

.  init
     {rest        = 0;
      size        = 0;
      num_members = 0;
      for (int i = 0; i < max_types; i++)
        {m_anz [i] =  anz [i];
         rest      += anz [i];
         size      += anz [i];
        };
      for (int i = 0; i < max_objects; i++)
        {grabbed [i] = false;
        };
     }.

.  pick_up
     {bool knight_replace;

      knight_replace = false;
      perform_pickup;
      if (rest > 0)
         {knight_replace = true;
          perform_pickup;
         };
     }.

.  perform_pickup
     {for (int i = 0; i < max_objects; i++)
       {check_object;
       };
     }.

.  check_object
     {if (! grabbed          [i] && 
          ! objects->is_free [i] && 
          objects->color [i] == own_color)
         perhaps_grab_object;
     }.

.  perhaps_grab_object
     {int t = objects->type [i];

      if (m_anz [t] > 0 || is_knight_replace)
         grab_man;
     }.

.  is_knight_replace
     (knight_replace && t == object_pawn && m_anz [object_knight] > 0).

.  grab_man
     {rest--;
      if   (knight_replace)
           m_anz [object_knight]--;
      else m_anz [t]--;
      id      [num_members] = i;
      grabbed [i]           = true;
      num_members++;
     }.
 
  }
