#include <stdlib.h>
#include <stdio.h>

// make ppnd16 from as241.c known
double ppnd16( double );

// create 1e8 normally distributed random numbers from the uniformly
// distributed random numbers provided in file
// rand_double.out and write those to file
// input_testWichura2x64Kernel.in
int main()
{
   const size_t elements = 1000 * 1000 * 100;
   FILE *f;
   double *uniform;
   double *normal;
   int i;
   uniform = malloc( elements * sizeof( double ) );
   normal  = malloc( elements * sizeof( double ) );
   if( ( uniform == NULL ) || ( uniform == NULL ) )
   {
      perror( "Malloc failed!\n" );
   }
   f = fopen( "tests/rand_double.out", "rb" );
   if( f == NULL )
   {
      perror( "Opening input file failed.\n" );
   }
   if( fread( (void*)uniform, sizeof(double), elements, f ) != elements )
   {
      perror( "Reading input failed!\n" );
   }
   fclose( f );
   for( i = 0; i < elements; i++ )
   {
      normal[ i ] = ppnd16( uniform[ i ] );
   }
   free( uniform );
   f = fopen( "tests/input_testWichura2x64Kernel.in", "wb" );
   if( f == NULL )
   {
      perror( "Opening output file failed.\n" );
   }
   if( fwrite( (void*)normal, sizeof( double ), elements, f ) != elements )
   {
      perror( "Writing output failed!\n" );
   }
   free( normal );

   return 0;
}
