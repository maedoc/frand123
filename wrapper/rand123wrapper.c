#include <stdint.h>

#if USE_ARS
   #include <ars.h>

   /*
    * Constants used to first map onto interval [0,1) and then onto (0,1)
    */
   static const double factor_double  = 1.  / ( (double)UINT64_MAX + 1. );
   static const double summand_double = 0.5 / ( (double)UINT64_MAX + 1. );

   /*
    * Function ars2x64_u01 calculates two double precision random numbers
    * uniformly distributed in (0,1).
    *
    * Arguments: state: four elements holding
    *                   counter: first  128 bit
    *                   key:     second 128 bit
    *            res:   address to storage for 2 double precision reals
    */
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
      res[0] = (double)resInts[0] * factor_double + summand_double;
      res[1] = (double)resInts[1] * factor_double + summand_double;
      // advance counter
      if( ctr_ars->v[0] < UINT32_MAX )
         ctr_ars->v[0]++;
      else
      {
         ctr_ars->v[0] = 0;
         if( ctr_ars->v[1] < UINT32_MAX )
            ctr_ars->v[1]++;
         else
         {
            ctr_ars->v[1] = 0;
            if( ctr_ars->v[2] < UINT32_MAX )
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

   /*
    * Constants used to first map onto (-0.5,0.5) and then (0,1)
    *
    * *******************
    * **** IMPORTANT ****
    * *******************
    * The value of enlarger was determined experimentally to ensure mapping onto (0,-1).
    * Its value is validated in test testAccuracyFloats
    */
#define enlarger 257.f;
   static const float  factor_float   = 1.f / ( (float)UINT32_MAX + 257.f );
   static const float  summand_float  = 0.5f;

   /*
    * Function ars4x32_u01 calculates four single precision random numbers
    * uniformly distributed in [0,1].
    *
    * Arguments: state: four elements holding
    *                   counter: first  128 bit
    *                   key:     second 128 bit
    *            res:   address to storage for 4 single precision reals
    */
   void ars4x32_u01( int64_t *state, float *res )
   {
      // extract counter and key from state
      ars4x32_ctr_t *ctr_ars = (ars4x32_ctr_t*)&state[0];
      ars4x32_key_t *key_ars = (ars4x32_key_t*)&state[2];
      // move to vector registers
      ars1xm128i_ctr_t c128;
      ars1xm128i_key_t k128;
      c128.v[0].m = _mm_set_epi32( ctr_ars->v[3], ctr_ars->v[2], ctr_ars->v[1], ctr_ars->v[0] );
      k128.v[0].m = _mm_set_epi32( key_ars->v[3], key_ars->v[2], key_ars->v[1], key_ars->v[0] );
      // calc uniformly distributed integers in SEE vector registers
      c128 = ars1xm128i_R( 6, c128, k128 );
      // convert signed integers to signed floats
      __m128 asSignedFloats = _mm_cvtepi32_ps( c128.v[0].m );
      // normalize to [-0.5,0.5] and add shift to end in [0,1]
      __m128 normFactor = _mm_load_ps1( &factor_float );
      __m128 summand    = _mm_load_ps1( &summand_float );
#ifdef USE_FMA
      __m128 restrictedToUnitInterval = _mm_fmadd_ps( asSignedFloats, normFactor, summand );
#else
      __m128 restrictedToUnitCircle = _mm_mul_ps( asSignedFloats, normFactor );
      __m128 restrictedToUnitInterval = _mm_add_ps( restrictedToUnitCircle, summand );
#endif
      // store result in memory
      _mm_storeu_ps( res, restrictedToUnitInterval );
      // advance counter
      if( ctr_ars->v[0] < UINT32_MAX )
         ctr_ars->v[0]++;
      else
      {
         ctr_ars->v[0] = 0;
         if( ctr_ars->v[1] < UINT32_MAX )
            ctr_ars->v[1]++;
         else
         {
            ctr_ars->v[1] = 0;
            if( ctr_ars->v[2] < UINT32_MAX )
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
   
   /*
    * Function ars2x64_int calculates two 64 bit signed integers
    *
    * Arguments: state: four elements holding
    *                   counter: first  128 bit
    *                   key:     second 128 bit
    *            res:   adress to storage for 2 64 bit signed integers
    */
   void ars2x64_int( int64_t *state, int64_t *res )
   {
      // extract counter and key from state
      ars4x32_ctr_t *ctr_ars = (ars4x32_ctr_t*)&state[0];
      ars4x32_key_t *key_ars = (ars4x32_key_t*)&state[2];
      // calc uniformly distributed integers
      ars4x32_ctr_t resArs = ars4x32_R( 6, *ctr_ars, *key_ars );
      // store in res and reinterpret as int64_t
      res[0] = *((int64_t*)&resArs.v[0]);
      res[1] = *((int64_t*)&resArs.v[2]);
      // advance counter
      if( ctr_ars->v[0] < UINT32_MAX )
         ctr_ars->v[0]++;
      else
      {
         ctr_ars->v[0] = 0;
         if( ctr_ars->v[1] < UINT32_MAX )
            ctr_ars->v[1]++;
         else
         {
            ctr_ars->v[1] = 0;
            if( ctr_ars->v[2] < UINT32_MAX )
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
   
   /*
    * Function ars4x32_int calculates four 32 bit signed integers
    *
    * Arguments: state: four elements holding
    *                   counter: first  128 bit
    *                   key:     second 128 bit
    *            res:   adress to storage for 4 32 bit signed integers
    */
   void ars4x32_int( int64_t *state, int32_t *res )
   {
      // extract counter and key from state
      ars4x32_ctr_t *ctr_ars = (ars4x32_ctr_t*)&state[0];
      ars4x32_key_t *key_ars = (ars4x32_key_t*)&state[2];
      // calc uniformly distributed integers
      ars4x32_ctr_t resArs = ars4x32_R( 6, *ctr_ars, *key_ars );
      // store in res and reinterpret as int64_t
      res[0] = *((int32_t*)&resArs.v[0]);
      res[1] = *((int32_t*)&resArs.v[1]);
      res[2] = *((int32_t*)&resArs.v[2]);
      res[3] = *((int32_t*)&resArs.v[3]);
      // advance counter
      if( ctr_ars->v[0] < UINT32_MAX )
         ctr_ars->v[0]++;
      else
      {
         ctr_ars->v[0] = 0;
         if( ctr_ars->v[1] < UINT32_MAX )
            ctr_ars->v[1]++;
         else
         {
            ctr_ars->v[1] = 0;
            if( ctr_ars->v[2] < UINT32_MAX )
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

   /*
    * Union conv_union_t simplifies access to bits generated using threefry2x64
    */
   typedef union
   {
      threefry2x64_ctr_t ctr;
      uint64_t ints[2];
   } conv_union_t;

   /*
    * Constants used to first map onto interval [0,1) and then onto (0,1)
    */
   static const double factor_double  = 1.  / ( (double)UINT64_MAX + 1. );
   static const double summand_double = 0.5 / ( (double)UINT64_MAX + 1. );

   /*
    * Function threefry2x64_u01 returns 2 double precision reals
    *
    * Arguments: state: four elements holding
    *                   counter: first  128 bit
    *                   key:     second 128 bit
    *            res:   address to storage for 2 double precision reals
    */
   void threefry2x64_u01( int64_t *state, double *res )
   {
      // extract counter and key from state
      threefry2x64_ctr_t *ctr_threefry = (threefry2x64_ctr_t*)&state[0];
      threefry2x64_key_t *key_threefry = (threefry2x64_key_t*)&state[2];
      // calc uniformly distributed integers
      conv_union_t resInt;
      resInt.ctr = threefry2x64_R( 13, *ctr_threefry, *key_threefry );
      // convert to uniformly distributed doubles in (0,1)
      res[0] = (double)resInt.ints[0] * factor_double + summand_double;
      res[1] = (double)resInt.ints[1] * factor_double + summand_double;
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

   /*
    * Constants used to first map onto interval [0,1) and then onto (0,1)
    */
   static const float factor_float   = 1.  / ( (float)UINT32_MAX + 400.f );
   static const float summand_float  = 0.5 / ( (float)UINT32_MAX + 400.f );

   /*
    * Function threefry4x32_u01 returns 4 single precision reals
    *
    * Arguments: state: four elements holding
    *                   counter: first  128 bit
    *                   key:     second 128 bit
    *                   res:     address to storage for 4 single precision reals
    */
   void threefry4x32_u01( int64_t *state, float *res )
   {
      // extract counter and key from state
      threefry4x32_ctr_t *ctr_threefry = (threefry4x32_ctr_t*)&state[0];
      threefry4x32_key_t *key_threefry = (threefry4x32_key_t*)&state[2];
      // calc uniformly distributed integers
      threefry4x32_ctr_t resInt = threefry4x32_R( 12, *ctr_threefry, *key_threefry );
      // convert to uniformly distributed floats in (0,1)
      res[0] = (float)resInt.v[0] * factor_float + summand_float;
      res[1] = (float)resInt.v[1] * factor_float + summand_float;
      res[2] = (float)resInt.v[2] * factor_float + summand_float;
      res[3] = (float)resInt.v[3] * factor_float + summand_float;
      // advance counter
      if( ctr_threefry->v[0] < UINT32_MAX )
         ctr_threefry->v[0]++;
      else
      {
         ctr_threefry->v[0] = 0;
         if( ctr_threefry->v[1] < UINT32_MAX )
            ctr_threefry->v[1]++;
         else
         {
            ctr_threefry->v[1] = 0;
            if( ctr_threefry->v[2] < UINT32_MAX )
               ctr_threefry->v[2]++;
            else
            {
               ctr_threefry->v[2] = 0;
               ctr_threefry->v[3]++;
            }
         }
      }
      return;
   }

   /*
    * Function threefry2x64_int returns 2 64 bit signed integers
    *
    * Arguments: state: four elements holding
    *                   counter: first  128 bit
    *                   key:     second 128 bit
    *            res:   address to storage for 2 64 bit signed integers
    */
   void threefry2x64_int( int64_t *state, int64_t *res )
   {
      // extract counter and key from state
      threefry2x64_ctr_t *ctr_threefry = (threefry2x64_ctr_t*)&state[0];
      threefry2x64_key_t *key_threefry = (threefry2x64_key_t*)&state[2];
      // calc uniformly distributed integers
      threefry2x64_ctr_t resThreefry = threefry2x64_R( 13, *ctr_threefry, *key_threefry );
      // reinterprete as signed 64 bit integer
      res[0] = *((int64_t*)&resThreefry.v[0]);
      res[1] = *((int64_t*)&resThreefry.v[2]);
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

   /*
    * Function threefry4x32 returns 4 32 bit signed integers
    *
    * Arguments: state: four elements holding
    *                   counter: first  128 bit
    *                   key:     second 128 bit
    *            res:     address to storage for 4 32 bit signed integers
    */
   void threefry4x32_int( int64_t *state, int32_t *res )
   {
      // extract counter and key from state
      threefry4x32_ctr_t *ctr_threefry = (threefry4x32_ctr_t*)&state[0];
      threefry4x32_key_t *key_threefry = (threefry4x32_key_t*)&state[2];
      // calc uniformly distributed integers
      threefry4x32_ctr_t resInt = threefry4x32_R( 12, *ctr_threefry, *key_threefry );
      // reinterprete as 32 bit signed integer
      res[0] = *((int32_t*)&resInt.v[0]);
      res[1] = *((int32_t*)&resInt.v[1]);
      res[2] = *((int32_t*)&resInt.v[2]);
      res[3] = *((int32_t*)&resInt.v[3]);
      // advance counter
      if( ctr_threefry->v[0] < UINT32_MAX )
         ctr_threefry->v[0]++;
      else
      {
         ctr_threefry->v[0] = 0;
         if( ctr_threefry->v[1] < UINT32_MAX )
            ctr_threefry->v[1]++;
         else
         {
            ctr_threefry->v[1] = 0;
            if( ctr_threefry->v[2] < UINT32_MAX )
               ctr_threefry->v[2]++;
            else
            {
               ctr_threefry->v[2] = 0;
               ctr_threefry->v[3]++;
            }
         }
      }
   }

#endif
