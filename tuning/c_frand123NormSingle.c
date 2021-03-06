#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tgmath.h>
#include <omp.h>
#include "../wrapper/frand123.h"

typedef struct
{
   double timeElapsed;
   float *sum;
} resSingle_t;

resSingle_t time_frand123NormSingle_scalar( frand123State_t *state, int64_t number )
{
   double startTime, endTime;
   volatile float sum = 0.;
   startTime = omp_get_wtime();
   for( int64_t i = 0; i < number; i++ )
   {
      sum += frand123NormSingle_scalar( state, 0.34, 0.32 );
   }
   endTime = omp_get_wtime();
   resSingle_t res;
   res.timeElapsed = endTime - startTime;
   res.sum = (float*)malloc( sizeof( float ) );
   *(res.sum) = sum;
   return res;
}

void time_frand123NormSingle_scalar_runner( frand123State_t *state, char *compileCombination )
{
   resSingle_t res;
   
   const int64_t number[ 6 ] = { INT64_C( 10 ), INT64_C( 100 ), INT64_C( 1000 ), INT64_C( 10000 ), INT64_C( 100000 ), INT64_C( 1000000 ) };

   char filename[ 200 ] = "tuning/timings/frand123NormSingle_scalar";
   strncat( filename, compileCombination, 100 );
   strncat( filename, ".dat", 4 );
   FILE *fd = fopen( filename, "w+" );
   if( fd == NULL )
   {
      perror( "Failed to open file in time_frand123NormSingle_scalar_runner" );
   }

   printf( "time frand123NormSingle_scalar\n" );

   for( int i = 0; i < 6; i++ )
   {
      const int64_t num = number[ i ];
      double meanTime = 0., minTime = 100., maxTime = 0.;
      for( int k = 0; k < 20; k++ )
      {
         res = time_frand123NormSingle_scalar( state, num );
         meanTime += res.timeElapsed;
         minTime = fmin( minTime, res.timeElapsed );
         maxTime = fmax( maxTime, res.timeElapsed );
      }
      meanTime = meanTime / 20.;
      fprintf( fd, "frand123NormSingle_scalar, %d, %e, %e, %e\n", num, meanTime, minTime, maxTime );
      printf( "frand123NormSingle_scalar, %d, %e, %e, %e\n", num, meanTime, minTime, maxTime );
      free( res.sum );
   }

   fclose( fd );
   return;
}

resSingle_t time_frand123NormSingle( frand123State_t *state, int64_t number, int64_t chunksize )
{
   double startTime, endTime;
   volatile float sum = 0.;
   float *chunks = (float*)malloc( chunksize * sizeof( float ) );
   if( chunks == NULL )
   {
      perror( "error allocating chunks in time_frand123NormSingle" );
   }
   startTime = omp_get_wtime();
   for( int64_t i = 0; i < number; i += chunksize )
   {
      frand123NormSingle( state, 0.74, 1.3, chunksize, chunks );
   }
   endTime = omp_get_wtime();
   resSingle_t res;
   res.timeElapsed = endTime - startTime;
   res.sum = chunks;
   return res;
}

void time_frand123NormSingle_runner( frand123State_t *state, char *compileCombination )
{
   resSingle_t res;

   const int64_t number[ 6 ] = { INT64_C( 10 ), INT64_C( 100 ), INT64_C( 1000 ), INT64_C( 10000 ), INT64_C( 100000 ), INT64_C( 1000000 ) };
   const int64_t chunksize[ 8 ] = { INT64_C( 1 ), INT64_C( 2 ), INT64_C( 10 ), INT64_C( 100 ), INT64_C( 1000 ), INT64_C( 10000 ), INT64_C( 100000 ), INT64_C( 1000000 ) };

   char filename[ 200 ] = "tuning/timings/frand123NormSingle";
   strncat( filename, compileCombination, 100 );
   strncat( filename, ".dat", 4 );
   FILE *fd = fopen( filename, "w+" );
   if( fd == NULL )
   {
      perror( "Failed to open file in time_frand123NormSingle_runner" );
   }

   printf( "time frand123NormSingle\n" );

   for( int i = 0; i < 6; i++ )
   {
      for( int j = 0; j < 8; j++ )
      {
         const int64_t num = number[ i ];
         const int64_t cs = chunksize[ j ];
         if( cs <= num )
         {
            double meanTime = 0., minTime = 100., maxTime = 0.;
            for( int k = 0; k < 20; k++ )
            {
               res = time_frand123NormSingle( state, num, cs );
               meanTime += res.timeElapsed;
               minTime = fmin( minTime, res.timeElapsed );
               maxTime = fmax( maxTime, res.timeElapsed );
            }
            meanTime = meanTime / 20.;
            fprintf( fd, "frand123NormSingle, %d, %d, %e, %e, %e\n", num, cs, meanTime, minTime, maxTime );
            printf( "frand123NormSingle, %d, %d, %e, %e, %e\n", num, cs, meanTime, minTime, maxTime );
            free( res.sum );
         }
      }
   }

   fclose( fd );
   return;
}

int main( int argc, char **argv )
{
   frand123State_t state;
   frand123Init( &state, 0, 0, NULL );

   if( argc < 2 )
   {
      perror( "Compiler name required as command line argument" );
   }
   if( strlen( argv[ 1 ] ) > 100 )
   {
      perror( "Use shorter name for compiler" );
   }

   printf( "frand123 tuning script for the C interface\n" );

   // time frand123NormSingle_scalar
   time_frand123NormSingle_scalar_runner( &state, argv[ 1 ] );

   // time frand123NormSingle
   time_frand123NormSingle_runner( &state, argv[ 1 ] );

   return 0;
}
