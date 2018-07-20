/*======================================================================*/
/*= CHANGES AND UPDATES                                                =*/
/*======================================================================*/
/*= date   person file       subject                                   =*/
/*=--------------------------------------------------------------------=*/
/*=                                                                    =*/
/*= 270694 hua    list.h     created                                   =*/
/*=                                                                    =*/
/*======================================================================*/

#ifndef list_h
#define list_h

#include "bool.h"

#define max_elements 100


struct list
  {int  num;
   int  elem [max_elements];
   bool is_universal;
 };


list list           (int e);
list empty_list     ();
list universal_list ();
void print          (list l);
void copy           (list &l , list r);
list operator +     (list l, int e);
list operator -     (list l, int e);
bool operator %     (int e, list l);

#endif


