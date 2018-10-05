/*======================================================================*/
/*= CHANGES AND UPDATES                                                =*/
/*======================================================================*/
/*= date   person file       subject                                   =*/
/*=--------------------------------------------------------------------=*/
/*=                                                                    =*/
/*= 190793 hua    masks.h    created                                   =*/
/*=                                                                    =*/
/*======================================================================*/

#ifndef mask_h
#define mask_h

#include "bool.h"
#include "win.h"

#define frame_font  "-misc-*-*-*-*-*-*-*-*-*-*-*-*-*"
#define frame_size  5

void background (win *w);
void background (win *w, int x, int y, int dx, int dy);
void frame      (win *w);
void frame      (win *w,
                 int x, int y,
                 int dx, int dy, 
                 int color_1, int color_2);

bool yes        (win *w, char host [], const char question []);
bool yes        (const char host [], const char question []);
bool yes        (const char question []);
void ack        (const char host [], char msg []);
void ack        (char message []);
void tell       (win  *&w,
                 char message []);
void tell       (const char host [],
                 win  *&w,
                 char message []);
void tell       (char host [],
                 win  *parent,
                 win  *&w,
                 char message []);

bool get_line   (char s    [],
                 char name [],
                 int  dx           = 300,
                 bool with_history = true);

int  select     (char menu_string [], char *name = NULL);


#endif
