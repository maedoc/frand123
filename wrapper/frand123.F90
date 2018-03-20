module frand123
   use, intrinsic :: iso_c_binding, only: c_float, c_double, c_int64_t
   implicit none

   private

   integer, parameter, public :: state_kind      = c_int64_t
   integer, parameter, public :: state_size      = 4
   integer, parameter, public :: res_kind_double = c_double
   integer, parameter, public :: res_kind_single = c_float
      
#ifdef USE_ARS
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
   end interface
#else
   interface
      ! Threefry based on threefry2x64_R with 13 rounds
      subroutine threefry2x64_u01( state, res ) bind( C, name='threefry2x64_u01')
         use, intrinsic :: iso_c_binding, only: c_double, c_int64_t
         implicit none
         integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
         real( kind = c_double ), dimension( 2 ), intent( inout )  :: res
      end subroutine
   end interface
#endif

   public :: frand123Double, frand123Single, init_rand

contains
   ! generate size(res) random double precision numbers using ARS
   subroutine frand123Double( state, res )
      implicit none
      integer( kind = state_kind ), dimension( state_size ), intent( inout ) :: state
      real( kind = res_kind_double ), dimension(:), intent( inout ) :: res

      integer :: len_res, safe_it, i
      real( kind = res_kind_double ), dimension( 2 ) :: buffer

      ! get length of res
      len_res = size( res )
      
      ! calc number of safe iterations
      safe_it = len_res / 2

      ! generate sufficient number of random numbers
      do i = 1, safe_it
#ifdef USE_ARS
         call ars2x64_u01( state, res( 2*i-1:2*i ) )
#else
         call threefry2x64_u01( state, res( 2*i-1:2*i ) )
#endif
      enddo
      ! finish in case of odd number of random numbers
      if ( 2*i .lt. len_res ) then
#ifdef USE_ARS
         call ars2x64_u01( state, buffer )
#else
         call threefry2x64_u01( state, buffer )
#endif
         res( len_res ) = buffer( 1 )
      endif
   end subroutine frand123Double

   ! generate size(res) random single precision numbers using ARS
   subroutine frand123Single( state, res )
      implicit none
      integer( kind = state_kind ), dimension( state_size ), intent( inout ) :: state
      real( kind = res_kind_single ), dimension(:), intent( inout ) :: res

      integer :: len_res, safe_it, i, remaining
      real( kind = res_kind_single ), dimension( 4 ) :: buffer

      ! get length of res
      len_res = size( res )

      ! calc numver of safe iterations
      safe_it = len_res / 4

      ! generate sufficient number of random numbers
      do i = 1, safe_it
#ifdef USE_ARS
         call ars4x32_u01( state, res( 4*i-3:4*i ) )
#else
#endif
      enddo
      ! finish remaining random numbers
      if( 4*i .lt. len_res ) then
#ifdef USE_ARS
         call ars4x32_u01( state, buffer )
#else
#endif
         ! calc number of remaining random numbers
         remaining = len_res - 4 * i
         ! store calculated random numbers in res
         res( 4*i+1:len_res ) = buffer( 1:remaining )
      endif
   end subroutine frand123Single

   ! initialize the state as follows:
   ! counter: first 64 bits:  first entry of seed
   !          second 64 bits: second entry of seed
   ! key:     first 64 bits:  rank
   !          second 64 bits: threadID
   subroutine init_rand( state, rank, threadID, seed )
      implicit none
      integer( kind = state_kind ), dimension( state_size ), intent( inout ) :: state
      integer, intent( in ) :: rank
      integer, intent( in ) :: threadID
      integer( kind = state_kind ), dimension( 2 ), intent( in ), optional :: seed

      ! set counter if present
      if(present(seed)) then
         state( 1 ) = seed( 1 )
         state( 2 ) = seed( 2 )
      end if

      ! set key
      state( 3 ) = rank
      state( 4 ) = threadID
   end subroutine init_rand
end module
