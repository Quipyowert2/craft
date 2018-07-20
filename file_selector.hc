#include "file_selector.h"
#include "xstring.h"
#include "pattern_match.h"

#define w_dx        320
#define w_dy        400

#define cancel_x    120
#define cancel_y    370

#define sel_x       10
#define sel_y       100
#define sel_dx      280
#define sel_dy      260
  
#define name_x      10
#define name_y      10
#define name_dx     292
#define name_dy     20

#define pattern_x   10
#define pattern_y   35
#define pattern_dx  292
#define pattern_dy  20
  
file_selector::file_selector (char p_name [],
                              int  x,
                              int  y,
                              char full_file_name [],
                              bool must_exist)

  {store_params;
   set_defaults;
   open_w;
   open_buttons;
   open_getlines;
   get_file_list ();
   open_selector;
   w->tick ();

.  store_params
     {strcpy (name, p_name);
      strcpy (file_name, full_file_name);
      strcpy (file_pattern, "");
      is_force_exist = must_exist;
     }.

.  set_defaults
     {num_files = 0;
     }.

.  open_w
     {w = new win (name, "", x, y, w_dx, w_dy);
      w->set_color (win_default_c ("filesel_background"));
      w->fill      (0, 0, w_dx, w_dy);
     }.

.  open_buttons
     {cancel = new button (w, "cancel", cancel_x, cancel_y);
     }.

.  open_getlines
     {get_name    = new getline ("get_name", w, file_name,
                                 name_x, name_y, name_dx, name_dy,
                                 true);
      get_pattern = new getline ("get_pattern", w, file_pattern,
                                 pattern_x, pattern_y, pattern_dx, pattern_dy,
                                 true);
     }.

.  open_selector
     {sel = new selector ("", w,
                          num_files, file_list, 
                          sel_x, sel_y, sel_dx, sel_dy, false, true);

     }.   

  }

file_selector::file_selector (char p_name [], 
                              int  x,
                              int  y,
                              char p_file_name    [],
                              char p_file_pattern [],
                              bool must_exist)

  {store_params;
   set_defaults;
   open_w;
   open_buttons;
   open_getlines;
   get_file_list ();
   open_selector;
   w->tick ();

.  store_params
     {strcpy (name, p_name);
      strcpy (file_name, p_file_name);
      strcpy (file_pattern, p_file_pattern);
      is_force_exist = must_exist;
     }.

.  set_defaults
     {num_files = 0;
     }.

.  open_w
     {w = new win (name, "", x, y, w_dx, w_dy);
      w->set_color (win_default_c ("filesel_background"));
      w->fill      (0, 0, w_dx, w_dy);
     }.

.  open_buttons
     {cancel = new button (w, "cancel", cancel_x, cancel_y);
     }.

.  open_getlines
     {get_name    = new getline ("get_name", w, file_name,
                                 name_x, name_y, name_dx, name_dy,
                                 true);
      get_pattern = new getline ("get_pattern", w, file_pattern,
                                 pattern_x, pattern_y, pattern_dx, pattern_dy,
                                 true);
     }.

.  open_selector
     {sel = new selector ("", w,
                          num_files, file_list, 
                          sel_x, sel_y, sel_dx, sel_dy, false, true);

     }.   

  }

file_selector::~file_selector ()
  {delete (sel);
   delete (get_name);
   delete (get_pattern);
   delete (cancel);
   delete (w);
  }

void file_selector::get_file_list ()
  {set_busy_cursor;
   get_file_list;
   read_file_list;
   update_state;
   set_ready_cursor;

.  set_busy_cursor
    {w->set_cursor (XC_watch);
     w->tick       ();
    }.

.  set_ready_cursor
     {w->set_cursor (XC_arrow);
      w->tick       ();
     }. 

.  update_state
     {strcpy (last_name,    file_name);
      strcpy (last_pattern, file_pattern);
     }.

.  get_file_list
     {char cmd [512];

      if   (strlen (file_name) == 0)
           sprintf (cmd, "csh -f -c \"ls -F > filesel.temp\"");
      else sprintf (cmd, "csh -f -c \"ls -F %s > filesel.temp\"", file_name);
      system (cmd);
     }.

.  file_path
     f_path (file_name).

.  read_file_list
     {FILE *l_file;
      char f_line [1024];

      l_file    = fopen ("filesel.temp", "r");
      num_files = 0;
      store_backlink;
      while (another_name)
        if (p_match (f_line, file_pattern) || f_is_dir (f_line))
           store_name;
      perhaps_skip_empty_msg;
      fclose (l_file);
     }.

.  store_backlink
     {strcpy (file_list [0], "..");
      num_files++;
     }.

.  perhaps_skip_empty_msg
     {if (num_files == 4 && 
          strcmp (file_list [3], "found") == 0 &&
          strcmp (file_list [2], "not")   == 0)
      num_files = 0;
      if (num_files == 4 && 
          strcmp (file_list [3], "match.") == 0 &&
          strcmp (file_list [2], "No")     == 0)
      num_files = 0;
     }.

.  another_name
     (fscanf (l_file, "%s", f_line) != EOF).

.  store_name
     {strcpy (act_f_name, f_tail (f_line));
      num_files = i_min (max_selector_cases-1, num_files + 1);
     }.

.  act_f_name
     file_list [num_files].

  }

bool file_selector::eval (char full_name [])
  {bool over = false;
   char old_dir [512];

   w->mark_mouse ();
   store_current_dir;
   check_buttons;
   check_selector;
   check_getlines;
   w->scratch_mouse ();
   return over;

.  store_current_dir
     {if   (strlen (file_name) == 0)
           strcpy (old_dir, ".");
      else strcpy (old_dir, file_name);
     }.

.  check_buttons
     {if (cancel->eval ())
         no_result;
     }.

.  no_result
     {strcpy (full_name, "");
      over = true;
     }.

.  check_getlines
     {handle_get_pattern;
      handle_get_name;
     }.

.  handle_get_pattern
     {if (get_pattern->eval () && any_change)
         refresh_selector;
     }.

.  any_change
     (strcmp (file_pattern, last_pattern) != 0).

.  refresh_selector
     {get_file_list  ();
      sel->set_cases (num_files, file_list);
     }.

.  handle_get_name
     {if (get_name->eval ())
         handle_new_file_name;
      perhaps_home_request;
     }.

.  perhaps_home_request
     {if (strpos (file_name, '~') >= 0)
         handle_home_request;
     }.

.  handle_home_request
     {strcpy (file_name, substring (file_name, strpos (file_name, '~')));
      get_name->refresh ();
     }.

.  handle_new_file_name
     {if      (f_is_dir (file_name))
              handle_change_dir
      else if (f_is_home_dir (file_name))
              handle_to_home_dir
      else    handle_full_file_name;
      get_name->refresh ();
      refresh_selector;
     }.

.  handle_to_home_dir
     {strcpy (file_name, f_home_dir (file_name));
      strcat (file_name, "/");
     }.

.  handle_change_dir
     {if (strcmp (file_name, "..") == 0)
           cd_to_previous;
      get_name->refresh ();
     }.

.  cd_to_previous
     {FILE *f;
      char cmd [1024];

      sprintf (cmd,
               "csh -f -c \"cd %s; pushd .. > %s/filesel.temp\"",
               old_dir,
               getenv ("PWD"));
      system  (cmd);
      f = fopen ("filesel.temp", "r");
      fscanf    (f, "%s", file_name);
      strcat    (file_name, "/");
      fclose    (f);
     }.

.  handle_full_file_name
     {strcpy (full_name, file_name);
      over = (strlen (file_name) != 0 && file_valid);
      if   (! over)
           strcpy (file_name, last_name);
      else add_to_history;
     }.

.  add_to_history
     {get_name->hist->push (file_name);
     }.

.  file_valid
     (f_exists (full_name) || ! is_force_exist).

.  check_selector
     {int case_no;

      if (sel->eval (case_no))
         handle_sel_action;
     }.

.  handle_sel_action
     {if   (strcmp (act_case_string, "..") == 0)
           strcpy (file_name, "..");
      else strcat (file_name, act_case_string);
      get_name->refresh ();
      handle_new_file_name;
     }.

.  act_case_string
     file_list [case_no].

  }


