#ifndef violation_h
#define violation_h

extern void
__array_bounds_violation (char const *file_name, int line_number,
                          char const *array_name, int upper_bound,
                          char const *index_name, int bad_index);


#endif
