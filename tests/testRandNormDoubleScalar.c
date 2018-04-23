#include <stdio.h>
#include <stdint.h>
#include <omp.h>
#include "../wrapper/frand123.h"

int main()
{
   const long long numVariates = 1000ll * 1000ll * 1000ll;
   double sum;
   double startTime, endTime;
   int64_t state[ 4 ];
   const int64_t seed[ 2 ] = { 0, 0 };
   startTime = omp_get_wtime();
   frand123Init( state, 0, 0, seed );
   for( long long i = 0ll; i < numVariates; i++ )
   {
      sum += frand123NormDouble_scalar( state, 0.5, 1. );
   }
   endTime = omp_get_wtime();
   printf( "time: %e\n", endTime - startTime );
   printf( "result: %e\terror: %e\n", sum / (double)numVariates, 0.5 - sum / (double)numVariates );
   return 0;
}

