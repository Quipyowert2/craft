#include "stdio.h"
#include "limits.h"

#include "xfile.h"
#include "xstring.h"
#include "file_selector.h"
#include "masks.h"


/*----------------------------------------------------------------------*/
/* local data struktures                                                */
/*----------------------------------------------------------------------*/

struct conv 
   {char b0; 
    char b1;
    char b2;
    char b3;
   };

union conv_data
  {conv a;
   int  b;
  };


  
/*----------------------------------------------------------------------*/
/* General functions                                                    */
/*----------------------------------------------------------------------*/

bool f_exists (char file_name [])
  {FILE *f;
   bool is_error;

   f = fopen (file_name, "r");
   is_error = (f == NULL);
   if (! is_error)
      fclose (f);
   return ! is_error;
  }

double d_get (FILE *f, bool &is_eof) 
  {char buf [40];
   int  ptr = 0;
   int  c;

   skip_delimiter;
   while (read_char != ' ' && c != EOF && c != '\n');
   buf [ptr] = '0';
   is_eof = (c == EOF);
   return atof (buf);

.  skip_delimiter
     while (read_char == ' ' || c == '\n')
       ptr = 0.

.  read_char
     (c = (buf [ptr++] = getc (f))).

  }

void f_open (FILE *&f, char name [], char mode [])
  {f = fopen (name, mode);
   check_error;

.  check_error
     {if (mode [0] == 'r' && f == NULL)
         {printf ("1, FILE, file '%s' not existing\n", name);
          fflush (stdout);
          exit   (1);
         };
     }.

  }
      
void f_open_with_extend (FILE *&f, char name [], char mode [], int max_no)
  {int  version;
   char v_name [128];

   get_version;
   f_open (f, v_name, mode);

.  get_version
     {for (version = 0; version < max_no; version++)
        check_v_name;
      if (version >= max_no)
         tell_oh_boy_too_much;
     }.

.  tell_oh_boy_too_much
     {char msg [256];

      sprintf   (msg,
                 "There are more than %d versions of \"%s\"",
                 max_no, name);
      errorstop (1, "XFILE", msg);
     }.

.  check_v_name
     {sprintf (v_name, "%s.%d", name, version);
      if (! f_exists (v_name))
         break;
     }.

  }

char *f_getline (FILE *f, char record [], int max_length)
  {char *r;

   r = fgets (record, max_length, f);
   record [strlen (record) - 1] = 0;
   return r;
  }

time_t f_date (char file_name [])
  {
  }
/*
  {stat status;

   stat (file_name, &status);
   return status.st_ctime;
  }
*/

char *f_name (char full_path [])
  {static char r [1024];
   int         i;

   for (i = strlen (full_path); i > 0 && full_path [i] != '/'; i--)
     {};
   if (full_path [i] == '/')
      i++;
   strcpy (r,substring (full_path, i, strlen (full_path) + 1)); 
   return r;
  }

char *f_path (char full_path [])
  {static char r [1024];
          int  p = 0;

   for (int i = 0; i < strlen (full_path); i++)
     {if (full_path [i] == '/')
         p = i;
     };
   if (full_path [p] == '/')
      p--;
   strcpy (r, substring (full_path, 0, p+1));
   return r;
  }

char *f_tail (char full_path [])
  {static char r [1024];

   if   (f_is_dir (full_path))
        return_last_dir
   else return f_name (full_path);

.  return_last_dir
     {int p;

      for (p = strlen (full_path)-2; p >= 0 && full_path [p] != '/'; p--)
        {};
      strcpy (r, substring (full_path, p+1, strlen (full_path)));
      return r;
     }.

  }

char *f_home_dir (char full_name [])
  {static char result [512];

   sprintf (result, "/home/%s", &full_name [1]);
   return result;
  }

bool f_is_pattern (char f_name [])
  {return (strstr (f_name, "*") != NULL);
  }

bool f_is_dir (char file_name [])
  {return (file_name [strlen (file_name)-1] == '/' || 
           file_name [strlen (file_name)-1] == '.');
  }

bool f_is_home_dir (char full_name [])
  {return full_name [0] == '~';
  }

bool sel_get_name (char name      [],
                   char f_name    [],
                   char f_pattern [],
                   char mode      [])

  {char          pat [256];
   file_selector *fsel;
      
   open_fsel;
   perform_select;
   delete (fsel);
   handle_result;

.  open_fsel
     {strcpy (pat, f_pattern);
      fsel = new file_selector (name, by_fix, by_fix,
                                f_name, pat, is_read_access);
     }.

.  perform_select
     {while (! fsel->eval (f_name))
        {
        };
     }.

.  handle_result
     {perhaps_complete_file_name;
      perhaps_check_overwrite;
      if   (f_name [0] == 0)
           return false;
      else return true;
     }.

.  perhaps_complete_file_name
     {char correct_tail [128];

      strcpy (correct_tail, substring (f_pattern, 1));
      if ((is_write_access || is_read_write_access) && wrong_tail)
         complete_file_name;
     }.

.  wrong_tail
     (strcmp (name_tail, correct_tail) != 0).

.  name_tail 
     (substring (f_name, strlen (f_name) - strlen (correct_tail))).

.  complete_file_name
     {strcat (f_name, correct_tail);
     }.

.  perhaps_check_overwrite
     {if (is_write_access)
         check_overwrite;
     }.

.  check_overwrite
     {if (f_exists (f_name) && ! yes ("overwrite existing file"))
         return false;
     }.

.  is_write_access
     (strcmp (mode, "w") == 0).

.  is_read_access
     (strcmp (mode, "r") == 0).

.  is_read_write_access
     ((strcmp (mode, "rw") == 0) || (strcmp (mode, "wr") == 0)).

  }

char *complete (char name [], char tail [])
  {static char r [256];

   strcpy (r, name);
   if (wrong_tail)
      strcat (r, tail);
   return r;

.  wrong_tail
     (strcmp (name_tail, tail) != 0).

.  name_tail 
     (substring (name, strlen (name) - strlen (tail))).

  }  
 
char *f_postfix (char full_path [])
  {       int  i;
   static char r [256];

   r [0] = 0;
   skip_to_point;
   grab_tail;
   return r;

.  skip_to_point
     {for (i = strlen (full_path); i >= 0; i--)
        if (full_path [i] == '.')
           break;
     }.

.  grab_tail
     {if (i >= 0)
         strcpy (r, substring (full_path, i));
     }.
   
  }

void bprintf (FILE *f, int num_bytes, int i)
  {conv_data c;

   c.b = i;
   if   (num_bytes == 1) 
        fputc (c.a.b3, f); 
   else {fputc (c.a.b3, f);
         fputc (c.a.b2, f);
         fputc (c.a.b1, f);
         fputc (c.a.b0, f);
        };
  }

bool bscanf (FILE *f, int num_bytes, int &i)
  {conv_data c;
   bool      was_eof;
 
   read_data;
   return ! was_eof;

.  read_data
     {if   (num_bytes == 1) 
           get_byte
      else get_int;
     }.

.  get_byte
     {c.b     = 0;
      was_eof = ((c.a.b3 = fgetc (f)) == EOF);
      i       = c.b;
     }.

.  get_int
     {was_eof = ((c.a.b3 = fgetc (f)) == EOF);
      if (! was_eof) was_eof = ((c.a.b2 = fgetc (f)) == EOF);
      if (! was_eof) was_eof = ((c.a.b1 = fgetc (f)) == EOF);
      if (! was_eof) was_eof = ((c.a.b0 = fgetc (f)) == EOF);
      i       = c.b;
     }.

  }

