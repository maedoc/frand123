#include <stdio.h>
#include <stdint.h>
#include <math.h>
#include <omp.h>

void polar2x64( int64_t *state, const double mu, const double sigma, double *res );

// parameters
// vector width of SIMD unit w.r.t. size of doubles
const int vec_width_in_doubles = 4;
// number of random numbers to generate
// needs to be divisible by vec_width_in_doubles
const uint64_t number_random_numbers = 1000ll * 1000ll * 1000ll * 10ll;

// derived parameters
// number of calls to polar 4x32 to fill vector registers
const int rng_calls_per_loop = vec_width_in_doubles / 2;
const int loop_iterations = number_random_numbers / vec_width_in_doubles;

void computeCentralMoments( int64_t *state, const double mu, const double sigma, double *centralMoments )
{
   // vector for random numbers
   double r[ vec_width_in_doubles ];
   // vector to hold intermediate vector with r^2
   double r2[ vec_width_in_doubles ];
   // vector to hold intermediate values
   double intermediate[ vec_width_in_doubles ];
   // vectors for central moments
   double cm02[ vec_width_in_doubles ];
   double cm04[ vec_width_in_doubles ];
   double cm06[ vec_width_in_doubles ];
   double cm08[ vec_width_in_doubles ];
   double cm10[ vec_width_in_doubles ];
   double cm12[ vec_width_in_doubles ];
   double cm14[ vec_width_in_doubles ];
   double cm16[ vec_width_in_doubles ];
   double cm18[ vec_width_in_doubles ];
   double cm20[ vec_width_in_doubles ];
   // iteration variable
   uint64_t i;
   int j;

   // initialize central moments to 0
   for( j = 0; j < vec_width_in_doubles; j++ )
   {
      cm02[ j ] = 0.;
      cm04[ j ] = 0.;
      cm06[ j ] = 0.;
      cm08[ j ] = 0.;
      cm10[ j ] = 0.;
      cm12[ j ] = 0.;
      cm14[ j ] = 0.;
      cm16[ j ] = 0.;
      cm18[ j ] = 0.;
      cm20[ j ] = 0.;
   }

   // compute central moments
   for( i = 0; i < number_random_numbers; i += vec_width_in_doubles )
   {
      // fill r with random numbers
      for( j = 0; j < rng_calls_per_loop; j++ )
      {
         polar2x64( state, mu, sigma, &r[ j * 2 ] );
      }
      // iteratively compute central moments
      #pragma omp simd
      for( j = 0; j < vec_width_in_doubles; j++ )
      {
         // foundation for central moments
         r[ j ] = r[ j ] - mu;
         // always need to multiply by r^2
         r2[ j ] = r[ j ] * r[ j ];
         // initialize intermediate to r2
         intermediate[ j ] = r2[ j ];
         // central moments
         cm02[ j ] += r2[ j ];
         intermediate[ j ] = intermediate[ j ] * r2[ j ];
         cm04[ j ] += intermediate[ j ];
         intermediate[ j ] = intermediate[ j ] * r2[ j ];
         cm06[ j ] += intermediate[ j ];
         intermediate[ j ] = intermediate[ j ] * r2[ j ];
         cm08[ j ] += intermediate[ j ];
         intermediate[ j ] = intermediate[ j ] * r2[ j ];
         cm10[ j ] += intermediate[ j ];
         intermediate[ j ] = intermediate[ j ] * r2[ j ];
         cm12[ j ] += intermediate[ j ];
         intermediate[ j ] = intermediate[ j ] * r2[ j ];
         cm14[ j ] += intermediate[ j ];
         intermediate[ j ] = intermediate[ j ] * r2[ j ];
         cm16[ j ] += intermediate[ j ];
         intermediate[ j ] = intermediate[ j ] * r2[ j ];
         cm18[ j ] += intermediate[ j ];
         intermediate[ j ] = intermediate[ j ] * r2[ j ];
         cm20[ j ] += intermediate[ j ];
      }
   }

   // compute final central moments
   for( j = 0; j < 10; j++ )
   {
      centralMoments[ j ] = 0.;
   }
   #pragma omp simd
   for( j = 0; j < vec_width_in_doubles; j++ )
   {
      centralMoments[ 0 ] += cm02[ j ];
      centralMoments[ 1 ] += cm04[ j ];
      centralMoments[ 2 ] += cm06[ j ];
      centralMoments[ 3 ] += cm08[ j ];
      centralMoments[ 4 ] += cm10[ j ];
      centralMoments[ 5 ] += cm12[ j ];
      centralMoments[ 6 ] += cm14[ j ];
      centralMoments[ 7 ] += cm16[ j ];
      centralMoments[ 8 ] += cm18[ j ];
      centralMoments[ 9 ] += cm20[ j ];
   }
}

int main()
{
   // state for RNG
   int64_t state[ 4 ];
   // parameters of normal distribution
   const double mu = 0.;
   const double sigma = 1.;
   // double factorial
   long double_fac = 1;
   // timing
   double startTime, stopTime;
   // final central moments
   double final_cm[ 10 ];
   // iteration variables
   int j;
   // store number of threads
   int num_threads;

   // timing
   startTime = omp_get_wtime();

   #pragma omp parallel default(none) private(state) shared(num_threads) reduction(+:final_cm[:10])
   {
      // store number of threads for correct results
      #pragma omp master
      {
         num_threads = omp_get_num_threads();
      }

      // init the rng
      uint64_t *state_as_uint64_t = state;
      state_as_uint64_t[ 0 ] = (uint64_t)omp_get_thread_num() * number_random_numbers / (uint64_t)2;
      state_as_uint64_t[ 1 ] = 0;

      // compute central moments
      computeCentralMoments( state, mu, sigma, final_cm );
   }
   
   // timing
   stopTime = omp_get_wtime();
   printf( "Timing: %es\n\n", stopTime - startTime );

   // print out results
   for( j = 0; j < 10; j++ )
   {
      double_fac = double_fac * ( 2 * j + 1 );
      final_cm[ j ] = final_cm[ j ] / ( (uint64_t)num_threads * number_random_numbers );
      printf( "%02dth numerical central moment: %e, exact central moment: %9ld, relative error: %e\n", j * 2 + 2, final_cm[ j ], double_fac, fabs( final_cm[ j ] - (double)double_fac ) / (double)double_fac );
   }

   return 0;
}
