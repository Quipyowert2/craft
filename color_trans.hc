
#include "color_trans.h"

color_trans::color_trans ()
  {for (int i = 0; i < 256; i++)
     translate [i] = i;
  }

color_trans::~color_trans() 
  {
  }

void color_trans::add (int c1, int c2)
  {translate [c1] = c2;
  }

int color_trans::trans (int c)
  {return translate [c];
  }
