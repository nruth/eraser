#include <stdlib.h>
#include <stdio.h> 

int xor_files(FILE *files[], int number_of_files, char *outputfilename) {
  int file_index;
  int x = 0;

  FILE* output;  
  output = fopen(outputfilename, "wb");

  // read a byte from each file and store them in tmp
  while ((x = fgetc(files[0])) != EOF) {
    for (file_index = 1; file_index < number_of_files; file_index++) {
      x = x ^ fgetc(files[file_index]);
    }

    fputc(x, output);
  }

  fclose(output);

  return 0;
}

/**
 * arg1 = name of output file
 * arg2-N = files to xor
 */
int main(int args, char** argv) 
{
  int number_of_files = args-2;
  FILE *files[number_of_files];
  int i; 

  for (i = 0; i < number_of_files; i++) {
    files[i] = fopen(argv[i+2], "rb");
  }
  
  xor_files(files, number_of_files, argv[1]);

  for (i = 0; i < number_of_files; i++) {
    fclose(files[i]);
  }
  
  return 0;
}


