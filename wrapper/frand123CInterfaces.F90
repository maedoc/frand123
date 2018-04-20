module frand123CInterfaces
   use, intrinsic :: iso_c_binding, only: c_float, c_double, c_int64_t, c_int32_t
   implicit none

   ! kind parameter for state variables
   integer, parameter, public :: state_kind      = c_int64_t
   ! size of the state (might be different if additional RNGs be supported
   integer, parameter, public :: state_size      = 4
   ! kind parameter for return arrays for double precision reals
   integer, parameter, public :: res_kind_double = c_double
   ! kind parameter for return arrays for single precision reals
   integer, parameter, public :: res_kind_single = c_float
   ! kind parameter for return arrays for 64 bit signed integers
   integer, parameter, public :: res_kind_int64  = c_int64_t
   ! kind parameter for return arrays for 32 bit signed integers
   integer, parameter, public :: res_kind_int32  = c_int32_t
      
#ifdef USE_ARS
   ! interfaces to C functions using ARS for random number generation
   interface
      ! ARS for 2 double precision based on ars4x32_R with 6 rounds
      subroutine ars2x64_u01( state, res ) bind( C, name='ars2x64_u01' )
         use, intrinsic :: iso_c_binding, only: c_double, c_int64_t
         implicit none
         integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
         real( kind = c_double ), dimension( 2 ), intent( inout )  :: res
      end subroutine
      ! ARS for 4 single precision based directly on ars1xm128i_R
      subroutine ars4x32_u01( state, res ) bind( C, name='ars4x32_u01' )
         use, intrinsic :: iso_c_binding, only: c_float, c_int64_t
         implicit none
         integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
         real( kind = c_float ), dimension( 4 ), intent( inout ) :: res
      end subroutine
      ! ARS for 2 64 bit signed integers based on ars4x32_R with 6 rounds
      subroutine ars2x64_int( state, res ) bind( C, name='ars2x64_int' )
         use, intrinsic :: iso_c_binding, only: c_int64_t
         implicit none
         integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
         integer( kind = c_int64_t ), dimension( 2 ), intent( inout ) :: res
      end subroutine
      ! ARS for 4 32 bit signed integers based on ars4x32_R with 6 rounds
      subroutine ars4x32_int( state, res ) bind( C, name='ars4x32_int' )
         use, intrinsic :: iso_c_binding, only: c_int64_t, c_int32_t
         implicit none
         integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
         integer( kind = c_int32_t ), dimension( 4 ), intent( inout ) :: res
      end subroutine
   end interface
#else
   ! interfaces to C functions using Threefry for random number generation
   interface
      ! Threefry based on threefry2x64_R with 13 rounds
      subroutine threefry2x64_u01( state, res ) bind( C, name='threefry2x64_u01')
         use, intrinsic :: iso_c_binding, only: c_double, c_int64_t
         implicit none
         integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
         real( kind = c_double ), dimension( 2 ), intent( inout )  :: res
      end subroutine
      ! Threefry based on threefry4x32_R with 12 rounds
      subroutine threefry4x32_u01( state, res ) bind( C, name='threefry4x32_u01')
         use, intrinsic :: iso_c_binding, only: c_float, c_int64_t
         implicit none
         integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
         real( kind = c_float ), dimension( 2 ), intent( inout )  :: res
      end subroutine
      ! Threefry for 2 64 bit signed integers based on ars4x32_R with 6 rounds
      subroutine threefry2x64_int( state, res ) bind( C, name='threefry2x64_int' )
         use, intrinsic :: iso_c_binding, only: c_int64_t
         implicit none
         integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
         integer( kind = c_int64_t ), dimension( 2 ), intent( inout ) :: res
      end subroutine
      ! Threefry for 4 32 bit signed integers based on ars4x32_R with 6 rounds
      subroutine threefry4x32_int( state, res ) bind( C, name='threefry4x32_int' )
         use, intrinsic :: iso_c_binding, only: c_int64_t, c_int32_t
         implicit none
         integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
         integer( kind = c_int32_t ), dimension( 4 ), intent( inout ) :: res
      end subroutine
   end interface
#endif
#ifdef USE_POLAR
   interface
      ! compute two double precision normally distributed random variables with
      ! expectation mu and variance sigma using polar Box-Muller algorithm
      ! use ARS or threefry based uniform random number generators
      subroutine polar2x64( state, mu, sigma, res ) bind( C, name='polar2x64')
         use, intrinsic :: iso_c_binding, only: c_double, c_int64_t
         implicit none
         integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
         real( kind = c_double ), value, intent( in ) :: mu
         real( kind = c_double ), value, intent( in ) :: sigma
         real( kind = c_double ), dimension( 2 ), intent( inout )  :: res
      end subroutine
   end interface
#else
   interface
      ! compute two double precision normally distributed random variables with
      ! expectation mu and variance sigma using inverse transform sampling using
      ! the algorithm AS241 proposed by Wichura 1988
      ! use ARS or threefry based uniform random number generators
      subroutine wichura2x64( state, mu, sigma, res ) bind( C, name='wichura2x64')
         use, intrinsic :: iso_c_binding, only: c_double, c_int64_t
         implicit none
         integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
         real( kind = c_double ), value, intent( in ) :: mu
         real( kind = c_double ), value, intent( in ) :: sigma
         real( kind = c_double ), dimension( 2 ), intent( inout )  :: res
      end subroutine
   end interface
#endif
   interface
      ! compute four single precision normally distributed random variables with
      ! expectation mu and variance sigma using polar Box-Muller algorithm
      ! use ARS or threefry based uniform random number generators
      subroutine polar4x32( state, mu, sigma, res ) bind( C, name='polar4x32')
         use, intrinsic :: iso_c_binding, only: c_float, c_int64_t
         implicit none
         integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
         real( kind = c_float ), value, intent( in ) :: mu
         real( kind = c_float ), value, intent( in ) :: sigma
         real( kind = c_float ), dimension( 4 ), intent( inout )  :: res
      end subroutine
      ! compute two single precision normally distributed random variables with
      ! expectation mu and variance sigma using polar Box-Muller algorithm
      ! use ARS or threefry based uniform random number generators
      ! beneficial wrt to runtime if only 1 or 2 random numbers required
      subroutine polar4x32_two( state, mu, sigma, res ) bind( C, name='polar4x32_two')
         use, intrinsic :: iso_c_binding, only: c_float, c_int64_t
         implicit none
         integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
         real( kind = c_float ), value, intent( in ) :: mu
         real( kind = c_float ), value, intent( in ) :: sigma
         real( kind = c_float ), dimension( 2 ), intent( inout )  :: res
      end subroutine
   end interface

   interface
      subroutine frand123Double_C( state, lenRes, res ) bind( C, name='frand123Double' )
         use, intrinsic :: iso_c_binding, only: c_double, c_int64_t, c_long_long
         implicit none
         integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
         integer( kind = c_long_long ), value, intent( in ) :: lenRes
         real( kind = c_double ), dimension( lenRes ), intent( inout ) :: res
      end subroutine
      subroutine frand123Single_C( state, lenRes, res ) bind( C, name='frand123Single' )
         use, intrinsic :: iso_c_binding, only: c_float, c_int64_t, c_long_long
         implicit none
         integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
         integer( kind = c_long_long ), value, intent( in ) :: lenRes
         real( kind = c_float ), dimension( lenRes ), intent( inout ) :: res
      end subroutine
      subroutine frand123NormDouble_C( state, mu, sigma, lenRes, res ) bind( C, name='frand123NormDouble' )
         use, intrinsic :: iso_c_binding, only: c_double, c_int64_t, c_long_long
         implicit none
         integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
         real( kind = c_double ), value, intent( in ) :: mu
         real( kind = c_double ), value, intent( in ) :: sigma
         integer( kind = c_long_long ), value, intent( in ) :: lenRes
         real( kind = c_double ), dimension( lenRes ), intent( inout ) :: res
      end subroutine
      subroutine frand123NormSingle_C( state, mu, sigma, lenRes, res ) bind( C, name='frand123NormSingle' )
         use, intrinsic :: iso_c_binding, only: c_float, c_int64_t, c_long_long
         implicit none
         integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
         real( kind = c_float ), value, intent( in ) :: mu
         real( kind = c_float ), value, intent( in ) :: sigma
         integer( kind = c_long_long ), value, intent( in ) :: lenRes
         real( kind = c_float ), dimension( lenRes ), intent( inout ) :: res
      end subroutine
      subroutine frand123Integer64_C( state, lenRes, res ) bind( C, name='frand123Integer64' )
         use, intrinsic :: iso_c_binding, only: c_int64_t, c_long_long
         implicit none
         integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
         integer( kind = c_long_long ), value, intent( in ) :: lenRes
         integer( kind = c_int64_t ), dimension( lenRes ), intent( inout ) :: res
      end subroutine
      subroutine frand123Integer32_C( state, lenRes, res ) bind( C, name='frand123Integer32' )
         use, intrinsic :: iso_c_binding, only: c_int32_t, c_int64_t, c_long_long
         implicit none
         integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
         integer( kind = c_long_long ), value, intent( in ) :: lenRes
         integer( kind = c_int32_t ), dimension( lenRes ), intent( inout ) :: res
      end subroutine
   end interface

end module frand123CInterfaces
