/*======================================================================*/
/*= CHANGES AND UPDATES                                                =*/
/*======================================================================*/
/*= date   person file       subject                                   =*/
/*=--------------------------------------------------------------------=*/
/*=                                                                    =*/
/*======================================================================*/

#ifndef errorhandling_h
#define errorhandling_h

#include "stdlib.h"
#include "stdio.h"

void errorstop (int  error_no,
                char c_class [],
                char msg     []);

void errorstop (int  error_no,
                char c_class [],
                char msg     [],
                char info    []);

void errorstop (int  error_no,
                char c_class [],
                char msg     [],
                char info    [],
		char param1  []);

void errorstop (int  error_no,
                char c_class [],
                char msg     [],
                char info    [],
		char param1  [],
                char param2  []);

#endif


 

