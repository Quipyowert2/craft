
#ifndef morph_h
#define morph_h

#include "objects.h"
#include "ppm.h"

void morph (ppm      *pa, 
            ppm      *pb, 
            ppm      *pc,
            triangle ta,
            triangle tb,
            double   s);

void morph (char orig       [],
            char dest       [],
            char background [],
            char triangles  [],
            int  number_of_steps);


#endif
