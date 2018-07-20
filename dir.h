#ifndef dir_h
#define dir_h

int  dir_left  (int dir);
int  dir_right (int dir);
void dir_dx_dy (int dir, int &dx, int &dy);
int  direction (int dx, int dy);
int  dir_back  (int dir);
int  fdir      (int dx, int dy);
int  left_dist (int dir1, int dir2);

#endif  
