#ifndef building_h
#define building_h

int   building_pic   (int type, int dx, int dy, int state);
int   docks_pic      (int dir,  int dx, int dy, int state);
int   docks_ship_pic (int dir,  int dx, int dy, int state);
int   docks_site_pic (int dir,  int dx, int dy, int state);
int   docks_dir      (int x0, int y0);
char *building_name  (int type);
bool  is_building    (int type);
bool  is_building    (int x, int y);

#endif
