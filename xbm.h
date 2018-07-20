/*======================================================================*/
/*= CHANGES AND UPDATES                                                =*/
/*======================================================================*/
/*= date   person file       subject                                   =*/
/*=--------------------------------------------------------------------=*/
/*=                                                                    =*/
/*= 111094 hua    xbm.h      created                                   =*/
/*=                                                                    =*/
/*======================================================================*/

#include "win.h"

#ifndef xbm_h
#define xbm_h


class xbm
  {public:

     int *data;

     int dx;
     int dy;
 

     xbm       (char name []);
     xbm       (int  dx, int dy);
     ~xbm      ();

     void save (char name []);

     void bit  (int x, int y, int &b);   
     void set  (int x, int y, int b);
    
     int  ind  (int x, int y);

   };


#endif

