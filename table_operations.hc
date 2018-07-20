/*======================================================================*/
/*= CHANGES AND UPDATES                                                =*/
/*======================================================================*/
/*= date   person file                subject                          =*/
/*=--------------------------------------------------------------------=*/
/*=                                                                    =*/
/*= 260493 hua    table_operations.hc created                          =*/
/*=                                                                    =*/
/*======================================================================*/

#include "collist.h"
#include "table.h"
#include "table_operations.h"
#include "bool.h"

void table_id (char t1 [], char t2 [])
  {table *ta;
   table *tb;
   bool  d;

   create_tb;
   gen_id;
   close_tables;

.  close_tables
     {delete (ta);
      delete (tb);
     }.
  
.  create_tb
     {ta = new table ("", t1, d);
      tb = new table ("", t2, d);
      tb->add_column ("id", col_type_int);
      for (int i = 0; i < ta->num_columns (); i++)
        tb->add_column (ta->column_name [i], ta->column_type [i]);
     }.

.  gen_id
     {for (int r = 0; r < ta->num_rows (); r++)
        add_row_to_tb;
     }.

.  add_row_to_tb
     {tb->append (0, r);
      for (int c = 0; c < ta->num_columns (); c++)
        write_column;
     }.

.  write_column
     tb->append (c+1, ta->read_int (r, c)).

  }

void table_join (char t1  [], char cols1 [],
                 char t2  [], char cols2 [],
                 char exp [],
                 char t3  [])

  {table   *ta;
   table   *tb;
   table   *tc;
   collist *colsa;
   collist *colsb;

   open_tables;
   open_collists;
   create_tc;
   exec_join;
   close_tables;

.  close_tables
     {delete (ta);
      delete (tb);
      delete (tc);
     }.

.  open_tables
     {bool d;

      ta = new table ("", t1, d);
      tb = new table ("", t2, d);
      tc = new table ("", t3, d);
     }.

.  open_collists
     {colsa = new collist (cols1);
      colsb = new collist (cols2);
     }.

.  create_tc
     {int c;

      for (c = 0; c < colsa->num (); c++)
        tc->add_column (ta->column_name [colsa->col (c)],
                        ta->column_type [colsa->col (c)]);
      for (c = 0; c < colsb->num (); c++)
        tc->add_column (tb->column_name [colsb->col (c)],
                        tb->column_type [colsb->col (c)]);
     }.

.  exec_join
     {for (int ra = 0; ra < ta->num_rows (); ra++)
        for (int rb = 0; rb < tb->num_rows (); rb ++)
          test_join;
     }.

.  test_join
     if (match)
        append_tc.

.  append_tc
     {int i = 0;
      int c;

      for (c = 0; c < colsa->num (); c++)
        tc->append (i++, ta->read_int (ra, colsa->col (c)));
      for (c = 0; c < colsb->num (); c++)
        tc->append (i++, tb->read_int (rb, colsb->col (c)));
     }.

.  match
     (true).

  }

void table_append (char t1 [], char t2 [])
  {table *ta;
   table *tb;

   open_tables;
   perform_append;
   close_tables;

.  close_tables
     {delete (ta);
      delete (tb);
     }.

.  open_tables
     {bool d;

      ta = new table ("", t1, d);
      tb = new table ("", t2, d);
     }.

.  perform_append
     {for (int r = 0; r < tb->num_rows (); r++)
       for (int c = 0; c < tb->num_columns (); c++)
         append_column;
     }.

.  append_column
     ta->append (c, tb->read_int (r, c)).

  }
