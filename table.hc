/*======================================================================*/
/*= CHANGES AND UPDATES                                                =*/
/*======================================================================*/
/*= date   person file       subject                                   =*/
/*=--------------------------------------------------------------------=*/
/*=                                                                    =*/
/*= 260493 hua    table.hc   created                                   =*/
/*=                                                                    =*/
/*======================================================================*/
   
#include "table.h"

#include "bool.h"
#include "io.h"

/*----------------------------------------------------------------------*/
/* CLASS table (functions)                                              */
/*----------------------------------------------------------------------*/

table::table (char t_dir [], char t_name [], bool &is_new, int t_lru_size)
  {strcpy (name, t_name);
   strcpy (dir,  t_dir);
   init_status_data;
   init_lru;
   perhaps_load_table;
   message;

. message
    {
    }.

.  init_lru
     {lru_size = t_lru_size;
      is_lru   = (lru_size != 0);
      if (is_lru)
         lru_queue = new lru (lru_size);
     }.

.  init_status_data
     {column_length     = 0;
      number_of_rows    = 0;
      number_of_columns = 0;
      data_size         = 0;
      was_write_access  = false;
     }.

.  perhaps_load_table
     {char f_name [128];

      is_new = true;
      sprintf (f_name, "%s%s", dir, name);
      if (f_exists (f_name))
         {load ();
          is_new = false;
         };
     }.
  
  }
        
table::~table ()
  {if (was_write_access)
      save ();
   if (data_size != 0)
      delete (data);
   if (is_lru)
      delete (lru_queue);
  }
   
void table::check_bound (int adr, int row_no, int column_no, char action [])
  {if (row_no < 0 || row_no >= number_of_rows) {
       fprintf (stderr, "row = %d\n", row_no);
       errorstop (4, "table", action, "row out of range", name);
     }
   if (column_no < 0 || column_no >= number_of_columns)
      errorstop (5, "table", action, "column out of range", name);
   if (adr < 0 || adr >= data_size)
      errorstop (6, "table", action, "adr out of range", name);
  }

void table::save ()
  {FILE *f;

   perhaps_swap_message;
   open_save_file;
   enter_dd;
   enter_data;
   close_save_file;
   perhaps_delete_empty_file;

.  perhaps_swap_message
     {
     }.

.  open_save_file
     {char fname [128];

      sprintf (fname, "%s%s", dir, name);
      f = fopen (fname, "w");
     }.

.  close_save_file
     {fclose (f);
     }.

.  perhaps_delete_empty_file
     if (number_of_rows == 0)
        delete_empty_file.

.  delete_empty_file
     {char cmd [128];

      sprintf (cmd, "rm -f %s%s", dir, name);
      system  (cmd);
      printf ("file '%s' was empty\n", name);
     }.

.  enter_dd
     {fprintf (f, "%d %d %d %d %d\n", 
               number_of_columns,
               number_of_rows,
               column_length,
               max_rows,
               id);
      for (int i = 0; i < number_of_columns; i++)
        fprintf (f, "%s %d %d %d\n", 
                 column_name  [i],
                 column_type  [i],
                 column_size  [i],
                 column_index [i]);
     }.

.  enter_data
     {if   (is_lru)
           write_lru_table
      else write_none_lru_table;
     }.

.  write_lru_table
     {for (int k = number_of_rows-1; k >= 0; k--)
        {write_lru_record;
        };
     }.

.  write_lru_record
     {int i = freshest (k);
      
      write_record;
     }.

.  write_none_lru_table
     {for (int i = 0; i < number_of_rows; i++)
        {write_record;
        };
     }.

.  write_record
     {for (int j = 0; j < number_of_columns; j++)
        write_field;
      fprintf (f, "\n");
     }.

.  write_field
     switch (column_type [j])
       {case col_type_int    : fprintf (f, "%d ", read_int   (i, j)); break;
        case col_type_float  : fprintf (f, "%f ", read_float (i, j)); break;
        case col_type_text   : fprintf (f, "%s ", read_text  (i, j)); break;
        case col_type_point  : save_point;                            break;
        case col_type_cube   : save_cube;                             break;
        case col_type_config : save_config;                           break;
        case col_type_vector : save_vector;                           break;
        case col_type_plane  : save_plane;                            break;
       }.

.  save_point
     {point p;

      p = read_point (i, j);
      fprintf (f, "%f %f %f ", p.x, p.y, p.z);
     }.

.  save_cube
     {cube c;

      c = read_cube (i, j);
      fprintf (f, "%f %f %f %f %f %f %f %f %f %f %f %f ", 
               c.p0.x, c.p0.y, c.p0.z,
               c.p1.x, c.p1.y, c.p1.z,
               c.p2.x, c.p2.y, c.p2.z,
               c.p3.x, c.p3.y, c.p3.z);
     }.

.  save_plane
     {plane p;

      p = read_plane (i, j);
      fprintf (f, "%f %f %f %f %f %f %f %f %f ", 
               p.p0.x, p.p0.y, p.p0.z,
               p.p1.x, p.p1.y, p.p1.z,
               p.p2.x, p.p2.y, p.p2.z);
     }.

.  save_config
     {config c;

      c = read_config (i, j);
      fprintf (f, "%d ", max_config_size);
      for (int g = 0; g < max_config_size; g++)
        fprintf (f, "%f ", c.v [g]);
     }.

.  save_vector
     {vector v;

      v = read_vector (i, j);
      fprintf (f, "%f %f %f ",  v.dx, v.dy, v.dz);
     }.

  }
   
void table::load ()
  {FILE *f;

   open_load_file;
   load_dd;
   load_data;
   close_load_file;

.  open_load_file
     {char fname [128];

      sprintf (fname, "%s%s", dir, name);
      f = fopen (fname, "r");
     }.

.  close_load_file
     {fclose (f);
     }.
      
.  load_dd
     {int d;

      fscanf (f, "%d %d %d %d %d",
              &number_of_columns,
              &number_of_rows,
              &column_length,
              &d,
              &id);
      for (int i = 0; i < number_of_columns; i++)
        load_column;
     }.

.  load_column
     {fscanf (f, "%s %d %d %d\n", 
              column_name  [i],
              &column_type  [i],
              &column_size  [i],
              &column_index [i]);
     }.

.  load_data
     {int num_rows = number_of_rows;

      number_of_rows = 0;
      for (int i = 0; i < num_rows; i++)
        read_record;
     }.

.  read_record
     {int row_no = add_row ();

      for (int j = 0; j < number_of_columns; j++)
        read_field;
      fscanf (f, "\n");
     }.

.  read_field
     switch (column_type [j])
       {case col_type_int    : read_int;    break;
        case col_type_float  : read_float;  break;
        case col_type_text   : read_text;   break;
        case col_type_point  : read_point;  break;
        case col_type_cube   : read_cube;   break;
        case col_type_config : read_config; break;
        case col_type_vector : read_vector; break;
        case col_type_plane  : read_plane; break;
       }.

.  read_point
     {point p;
      float x;
      float y;
      float z;

      fscanf (f, "%f %f %f ", &x, &y, &z);
      p.x = x;
      p.y = y;
      p.z = z;
      write  (row_no, j, p);
     }.

.  read_cube
     {cube  c;
      float p0x;
      float p0y;
      float p0z;
      float p1x;
      float p1y;
      float p1z;
      float p2x;
      float p2y;
      float p2z;
      float p3x;
      float p3y;
      float p3z;

      fscanf (f, "%f %f %f %f %f %f %f %f %f %f %f %f ", 
              &p0x, &p0y, &p0z, 
              &p1x, &p1y, &p1z, 
              &p2x, &p2y, &p2z, 
              &p3x, &p3y, &p3z);
      write  (row_no, j, new_cube (new_point (p0x, p0y, p0z),
                                   new_point (p1x, p1y, p1z),
                                   new_point (p2x, p2y, p2z),
                                   new_point (p3x, p3y, p3z)));
     }.

.  read_plane
     {cube  p;
      float p0x;
      float p0y;
      float p0z;
      float p1x;
      float p1y;
      float p1z;
      float p2x;
      float p2y;
      float p2z;

      fscanf (f, "%f %f %f %f %f %f %f %f %f ", 
              &p0x, &p0y, &p0z, 
              &p1x, &p1y, &p1z, 
              &p2x, &p2y, &p2z);
      write  (row_no, j, new_plane (new_point (p0x, p0y, p0z),
                                    new_point (p1x, p1y, p1z),
                                    new_point (p2x, p2y, p2z)));
     }.

.  read_config
     {config c;
      float  a;
      int    size;

      fscanf (f, "%d ", &size);
      for (int g = 0; g < max_config_size; g++)
        {fscanf (f, "%f ", &a);
         c.v [g] = a;
        };
      write  (row_no, j, c);
     }.

.  read_vector
     {vector v;
      float a0;
      float a1;
      float a2;

      fscanf (f, "%f %f %f ", &a0, &a1, &a2);
      write  (row_no, j, new_vector (a0, a1, a2));
     }.
      
.  read_int
     {int k;

      fscanf (f, "%d ", &k);
      write  (row_no, j, k);
     }.

.  read_float
     {float k;

      fscanf (f, "%f ", &k);
      write  (row_no, j, k);
     }.

.  read_text
     {char t [128];

      fscanf (f, "%s ", t);
      write  (row_no, j, t);
     }.

  }
   
void table::rename (char new_name [])
  {rename (dir, new_name);
  }

void table::rename (char new_dir [], char new_name [])
  {char cmd [128];

   /* sprintf (cmd, "rm %s%s", dir, name);
   system  (cmd); */
   strcpy  (dir,  new_dir);
   strcpy  (name, new_name);
   was_write_access = true;
  }

void table::copy (table *dest)
  {copy_status_data;
   copy_row_data;

.  copy_status_data
     {dest->number_of_columns = number_of_columns;
      dest->number_of_rows    = number_of_rows;
      dest->column_length     = column_length;
      dest->was_write_access  = true;
      dest->data_size         = data_size;
      dest->data              = new char [data_size];
     }.

.  copy_row_data
     {memcpy (dest->data, data, data_size);
     }.

  }

int table::add_column (char name [], int type)
  {int col_no;

   get_col_no;
   set_size;
   col_type         =  type;
   col_index        =  column_length;
   strcpy (col_name, name);
   column_length    += col_size;
   was_write_access =  true;
   return col_no;

.  set_size
     switch (type)
       {case col_type_int    : col_size = 4;           break;
        case col_type_float  : col_size = 8;           break;
        case col_type_text   : col_size = 128;         break;
        case col_type_point  : col_size = 24;          break;
        case col_type_cube   : col_size = 96;          break;
        case col_type_config : col_size = config_size; break;
        case col_type_vector : col_size = 24;          break;
        case col_type_plane  : col_size = 72;          break;
       }.

.  config_size
     max_config_size * sizeof (double) + sizeof (int).

.  get_col_no
     {col_no = number_of_columns++;
     }.
             
.  col_type   column_type  [col_no].
.  col_size   column_size  [col_no].
.  col_name   column_name  [col_no].
.  col_index  column_index [col_no].

  }
   
int table::column_no (char name [])
  {for (int i = 0; i < number_of_rows; i++)
     if (strcmp (column_name [i], name) == 0)
        return i;
   return -1;
  } 

int table::num_columns ()
  {return number_of_columns;
  }

int table::num_rows ()
  {return number_of_rows;
  }

void table::clear ()
  {number_of_rows   = 0;
   was_write_access = true;
   if (is_lru)
      lru_queue->clear ();
  }
   
void table::access_row (int row_no)
  {lru_queue->access (row_no);
  }

int table::candidate (bool &with_remove)
  {if   (is_lru)
        get_lru_candidate
   else handle_no_candidate;

.  handle_no_candidate
     {with_remove = false;
      return no_lru_candidate;
     }.

.  get_lru_candidate
     {return lru_queue->candidate (with_remove);
     }.

  }

int table::freshest (int no)
  {if   (is_lru)
        get_lru_freshest
   else handle_no_freshest;

.  handle_no_freshest
     {return no_lru_candidate;
     }.

.  get_lru_freshest
     {return lru_queue->freshest (no);
     }.

  }

int table::add_row ()
  {int row_no;

   grab_row_no;
   perhaps_grab_mem;
   was_write_access = true;
   perhaps_too_many_rows;
   return row_no;

.  grab_row_no
     if   (is_lru)
          grab_lru_row
     else grab_non_lru_row.

.  grab_non_lru_row
     {number_of_rows++;
      row_no = number_of_rows - 1;
     }.
    
.  grab_lru_row
     {bool must_remove;

      row_no         = lru_queue->add (must_remove);
      number_of_rows = i_max (number_of_rows, row_no + 1);
     }.

.  perhaps_grab_mem
     if (data_size <= (number_of_rows + 1) * column_length)
        grab_new_mem.

.  grab_new_mem
     {char *new_mem;
      bool must_delete = (data_size != 0);

      new_mem   = new char [data_size + grab_increment];
      if (data_size != 0)
         memcpy (new_mem, data, data_size);
      data_size += grab_increment;
      if (must_delete)
         delete (data);
      data      = new_mem;
     }.

.  grab_increment
     (column_length * rows_per_grab).

.  perhaps_too_many_rows
     if (number_of_rows > max_rows)
        {printf    ("rows = %d\n", number_of_rows);
         errorstop (1, "table", "add_row", "too many rows", name);
        }.

  }

void table::delete_row (int row_no)
  {was_write_access = true;
   handle_lru_remove;
   check_bound (to_ptr,             row_no, 0, "delete_row");  
   check_bound (to_ptr + move_size, row_no, 0, "delete_row");  
   memmove     (to_addr, from_addr, move_size);
   number_of_rows--;

.  handle_lru_remove
     if (is_lru)
        lru_queue->remove (row_no).

.  to_ptr
     row_no * column_length.

.  to_addr
     &data [row_no * column_length].

.  from_addr
     &data [(row_no+1) * column_length].

.  move_size
     (number_of_rows - row_no - 1) * column_length.

  }

int table::insert_row (int row_no)
  {was_write_access = true;
   check_lru;
   check_bound (to_ptr,             row_no, 0, "insert_row");  
   check_bound (to_ptr + move_size, row_no, 0, "insert_row");  
   add_row ();
   shift_data;
   return row_no;
   
.  check_lru
     {if (is_lru)
         errorstop (9, "table", "insert", " in lru mode", name);
     }.

.  shift_data
     {memmove (to_addr, from_addr, move_size);
     }.

.  to_ptr
     (row_no+1) * column_length.

.  to_addr
     &data [(row_no+1) * column_length].

.  from_addr
     &data [row_no * column_length].

.  move_size
     (number_of_rows - row_no - 1) * column_length.

  }
      
int table::read_int (int row_no, int column_no)
  {check_bound (col_ptr, row_no, column_no, "read_int");  
   check_type;
   return *(int*)(&data [col_ptr]);

.  check_type
     if (column_type [column_no] != col_type_int)
        errorstop (2, "table", "read_int", "wrong type", name).

.  col_ptr
     row_no * column_length + column_index [column_no].

  }

float table::read_float (int row_no, int column_no)
  {check_bound (col_ptr, row_no, column_no, "read_float");  
   check_type;
   return *(float*)(&data [col_ptr]);

.  check_type
     if (column_type [column_no] != col_type_float)
        errorstop (2, "table", "read_float", "wrong type", name).

.  col_ptr
     row_no * column_length + column_index [column_no].

  }

char* table::read_text (int row_no, int column_no)
  {check_bound (col_ptr, row_no, column_no, "read_text");  
   check_type;
   return &data [col_ptr];

.  check_type
     if (column_type [column_no] != col_type_text)
        errorstop (2, "table", "read_text", "wrong type", name).

.  col_ptr
     row_no * column_length + column_index [column_no].

  }

point table::read_point (int row_no, int column_no)
  {point p;

   check_bound (col_ptr, row_no, column_no, "read_point");  
   check_type;
   p.x = *(float*)(&data [col_ptr]);
   p.y = *(float*)(&data [col_ptr+8]);
   p.z = *(float*)(&data [col_ptr+16]);
   return p;

.  check_type
     if (column_type [column_no] != col_type_point)
        errorstop (2, "table", "read_point", "wrong type", name).

.  col_ptr
     row_no * column_length + column_index [column_no].

  }

cube table::read_cube (int row_no, int column_no)
  {cube c;

   check_bound (col_ptr, row_no, column_no, "read_cube");  
   check_type;
   c.p0.x = *(float*)(&data [col_ptr]);
   c.p0.y = *(float*)(&data [col_ptr+8]);
   c.p0.z = *(float*)(&data [col_ptr+16]);
   c.p1.x = *(float*)(&data [col_ptr+24]);
   c.p1.y = *(float*)(&data [col_ptr+32]);
   c.p1.z = *(float*)(&data [col_ptr+40]);
   c.p2.x = *(float*)(&data [col_ptr+48]);
   c.p2.y = *(float*)(&data [col_ptr+56]);
   c.p2.z = *(float*)(&data [col_ptr+64]);
   c.p3.x = *(float*)(&data [col_ptr+72]);
   c.p3.y = *(float*)(&data [col_ptr+80]);
   c.p3.z = *(float*)(&data [col_ptr+88]);
   return c;

.  check_type
     if (column_type [column_no] != col_type_cube)
        errorstop (2, "table", "read_cube", "wrong type", name).

.  col_ptr
     row_no * column_length + column_index [column_no].

  }

plane table::read_plane (int row_no, int column_no)
  {plane p;

   check_bound (col_ptr, row_no, column_no, "read_plane");  
   check_type;
   p.p0.x = *(float*)(&data [col_ptr]);
   p.p0.y = *(float*)(&data [col_ptr+8]);
   p.p0.z = *(float*)(&data [col_ptr+16]);
   p.p1.x = *(float*)(&data [col_ptr+24]);
   p.p1.y = *(float*)(&data [col_ptr+32]);
   p.p1.z = *(float*)(&data [col_ptr+40]);
   p.p2.x = *(float*)(&data [col_ptr+48]);
   p.p2.y = *(float*)(&data [col_ptr+56]);
   p.p2.z = *(float*)(&data [col_ptr+64]);
   return p;

.  check_type
     if (column_type [column_no] != col_type_plane)
        errorstop (2, "table", "read_plane", "wrong type", name).

.  col_ptr
     row_no * column_length + column_index [column_no].

  }

config table::read_config (int row_no, int column_no)
  {config c;

   check_bound (col_ptr, row_no, column_no, "read_config");  
   check_type;
   for (int i = 0; i < max_config_size; i++)
     c.v [i] = *(float*)
                (&data [col_ptr + (i * sizeof (double))] +sizeof (int));
   return c;

.  check_type
     if (column_type [column_no] != col_type_config)
        errorstop (2, "table", "read_config", "wrong type", name).

.  col_ptr
     row_no * column_length + column_index [column_no].

  }

vector table::read_vector (int row_no, int column_no)
  {vector v;

   check_bound (col_ptr, row_no, column_no, "read_vector");  
   check_type;
   v.dx = *(float*)(&data [col_ptr]);
   v.dy = *(float*)(&data [col_ptr+8]);
   v.dz = *(float*)(&data [col_ptr+16]);

   return v;

.  check_type
     if (column_type [column_no] != col_type_vector)
        errorstop (2, "table", "read_vector", "wrong type", name).

.  col_ptr
     row_no * column_length + column_index [column_no].

  }

void table::write (int row_no, int column_no, int value)
  {was_write_access = true;
   check_bound (col_ptr, row_no, column_no, "write (int)");  
   check_type;
   *(int*)(&data [col_ptr]) = value;

.  check_type
     if (column_type [column_no] != col_type_int)
        errorstop (3, "table", "write (int)", "wrong type", name).

.  col_ptr
     row_no * column_length + column_index [column_no].

  }

void table::write (int row_no, int column_no, double value)
  {float f = value;

   write (row_no, column_no, f);
  }

void table::write (int row_no, int column_no, float value)
  {was_write_access = true;
   check_bound (col_ptr, row_no, column_no, "write (float)");  
   check_type;
   *(float*)(&data [col_ptr]) = value;

.  check_type
     if (column_type [column_no] != col_type_float)
        errorstop (3, "table", "write (float)", "wrong type", name).

.  col_ptr
     row_no * column_length + column_index [column_no].

  }

void table::write (int row_no, int column_no, char value [])
  {was_write_access = true;
   check_bound (col_ptr, row_no, column_no, "write_text");  
   check_type;
   check_size;
   strcpy (&data [col_ptr], value);
  
.  check_size
     {if (strlen (value) > 120 || strlen (value) < 0)
         printf ("Miststst\n");
     }.

.  check_type
     if (column_type [column_no] != col_type_text)
        print_error.

.  print_error
     {char msg [128];

      sprintf   (msg, "write (text)(%d,%d)",column_no,column_type [column_no]);
      errorstop (3, "table", msg, "wrong type", name);
     }.

.  col_ptr
     row_no * column_length + column_index [column_no].

  }

void table::write (int row_no, int column_no, point value)
  {was_write_access = true;
   check_bound (col_ptr, row_no, column_no, "write (point)");  
   check_type;
   *(float*)(&data [col_ptr])    = value.x;
   *(float*)(&data [col_ptr+8])  = value.y;
   *(float*)(&data [col_ptr+16]) = value.z;

.  check_type
     if (column_type [column_no] != col_type_point)
        errorstop (3, "table", "write (point)", "wrong type", name).

.  col_ptr
     row_no * column_length + column_index [column_no].

  }

void table::write (int row_no, int column_no, cube value)
  {was_write_access = true;
   check_bound (col_ptr, row_no, column_no, "write (cube)");  
   check_type;
   *(float*)(&data [col_ptr])    = value.p0.x;
   *(float*)(&data [col_ptr+8])  = value.p0.y;
   *(float*)(&data [col_ptr+16]) = value.p0.z;
   *(float*)(&data [col_ptr+24]) = value.p1.x;
   *(float*)(&data [col_ptr+32]) = value.p1.y;
   *(float*)(&data [col_ptr+40]) = value.p1.z;
   *(float*)(&data [col_ptr+48]) = value.p2.x;
   *(float*)(&data [col_ptr+56]) = value.p2.y;
   *(float*)(&data [col_ptr+64]) = value.p2.z;
   *(float*)(&data [col_ptr+72]) = value.p3.x;
   *(float*)(&data [col_ptr+80]) = value.p3.y;
   *(float*)(&data [col_ptr+88]) = value.p3.z;

.  check_type
     if (column_type [column_no] != col_type_cube)
        errorstop (3, "table", "write (cube)", "wrong type", name).

.  col_ptr
     row_no * column_length + column_index [column_no].

  }


void table::write (int row_no, int column_no, plane value)
  {was_write_access = true;
   check_bound (col_ptr, row_no, column_no, "write (plane)");  
   check_type;
   *(float*)(&data [col_ptr])    = value.p0.x;
   *(float*)(&data [col_ptr+8])  = value.p0.y;
   *(float*)(&data [col_ptr+16]) = value.p0.z;
   *(float*)(&data [col_ptr+24]) = value.p1.x;
   *(float*)(&data [col_ptr+32]) = value.p1.y;
   *(float*)(&data [col_ptr+40]) = value.p1.z;
   *(float*)(&data [col_ptr+48]) = value.p2.x;
   *(float*)(&data [col_ptr+56]) = value.p2.y;
   *(float*)(&data [col_ptr+64]) = value.p2.z;

.  check_type
     if (column_type [column_no] != col_type_plane)
        errorstop (3, "table", "write (plane)", "wrong type", name).

.  col_ptr
     row_no * column_length + column_index [column_no].

  }

void table::write (int row_no, int column_no, config value)
  {was_write_access = true;
   check_bound (col_ptr, row_no, column_no, "write (config)");  
   check_type;
   *(int*)(&data [col_ptr]) = max_config_size;
   for (int i = 0; i < max_config_size; i++)
     *(float*)
     (&data [col_ptr + (i * sizeof (double) + sizeof (int))]) = value.v [i];

.  check_type
     if (column_type [column_no] != col_type_config)
        errorstop (3, "table", "write (config)", "wrong type", name).

.  col_ptr
     row_no * column_length + column_index [column_no].

  }

void table::write (int row_no, int column_no, vector value)
  {was_write_access = true;
   check_bound (col_ptr, row_no, column_no, "write (vector)");  
   check_type;
   *(float*)(&data [col_ptr])    = value.dx;
   *(float*)(&data [col_ptr+8])  = value.dy;
   *(float*)(&data [col_ptr+16]) = value.dz;

.  check_type
     if (column_type [column_no] != col_type_vector)
        errorstop (3, "table", "write (vector)", "wrong type", name).

.  col_ptr
     row_no * column_length + column_index [column_no].

  }

int table::append (int column_no, int value)
  {was_write_access = true;
   perhaps_new_row;
   check_type;
   write (row_no, column_no, value);
   return row_no;

.  perhaps_new_row
     {if (column_no == 0)
         if (new_row == -1)
            return -1;
     }.

.  new_row
     (row_no = add_row ()).

.  check_type
     if (column_type [column_no] != col_type_int)
        errorstop (3, "table", "append (int)", "wrong type", name).

  }

int table::append (int column_no, double value)
  {float f = value;

   return append (column_no, f);
  }

int table::append (int column_no, float value)
  {was_write_access = true;
   perhaps_new_row;
   check_type;
   write (row_no, column_no, value);
   return row_no;

.  perhaps_new_row
     {if (column_no == 0)
         if (new_row == -1)
            return -1;
     }.

.  new_row
     (row_no = add_row ()).

.  check_type
     if (column_type [column_no] != col_type_float)
        errorstop (3, "table", "append (float)", "wrong type", name).

  }

int table::append (int column_no, char value [])
  {was_write_access = true;
   perhaps_new_row;
   check_type;
   write (row_no, column_no, value);
   return row_no;

.  perhaps_new_row
     {if (column_no == 0)
         if (new_row == -1)
            return -1;
     }.

.  new_row
     (row_no = add_row ()).

.  check_type
     if (column_type [column_no] != col_type_text)
        errorstop (3, "table", "append (text)", "wrong type", name).

  }

int table::append (int column_no, point value)
  {was_write_access = true;
   perhaps_new_row;
   check_type;
   write (row_no, column_no, value);
   return row_no;

.  perhaps_new_row
     {if (column_no == 0)
         if (new_row == -1)
            return -1;
     }.

.  new_row
     (row_no = add_row ()).

.  check_type
     if (column_type [column_no] != col_type_point)
        errorstop (3, "table", "append (point)", "wrong type", name).

  }

int table::append (int column_no, cube value)
  {was_write_access = true;
   perhaps_new_row;
   check_type;
   write (row_no, column_no, value);
   return row_no;

.  perhaps_new_row
     {if (column_no == 0)
         if (new_row == -1)
            return -1;
     }.

.  new_row
     (row_no = add_row ()).

.  check_type
     if (column_type [column_no] != col_type_cube)
        errorstop (3, "table", "append (cube)", "wrong type", name).

  }

int table::append (int column_no, plane value)
  {was_write_access = true;
   perhaps_new_row;
   check_type;
   write (row_no, column_no, value);
   return row_no;

.  perhaps_new_row
     {if (column_no == 0)
         if (new_row == -1)
            return -1;
     }.

.  new_row
     (row_no = add_row ()).

.  check_type
     if (column_type [column_no] != col_type_plane)
        errorstop (3, "table", "append (plane)", "wrong type", name).

  }

int table::append (int column_no, config value)
  {was_write_access = true;
   perhaps_new_row;
   check_type;
   write (row_no, column_no, value);
   return row_no;

.  perhaps_new_row
     {if (column_no == 0)
         if (new_row == -1)
            return -1;
     }.

.  new_row
     (row_no = add_row ()).

.  check_type
     if (column_type [column_no] != col_type_config)
        errorstop (3, "table", "append (config)", "wrong type", name).

  }

int table::append (int column_no, vector value)
  {was_write_access = true;
   perhaps_new_row;
   check_type;
   write (row_no, column_no, value);
   return row_no;

.  perhaps_new_row
     {if (column_no == 0)
         if (new_row == -1)
            return -1;
     }.

.  new_row
     (row_no = add_row ()).

.  check_type
     if (column_type [column_no] != col_type_vector)
        errorstop (3, "table", "append (vector)", "wrong type", name).

  }

/*----------------------------------------------------------------------*/
/* MODULE table handler (declarations)                                  */
/*----------------------------------------------------------------------*/

char  global_dir [128];
char  local_dir  [128];
int   table_ticker;

table *tables     [max_open_tables];
int   stamp       [max_open_tables];
bool  is_resident [max_open_tables];
bool  is_clean    [max_open_tables];
int   use_count   [max_open_tables];
char  names       [max_open_tables][128];

/*----------------------------------------------------------------------*/
/* MODULE table handler (functions)                                     */
/*----------------------------------------------------------------------*/

void open_table_handler (char global_table_dir [], char local_table_dir [])
  {table_ticker = 0;
   strcpy (global_dir, global_table_dir);
   strcpy (local_dir,  local_table_dir);
   for (int i = 0; i < max_open_tables; i++)
     {use_count   [i] = 0;
      is_resident [i] = false;
      is_clean    [i] = true;
      strcmp (names [i], "");
     };
  }

void close_table_handler (bool flush_buffers)
  {if (flush_buffers)
      perform_flush;

.  perform_flush
     {for (int i = 0; i < max_open_tables; i++)
        if (! is_clean [i])
           force_close;
     }.

.  force_close
     {delete (tables [i]);
     }.

  }

void dump_table_handler ()  
  {printf ("--- tables ------------------------------------------------\n");
   printf ("no,usecount,stamp,resident,clean,gdir,ldir,name\n");
   for (int i = 0; i < max_open_tables; i++)
     printf ("%d : %d %d %d %d %s %s %s\n",
             i,
             use_count   [i],
             stamp       [i],
             is_resident [i],
             is_clean    [i],
             global_dir,
             local_dir,
             names       [i]);
   printf ("-----------------------------------------------------------\n");
  }

void flush_table_handler ()
  {for (int e = 0; e < max_open_tables; e++)
     if (! is_clean [e])
        tables [e]->save ();
  }

table *table_open (char name [], 
                   bool &is_new, 
                   int  paging_mode,
                   int  lru_size)

  {int e;

   get_free_entry;
   perhaps_flush_entry;
   allocate_entry;
   return tables [e];

.  get_free_entry
     {int s = ++table_ticker;

      for (int i = 0; i < max_open_tables; i++)
        check_entry;
     }.

.  check_entry
     {if (strcmp (names [i], name) == 0)
         handle_reopen;
      if (use_count [i] == 0 && stamp [i] < s && ! is_resident [i])
         grab_it;
     }.

.  handle_reopen 
     {grab_it;
      break;
     }.

.  grab_it
     {e = i;
      s = stamp [i];
     }.

.  perhaps_flush_entry
     {if (strcmp (names [e], name) != 0 && ! is_clean [e])
         flush_entry;
     }.

.  flush_entry
     {delete (tables [e]);
      is_clean  [e] = true;
      use_count [e] = 0;
     }.

.  allocate_entry
     {stamp       [e] = table_ticker;
      is_resident [e] = (paging_mode == resident);
      is_new          = false;
      if (is_clean [e])
         open_new;
      use_count [e]++;
     }.

.  open_new
     {char dir [128];

      get_dir;
      tables    [e]     = new table (dir, name, is_new, lru_size);
      tables    [e]->id = e;
      is_clean  [e]     = false;
      use_count [e]     = 0;
      strcpy (names [e], name);
     }.

.  get_dir
     {if      (table_exists (local_dir,  name))  strcpy (dir, local_dir);
      else if (table_exists (global_dir, name))  strcpy (dir, global_dir);
      else                                       strcpy (dir, local_dir);
     }.
           
  }

void table_close (table *t)
  {use_count [t->id]--;
   if (use_count [t->id] < 0)
      errorstop (1, "table handler", "to many close operations");
  }
   
void table_rename (table *t, char new_name [])
  {clear_destination;
   exec_rename;

.  clear_destination
     {table *td;
      bool  d;

      td = table_open (new_name, d);
      table_delete (td);
     }.

.  exec_rename
     {tables [t->id]->rename (local_dir, new_name);
      strcpy (names [t->id], new_name);
     }.

  } 

bool table_exists (char dir [], char name [])
  {char f_name [128];

   sprintf (f_name, "%s%s", dir, name);
   return f_exists (f_name);
  }
   
void table_delete (table *t)
  {check_dangling_pointers;
   use_count [t->id] = 0;
   delete_file;
   strcpy (names [t->id], "");

.  delete_file
     {char cmd [128];

      sprintf (cmd, "rm -f %s%s", local_dir, names [t->id]);
      system  (cmd);
     }.

.  check_dangling_pointers
     if (use_count [t->id] != 1)
        errorstop (2, "table handler", "dangling pointer at delete").

  }
