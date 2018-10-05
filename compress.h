/*======================================================================*/
/*= CHANGES AND UPDATES                                                =*/
/*======================================================================*/
/*= date   person file       subject                                   =*/
/*=--------------------------------------------------------------------=*/
/*=                                                                    =*/
/*= 111094 hua    compress.h created                                   =*/
/*=                                                                    =*/
/*======================================================================*/

#include "win.h"
#include "ppm.h"

#ifndef compress_h
#define compress_h

class compress
  {public:

     ppm  *act;
     int  snr;
     char name [128];

     FILE *f;

     compress  ();
     ~compress ();

     char *frame_name (const char postfix []);
     void encode      (char name    []);
     void decode      (char name    []);
 
   };


#endif

