#include "rand123wrapper.h"

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

void frand123Init( int64_t *state, const int64_t rank, const int64_t threadID, const int64_t *seed )
{
   // use the seed for the counter
   state[ 0 ] = seed[ 0 ];
   state[ 1 ] = seed[ 1 ];
   // use rank and threadID to choose a random stream
   state[ 2 ] = rank;
   state[ 3 ] = threadID;
   return;
}
