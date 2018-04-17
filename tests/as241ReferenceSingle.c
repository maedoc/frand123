#include <stdlib.h>
#include <stdio.h>

// make ppnd7 from as241.c known
double ppnd7( double );

// create 1e8 normally distributed random numbers from the uniformly
// distributed random numbers provided in file
// rand_float.out and write those to file
// input_testWichura4x32Kernel.in
int main()
{
   const size_t elements = 1000 * 1000 * 100;
   FILE *f;
   float *uniform;
   float *normal;
   int i;
   uniform = malloc( elements * sizeof( float ) );
   normal  = malloc( elements * sizeof( float ) );
   if( ( uniform == NULL ) || ( uniform == NULL ) )
   {
      perror( "Malloc failed!\n" );
   }
   f = fopen( "tests/rand_single.out", "rb" );
   if( f == NULL )
   {
      perror( "Opening input file failed.\n" );
   }
   if( fread( (void*)uniform, sizeof(float), elements, f ) != elements )
   {
      perror( "Reading input failed!\n" );
   }
   fclose( f );
   for( i = 0; i < elements; i++ )
   {
      normal[ i ] = (float)ppnd7( (double)uniform[ i ] );
   }
   free( uniform );
   f = fopen( "tests/input_testWichura4x32Kernel.in", "wb" );
   if( f == NULL )
   {
      perror( "Opening output file failed.\n" );
   }
   if( fwrite( (void*)normal, sizeof( float ), elements, f ) != elements )
   {
      perror( "Writing output failed!\n" );
   }
   free( normal );

   return 0;
}
