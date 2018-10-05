#ifndef file_selector_h
#define file_selector_h

#include "bool.h"
#include "win.h"
#include "selector.h"
#include "getline.h"
#include "buttons.h"

#define max_file_selector_cases 1000

class file_selector
  {public:

   char     name [128];
   win      *w;

   selector *sel;
   getline  *get_name;
   getline  *get_pattern;

   int      num_files;
   char     file_list [max_selector_cases][128];

   bool     is_force_exist;
   char     file_pattern [128];
   char     file_name    [256];

   char     last_pattern [128];
   char     last_name    [256];
   char     last_path    [256];

   button   *cancel;
  
   file_selector      (char name [], 
                       int  x,
                       int  y,
                       char file_name    [],
                       char file_pattern [],
                       bool must_exists = true);

   file_selector      (const char name [],
                       int  x,
                       int  y,
                       char full_file_name [],
                       bool must_exist = true);

   ~file_selector     ();

   bool eval          (char file_name []);

   void get_file_list ();

  }; 

#endif

