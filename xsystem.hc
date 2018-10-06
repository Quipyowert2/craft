#include "stdlib.h"

#include "xsystem.h"
#include "xfile.h"

#define temp_file_name "jobs~"

int batch (char cmd [])
  {int job_no = 0;

   start_cmd;
   get_job_no;
   return job_no;

.  start_cmd
     {char f_cmd [1024];

      sprintf (f_cmd, "%s &", cmd);
      system  (f_cmd);
     }.

.  get_job_no
     {read_job_info;
      read_no;
     }.

.  read_job_info
     {char cmd [128];

      sprintf (cmd, "csh -c \"jobs -l > %s\"", temp_file_name);
      system  (cmd);
     }.

.  read_no
     {FILE *f;
      char d [128];

      f = fopen (temp_file_name, "r");
      fscanf (f, "%127s %d", d, &job_no);
      fclose (f);
     }.
 
  }
