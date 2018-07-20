#ifndef collist_h
#define collist_h

/*======================================================================*/
/*= CHANGES AND UPDATES                                                =*/
/*======================================================================*/
/*= date   person file               subject                           =*/
/*=--------------------------------------------------------------------=*/
/*=                                                                    =*/
/*= 260493 hua    collist.h          created                           =*/
/*=                                                                    =*/
/*======================================================================*/

#define max_cols 200

class collist
  {public :

     int num_cols;
     int col_no [max_cols];

       collist  (char list []);
       ~collist ();

   int num      ();
   int col      (int i);

 };

#endif
