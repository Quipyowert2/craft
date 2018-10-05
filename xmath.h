/*======================================================================*/
/*= CHANGES AND UPDATES                                                =*/
/*======================================================================*/
/*= date   person file       subject                                   =*/
/*=--------------------------------------------------------------------=*/
/*=                                                                    =*/
/*= 170293 hua    xmath.h    added i_abs                               =*/
/*=                                                                    =*/
/*======================================================================*/

#ifndef xmath_h
#define xmath_h

/*-------------------------------------------------------------------------*/
/* xmath.inc                                                               */
/*                                                                         */
/*                                                                         */
/*                                                                         */
/*-------------------------------------------------------------------------*/

#undef bool
#include "stdlib.h"
#include "math.h"
#include "bool.h"

bool b_on    (int bits, int bno);
int  b_set   (int current, int bno);
int  b_reset (int current, int bno);

int i_abs    (int a);
int i_sign   (int a);
int i_min    (int a, int b); 
int i_max    (int a, int b);
int i_mean   (int a, int b);
int i_random (int lower_bound, int upper_bound);
int i_bound  (int min, int i, int max);

double d_min       (double a, double b);
double d_max       (double a, double b);
double d_bound     (double min, double v, double max);
double d_abs       (double a);
double d_sign      (double a);
double d_round     (double d, int s);

float  f_min       (float a, float b);
float  f_max       (float a, float b);

double g_sin       (double x);
double g_cos       (double x);
double g_arc_sin   (double x);
double g_arc_cos   (double x);
double g_arc_tan2  (double dx, double dy);
double g_norm      (double a);
double g_diff      (double a1, double a2);

double d_random    (double lower_bound, double upper_bound);
void   d_randomize (int d);

int    hextoint    (char hex []);
char  *inttohex    (int  i);

#endif
