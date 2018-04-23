#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include "rand123wrapper.h"
#include "frand123.h"

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
double frand123Double_scalar( int64_t *state )
{
   double buffer;
   frand123Double( state, 1ll, &buffer );
   return buffer;
}
// vectorial version
void frand123Double( int64_t *state, const long long lenRes, double *res )
{
   long long i;
   double buffer[ 2 ];

   // store directly to res while safe
   for( i = 0ll; ( i + 2ll ) < lenRes; i += 2ll )
   {
#ifdef USE_ARS
      ars2x64_u01( state, &res[ i ] );
#else
      threefry2x64_u01( state, &res[ i ] );
#endif
   }
   // catch a possible remainder
   if( i != lenRes )
   {
#ifdef USE_ARS
      ars2x64_u01( state, buffer );
#else
      threefry2x64_u01( state, buffer );
#endif
      res[ lenRes - 1ll ] = buffer[ 0 ];
   }
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
float frand123Single_scalar( int64_t *state )
{
   float buffer;
   frand123Single( state, 1ll, &buffer );
   return buffer;
}
// vectorial version
void frand123Single( int64_t *state, const long long lenRes, float *res )
{
   long long i, j;
   float buffer[ 4 ];

   // store directly to res while safe
   for( i = 0ll; ( i + 4ll ) < lenRes; i += 4ll )
   {
#ifdef USE_ARS
      ars4x32_u01( state, &res[ i ] );
#else
      threefry4x32_u01( state, &res[ i ] );
#endif
   }
   // catch a possible remainder
   if( i != lenRes )
   {
#ifdef USE_ARS
      ars4x32_u01( state, buffer );
#else
      threefry4x32_u01( state, buffer );
#endif
      for( j = 0ll; i + j < lenRes; j++ )
      {
         res[ i + j ] = buffer[ j ];
      }
   }
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
double frand123NormDouble_scalar( int64_t *state, const double mu, const double sigma )
{
   double buffer;
   frand123NormDouble( state, mu, sigma, 1ll, &buffer );
   return buffer;
}
// vectorial version
void frand123NormDouble( int64_t *state, const double mu, const double sigma, const long long lenRes, double *res )
{
   long long i;
   double buffer[ 2 ];

   // store directly to res while safe
   for( i = 0ll; ( i + 2ll ) < lenRes; i += 2ll )
   {
#ifdef USE_POLAR
      polar2x64( state, mu, sigma, &res[ i ] );
#else
      wichura2x64( state, mu, sigma, &res[ i ] );
#endif
   }
   // catch a possible remainder
   if( i != lenRes )
   {
#ifdef USE_POLAR
      polar2x64( state, mu, sigma, buffer );
#else
      wichura2x64( state, mu, sigma, buffer );
#endif
      res[ lenRes - 1ll ] = buffer[ 0 ];
   }
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
float frand123NormSingle_scalar( int64_t *state, const float mu, const float sigma )
{
   float buffer[ 2 ];
   polar4x32_two( state, mu, sigma, buffer );
   return buffer[ 0 ];
}
// vectorial version
void frand123NormSingle( int64_t *state, const float mu, const float sigma, const long long lenRes, float *res )
{
   long long i, j;
   float buffer[ 4 ];

   // store directly to res while safe
   for( i = 0ll; ( i + 4ll ) < lenRes; i += 4ll )
   {
      polar4x32( state, mu, sigma, &res[ i ] );
   }
   // catch a possible remainder
   if( i != lenRes )
   {
      polar4x32( state, mu, sigma, buffer );
      for( j = 0ll; i + j < lenRes; j++ )
      {
         res[ i + j ] = buffer[ j ];
      }
   }
   return;
}

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
int64_t frand123Integer64_scalar( int64_t *state )
{
   int64_t buffer;
   frand123Integer64( state, 1ll, &buffer );
   return buffer;
}
// vectorial version
void frand123Integer64( int64_t *state, const long long lenRes, int64_t *res )
{
   long long i;
   int64_t buffer[ 2 ];

   // store directly to res while safe
   for( i = 0ll; ( i + 2ll ) < lenRes; i += 2ll )
   {
#ifdef USE_ARS
      ars2x64_int( state, &res[ i ] );
#else
      threefry2x64_int( state, &res[ i ] );
#endif
   }
   // catch a possible remainder
   if( i != lenRes )
   {
#ifdef USE_ARS
      ars2x64_int( state, buffer );
#else
      threefry2x64_int( state, buffer );
#endif
      res[ lenRes - 1ll ] = buffer[ 0 ];
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
int32_t frand123Integer32_scalar( int64_t *state )
{
   int32_t buffer;
   frand123Integer32( state, 1ll, &buffer );
   return buffer;
}
// vectorial version
void frand123Integer32( int64_t *state, const long long lenRes, int32_t *res )
{
   long long i, j;
   int32_t buffer[ 4 ];

   // store directly to res while safe
   for( i = 0ll; ( i + 4ll ) < lenRes; i += 4ll )
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
      for( j = 0ll; i + j < lenRes; j++ )
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
uint64_t frand123UnsignedInteger64_scalar( int64_t *state )
{
   uint64_t buffer;
   frand123Integer64( state, 1ll, (int64_t*)&buffer );
   return buffer;
}
// vectorial version
void frand123UnsignedInteger64( int64_t *state, const long long lenRes, uint64_t *res )
{
   long long i;
   uint64_t buffer[ 2 ];

   // store directly to res while safe
   for( i = 0ll; ( i + 2ll ) < lenRes; i += 2ll )
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
      res[ lenRes - 1ll ] = buffer[ 0 ];
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
uint32_t frand123UnsignedInteger32_scalar( int64_t *state )
{
   uint32_t buffer;
   frand123Integer32( state, 1ll, (uint32_t*)&buffer );
   return buffer;
}
// vectorial version
void frand123UnsignedInteger32( int64_t *state, const long long lenRes, uint32_t *res )
{
   long long i, j;
   uint32_t buffer[ 4 ];

   // store directly to res while safe
   for( i = 0ll; ( i + 4ll ) < lenRes; i += 4ll )
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
      for( j = 0ll; i + j < lenRes; j++ )
      {
         res[ i + j ] = buffer[ j ];
      }
   }
   return;
}

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
void frand123Init( int64_t *state, const int64_t rank, const int64_t threadID, const int64_t *seed )
{
   // test if state is not NULL -> allocate it
   if( state == NULL )
   {
      perror( "state is equal to NULL" );
   }
   // if seed is given use it, otherwise use bits already in state
   if( seed != NULL )
   {
      // use the seed for the counter
      state[ 0 ] = seed[ 0 ];
      state[ 1 ] = seed[ 1 ];
   }
   // use rank and threadID to choose a random stream
   state[ 2 ] = rank;
   state[ 3 ] = threadID;
   return;
}
