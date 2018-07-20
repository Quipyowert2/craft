#ifndef table_h
#define table_h
 
/*======================================================================*/
/*= CHANGES AND UPDATES                                                =*/
/*======================================================================*/
/*= date   person file       subject                                   =*/
/*=--------------------------------------------------------------------=*/
/*=                                                                    =*/
/*= 260493 hua    table.h    created                                   =*/
/*=                                                                    =*/
/*======================================================================*/

#include "stdlib.h"
#include "stdio.h"
#include "string.h"

#include "errorhandling.h"
#include "xfile.h"
#include "lru.h"

#include "bool.h"
#include "io.h"
#include "objects.h"

/*----------------------------------------------------------------------*/
/* CLASS table (deklarations)                                           */
/*----------------------------------------------------------------------*/

#define max_columns      20
#define max_rows      10000
#define rows_per_grab    10

#define col_type_int    1
#define col_type_float  2
#define col_type_text   3
#define col_type_point  4
#define col_type_cube   5
#define col_type_config 6
#define col_type_vector 7
#define col_type_plane  8

#define no_lru_candidate -1

class table
  {public : 

     int  number_of_columns;
     int  number_of_rows;
     int  column_length;
     int  id;
     int  data_size;
     bool was_write_access;
     bool is_lru;
     int  row_no;
 
     lru  *lru_queue;
     int  lru_size;
     int  column_type  [max_columns];
     int  column_size  [max_columns];
     char column_name  [max_columns][128];
     int  column_index [max_columns];
     char *data;

     char name [128];
     char dir  [128];

     table  (char dir [], char name [], bool &is_new, int lru_size = 0);
     ~table ();

     void  check_bound (int adr, int row_no, int column_no, char action []);
     void  save        ();
     void  load        ();

     void  rename      (char  new_dir [], char new_name []);
     void  rename      (char  new_name []);
     void  copy        (table *destination); 

     int   add_column  (char name [], int type);
     int   column_no   (char name []);
     int   num_columns (); 

     int   candidate   (bool &with_remove);
     int   freshest    (int no);
     int   num_rows    ();
     int   add_row     ();
     int   insert_row  (int row_no);
     void  delete_row  (int row_no);
     void  clear       ();
     void  access_row  (int row_no);
    

     int    read_int    (int row_no, int column_no);
     float  read_float  (int row_no, int column_no);
     char*  read_text   (int row_no, int column_no);
     point  read_point  (int row_no, int column_no);
     plane  read_plane  (int row_no, int column_no);
     cube   read_cube   (int row_no, int column_no);
     config read_config (int row_no, int column_no);
     vector read_vector (int row_no, int column_no);

     void  write       (int row_no, int column_no, int    value);
     void  write       (int row_no, int column_no, float  value);
     void  write       (int row_no, int column_no, double value);
     void  write       (int row_no, int column_no, char   value []);
     void  write       (int row_no, int column_no, point  value);
     void  write       (int row_no, int column_no, plane  value);
     void  write       (int row_no, int column_no, cube   value);
     void  write       (int row_no, int column_no, config value);
     void  write       (int row_no, int column_no, vector value);

     int   append      (int column_no, int    value);
     int   append      (int column_no, float  value);
     int   append      (int column_no, double value);
     int   append      (int column_no, char   value []);
     int   append      (int column_no, point  value);
     int   append      (int column_no, plane  value);
     int   append      (int column_no, cube   value);
     int   append      (int column_no, config value);
     int   append      (int column_no, vector value);

 };

/*----------------------------------------------------------------------*/
/* MODULE table handler (deklarations)                                  */
/*----------------------------------------------------------------------*/

#define resident        0
#define paged           1
#define max_open_tables 5000

void open_table_handler  (char global_table_dir [], 
                          char local_table_dir  []);
void close_table_handler (bool flush_buffers);
void dump_table_handler  ();
void flush_table_handler ();

bool  table_exists (char dir [], char name []);
table *table_open  (char name [],
                    bool &is_new,
                    int  paging_mode = paged,
                    int  lru_size    = 0);
void  table_close  (table *);
void  table_rename (table *t, char new_name []);
void  table_delete (table *t);

#endif
