#include <stdlib.h>
#include <stdio.h>
#include <math.h>

void wichura4x32kernel( const float *p, const float mu, const float sigma, float *res );

/*
 * Test the implementation of the AS 241 algorithm by Wichura 1988.
 * 
 * The test reads uniformly distributed random variates generated by frand123
 * and compares the normally distributed random variates computed using the AS 241
 * algorithm to ones computed using the implementation provided by the GRASS GIS
 * project implemented in as241.c and stored in
 * tests/input_testWichura4x32Kernel.in
 */
int main()
{
   const size_t elements = 1000 * 1000 * 100;
   const float eps = 1e-6;
   FILE *funi, *fnorm;
   funi  = fopen( "tests/rand_single.out", "rb+" );
   fnorm = fopen( "tests/input_testWichura4x32Kernel.in", "rb+" );
   if( ( fnorm == NULL ) || ( funi == NULL ) )
   {
      perror( "Opening input files failed!" );
   }
   float uni[4], norm[4];
   int i;
   for( i = 0; i < elements; i += 4 )
   {
      if( ( fread( uni, sizeof(float), 4, funi ) != 4 ) || ( fread( norm, sizeof(float), 4, fnorm ) != 4 ) )
      {
         perror( "Reading input failed!" );
      }
      float res[ 4 ];
      wichura4x32kernel( uni, 0., 1., res );
      if( ( fabs( res[ 0 ] - norm[ 0 ] ) > eps ) ||
          ( fabs( res[ 1 ] - norm[ 1 ] ) > eps ) ||
          ( fabs( res[ 2 ] - norm[ 2 ] ) > eps ) ||
          ( fabs( res[ 3 ] - norm[ 3 ] ) > eps ) )
      {
         printf( "Difference too large: i = { %d, %d, %d, %d }, uniform = { %e, %e, %e, %e }\n", i, i+1, i+2, i+3, uni[ 0 ], uni[ 1 ], uni[ 2 ], uni[ 3 ] );
         printf( "%d: res = %e, ref = %e, error = %e\n", i, res[ 0 ], norm[ 0 ], res[ 0 ] - norm[ 0 ] );
         printf( "%d: res = %e, ref = %e, error = %e\n", i+1, res[ 1 ], norm[ 1 ], res[ 1 ] - norm[ 1 ] );
         printf( "%d: res = %e, ref = %e, error = %e\n", i+2, res[ 2 ], norm[ 2 ], res[ 2 ] - norm[ 2 ] );
         printf( "%d: res = %e, ref = %e, error = %e\n", i+3, res[ 3 ], norm[ 3 ], res[ 3 ] - norm[ 3 ] );
         exit( 1 );
      }
   }
   return 0;
}