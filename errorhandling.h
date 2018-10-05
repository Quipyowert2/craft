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
                const char c_class [],
                const char msg     []);

void errorstop (int  error_no,
                const char c_class [],
                const char msg     [],
                const char info    []);

void errorstop (int  error_no,
                const char c_class [],
                const char msg     [],
                const char info    [],
		char param1  []);

void errorstop (int  error_no,
                const char c_class [],
                const char msg     [],
                const char info    [],
		const char param1  [],
                const char param2  []);

#endif


 

