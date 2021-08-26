#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv)
{

   const char FILE_PATH[] = "/tmp/unreferenced-pk.txt";
   const int MAX_INTEGER = 2147483627;
   int record_count;

   if( argv[1] != 0){
     record_count = atoi(argv[1]);
   } else {
     record_count = MAX_INTEGER;
   }

   printf("Generating %d lines TO %s ...\n", record_count, FILE_PATH);

   FILE *fptr;

   fptr = fopen(FILE_PATH,"w");

  if(fptr == NULL)
   {
      printf("Cannot open file in write mode in /tmp");
      exit(1);
   }

  for (int i = 1; i <= record_count; ++i)
  {
    fprintf( fptr, "%d\n", i);

    if(i % 10000){
      fflush(fptr);
    }
  }

  fclose(fptr);

  printf("Done \n");

  return 0;
}
