/*======================================================================*/
/*= CHANGES AND UPDATES                                                =*/
/*======================================================================*/
/*= date   person file       subject                                   =*/
/*=--------------------------------------------------------------------=*/
/*=                                                                    =*/
/*======================================================================*/

#include "errorhandling.h"
#include "table.h"
#include "paramreader.h"

void errorstop (int  error_no,
                char c_class [],
                char msg     [])

  {errorstop (error_no, c_class, msg, "-", "-", "-");
  }

void errorstop (int  error_no,
                char c_class [],
                char msg     [],
                char info    [])

  {errorstop (error_no, c_class, msg, info, "-", "-");
  }

void errorstop (int  error_no,
                char c_class [],
                char msg     [],
                char info    [],
                char param1  [])
    
  {errorstop (error_no, c_class, msg, info, param1, "-");
  }

void errorstop (int  error_no,
                char c_class [],
                char msg     [],
                char info    [], 
                char param1  [],
                char param2  [])

  {printf              ("ERROR (%d) : %s : %s : %s : %s : %s\n",
                        error_no,
                        c_class,
                        msg,
	                info,
                        param1,
                        param2);
   close_table_handler (false);
   abort               ();
  }

 

