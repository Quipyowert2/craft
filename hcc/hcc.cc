#include "bool.h"
#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "ctype.h"

#define max_refinements 10000
#define max_src_lines   10000

char *src_stat       [max_src_lines];
bool *src_mode       [max_src_lines];
bool is_ref_line     [max_src_lines];

char *ref_name       [max_refinements];
int  ref_start       [max_refinements];
int  ref_end         [max_refinements];
int  ref_start_line  [max_refinements];
int  ref_end_line    [max_refinements];
int  ref_scope_start [max_refinements];
int  ref_scope_end   [max_refinements];

int  last_obj_c;
int  line_cor        [max_src_lines][2];
int  obj_line_no;

int  open_bracket_line;
int  open_string_line;
int  open_char_line;
int  open_sl_comment_line;
int  open_comment_line;

int  num_refs;
int  num_src_lines;

int  ref_search_base;

FILE *obj;
FILE *src;



void f_open (FILE *&f, const char name [], const char mode [])
  {f = fopen (name, mode);
    /* check_error */      {if (mode [0] == 'r' && f == NULL)
         {printf ("1, FILE, file '%s' not found\n", name);
          fflush (stdout);
          exit   (1);
         };
     };

  }


char *substring (char s [], int from)
  {static bool is_init = false;
   static char *result;

    /* perhaps_delete_old_result */      {if (is_init)
         delete (result);
     };
    /* calc_new_result */      {result  = new char [strlen (s) - from + 2];
      is_init = true;
      strcpy (result, &s [from]);
     };
   return result;



  }

char *substring (const char s [], int from, int to)
  {static bool is_init = false;
   static char *result;

    /* perhapss_delete_old_result */      {if (is_init)
         delete (result);
     };
    /* calcc_new_result */      {int i;

      result  = new char [to - from + 2];
      is_init = true;
      for (i = from; i < to; i++)
        result [i-from] = s [i];
      result [i-from] = 0;
     };
   return result;



  }

void changeall (char s           [], 
                int  max_length_of_s,
                const char tmplate     [],
                char replacement [])

  {char *pos;

   while ((pos = strstr (s, tmplate)) != NULL)
      /* perform_substitute */      { /* delete_tmplate */      {char *pp = pos;

      while (*(pp + strlen (tmplate)) != 0)
        {*(pp) = *(pp + strlen (tmplate));
         pp++;
        };
      *pp = 0;
     };
       /* insert_replacement */      {if (strlen (s) + strlen (replacement) < max_length_of_s)
          /* perform_insert */      {char buffer [max_length_of_s];
      char *pp = s;
      int  i   = 0;

      while (pp != pos)
        buffer [i++] = *(pp++);
      buffer [i] = 0;
      strcat (buffer, replacement);
      i = strlen (buffer);
      while (*pp != 0)
        buffer [i++] = *(pp++);
      buffer [i] = 0;
      strcpy (s, buffer);
     };
     };
     };





  }
 
char *complete (char name [], const char tail [])
  {static char r [256];

   strcpy (r, name);
   if ( /* wrong_tail */      (strcmp ( /* name_tail */ 
     (substring (name, strlen (name) - strlen (tail))), tail) != 0))
      strcat (r, tail);
   return r;



  }  

void dump_refs ()
  {for (int r = 0; r < num_refs; r++)
      /* dump_ref */      {printf ("%40s       %5d %5d : %5d %5d <%5d %5d>\n",
              ref_name        [r],
              ref_start_line  [r],
              ref_end_line    [r],
              ref_start       [r],
              ref_end         [r],
              ref_scope_start [r],
              ref_scope_end   [r]);
     };
 

  }

void dump_src ()
  {for (int i = 0; i < num_src_lines; i++)
     {printf ("%d : %s", is_ref_line [i], src_stat [i]);
      printf ("   ");
      for (int j = 0; j < strlen (src_stat [i]); j++)
        if   (src_mode [i][j])
             printf ("-");
        else printf (" ");
      printf ("\n");
     };  
  }

void dump_line_cor ()
  {for (int i = 0; i < obj_line_no; i++)
     {printf ("%5d %5d\n", line_cor [i][0], line_cor [i][1]);
     };
  }

void pass_1_error (int line_no, const char msg [], int l)
  {char err_msg [256];
   char ii      [128];

   sprintf   (ii, "%d", l);
   strcpy    (err_msg, msg);
   changeall (err_msg, 255, "$", ii);
   fclose    (src);
   printf    ("error : %d : %s\n", line_no, err_msg);
   exit      (1);
  }

void pass_1_error (int line_no, const char msg [])
  {fclose (src);
   printf ("error : %d : %s\n", line_no, msg);
   exit   (1);
  }

bool pass_1 (char src_name [])
  {bool inside_comment;
   bool inside_prc;
   int  symbol_no;
   int  line_no;
   char last_none_sep_sym;
   char last_sym;
   char last_last_sym;
   int  last_ref_sym_line;
   int  last_ref_sym_no;
   char sym;
   int  nested_brackets;
   bool inside_refinement;
   bool inside_string;
   bool inside_char;
   bool inside_sl_comment;
   char line_buffer [1024];
   bool line_mode   [1024];
   int  line_length;
   int  proc_base;
   int  ref_base;
 
    /* open_src_file */      {f_open (src, complete (src_name, ".hc"), "r");
     };
    /* init_symbol_table */      {num_refs          = 0;
      inside_prc        = false;  
      symbol_no         = 0;
      line_no           = 0;
      inside_comment    = false;
      last_none_sep_sym = 0;
      sym               = 0;
      nested_brackets   = 0;
      inside_refinement = false;
      line_buffer [0]   = 0;
      line_length       = 0;
      inside_string     = false;
      inside_char       = false;
      inside_sl_comment = false;
     };
    /* scan_file */      { /* get_sym */      {if (sym != ' ' && sym != '\n')
          /* handle_last_non_sep_symbol */      {last_none_sep_sym = sym;
      if (sym != '.')
         {last_ref_sym_line = line_no;
          last_ref_sym_no   = line_length;
         };
     };
      last_last_sym               = last_sym;
      last_sym                    = sym;
      sym                         = fgetc (src);
      line_mode   [line_length]   = inside_string     ||
                                    inside_char       ||
                                    inside_sl_comment ||
                                    inside_comment;
      if ( /* another_sym */      (sym != EOF))
         line_buffer [line_length++] = sym;
      line_buffer [line_length]   = 0;
      symbol_no++;
      if (sym == '\n')
          /* new_line */      {src_stat    [line_no] = new char [line_length + 1];
      src_mode    [line_no] = new bool [line_length + 1];
      strcpy (src_stat [line_no], line_buffer);
      memcpy (src_mode [line_no], line_mode, line_length * sizeof (bool));
      line_buffer [0]       = 0;
      line_length           = 0;
      is_ref_line [line_no] = inside_refinement;
      line_no++;
      num_src_lines         = line_no;
/*      if (num_src_lines > max_src_lines)  
	printf ("too many src_lines\n");
*/

     };
       /* handle_brackets */      {if (! inside_sl_comment &&
          ! inside_comment    &&
          ! inside_string     &&
          ! inside_char)
          /* count_brackets */      {if (sym == '{') nested_brackets++;
      if (sym == '}') nested_brackets--;
     };
     };
    };
      while ( /* another_sym */      (sym != EOF))
        { /* handle_sym */      {if      (inside_comment)       /* skip_to_end_of_comment */      {if (sym == '/' && last_sym == '*')
         {inside_comment          = false;
          line_mode [line_length] = true;
         };
       /* get_sym */      {if (sym != ' ' && sym != '\n')
          /* handle_last_non_sep_symbol */      {last_none_sep_sym = sym;
      if (sym != '.')
         {last_ref_sym_line = line_no;
          last_ref_sym_no   = line_length;
         };
     };
      last_last_sym               = last_sym;
      last_sym                    = sym;
      sym                         = fgetc (src);
      line_mode   [line_length]   = inside_string     ||
                                    inside_char       ||
                                    inside_sl_comment ||
                                    inside_comment;
      if ( /* another_sym */      (sym != EOF))
         line_buffer [line_length++] = sym;
      line_buffer [line_length]   = 0;
      symbol_no++;
      if (sym == '\n')
          /* new_line */      {src_stat    [line_no] = new char [line_length + 1];
      src_mode    [line_no] = new bool [line_length + 1];
      strcpy (src_stat [line_no], line_buffer);
      memcpy (src_mode [line_no], line_mode, line_length * sizeof (bool));
      line_buffer [0]       = 0;
      line_length           = 0;
      is_ref_line [line_no] = inside_refinement;
      line_no++;
      num_src_lines         = line_no;
/*      if (num_src_lines > max_src_lines)  
	printf ("too many src_lines\n");
*/

     };
       /* handle_brackets */      {if (! inside_sl_comment &&
          ! inside_comment    &&
          ! inside_string     &&
          ! inside_char)
          /* count_brackets */      {if (sym == '{') nested_brackets++;
      if (sym == '}') nested_brackets--;
     };
     };
    };
     }
      else if ( /* is_comment */      (sym == '*' && last_sym == '/'))           /* start_new_comment */      {inside_comment            = true;
      open_comment_line         = line_no;                     
      line_mode [line_length-1] = true;
       /* get_sym */      {if (sym != ' ' && sym != '\n')
          /* handle_last_non_sep_symbol */      {last_none_sep_sym = sym;
      if (sym != '.')
         {last_ref_sym_line = line_no;
          last_ref_sym_no   = line_length;
         };
     };
      last_last_sym               = last_sym;
      last_sym                    = sym;
      sym                         = fgetc (src);
      line_mode   [line_length]   = inside_string     ||
                                    inside_char       ||
                                    inside_sl_comment ||
                                    inside_comment;
      if ( /* another_sym */      (sym != EOF))
         line_buffer [line_length++] = sym;
      line_buffer [line_length]   = 0;
      symbol_no++;
      if (sym == '\n')
          /* new_line */      {src_stat    [line_no] = new char [line_length + 1];
      src_mode    [line_no] = new bool [line_length + 1];
      strcpy (src_stat [line_no], line_buffer);
      memcpy (src_mode [line_no], line_mode, line_length * sizeof (bool));
      line_buffer [0]       = 0;
      line_length           = 0;
      is_ref_line [line_no] = inside_refinement;
      line_no++;
      num_src_lines         = line_no;
/*      if (num_src_lines > max_src_lines)  
	printf ("too many src_lines\n");
*/

     };
       /* handle_brackets */      {if (! inside_sl_comment &&
          ! inside_comment    &&
          ! inside_string     &&
          ! inside_char)
          /* count_brackets */      {if (sym == '{') nested_brackets++;
      if (sym == '}') nested_brackets--;
     };
     };
    };
     }
      else if (inside_sl_comment)    /* skip_to_end_of_sl_comment */      {if (sym == '\n')
         inside_sl_comment = false;
       /* get_sym */      {if (sym != ' ' && sym != '\n')
          /* handle_last_non_sep_symbol */      {last_none_sep_sym = sym;
      if (sym != '.')
         {last_ref_sym_line = line_no;
          last_ref_sym_no   = line_length;
         };
     };
      last_last_sym               = last_sym;
      last_sym                    = sym;
      sym                         = fgetc (src);
      line_mode   [line_length]   = inside_string     ||
                                    inside_char       ||
                                    inside_sl_comment ||
                                    inside_comment;
      if ( /* another_sym */      (sym != EOF))
         line_buffer [line_length++] = sym;
      line_buffer [line_length]   = 0;
      symbol_no++;
      if (sym == '\n')
          /* new_line */      {src_stat    [line_no] = new char [line_length + 1];
      src_mode    [line_no] = new bool [line_length + 1];
      strcpy (src_stat [line_no], line_buffer);
      memcpy (src_mode [line_no], line_mode, line_length * sizeof (bool));
      line_buffer [0]       = 0;
      line_length           = 0;
      is_ref_line [line_no] = inside_refinement;
      line_no++;
      num_src_lines         = line_no;
/*      if (num_src_lines > max_src_lines)  
	printf ("too many src_lines\n");
*/

     };
       /* handle_brackets */      {if (! inside_sl_comment &&
          ! inside_comment    &&
          ! inside_string     &&
          ! inside_char)
          /* count_brackets */      {if (sym == '{') nested_brackets++;
      if (sym == '}') nested_brackets--;
     };
     };
    };
     }
      else if ( /* is_sl_comment */      (! inside_string && ! inside_char && sym == '/' && last_sym == '/' ))        /* start_new_sl_comment */      {inside_sl_comment         = true; 
      open_sl_comment_line      = line_no;                     
      line_mode [line_length-1] = true;
      line_mode [line_length-2] = true;
       /* get_sym */      {if (sym != ' ' && sym != '\n')
          /* handle_last_non_sep_symbol */      {last_none_sep_sym = sym;
      if (sym != '.')
         {last_ref_sym_line = line_no;
          last_ref_sym_no   = line_length;
         };
     };
      last_last_sym               = last_sym;
      last_sym                    = sym;
      sym                         = fgetc (src);
      line_mode   [line_length]   = inside_string     ||
                                    inside_char       ||
                                    inside_sl_comment ||
                                    inside_comment;
      if ( /* another_sym */      (sym != EOF))
         line_buffer [line_length++] = sym;
      line_buffer [line_length]   = 0;
      symbol_no++;
      if (sym == '\n')
          /* new_line */      {src_stat    [line_no] = new char [line_length + 1];
      src_mode    [line_no] = new bool [line_length + 1];
      strcpy (src_stat [line_no], line_buffer);
      memcpy (src_mode [line_no], line_mode, line_length * sizeof (bool));
      line_buffer [0]       = 0;
      line_length           = 0;
      is_ref_line [line_no] = inside_refinement;
      line_no++;
      num_src_lines         = line_no;
/*      if (num_src_lines > max_src_lines)  
	printf ("too many src_lines\n");
*/

     };
       /* handle_brackets */      {if (! inside_sl_comment &&
          ! inside_comment    &&
          ! inside_string     &&
          ! inside_char)
          /* count_brackets */      {if (sym == '{') nested_brackets++;
      if (sym == '}') nested_brackets--;
     };
     };
    };
     }
      else if (inside_string)        /* skip_to_end_of_string */      {if (sym == '\x22' && (last_sym != '\\' || last_last_sym == '\\'))
         {inside_string           = false;
          line_mode [line_length] = true;
         };
       /* get_sym */      {if (sym != ' ' && sym != '\n')
          /* handle_last_non_sep_symbol */      {last_none_sep_sym = sym;
      if (sym != '.')
         {last_ref_sym_line = line_no;
          last_ref_sym_no   = line_length;
         };
     };
      last_last_sym               = last_sym;
      last_sym                    = sym;
      sym                         = fgetc (src);
      line_mode   [line_length]   = inside_string     ||
                                    inside_char       ||
                                    inside_sl_comment ||
                                    inside_comment;
      if ( /* another_sym */      (sym != EOF))
         line_buffer [line_length++] = sym;
      line_buffer [line_length]   = 0;
      symbol_no++;
      if (sym == '\n')
          /* new_line */      {src_stat    [line_no] = new char [line_length + 1];
      src_mode    [line_no] = new bool [line_length + 1];
      strcpy (src_stat [line_no], line_buffer);
      memcpy (src_mode [line_no], line_mode, line_length * sizeof (bool));
      line_buffer [0]       = 0;
      line_length           = 0;
      is_ref_line [line_no] = inside_refinement;
      line_no++;
      num_src_lines         = line_no;
/*      if (num_src_lines > max_src_lines)  
	printf ("too many src_lines\n");
*/

     };
       /* handle_brackets */      {if (! inside_sl_comment &&
          ! inside_comment    &&
          ! inside_string     &&
          ! inside_char)
          /* count_brackets */      {if (sym == '{') nested_brackets++;
      if (sym == '}') nested_brackets--;
     };
     };
    };
     }
      else if ( /* is_string */      (! inside_string && sym == '\x22'))            /* start_new_string */      {inside_string    = true;
      open_string_line = line_no;                     
       /* get_sym */      {if (sym != ' ' && sym != '\n')
          /* handle_last_non_sep_symbol */      {last_none_sep_sym = sym;
      if (sym != '.')
         {last_ref_sym_line = line_no;
          last_ref_sym_no   = line_length;
         };
     };
      last_last_sym               = last_sym;
      last_sym                    = sym;
      sym                         = fgetc (src);
      line_mode   [line_length]   = inside_string     ||
                                    inside_char       ||
                                    inside_sl_comment ||
                                    inside_comment;
      if ( /* another_sym */      (sym != EOF))
         line_buffer [line_length++] = sym;
      line_buffer [line_length]   = 0;
      symbol_no++;
      if (sym == '\n')
          /* new_line */      {src_stat    [line_no] = new char [line_length + 1];
      src_mode    [line_no] = new bool [line_length + 1];
      strcpy (src_stat [line_no], line_buffer);
      memcpy (src_mode [line_no], line_mode, line_length * sizeof (bool));
      line_buffer [0]       = 0;
      line_length           = 0;
      is_ref_line [line_no] = inside_refinement;
      line_no++;
      num_src_lines         = line_no;
/*      if (num_src_lines > max_src_lines)  
	printf ("too many src_lines\n");
*/

     };
       /* handle_brackets */      {if (! inside_sl_comment &&
          ! inside_comment    &&
          ! inside_string     &&
          ! inside_char)
          /* count_brackets */      {if (sym == '{') nested_brackets++;
      if (sym == '}') nested_brackets--;
     };
     };
    };
     }
      else if (inside_char)          /* skip_to_end_of_char */      {if (sym == '\'' && (last_sym != '\\' || last_last_sym == '\\'))
         inside_char = false;
       /* get_sym */      {if (sym != ' ' && sym != '\n')
          /* handle_last_non_sep_symbol */      {last_none_sep_sym = sym;
      if (sym != '.')
         {last_ref_sym_line = line_no;
          last_ref_sym_no   = line_length;
         };
     };
      last_last_sym               = last_sym;
      last_sym                    = sym;
      sym                         = fgetc (src);
      line_mode   [line_length]   = inside_string     ||
                                    inside_char       ||
                                    inside_sl_comment ||
                                    inside_comment;
      if ( /* another_sym */      (sym != EOF))
         line_buffer [line_length++] = sym;
      line_buffer [line_length]   = 0;
      symbol_no++;
      if (sym == '\n')
          /* new_line */      {src_stat    [line_no] = new char [line_length + 1];
      src_mode    [line_no] = new bool [line_length + 1];
      strcpy (src_stat [line_no], line_buffer);
      memcpy (src_mode [line_no], line_mode, line_length * sizeof (bool));
      line_buffer [0]       = 0;
      line_length           = 0;
      is_ref_line [line_no] = inside_refinement;
      line_no++;
      num_src_lines         = line_no;
/*      if (num_src_lines > max_src_lines)  
	printf ("too many src_lines\n");
*/

     };
       /* handle_brackets */      {if (! inside_sl_comment &&
          ! inside_comment    &&
          ! inside_string     &&
          ! inside_char)
          /* count_brackets */      {if (sym == '{') nested_brackets++;
      if (sym == '}') nested_brackets--;
     };
     };
    };
     }
      else if ( /* is_char */      (! inside_char && sym == '\''))              /* start_new_char */      {inside_char               = true;
      open_char_line            = line_no;                     
      line_mode [line_length-1] = true;
       /* get_sym */      {if (sym != ' ' && sym != '\n')
          /* handle_last_non_sep_symbol */      {last_none_sep_sym = sym;
      if (sym != '.')
         {last_ref_sym_line = line_no;
          last_ref_sym_no   = line_length;
         };
     };
      last_last_sym               = last_sym;
      last_sym                    = sym;
      sym                         = fgetc (src);
      line_mode   [line_length]   = inside_string     ||
                                    inside_char       ||
                                    inside_sl_comment ||
                                    inside_comment;
      if ( /* another_sym */      (sym != EOF))
         line_buffer [line_length++] = sym;
      line_buffer [line_length]   = 0;
      symbol_no++;
      if (sym == '\n')
          /* new_line */      {src_stat    [line_no] = new char [line_length + 1];
      src_mode    [line_no] = new bool [line_length + 1];
      strcpy (src_stat [line_no], line_buffer);
      memcpy (src_mode [line_no], line_mode, line_length * sizeof (bool));
      line_buffer [0]       = 0;
      line_length           = 0;
      is_ref_line [line_no] = inside_refinement;
      line_no++;
      num_src_lines         = line_no;
/*      if (num_src_lines > max_src_lines)  
	printf ("too many src_lines\n");
*/

     };
       /* handle_brackets */      {if (! inside_sl_comment &&
          ! inside_comment    &&
          ! inside_string     &&
          ! inside_char)
          /* count_brackets */      {if (sym == '{') nested_brackets++;
      if (sym == '}') nested_brackets--;
     };
     };
    };
     }
      else if (! inside_prc)         /* skip_to_prc_start */      {if (sym == '{' && last_none_sep_sym == ')')
          /* start_new_prc */      {ref_base   = num_refs;

      proc_base         = line_no;
      inside_prc        = true;
      open_bracket_line = line_no;                     
     };
       /* get_sym */      {if (sym != ' ' && sym != '\n')
          /* handle_last_non_sep_symbol */      {last_none_sep_sym = sym;
      if (sym != '.')
         {last_ref_sym_line = line_no;
          last_ref_sym_no   = line_length;
         };
     };
      last_last_sym               = last_sym;
      last_sym                    = sym;
      sym                         = fgetc (src);
      line_mode   [line_length]   = inside_string     ||
                                    inside_char       ||
                                    inside_sl_comment ||
                                    inside_comment;
      if ( /* another_sym */      (sym != EOF))
         line_buffer [line_length++] = sym;
      line_buffer [line_length]   = 0;
      symbol_no++;
      if (sym == '\n')
          /* new_line */      {src_stat    [line_no] = new char [line_length + 1];
      src_mode    [line_no] = new bool [line_length + 1];
      strcpy (src_stat [line_no], line_buffer);
      memcpy (src_mode [line_no], line_mode, line_length * sizeof (bool));
      line_buffer [0]       = 0;
      line_length           = 0;
      is_ref_line [line_no] = inside_refinement;
      line_no++;
      num_src_lines         = line_no;
/*      if (num_src_lines > max_src_lines)  
	printf ("too many src_lines\n");
*/

     };
       /* handle_brackets */      {if (! inside_sl_comment &&
          ! inside_comment    &&
          ! inside_string     &&
          ! inside_char)
          /* count_brackets */      {if (sym == '{') nested_brackets++;
      if (sym == '}') nested_brackets--;
     };
     };
    };
     }
      else if ( /* is_refinement_start */      (! inside_refinement && sym == '.' && last_sym == '\n'))  /* handle_refinement_start */      {char name [128];

      if (inside_refinement)
         pass_1_error (line_no, "nested refinement");
       /* get_name */      {int l = 0;

      inside_refinement = true;
      name [0]          = 0;
       /* get_sym */      {if (sym != ' ' && sym != '\n')
          /* handle_last_non_sep_symbol */      {last_none_sep_sym = sym;
      if (sym != '.')
         {last_ref_sym_line = line_no;
          last_ref_sym_no   = line_length;
         };
     };
      last_last_sym               = last_sym;
      last_sym                    = sym;
      sym                         = fgetc (src);
      line_mode   [line_length]   = inside_string     ||
                                    inside_char       ||
                                    inside_sl_comment ||
                                    inside_comment;
      if ( /* another_sym */      (sym != EOF))
         line_buffer [line_length++] = sym;
      line_buffer [line_length]   = 0;
      symbol_no++;
      if (sym == '\n')
          /* new_line */      {src_stat    [line_no] = new char [line_length + 1];
      src_mode    [line_no] = new bool [line_length + 1];
      strcpy (src_stat [line_no], line_buffer);
      memcpy (src_mode [line_no], line_mode, line_length * sizeof (bool));
      line_buffer [0]       = 0;
      line_length           = 0;
      is_ref_line [line_no] = inside_refinement;
      line_no++;
      num_src_lines         = line_no;
/*      if (num_src_lines > max_src_lines)  
	printf ("too many src_lines\n");
*/

     };
       /* handle_brackets */      {if (! inside_sl_comment &&
          ! inside_comment    &&
          ! inside_string     &&
          ! inside_char)
          /* count_brackets */      {if (sym == '{') nested_brackets++;
      if (sym == '}') nested_brackets--;
     };
     };
    };
       /* skip_blanks */      {while (sym == ' ' &&  /* another_sym */      (sym != EOF))
       { /* get_sym */      {if (sym != ' ' && sym != '\n')
          /* handle_last_non_sep_symbol */      {last_none_sep_sym = sym;
      if (sym != '.')
         {last_ref_sym_line = line_no;
          last_ref_sym_no   = line_length;
         };
     };
      last_last_sym               = last_sym;
      last_sym                    = sym;
      sym                         = fgetc (src);
      line_mode   [line_length]   = inside_string     ||
                                    inside_char       ||
                                    inside_sl_comment ||
                                    inside_comment;
      if ( /* another_sym */      (sym != EOF))
         line_buffer [line_length++] = sym;
      line_buffer [line_length]   = 0;
      symbol_no++;
      if (sym == '\n')
          /* new_line */      {src_stat    [line_no] = new char [line_length + 1];
      src_mode    [line_no] = new bool [line_length + 1];
      strcpy (src_stat [line_no], line_buffer);
      memcpy (src_mode [line_no], line_mode, line_length * sizeof (bool));
      line_buffer [0]       = 0;
      line_length           = 0;
      is_ref_line [line_no] = inside_refinement;
      line_no++;
      num_src_lines         = line_no;
/*      if (num_src_lines > max_src_lines)  
	printf ("too many src_lines\n");
*/

     };
       /* handle_brackets */      {if (! inside_sl_comment &&
          ! inside_comment    &&
          ! inside_string     &&
          ! inside_char)
          /* count_brackets */      {if (sym == '{') nested_brackets++;
      if (sym == '}') nested_brackets--;
     };
     };
    };
       };
     };
      while ( /* another_sym */      (sym != EOF) && sym != '\n' && sym != ' ' && sym != '\t')
        {if (sym != ' ')
            {name [l++] = sym; name [l] = 0;
            };
          /* get_sym */      {if (sym != ' ' && sym != '\n')
          /* handle_last_non_sep_symbol */      {last_none_sep_sym = sym;
      if (sym != '.')
         {last_ref_sym_line = line_no;
          last_ref_sym_no   = line_length;
         };
     };
      last_last_sym               = last_sym;
      last_sym                    = sym;
      sym                         = fgetc (src);
      line_mode   [line_length]   = inside_string     ||
                                    inside_char       ||
                                    inside_sl_comment ||
                                    inside_comment;
      if ( /* another_sym */      (sym != EOF))
         line_buffer [line_length++] = sym;
      line_buffer [line_length]   = 0;
      symbol_no++;
      if (sym == '\n')
          /* new_line */      {src_stat    [line_no] = new char [line_length + 1];
      src_mode    [line_no] = new bool [line_length + 1];
      strcpy (src_stat [line_no], line_buffer);
      memcpy (src_mode [line_no], line_mode, line_length * sizeof (bool));
      line_buffer [0]       = 0;
      line_length           = 0;
      is_ref_line [line_no] = inside_refinement;
      line_no++;
      num_src_lines         = line_no;
/*      if (num_src_lines > max_src_lines)  
	printf ("too many src_lines\n");
*/

     };
       /* handle_brackets */      {if (! inside_sl_comment &&
          ! inside_comment    &&
          ! inside_string     &&
          ! inside_char)
          /* count_brackets */      {if (sym == '{') nested_brackets++;
      if (sym == '}') nested_brackets--;
     };
     };
    };
        };
     };
       /* open_refinement */      {ref_name         [num_refs] = new char [strlen (name) + 1];
      ref_start        [num_refs] = line_length;
      ref_start_line   [num_refs] = line_no;
      ref_scope_start  [num_refs] = proc_base;
      strcpy (ref_name [num_refs], name);
     };
     }
      else if ( /* is_refinement_end */      (sym == '\n' && last_none_sep_sym == '.' && inside_refinement))    /* handle_refinement_end */      {ref_end      [num_refs] = last_ref_sym_no;
      ref_end_line [num_refs] = last_ref_sym_line;
      inside_refinement       = false;
      num_refs++;
/*      if (num_refs > max_refinements)
	printf ("too many refs\n");
*/
       /* get_sym */      {if (sym != ' ' && sym != '\n')
          /* handle_last_non_sep_symbol */      {last_none_sep_sym = sym;
      if (sym != '.')
         {last_ref_sym_line = line_no;
          last_ref_sym_no   = line_length;
         };
     };
      last_last_sym               = last_sym;
      last_sym                    = sym;
      sym                         = fgetc (src);
      line_mode   [line_length]   = inside_string     ||
                                    inside_char       ||
                                    inside_sl_comment ||
                                    inside_comment;
      if ( /* another_sym */      (sym != EOF))
         line_buffer [line_length++] = sym;
      line_buffer [line_length]   = 0;
      symbol_no++;
      if (sym == '\n')
          /* new_line */      {src_stat    [line_no] = new char [line_length + 1];
      src_mode    [line_no] = new bool [line_length + 1];
      strcpy (src_stat [line_no], line_buffer);
      memcpy (src_mode [line_no], line_mode, line_length * sizeof (bool));
      line_buffer [0]       = 0;
      line_length           = 0;
      is_ref_line [line_no] = inside_refinement;
      line_no++;
      num_src_lines         = line_no;
/*      if (num_src_lines > max_src_lines)  
	printf ("too many src_lines\n");
*/

     };
       /* handle_brackets */      {if (! inside_sl_comment &&
          ! inside_comment    &&
          ! inside_string     &&
          ! inside_char)
          /* count_brackets */      {if (sym == '{') nested_brackets++;
      if (sym == '}') nested_brackets--;
     };
     };
    };
     }
      else if ( /* is_prc_end */      (inside_prc && nested_brackets == 0))           /* handle_prc_end */      {inside_prc = false;
       /* set_ref_scope_end */      {for (int i = ref_base; i < num_refs; i++)
        ref_scope_end [i] = line_no;
     };
      if (inside_refinement)
         pass_1_error (line_no, "unexpected end of function");
     }
      else                           /* get_sym */      {if (sym != ' ' && sym != '\n')
          /* handle_last_non_sep_symbol */      {last_none_sep_sym = sym;
      if (sym != '.')
         {last_ref_sym_line = line_no;
          last_ref_sym_no   = line_length;
         };
     };
      last_last_sym               = last_sym;
      last_sym                    = sym;
      sym                         = fgetc (src);
      line_mode   [line_length]   = inside_string     ||
                                    inside_char       ||
                                    inside_sl_comment ||
                                    inside_comment;
      if ( /* another_sym */      (sym != EOF))
         line_buffer [line_length++] = sym;
      line_buffer [line_length]   = 0;
      symbol_no++;
      if (sym == '\n')
          /* new_line */      {src_stat    [line_no] = new char [line_length + 1];
      src_mode    [line_no] = new bool [line_length + 1];
      strcpy (src_stat [line_no], line_buffer);
      memcpy (src_mode [line_no], line_mode, line_length * sizeof (bool));
      line_buffer [0]       = 0;
      line_length           = 0;
      is_ref_line [line_no] = inside_refinement;
      line_no++;
      num_src_lines         = line_no;
/*      if (num_src_lines > max_src_lines)  
	printf ("too many src_lines\n");
*/

     };
       /* handle_brackets */      {if (! inside_sl_comment &&
          ! inside_comment    &&
          ! inside_string     &&
          ! inside_char)
          /* count_brackets */      {if (sym == '{') nested_brackets++;
      if (sym == '}') nested_brackets--;
     };
     };
    };
     };
        };
       /* new_line */      {src_stat    [line_no] = new char [line_length + 1];
      src_mode    [line_no] = new bool [line_length + 1];
      strcpy (src_stat [line_no], line_buffer);
      memcpy (src_mode [line_no], line_mode, line_length * sizeof (bool));
      line_buffer [0]       = 0;
      line_length           = 0;
      is_ref_line [line_no] = inside_refinement;
      line_no++;
      num_src_lines         = line_no;
/*      if (num_src_lines > max_src_lines)  
	printf ("too many src_lines\n");
*/

     };
       /* check_everything_closed */      {if (inside_string)  
         pass_1_error (line_no,
                       "EOF ($) inside string, depp",
                       open_string_line);
      if (inside_char)       
         pass_1_error (line_no,
                       "EOF ($) inside char constant, hahaha",
                       open_char_line);
      if (inside_sl_comment) 
         pass_1_error (line_no,
                       "EOF ($) inside comment, forget it",
                       open_sl_comment_line);
      if (inside_comment)
         pass_1_error (line_no,
                       "EOF ($) inside comment, oh boy",
                       open_comment_line);
      if (inside_prc)
         pass_1_error (line_no,
                       "'}' ($) missing, start to search it, haha",
                       open_bracket_line);
     };
     };
   fclose (src);
   










 







   

   

   

   



  



 


  }

void write_obj (int line_no, char c)
  {fprintf (obj, "%c", c);
   if (last_obj_c == '\n')
       /* handle_new_line */      {line_cor [obj_line_no][0] = obj_line_no;
      line_cor [obj_line_no][1] = line_no;
      obj_line_no ++;
     };
   last_obj_c = c;
   

  }

void write_obj (int line_no, char st [])
  {int l = strlen (st);

   for (int i = 0; i < l; i++)
     write_obj (line_no, st [i]);
  }

int ref_no (int line_no, char sym [])
  {int ref_n;

    /* search_sym */      {for (ref_n = ref_search_base; ref_n < num_refs; ref_n++)
         /* check_refinment */      {if (strcmp (ref_name [ref_n], sym) == 0 &&
          ref_scope_start [ref_n] <= line_no  &&
          ref_scope_end   [ref_n] >= line_no)
         break;
     };
      if (ref_n >= num_refs)
         ref_n = -1;
     };
   if (ref_n >= 0)
       /* set_search_base */      {while (ref_search_base > 0 &&
             ref_scope_start [ref_search_base] == 
             ref_scope_start [ref_search_base-1])
        {ref_search_base--;
        };
     };
   return ref_n;




  }

void sub_ref (int ref_n)
  { /* write_name */      {fprintf (obj, " /* %s */ ", ref_name [ref_n]);
     };
   for (int l = ref_start_line [ref_n]; l <= ref_end_line [ref_n]; l++)
      /* gen_ref_line */      {int min;
      int max;

       /* calc_min */      {if   ( /* first_line */      (l == ref_start_line [ref_n]))
           min =  ref_start [ref_n];
      else min = 0;
     };
       /* calc_max */      {if   ( /* last_line */      (l == ref_end_line [ref_n]))
           max = ref_end [ref_n];
      else max = strlen (src_stat [l]);
     };
      for (int c = min; c < max; c++)
         /* handle_char */      {if   ( /* within_identi */      (isalnum ( /* ss */ 
     src_stat [l][c]) ||  /* ss */ 
     src_stat [l][c] == '_') && ! src_mode [l][c])
            /* handle_identi */      {char ident [1024];
      int  ref;

       /* get_identi */      {int h = 0;
 
      while (c < max &&  /* within_identi */      (isalnum ( /* ss */ 
     src_stat [l][c]) ||  /* ss */ 
     src_stat [l][c] == '_'))
        {ident [h++] =  /* ss */ 
     src_stat [l][c];
         c++;
        };
      c--;
      ident [h] = 0;
     };
      ref = ref_no (l, ident);
      if   (ref != -1)
           sub_ref (ref);
      else write_obj (l, ident);
     }
      else  /* to_obj */      {write_obj (l,  /* ss */ 
     src_stat [l][c]);
     };
     };
     };







      




 
  }

bool pass_2 (char obj_name [])
  {int  line_no;
   int  char_no;
   bool within_string;
   bool within_comment;
   bool within_char;

    /* open_obj_file */      {f_open (obj, complete (obj_name, ".cc"), "w");
     };
    /* init_symbol_tab */      {line_no         = 0;
      ref_search_base = 0;
      obj_line_no     = 1;
      line_cor [0][0] = 0;
      line_cor [0][1] = 0;
      within_string   = false;
      within_comment  = false;
      within_char     = false;
     };
    /* scan_lines */      {while (line_no < num_src_lines)
         /* handle_line */      {if   (is_ref_line [line_no])
           line_no++;
      else  /* handle_main_line */      {int ll = strlen (src_stat [line_no]);

      char_no = 0;
      while ( /* within_line */      (char_no < ll))
        { /* handle_symbol */      {if   ( /* within_ident */      (isalnum ( /* s */ 
     src_stat [line_no][char_no]) ||  /* s */ 
     src_stat [line_no][char_no] == '_') && ! src_mode [line_no][char_no])
            /* handle_ident */      {char ident [1024];
      int  ref;

       /* get_ident */      {int l = 0;
 
      while ( /* within_line */      (char_no < ll) &&  /* within_ident */      (isalnum ( /* s */ 
     src_stat [line_no][char_no]) ||  /* s */ 
     src_stat [line_no][char_no] == '_'))
        {ident [l++] =  /* s */ 
     src_stat [line_no][char_no];
         char_no++;
        };
      ident [l] = 0;
     };
      ref = ref_no (line_no, ident);
      if   (ref != -1)
           sub_ref (ref);
      else write_obj (line_no, ident);
     }
      else  /* char_to_obj */      {write_obj (line_no,  /* s */ 
     src_stat [line_no][char_no]);
      char_no++;
     };
     };
        };
      line_no++;
     };
     };
     };
   fclose (obj);











      

  }

void pass_1_and_a_half ()
  {for (int r = num_refs-1; r >= 0; r--)
      /* check_ref */      {ref_search_base = 0;
      if ( /* dr */     ref_no (ref_start_line [r], ref_name [r]) != r)
          /* handle_double */      {printf ("Refinement : '%s' (in lines %d, %d) multiply declared\n",
              ref_name [r],
              ref_start_line [r],
              ref_start_line [ /* dr */     ref_no (ref_start_line [r], ref_name [r])]);
      exit   (1);
     };
     };




  }

void gcc_call(char gcc_exec [],
              char src_name [],
              char options  [])

  {char cmd [8000];

   sprintf (cmd, "%s %s.cc %s 1> %s.err 2>&1", 
            gcc_exec,
            src_name,
            options,
            src_name); 
   system (cmd);
  }

int ref_line (int i)
  {for (int j = 0; j < obj_line_no; j++)
     if (line_cor [j][0] >= i)
        return line_cor [j][1];
   return line_cor [obj_line_no-1][1];
  }

void pass_3 (char src_name [])
  {FILE *err_file;

    /* open_err_file */      {err_file = fopen (complete (src_name, ".err"), "r");
     };
   if (err_file != NULL)
       /* scan_errors */      {char buffer [1024];
      int  num_errors = 0;

      while ( /* another_error_msg */      (fgets (buffer, 1020, err_file) != NULL))
        { /* handle_error_msg */      {int  p;
      int  p0;
      int  c = 0;

      num_errors++;
       /* get_p */      {while (c < strlen (buffer) && buffer [c] != ':') 
        {c++;
        };
      p = c;
      c++;
     };
      if   (p < strlen (buffer))
            /* handle_second_colon */      {char num [128];

      p0 = p;
      if   (strcmp (substring (buffer, p-3, p), ".cc") == 0)
            /* handle_cc_error_msg */      { /* get_num */      {int l = 0;

      while (c < strlen (buffer) && isdigit (buffer [c])) 
        {num [l++] = buffer [c];
         c++;
        };
      num [l] = 0;
      p       = c;
      c++;
     };
      if   (strlen (num) > 0)
            /* handle_full_error */      {printf ("%s.hc:%d%s\n", 
              substring (buffer, 0, p0-3),   
              ref_line  (atoi (num)),
              substring (buffer, p));
     }
      else printf ("%s.hc:%s",
                   substring (buffer, 0, p0-3),
                   substring (buffer, p0+1));
     }
      else printf ("%s", buffer);
     }
      else printf ("%s", buffer);
     };
        };
      if (num_errors > 0)
          /* remove_o */      {char msg [80];                                  

      sprintf (msg, "rm -f %s.o", src_name);          
      system  (msg);             
      exit    (1);
     };
     };
   fclose (err_file); 











  }

main (int num_params, char *shell_params [])
  {char gcc_exec [256];
   char src_name [256];
   char options  [256];

    /* handle_params */      {if   (num_params < 2)
            /* usage */      {printf ("usage : hcc -complier <gcc_executbale> [options] <src>\n");
      exit   (1);
     }
      else  /* analyse_params */      {bool any_gcc_executable = false;
      
      strcpy (gcc_exec, "");
      strcpy (src_name, "");
      strcpy (options,  "");
       /* pharse_params */ 
     {for (int p = 1; p < num_params-1; p++)
        {if   (strcmp (shell_params [p], "-compiler") == 0)
               /* grab_compiler */      {any_gcc_executable = true;
      strcpy (gcc_exec, shell_params [p+1]);
      p++;
     }
         else {strcat (options, shell_params [p]);
               strcat (options, " "); 
              };
        };
      strcpy (src_name, shell_params [num_params-1]);
     };
      if (! any_gcc_executable)
          /* fuck */      {printf ("Idiot, tell me what compiler to use !!!\n");
      exit   (1);
     };
     };
     };
   pass_1            (src_name);
   pass_1_and_a_half ();
   pass_2            (src_name);
   gcc_call          (gcc_exec, src_name, options);
   pass_3            (src_name);
   return 0;
  






  }
