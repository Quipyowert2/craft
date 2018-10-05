/*======================================================================*/
/*= CHANGES AND UPDATES                                                =*/
/*======================================================================*/
/*= date   person file       subject                                   =*/
/*=--------------------------------------------------------------------=*/
/*=                                                                    =*/
/*= 301092 hua    xstring.hc created                                   =*/
/*=                                                                    =*/
/*======================================================================*/

#include "string.h"
#include "ctype.h"
#include "stdio.h"

#include "xmath.h"
#include "xstring.h"
#include "io.h"

/*======================================================================*/
/*                                                                      */
/* XSTRING                                                              */
/*                                                                      */
/*   Some special routines for 0-terminated char []                     */
/*                                                                      */
/*======================================================================*/

void compress (char s [])
  {delete_leading_blanks;
   delete_trailing_blanks;

.  delete_leading_blanks
     while (first_char == ' ')
       delete_first_char.

.  delete_first_char
     {for (int i = 0; s [i] != '\0' && s [i] != 0; i++)
        s [i] = s [i+1];
     }.

.  delete_trailing_blanks
     {int i;

      skip_to_last_char;
      while (last_char == ' ')
        delete_last_char;
     }.

.  skip_to_last_char
     {for (i = 0; s [i] != '\0' && s [i] != 0; i++);
        i--;
     }.

.  delete_last_char
     {last_char = 0;
      i--;
     }.
      
.  first_char s [0].
.  last_char  s [i].

  }

void strcat (char s [], int len, char app [])
  {int len_s   = strlen (s);
   int len_app = strlen (app);

   if   (len_s + len_app < len)
        strcat (s, app);
   else strcat (s, substring (app, 0, len - len_s - 1));
  }

 
void lower (char s [])
  {char ss [1024];
   int  i;
  
   for (i = 0; i < strlen (s); i++)
      if   (isupper (s [i]))
           ss [i] = tolower (s [i]);
      else ss [i] = s [i];
   ss [i] = 0;
   strcpy (s, ss);
  }
 
void changeall (char s           [], 
                int  max_length_of_s,
                char tmplate     [],
                char replacement [])

  {char *pos;

   while ((pos = strstr (s, tmplate)) != NULL)
     perform_substitute;

.  perform_substitute
     {delete_tmplate;
      insert_replacement;
     }.

.  delete_tmplate
     {char *pp = pos;

      while (*(pp + strlen (tmplate)) != 0)
        {*(pp) = *(pp + strlen (tmplate));
         pp++;
        };
      *pp = 0;
     }.

.  insert_replacement
     {if (strlen (s) + strlen (replacement) < max_length_of_s)
         perform_insert;
     }.

.  perform_insert
     {char buffer [max_length_of_s];
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
     }.

  }

char *substring (char s [], int from)
  {static bool is_init = false;
   static char *result;

   perhaps_delete_old_result;
   calc_new_result;
   return result;

.  perhaps_delete_old_result
     {if (is_init)
         delete[] (result);
     }.

.  calc_new_result
     {result  = new char [strlen (s) - from + 2];
      is_init = true;
      strcpy (result, &s [from]);
     }.

  }

char *substring (const char s [], int from, int to)
  {static bool is_init = false;
   static char *result;

   perhaps_delete_old_result;
   calc_new_result;
   return result;

.  perhaps_delete_old_result
     {if (is_init)
         delete[] (result);
     }.

.  calc_new_result
     {int i;

      result  = new char [to - from + 2];
      is_init = true;
      for (i = from; i < to; i++)
        result [i-from] = s [i];
      result [i-from] = 0;
     }.

  }
   
int submatch (char s [], char p [], int &pos)
  {int matched_chars = 0;
   int len_s         = strlen (s);
   int len_p         = strlen (p);

   pos        = len_s + 1;
   for (int i = 0; i < len_s; i++)
     check_sub_match;
   return matched_chars;

.  check_sub_match
     {int j;

      for (j = 0; j < len_p && (i+j) < len_s; j++)
        if (s [i+j] != p [j])
           break;
      if (j > matched_chars)
         {matched_chars = j;
          pos           = i;
         };
     }.

  }

void delchar (char s [], int pos)
  {for (int p = pos; p < strlen (s); p++)
     s [p] = s [p+1];
  }

void inschar (char s[], int pos, char n)
  {if   (pos < strlen (s))
        handle_insert
   else handle_append;

.  handle_insert
     {for (int i = strlen (s); i >= pos; i--)
        s [i+1] = s [i];
      s [pos] = n;
     }.

.  handle_append
     {int l = strlen (s);

      s [l] = n;
      s [l+1] = 0;
     }.

  }

int strpos (char s [], char p)
  {for (int i = 0 ; i < strlen (s); i++)
     if (s [i] == p)
        return i;
   return -1;
  }
