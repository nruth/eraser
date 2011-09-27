#include <stdio.h>
#include <stdlib.h>

int xor_files(FILE *files[], int number_of_files, char *outputfilename) {
  int i;
  int *tmp = (int *) malloc(number_of_files * sizeof (FILE));

  // init tmp
  for (i = 0; i < number_of_files; i++) tmp[i] = 0;

  FILE* output;  
  output = fopen(outputfilename, "wb");

  // read a byte from each file and store them in tmp
  while ((tmp[0] = fgetc(files[0])) != EOF) {
    for (i = 1; i < number_of_files; i++) {
      tmp[i] = fgetc(files[i]);
    }

    // xor
    int j; 
    int xor_result = 0;
    for (j = 0; j < number_of_files-1; j++) {
      xor_result = tmp[j] ^ tmp[j+1];
    }
    
    // then write to new file
    fputc(xor_result, output);
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
  FILE *files[args-2];
  int i; 

  for (i = 0; i < args-2; i++) {
    files[i] = fopen(argv[i+2], "r");
  }
  
  xor_files(files, args-2, argv[1]);

  for (i = 0; i < args-2; i++) {
    fclose(files[i]);
  }
  
  return 0;
}