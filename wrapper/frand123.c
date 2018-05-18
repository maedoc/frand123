#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <assert.h>
#include "rand123wrapper.h"
#include "frand123.h"
#ifdef USE_MKL
#include <mkl_vsl.h>
#endif

/*
 * generate random double precision numbers uniformly distributed in (0,1)
 *
 * Arguments: state:  state of the random number generator
 *                    the counter in the state is incremented appropriately
 *            lenRes: number of random variates to generate
 *            res:    array to be filled with random numbers
 *                    length of array: lenRes
 */
// scalar version returns one random number
double frand123Double_scalar( frand123State_t *state )
{
   // assert validity of arguments
   assert( state != NULL );

   // call vector-valued implementation
   double buffer;
   frand123Double( state, INT64_C( 1 ), &buffer );
   return buffer;
}
// vectorial version
void frand123Double( frand123State_t *state, const int64_t lenRes, double *restrict res )
{
   int64_t i;
   double buffer[ 2 ];

   // assert validity of arguments
   assert( state != NULL );
   assert( lenRes > 0 );
   assert( res != NULL );

#ifndef USE_MKL
   // store directly to res while safe
   for( i = INT64_C( 0 ); ( i + UINT64_C( 1 ) ) < lenRes; i += UINT64_C( 2 ) )
   {
#ifdef USE_ARS
      ars2x64_u01( state, &res[ i ] );
#else // USE_ARS
      threefry2x64_u01( state, &res[ i ] );
#endif // USE_ARS
   }
   // catch a possible remainder
   if( i != lenRes )
   {
#ifdef USE_ARS
      ars2x64_u01( state, buffer );
#else // USE_ARS
      threefry2x64_u01( state, buffer );
#endif // USE_ARS
      res[ lenRes - INT64_C( 1 ) ] = buffer[ 0 ];
   }
#else // USE_MKL
   vdRngUniform( VSL_RNG_METHOD_UNIFORM_STD, *state, lenRes, res, 0., 1. );
#endif // USE_MKL
   return;
}

/*
 * generate random single precision numbers uniformly distributed in (0,1)
 *
 * Arguments: state:  state of the random number generator
 *                    the counter in the state is incremented appropriately
 *            lenRes: number of random variables to generate
 *            res:    array to be filled with random numbers
 *                    length of array: lenRes
 */
// scalar version returns one random number
float frand123Single_scalar( frand123State_t *state )
{
   // assert validity of arguments
   assert( state != NULL );

   // call vector-valued implementation
   float buffer;
   frand123Single( state, INT64_C( 1 ), &buffer );
   return buffer;
}
// vectorial version
void frand123Single( frand123State_t *state, const int64_t lenRes, float *restrict res )
{
   int64_t i, j;
   float buffer[ 4 ];

   // assert validity of arguments
   assert( state != NULL );
   assert( lenRes > 0 );
   assert( res != NULL );

#ifndef USE_MKL
   // store directly to res while safe
   for( i = INT64_C( 0 ); ( i + UINT64_C( 3 ) ) < lenRes; i += UINT64_C( 4 ) )
   {
#ifdef USE_ARS
      ars4x32_u01( state, &res[ i ] );
#else // USE_ARS
      threefry4x32_u01( state, &res[ i ] );
#endif // USE_ARS
   }
   // catch a possible remainder
   if( i != lenRes )
   {
#ifdef USE_ARS
      ars4x32_u01( state, buffer );
#else // USE_ARS
      threefry4x32_u01( state, buffer );
#endif // USE_ARS
      for( j = INT64_C( 0 ); i + j < lenRes; j++ )
      {
         res[ i + j ] = buffer[ j ];
      }
   }
#else // USE_MKL
   vsRngUniform( VSL_RNG_METHOD_UNIFORM_STD, *state, lenRes, res, 0., 1. );
#endif // USE_MKL
   return;
}

/*
 * generate random double precision numbers normally distributed with expectation mu and variance sigma
 *
 * Arguments: state:  state of the random number generator
 *                    the counter in the state is incremented appropriately
 *            mu:     expectation of the normal distribution
 *            sigma:  variance of the normal distribution
 *            lenRes: number of random variates to generate
 *            res:    array to be filled with random numbers
 *                    length of array: lenRes
 */
// scalar version returns one random number
double frand123NormDouble_scalar( frand123State_t *state, const double mu, const double sigma )
{
   // assert validity of arguments
   assert( state != NULL );
   assert( sigma > 0 );

   // call vector-valued implementation
   double buffer;
   frand123NormDouble( state, mu, sigma, INT64_C( 1 ), &buffer );
   return buffer;
}
// vectorial version
void frand123NormDouble( frand123State_t *state, const double mu, const double sigma, const int64_t lenRes, double *restrict res )
{
   int64_t i;
   double buffer[ 2 ];
   
   // assert validity of arguments
   assert( state != NULL );
   assert( sigma > 0 );
   assert( lenRes > 0 );
   assert( res != NULL );

#ifndef USE_MKL
   // store directly to res while safe
   for( i = INT64_C( 0 ); ( i + UINT64_C( 1 ) ) < lenRes; i += UINT64_C( 2 ) )
   {
#ifdef USE_POLAR
      polar2x64( state, mu, sigma, &res[ i ] );
#else // USE_POLAR
      wichura2x64( state, mu, sigma, &res[ i ] );
#endif // USE_POLAR
   }
   // catch a possible remainder
   if( i != lenRes )
   {
#ifdef USE_POLAR
      polar2x64( state, mu, sigma, buffer );
#else // USE_POLAR
      wichura2x64( state, mu, sigma, buffer );
#endif // USE_POLAR
      res[ lenRes - INT64_C( 1 ) ] = buffer[ 0 ];
   }
#else // USE_MKL
   vdRngGaussian( VSL_RNG_METHOD_GAUSSIAN_ICDF, *state, lenRes, res, mu, sigma );
#endif // USE_MKL
   return;
}

/*
 * generate random single precision numbers normally distributed with expectation mu and variance sigma
 *
 * Arguments: state:  state of the random number generator
 *                    the counter in the state is incremented appropriately
 *            mu:     expectation of the normal distribution
 *            sigma:  variance of the normal distribution
 *            lenRes: number of random variates to generate
 *            res:    array to be filled with random numbers
 *                    length of array: lenRes
 */
// scalar version returns one random number
// Note: utilize specialized version with lower #calls to RNG per random number
float frand123NormSingle_scalar( frand123State_t *state, const float mu, const float sigma )
{
   // assert validity of arguments
   assert( state != NULL );
   assert( sigma > 0 );

#ifndef USE_MKL
   // call vector-valued implementation
   float buffer[ 2 ];
   polar4x32_two( state, mu, sigma, buffer );
#else // USE_MKL
   float buffer[ 1 ];
   frand123NormSingle( state, mu, sigma, 1, buffer );
#endif // USE_MKL
   return buffer[ 0 ];
}
// vectorial version
void frand123NormSingle( frand123State_t *state, const float mu, const float sigma, const int64_t lenRes, float *restrict res )
{
   int64_t i, j;
   float buffer[ 4 ];

   // assert validity of arguments
   assert( state != NULL );
   assert( sigma > 0 );
   assert( lenRes > 0 );
   assert( res != NULL );

#ifndef USE_MKL
   // store directly to res while safe
   for( i = INT64_C( 0 ); ( i + UINT64_C( 3 ) ) < lenRes; i += UINT64_C( 4 ) )
   {
      polar4x32( state, mu, sigma, &res[ i ] );
   }
   // catch a possible remainder
   if( i != lenRes )
   {
      polar4x32( state, mu, sigma, buffer );
      for( j = INT64_C( 0 ); i + j < lenRes; j++ )
      {
         res[ i + j ] = buffer[ j ];
      }
   }
#else // USE_MKL
   vsRngGaussian( VSL_RNG_METHOD_GAUSSIAN_ICDF, *state, lenRes, res, mu, sigma );
#endif // USE_MKL
   return;
}

#ifndef USE_MKL

/*
 * generate random 64-bit signed integers uniformly distributed over INT64_MIN,..,INT64_MAX
 *
 * Arguments: state:  state of the random number generator
 *                    the counter in the state is incremented appropriately
 *            lenRes: number of random variates to generate
 *            res:    array to be filled with random numbers
 *                    length of array: lenRes
 */
// scalar version returns one random number
int64_t frand123Integer64_scalar( frand123State_t *state )
{
   // assert validity of arguments
   assert( state != NULL );

   // call vector-valued implementation
   int64_t buffer;
   frand123Integer64( state, INT64_C( 1 ), &buffer );
   return buffer;
}
// vectorial version
void frand123Integer64( frand123State_t *state, const int64_t lenRes, int64_t *restrict res )
{
   int64_t i;
   int64_t buffer[ 2 ];

   // assert validity of arguments
   assert( state != NULL );
   assert( lenRes > 0 );
   assert( res != NULL );

   // store directly to res while safe
   for( i = INT64_C( 0 ); ( i + UINT64_C( 1 ) ) < lenRes; i += UINT64_C( 2 ) )
   {
#ifdef USE_ARS
      ars2x64_int( state, &res[ i ] );
#else // USE_ARS
      threefry2x64_int( state, &res[ i ] );
#endif // USE_ARS
   }
   // catch a possible remainder
   if( i != lenRes )
   {
#ifdef USE_ARS
      ars2x64_int( state, buffer );
#else // USE_ARS
      threefry2x64_int( state, buffer );
#endif // USE_ARS
      res[ lenRes - INT64_C( 1 ) ] = buffer[ 0 ];
   }
   return;
}

/*
 * generate random 32-bit signed integers uniformly distributed over INT32_MIN,..,INT32_MAX
 *
 * Arguments: state:  state of the random number generator
 *                    the counter in the state is incremented appropriately
 *            lenRes: number of random variates to generate
 *            res:    array to be filled with random numbers
 *                    length of array: lenRes
 */
// scalar version returns one random number
int32_t frand123Integer32_scalar( frand123State_t *state )
{
   // assert validity of arguments
   assert( state != NULL );

   // call vector-valued implementation
   int32_t buffer;
   frand123Integer32( state, INT64_C( 1 ), &buffer );
   return buffer;
}
// vectorial version
void frand123Integer32( frand123State_t *state, const int64_t lenRes, int32_t *restrict res )
{
   int64_t i, j;
   int32_t buffer[ 4 ];

   // assert validity of arguments
   assert( state != NULL );
   assert( lenRes > 0 );
   assert( res != NULL );

   // store directly to res while safe
   for( i = INT64_C( 0 ); ( i + UINT64_C( 3 ) ) < lenRes; i += UINT64_C( 4 ) )
   {
#ifdef USE_ARS
      ars4x32_int( state, &res[ i ] );
#else
      threefry4x32_int( state, &res[ i ] );
#endif
   }
   // catch a possible remainder
   if( i != lenRes )
   {
#ifdef USE_ARS
      ars4x32_int( state, buffer );
#else
      threefry4x32_int( state, buffer );
#endif
      for( j = INT64_C( 0 ); i + j < lenRes; j++ )
      {
         res[ i + j ] = buffer[ j ];
      }
   }
   return;
}

/*
 * generate random 64-bit unsigned integers uniformly distributed over UINT64_MIN,..,UINT64_MAX
 *
 * Arguments: state:  state of the random number generator
 *                    the counter in the state is incremented appropriately
 *            lenRes: number of random variates to generate
 *            res:    array to be filled with random numbers
 *                    length of array: lenRes
 */
// scalar version returns one random number
uint64_t frand123UnsignedInteger64_scalar( frand123State_t *state )
{
   // assert validity of arguments
   assert( state != NULL );

   // call vector-valued implementation
   uint64_t buffer;
   frand123Integer64( state, INT64_C( 1 ), (int64_t*)&buffer );
   return buffer;
}
// vectorial version
void frand123UnsignedInteger64( frand123State_t *state, const int64_t lenRes, uint64_t *restrict res )
{
   int64_t i;
   uint64_t buffer[ 2 ];

   // assert validity of arguments
   assert( state != NULL );
   assert( lenRes > 0 );
   assert( res != NULL );

   // store directly to res while safe
   for( i = INT64_C( 0 ); ( i + UINT64_C( 1 ) ) < lenRes; i += UINT64_C( 2 ) )
   {
#ifdef USE_ARS
      ars2x64_int( state, (int64_t*)&res[ i ] );
#else
      threefry2x64_int( state, (int64_t*)&res[ i ] );
#endif
   }
   // catch a possible remainder
   if( i != lenRes )
   {
#ifdef USE_ARS
      ars2x64_int( state, (int64_t*)buffer );
#else
      threefry2x64_int( state, (int64_t*)buffer );
#endif
      res[ lenRes - INT64_C( 1 ) ] = buffer[ 0 ];
   }
   return;
}

/*
 * generate random 32-bit unsigned integers uniformly distributed over UINT32_MIN,..,UINT32_MAX
 *
 * Arguments: state:  state of the random number generator
 *                    the counter in the state is incremented appropriately
 *            lenRes: number of random variates to generate
 *            res:    array to be filled with random numbers
 *                    length of array: lenRes
 */
// scalar version returns one random number
uint32_t frand123UnsignedInteger32_scalar( frand123State_t *state )
{
   // assert validity of arguments
   assert( state != NULL );

   // call vector-valued implementation
   uint32_t buffer;
   frand123Integer32( state, INT64_C( 1 ), (int32_t*)&buffer );
   return buffer;
}
// vectorial version
void frand123UnsignedInteger32( frand123State_t *state, const int64_t lenRes, uint32_t *restrict res )
{
   int64_t i, j;
   uint32_t buffer[ 4 ];

   // assert validity of arguments
   assert( state != NULL );
   assert( lenRes > 0 );
   assert( res != NULL );

   // store directly to res while safe
   for( i = INT64_C( 0 ); ( i + UINT64_C( 3 ) ) < lenRes; i += UINT64_C( 4 ) )
   {
#ifdef USE_ARS
      ars4x32_int( state, (int32_t*)&res[ i ] );
#else
      threefry4x32_int( state, (int32_t*)&res[ i ] );
#endif
   }
   // catch a possible remainder
   if( i != lenRes )
   {
#ifdef USE_ARS
      ars4x32_int( state, (int32_t*)buffer );
#else
      threefry4x32_int( state, (int32_t*)buffer );
#endif
      for( j = INT64_C( 0 ); i + j < lenRes; j++ )
      {
         res[ i + j ] = buffer[ j ];
      }
   }
   return;
}

#endif // USE_MKL

/*
 * initialize the state for the random number generators used (Threefry or ARS)
 * rank and threadID determine the stream of random numbers used (by determining the key used in Threefry or ARS)
 * seed determines the initial value of the counter and by this the position within the stream of random numbers
 *
 * Arguments: state:    memory for state of the random number generator to initialize
 *            rank:     rank of the program (MPI)/number of the image (PGAS) using this state for a random number generator
 *            threadID: id of the thread using this state with a random number generator (pthreads/OpenMP)
 *            seed:     
 */
void frand123Init( frand123State_t *state, const int64_t rank, const int64_t threadID, const int64_t *seed )
{
#ifndef USE_MKL
   // test if state is not NULL -> allocate it
   if( state == NULL )
   {
      perror( "state is equal to NULL" );
   }
   // if seed is given use it, otherwise use bits already in state
   if( seed != NULL )
   {
      // use the seed for the counter
      state->state[ 0 ] = seed[ 0 ];
      state->state[ 1 ] = seed[ 1 ];
   }
   // use rank and threadID to choose a random stream
   state->state[ 2 ] = rank;
   state->state[ 3 ] = threadID;
#else // USE_MKL
   unsigned int params[ 8 ];
   int64_t *paramsAsInt64 = (int64_t*)&( params );
   if( seed != NULL )
   {
      // use the seed for the counter
      paramsAsInt64[ 2 ] = seed[ 0 ];
      paramsAsInt64[ 3 ] = seed[ 1 ];
   }
   // use rank and threadID to choose a random stream
   paramsAsInt64[ 0 ] = rank;
   paramsAsInt64[ 1 ] = threadID;
   vslNewStreamEx( state, VSL_BRNG_ARS5, 8, params );
#endif // USE_MKL
   return;
}
