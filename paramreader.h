/*======================================================================*/
/*= CHANGES AND UPDATES                                                =*/
/*======================================================================*/
/*= date   person file           subject                               =*/
/*=--------------------------------------------------------------------=*/
/*=                                                                    =*/
/*= 121192 hua    paramreader.h  add include of string.h               =*/
/*=                                                                    =*/
/*= 181192 smieja paramreader.h  increased param limit                 =*/
/*=                                                                    =*/
/*======================================================================*/

#ifndef paramreader_h
#define paramreader_h

/*======================================================================*/
/*                                                                      */
/* Includes                                                             */
/*                                                                      */
/*======================================================================*/

#include "stdlib.h"
#include "stdio.h"
#include "limits.h"
#include "float.h"
#include "math.h"
#include "ctype.h"
#include "string.h"

#include "bool.h"
#include "xmath.h"
#include "io.h"
#include "errorhandling.h"

/*----------------------------------------------------------------------*/
/* check params functions                                               */
/*----------------------------------------------------------------------*/

void check_params (int num);

/*----------------------------------------------------------------------*/
/* CLASS paramreader (deklarations)                                     */
/*----------------------------------------------------------------------*/

#define max_includes     4
#define max_params       1000
#define max_param_length 80

class paramreader
  {public:

     char name  [max_params][max_param_length];
     char value [max_params][max_param_length];
     int  num_params;
     FILE *f    [max_includes];
     int  num_includes;


          paramreader (const char *param_file_name);

   void   dump       ();
   char * s_param    (const char name []);
   double d_param    (char name []);
   int    i_param    (const char name []);
   int    param_no   (const char name []);
   void   set        (char name [], char value []);
   void   read_sym   (char sym  [], bool &is_eof);
   int    max_i_name ();

  };

#endif
