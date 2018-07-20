#include "string.h"
#include "stdio.h"

#include "history.h"
#include "xstring.h"
#include "win.h"
#include "selector.h"

history::history (char   h_name [],
                  button *cancel)

  {cancel_button = cancel;
   strcpy (name, h_name);
   load   ();
  }

history::~history ()
  {save ();
  }

void history::load ()
  {char f_name [128];

   num_entries = 0;
   calc_f_name;
   if (f_exists (f_name))
      perform_load;

.  calc_f_name
     {sprintf (f_name, "%s.hist", name);
     }.

.  perform_load
     {FILE *f;

      f = fopen (f_name, "r");
      load_records;
      fclose (f);
     }.

.  load_records
     {while (num_entries < history_size && another_record)
        {num_entries++;
        };
     }.

.  another_record
     (f_getline (f, entry [num_entries], history_entry_length) != NULL).
   
  }

void history::save ()
  {FILE *f;

   open_f;
   save_records;
   fclose (f);

.  open_f
     {char f_name [128];

      sprintf (f_name, "%s.hist", name);
      f = fopen (f_name, "w");
     }.

.  save_records
     {for (int i = 0; i < num_entries; i++)
        fprintf (f, "%s\n", entry [i]);
     }.

  }

void history::push (char s [])
  {
  }

char *history::top ()
  {static char result [history_entry_length];

   calc_result;
   return result;

.  calc_result
     {if   (num_entries > 0)
           strcpy (result, entry [0]);
      else strcpy (result, "");
     }.

  }

char *history::select (int x, int y, int dx, int dy) 
  {static char     result [history_entry_length];
          selector *sel;
          win      *w;
          char     case_string [max_selector_cases][128];
         
   open_sel;
   perform_sel;
   delete (sel);
   delete (w);
   return result;
    
.  open_sel
     {char f_name [128];

      fill_cases;
      sprintf (f_name, "%s.hist", name);
      w   = new win      (f_name, "", x, y, dx, dy);
      sel = new selector (f_name,w,num_entries,case_string, 0, 0, dx-16, dy);
     }.

.  fill_cases
     {for (int i = 0; i < num_entries; i++)
        strcpy (case_string [i], entry [i]);
     }.

.  perform_sel
     {int  case_no;
      bool is_quit = false;

      while (! sel->eval (case_no, is_quit) && ! is_quit)
        {check_cancel;
        };
      if   (is_quit)
           strcpy (result, "");
      else {strcpy (result, entry [case_no]); 
            push   (result);
           }     
     }.

.  check_cancel
     {if (cancel_button != 0)
         is_quit = cancel_button->eval ();
     }.

  }
