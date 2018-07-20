#ifndef xfile_h
#define xfile_h

/*======================================================================*/
/*                                                                      */
/* Routines for file access                                             */
/*                                                                      */
/*======================================================================*/

#include "stdio.h"
#include "sys/types.h"
#include "sys/stat.h"

#include "io.h"
#include "bool.h"

double d_get              (FILE *f, bool &is_eof);
time_t f_date             (char f_name []);
bool   f_exists           (char f_name []);
void   f_open             (FILE *&f, char name [], char mode []);
void   f_open_with_extend (FILE *&f, char name [], char mode [], int max_no);
char   *f_getline         (FILE *f,  char line [], int  max_length); 

char   *f_postfix         (char full_path []);
char   *f_name            (char full_path []);
char   *f_tail            (char full_path []);
char   *f_path            (char full_path []);
char   *f_home_dir        (char full_path []);
bool   f_is_pattern       (char f_name    []);
bool   f_is_dir           (char f_name    []);
bool   f_is_home_dir      (char f_name    []);

bool   sel_get_name       (char name   [],
                           char f_name [],
                           char f_pat  [],
                           char mode   []);

char   *complete          (char name [],
                           char tail []);

void   bprintf            (FILE *f, int num_bytes, int i);
bool   bscanf             (FILE *f, int num_bytes, int &i);

#endif



