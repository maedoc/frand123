#include <limits.h>

#if USE_ARS
   #include <ars.h>

   static const double factor  = 1.  / ( (double)UINT64_MAX + 1. );
   static const double summand = 0.5 / ( (double)UINT64_MAX + 1. );

   void ars2x64_u01( int64_t *state, double *res )
   {
      // extract counter and key from state
      ars4x32_ctr_t *ctr_ars = (ars4x32_ctr_t*)&state[0];
      ars4x32_key_t *key_ars = (ars4x32_key_t*)&state[2];
      // calc uniformly distributed integers
      ars4x32_ctr_t resArs = ars4x32_R( 6, *ctr_ars, *key_ars );
      // convert to uint64_t
      uint64_t resInts[2];
      resInts[0] = *((uint64_t*)&resArs.v[0]);
      resInts[1] = *((uint64_t*)&resArs.v[2]);
      // convert to uniformly distributed doubles in (0,1)
      res[0] = (double)resInts[0] * factor + summand;
      res[1] = (double)resInts[1] * factor + summand;
      // advance counter
      if( ctr_ars->v[0] < UINT64_MAX )
         ctr_ars->v[0]++;
      else
      {
         ctr_ars->v[0] = 0;
         if( ctr_ars->v[1] < UINT64_MAX )
            ctr_ars->v[1]++;
         else
         {
            ctr_ars->v[1] = 0;
            if( ctr_ars->v[2] < UINT64_MAX )
               ctr_ars->v[2]++;
            else
            {
               ctr_ars->v[2] = 0;
               ctr_ars->v[3]++;
            }
         }
      }
      return;
   }
#else
   #include <threefry.h>
   typedef union
   {
      threefry2x64_ctr_t ctr;
      uint64_t ints[2];
   } conv_union_t;

   static const double factor  = 1.  / ( (double)UINT64_MAX + 1. );
   static const double summand = 0.5 / ( (double)UINT64_MAX + 1. );

   void threefry2x64_u01( int64_t *state, double *res )
   {
      // extract counter and key from state
      threefry2x64_ctr_t *ctr_threefry = (threefry2x64_ctr_t*)&state[0];
      threefry2x64_key_t *key_threefry = (threefry2x64_key_t*)&state[2];
      // calc uniformly distributed integers
      conv_union_t resInt;
      resInt.ctr = threefry2x64_R( 13, *ctr_threefry, *key_threefry );
      // convert to uniformly distributed doubles in (0,1)
      res[0] = (double)resInt.ints[0] * factor + summand;
      res[1] = (double)resInt.ints[1] * factor + summand;
      // advance counter
      if( ctr_threefry->v[0] < UINT64_MAX )
         ctr_threefry->v[0]++;
      else
      {
         ctr_threefry->v[0] = 0;
         ctr_threefry->v[1]++;
      }
      return;
   }
#endif
