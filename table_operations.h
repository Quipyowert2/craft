#ifndef table_operations_h
#define table_operations_h

/*======================================================================*/
/*= CHANGES AND UPDATES                                                =*/
/*======================================================================*/
/*= date   person file               subject                           =*/
/*=--------------------------------------------------------------------=*/
/*=                                                                    =*/
/*= 260493 hua    table_operations.h created                           =*/
/*=                                                                    =*/
/*======================================================================*/

void table_id    (char t1 [],
                  char t2 []);

void table_join  (char t1  [], char cols1 [],
                  char t2  [], char cols2 [],
                  char exp [],
                  char t3  []);

void table_union (char t1 [], char t2, char t3 []);


#endif
