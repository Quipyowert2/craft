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
                const char c_class [],
                const char msg     [])

  {errorstop (error_no, c_class, msg, "-", "-", "-");
  }

void errorstop (int  error_no,
                const char c_class [],
                const char msg     [],
                const char info    [])

  {errorstop (error_no, c_class, msg, info, "-", "-");
  }

void errorstop (int  error_no,
                const char c_class [],
                const char msg     [],
                const char info    [],
                char param1  [])
    
  {errorstop (error_no, c_class, msg, info, param1, "-");
  }

void errorstop (int  error_no,
                const char c_class [],
                const char msg     [],
                const char info    [],
                const char param1  [],
                const char param2  [])

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

 

