#include "formation.h"
#include "sector_map.h"

formation::formation (char name [])
  {strcpy (f_name, name);
   load   (f_name);
  } 

formation::~formation ()
  {  
  }

void formation::save ()
  {save (f_name);
  }

void formation::save (char name [])
  {FILE *f;

   open_f;
   perform_save;
   fclose (f);

.  open_f
     {f_open (f, complete (name, ".formation"), "w");
     }.

.  perform_save
     {save_f;
      save_men;
     }.

.  save_men
     {for (int i = 0; i < num; i++)
        fprintf (f, "%d %d %d %d\n", type [i], prio [i], x [i], y [i]); 
     }.

.  save_f
     {for (int i = 0; i < 8; i++)
        {fprintf (f,
                  "%d %d %d %d\n",
                  s  [i],
                  l  [i],
                  ss [i],
                  ll [i]);
        };
     }.

  }

void formation::load (char name [])
  {FILE *f;

   open_f;
   init ();
   perform_load;
   fclose (f);

.  open_f
     {f_open (f, complete (name, ".formation"), "r");
     }.

.  perform_load
     {load_f;
      load_men;
     }.

.  load_f
     {for (int i = 0; i < 8; i++)
        {fscanf (f,
                 "%d %d %d %d",
                 &s  [i],
                 &l  [i],
                 &ss [i],
                 &ll [i]);
        };
     }.

.  load_men
     {while (another_record)
        {read_record;
        };
    }.

.  another_record
     fscanf (f, "%d %d %d %d",&type[num],&prio[num],&x[num],&y[num]) != EOF.

.  read_record
     {num++;
     }.

  }
       
void formation::edit ()
  {
  }

void formation::init ()
  {num = 0;
  }
 
int formation::match (sector_map *sm)
  {int r = 0;

   for (int i = 0; i < 8; i++)
     check_dir;
   return r;

.  check_dir
     {check_s;
      check_l;
     }.

.  check_s
     {if (sm->s [i] > s [i] || sm->ss [i] > ss [i])
         {r += 10 * i_max (0, sm->s  [i] - s  [i]);    
          r += 10 * i_max (0, sm->ss [i] - ss [i]);    
         };
     }.

.  check_l
     {if (sm->l [i] > l [i] || sm->ll [i] > ll [i])
         {r += i_max (0, sm->l  [i] - l  [i]);    
          r += i_max (0, sm->ll [i] - ll [i]);    
         };
     }.

  }

