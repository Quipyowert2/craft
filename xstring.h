/*======================================================================*/
/*= CHANGES AND UPDATES                                                =*/
/*======================================================================*/
/*= date   person file       subject                                   =*/
/*=--------------------------------------------------------------------=*/
/*=                                                                    =*/
/*= 301092 hua    xstring.h  created                                   =*/
/*=                                                                    =*/
/*======================================================================*/

void compress   (char s []);
void lower      (char s []);
void changeall  (char s [], 
                 int  max_length_of_s,
                 char tmpalte     [],
                 char replacement []);
char *substring (const char s [], int from, int to);
char *substring (char s [], int from); 
int  submatch   (char s [], char p [], int &pos);
void strcat     (char s [], int len, char app []);
void delchar    (char s [], int pos);
void inschar    (char s [], int pos, char n);
int  strpos     (char s[], char p);
