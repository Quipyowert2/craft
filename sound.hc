/*======================================================================*/
/*= CHANGES AND UPDATES                                                =*/
/*======================================================================*/
/*= date   person file       subject                                   =*/
/*=--------------------------------------------------------------------=*/
/*=                                                                    =*/
/*= 300195 hua    sound.hc   created                                   =*/
/*=                                                                    =*/
/*======================================================================*/

#include "io.h"
#include "sound.h"

FILE *s_device;

#define s_device_name "/dev/audio"


void sound_open ()
  {s_device = fopen (s_device_name, "w");
  }

void sound_close ()
  {fclose (s_device);
  }

void sound (char au_file_name [])
  {FILE *au;
   char c;

   au = fopen (au_file_name, "r");
   while (another_char)
     {audio_char;
     };
   fflush (s_device);
   fclose (au);
 
.  another_char
     ((c = fgetc (au)) != EOF).

.  audio_char
     {fputc (c, s_device);
     }.

  }
      


