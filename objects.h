#include "float.h"
#include "stdio.h"
#include "math.h"
#include "bool.h"
#include "xmath.h"

#ifndef objects_h
#define objects_h

/*----------------------------------------------------------------------*/
/* forward references                                                   */
/*----------------------------------------------------------------------*/

struct vector;
struct config;
struct point;
struct line;
struct plane;

/*----------------------------------------------------------------------*/
/* point (declarations)                                                 */
/*----------------------------------------------------------------------*/

struct point
  {double x;
   double y;
   double z;
  };

point  new_point   (double x, double y, double z);
void   print       (point p);
void   scan        (point &p);
point  operator +  (point p,     point  v);
point  operator +  (point p,     vector v);
point  operator -  (point p,     vector v);
point  operator +  (point p,     point  p1);
point  operator -  (point p,     point  p1);
point  operator *  (point p1,    point  p2);
point  operator /  (point p1,    point  p2);
point  operator /  (point p1,    double d);
point  rotate      (point pivot, point  p, double ax, double ay, double az);
point  floor       (point p);
double dist        (point p1,    point p2);
double qdist       (point p1,    point p2);
bool   operator <= (point p1,    point p2);
bool   operator <  (point p1,    point p2);
bool   operator << (point p1,    point p2);
bool   operator == (point p1,    point p2);
bool   operator != (point p1,    point p2);
point  p_min       (point p1,    point p2);
point  p_max       (point p1,    point p2);
point  p_bound     (point p1,    point p2, point p3);
point  rotate      (point p,     line  axis, double angle);

/*----------------------------------------------------------------------*/
/* vector (declarations)                                                */
/*----------------------------------------------------------------------*/

struct vector
  {double dx;
   double dy;
   double dz;
  };

vector new_vector  (line l);
vector new_vector  (double dx, double dy, double dz);
vector new_vector  (point  p1, point  p2);
void   print       (vector v);
vector operator +  (vector v1, vector v2);
vector operator -  (vector v1, vector v2);
vector operator *  (vector v1, double s);
double operator *  (vector v1, vector v2);
vector operator /  (vector v1, double s);
vector operator -  (vector v);
bool   operator == (vector p1,    vector p2);
bool   operator != (vector p1,    vector p2);
vector sign        (vector p);
vector sign        (vector p, int round_factor);
vector abs         (vector p);
bool   parallel    (vector v1, vector v2);
bool   parallel    (vector v1, vector v2, double d);

vector cross      (vector v1, vector v2);
point  rotate     (point  pivot, point  p, double ax, double ay, double az);
vector perp       (vector    v1, vector v2);
double length     (vector v);
double angle      (vector v1,    vector v2);
double preangle   (vector v1,    vector v2);
vector set_length (vector v, double s);

point  gen        (point p0, vector v [3], vector a);
void   get_gen    (point  p,
                   point  p1,
                   point  p2,
                   point  p3,
                   double &a,
                   double &b);

/*----------------------------------------------------------------------*/
/* line (declarations)                                                  */
/*----------------------------------------------------------------------*/

struct line
  {point p0;
   point p1;
  };

line          new_line (point p0, point p1);
bool operator ==       (line l1, line l2);
void          print    (line l);
line          expand   (line l, double extent);

/*----------------------------------------------------------------------*/
/* triangle (declarations)                                              */
/*----------------------------------------------------------------------*/

struct triangle
  {point p0;
   point p1;
   point p2;
  };

triangle new_triangle (point p0, point p1, point p2);
void     hull     (triangle t, point &pmin, point &pmax);
bool     inside   (triangle t, point p);

/*----------------------------------------------------------------------*/
/* rectangle (declarations)                                             */
/*----------------------------------------------------------------------*/

struct rectangle
  {point p0;
   point p1;
   point p2;
   point p3;
  };

rectangle new_rectangle (point p0, point p1, point p2, point p3);
rectangle new_rectangle (double p [12]);
  
/*----------------------------------------------------------------------*/
/* cube (declarations)                                                  */
/*----------------------------------------------------------------------*/

struct cube
  {point p0;
   point p1;
   point p2;
   point p3;
  };

cube   new_cube       (point  p0, point p1, point p2, point p3);
cube   new_cube       (point  p, double dx, double dy, double dz);
cube   new_cube       (double p [12]);
bool   operator ==    (cube a, cube b);
bool   operator !=    (cube a, cube b);
cube   operator +     (cube a, vector v);
void   print          (cube c);
point  corner         (cube  c,  int   corner_no);
point  center         (cube c);
cube   rotate         (cube c, point pivot, double ax, double ay, double az);
cube   rotate         (cube c, point p, vector axis, double angle);
cube   rotate         (cube c, line axis, double angle);
void   edges          (cube c, line edge_list [12]);
plane  xplane         (cube  c, int side_no);
void   xplane         (cube  c,  int   side_no, 
                       point &p0, point &p1, point &p2, point &pl);
void   xplane         (cube  c,  int corner, int   side_no, 
                       point &p0, point &p1, point &p2, point &pl);
bool   hulls_disjunct (cube c1, cube c2);
bool   disjunct       (cube  c1, cube  c2, bool with_trace = false);
cube   normalize      (cube c);
cube   shift          (cube c, vector d);
cube   set_size       (cube c, double sx, double sy, double sz);
cube   cover          (cube c, double d);
void   hull           (cube c, point &min, point &max);
bool   inside         (cube c, point p);
int    parside        (cube c, vector v);
vector sidevect       (cube c, int s);
bool   is_edge        (cube c, vector v);
vector shortest_side  (cube c);
vector longest_side   (cube c);
plane  bottom         (cube c);
plane  top            (cube c);
void   get_gen        (point p, cube c, vector &v);
point  gen            (cube c, vector v);
bool   intersect      (cube c, line l,  point  &ip, point &ip1);
bool   intersect      (cube c, cube c1, point  ip [32]);
void   nearest_points (cube c1, cube c2, point &p1, point &p2);
point  nearest_point  (cube c1, point p);
double dist           (cube c1, cube c2);
double dist           (cube c,  point p);

/*----------------------------------------------------------------------*/
/* config (declarations)                                                */
/*----------------------------------------------------------------------*/

#define max_config_size 10

struct config
  {double v [max_config_size];
  };

config new_config          (double v []);
config nil_config          ();
void   print               (config c);
double dist                (config c1, config c2);
double qdist               (config c1, config c2);
config operator +          (config c1, config c2);
config operator -          (config c1, config c2);
bool   is_nil              (config c);
bool   operator ==         (config c1, config c2);
bool   operator !=         (config c1, config c2);
void   check_compatibility (config c1, config c2, char operation []);
config sign                (config c1);

/*----------------------------------------------------------------------*/
/* plane (declarations)                                                 */
/*----------------------------------------------------------------------*/

struct plane
  {point p0;
   point p1;
   point p2;
  };

plane  new_plane   (point p0, point p1, point p2);
plane  new_plane   (vector v0, vector v1);
void   print       (plane p);
bool   operator == (plane a, plane b);
plane  operator -  (plane a);
bool   operator != (plane a, plane b);
bool   on          (plane a, point p);
point  center      (plane p);
bool   intersect   (plane p, line l, point &ip);
point  socket      (plane p, point op);
double angle       (plane p, vector v);
double angle       (plane p1, plane p2);

/*----------------------------------------------------------------------*/
/* scene (declarations)                                                 */
/*----------------------------------------------------------------------*/

#define max_scene_elements 200

struct scene
  {int  num_elements;
   char name  [128];
   cube cubes [max_scene_elements];
   char names [max_scene_elements][128];
  };

scene new_scene (char s_name []);
void  add       (scene &s, cube c, char c_name []);
cube  xcube     (scene s, char c_name []);
void  print     (scene s);

/*----------------------------------------------------------------------*/
/* NILS                                                                 */
/*----------------------------------------------------------------------*/

#define NaN           -(FLT_MAX-1)
#define nil_angle     NaN
#define nil_point     new_point     (NaN, NaN, NaN)
#define nil_line      new_line      (nil_point, nil_point)
#define nil_vector    new_vector    (NaN, NaN, NaN)
#define nil_triangle  new_triangle  (nil_point,nil_point,nil_point)
#define nil_rectangle new_rectangle (nil_point,nil_point,nil_point, nil_point)
#define nil_cube      new_cube      (nil_point,nil_point,nil_point, nil_point)
#define nil_plane     new_plane     (nil_point,nil_point,nil_point)

#endif


