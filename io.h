/*-------------------------------------------------------------------------*/
/* io.inc                                                                  */
/*                                                                         */
/*                                                                         */
/*                                                                         */
/*-------------------------------------------------------------------------*/

#include "stdio.h"

#include "bool.h"

#ifndef io_h
#define io_h

void   ack   ();
void   s_ack (char msg []);
bool   ok    ();
double d_get (char msg []);
int    i_get (char msg []);

#endif
