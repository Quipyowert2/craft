#include <sys/types.h>
#include <sys/stat.h>
#include <std.h>
#include <sys/time.h>
#include <signal.h>

/*======================================================================*/
/*                                                                      */
/* signals.h                                                            */
/*                                                                      */
/*======================================================================*/

#ifndef signals_h
#define signals_h

void set_interrupt (int indicator, void (*handler)());

#endif
