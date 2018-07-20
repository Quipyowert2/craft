
#include "craft_def.h"
#include "craft.h"
#include "building.h"

int docks_dir (int x0, int y0)
  {int  dir;
   bool ok;
   int  xs;
   int  ys;
   int  dx;
   int  dy;
   int  dd;

   xs = x0    ; ys = y0 - 1; dx = 1; dy = 0; dd = -1; check; if (ok) return 0;
   xs = x0    ; ys = y0 + 3; dx = 1; dy = 0; dd =  1; check; if (ok) return 4;
   xs = x0 - 1; ys = y0    ; dx = 0; dy = 1; dd = -1; check; if (ok) return 2;
   xs = x0 + 3; ys = y0    ; dx = 0; dy = 1; dd =  1; check; if (ok) return 6;
   return 0;     

.  check
     {ok = true;
      if   (dx != 0)
           check_dx
      else check_dy;
     }.

.  check_dx
     {for (int xw = xs; xw < xs + 3 && dx != 0; xw += dx)
        for (int i = 0; i < 3; i++)
            if (! land_properties [landscape [xw][ys + i * dd]].is_water)
               ok = false;
     }.

.  check_dy
     {for (int yw = ys; yw < ys + 3 && dy != 0; yw += dy)
        for (int i = 0; i < 3; i++)
            if (! land_properties [landscape [xs + i * dd][yw]].is_water)
               ok = false;
     }.

  }

int docks_pic (int dir, int dx, int dy, int state)
  {switch (dir)
     {case 0: return pic_docks + dy * 3 + dx;      break;
      case 2: return pic_docks + dy * 3 + dx + 30; break;
      case 4: return pic_docks + dy * 3 + dx + 10; break;
      case 6: return pic_docks + dy * 3 + dx + 20; break;
     };
  }

int docks_ship_pic (int dir, int dx, int dy, int state)
  {switch (dir)
     {case 0: return xpic_ship_on_dock + dy * 3 + dx;      break;
      case 2: return xpic_ship_on_dock + dy * 3 + dx + 30; break;
      case 4: return xpic_ship_on_dock + dy * 3 + dx + 10; break;
      case 6: return xpic_ship_on_dock + dy * 3 + dx + 20; break;
     };
  }

int docks_site_pic (int dir, int dx, int dy, int state)
  {switch (dir)
     {case 0: return pic_docks_built + dy * 3 + dx;      break;
      case 2: return pic_docks_built + dy * 3 + dx + 30; break;
      case 4: return pic_docks_built + dy * 3 + dx + 10; break;
      case 6: return pic_docks_built + dy * 3 + dx + 20; break;
     };
  }

int building_pic (int type, int dx, int dy, int state)
  {int base_pic;

   get_base_pic;
   if   (type == object_docks || type == object_site_docks)
        return base_pic + dy * 3 + dx;
   else return base_pic + dy * 2 + dx;
 
.  get_base_pic
     {switch (type)
       {case object_home          : base_pic = pic_town_hall;     break;
        case object_mine          : base_pic = pic_mine;          break;
        case object_building_site : base_pic = pic_building_site; break;
        case object_camp          : base_pic = pic_camp;          break;
        case object_farm          : base_pic = pic_farm;          break;
        case object_market        : base_pic = pic_market;        break;
        case object_tents         : base_pic = pic_tents;         break;
        case object_mill          : base_pic = pic_mill;          break;
        case object_smith         : base_pic = pic_smith;         break;
        case object_docks         : base_pic = pic_docks;         break;
        case object_site_docks    : base_pic = pic_docks_built;   break;
        case object_uni           : base_pic = pic_uni;           break;
       };
     }.
 
  }

char *building_name (int type)
  {static char r [128];

   get_name;
   return r;

.  get_name
     {switch (type)
       {case object_home          : strcpy (r, "townhall");       break;
        case object_mine          : strcpy (r, "mine");           break;
        case object_building_site : strcpy (r, "building site");  break;
        case object_site_docks    : strcpy (r, "building docks"); break;
        case object_camp          : strcpy (r, "camp");           break;
        case object_farm          : strcpy (r, "farm");           break;
        case object_market        : strcpy (r, "market");         break;
        case object_tents         : strcpy (r, "fort");           break;
        case object_mill          : strcpy (r, "lumber mill");    break;
        case object_smith         : strcpy (r, "smith");          break;
        case object_uni           : strcpy (r, "university");     break;
        case object_docks         : strcpy (r, "docks");          break;
        default                   : strcpy (r, "unknown");        break;
       };
     }.

  }

bool is_building (int type)
  {return (type == object_home       ||
           type == object_mine       ||
           type == object_camp       ||
           type == object_farm       ||
           type == object_market     ||
           type == object_tents      ||
           type == object_mill       ||
           type == object_smith      ||
           type == object_uni        ||
           type == object_site_docks ||
           type == object_docks      ||
           type == object_building_site);
  }

bool is_building (int x, int y)
  {int u = unit [x][y];

   return (u != none && is_building (objects->type [u]));
  }
