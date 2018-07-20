#ifndef land_h
#define land_h

#include "bool.h"
#include "craft_def.h"
#include "craft.h"

void new_land         (char name [], int dx, int dy);

void init_land_units  ();
void load_land        (char name []);
void rnd_land         ();
void rnd_water_land   ();
void load_units       (char name []);
void load_land_props  ();

void save_land        (char name []);

void land_push        (int id, int x, int y, int dx, int dy);
void land_push        (int id, int x, int y, int dx, int dy, int nx, int ny);
void land_push        (int id, int x, int y);
void land_pop         (int id, int x, int y, int dx, int dy);
void land_pop         (int id, int x, int y, int dx, int dy, int nx, int ny);
void land_pop         (int id, int x, int y);

bool is_water         (int id, int x, int y);
bool is_water         (int id, int x, int y, int gid);

int  land_profile     (int x, int y, int min_d);

bool anything_on_land (int x, int y); 

int  land_num_il ();
int  land_x_il   (int i);
int  land_y_il   (int i); 

void trace_il    ();

#endif
