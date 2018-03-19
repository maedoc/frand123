module frand123
   use, intrinsic :: iso_c_binding, only: c_double, c_int64_t
   implicit none
   integer, parameter, public :: state_kind = c_int64_t
   integer, parameter, public :: state_size = 4
   integer, parameter, public :: res_kind   = c_double
      
#ifdef USE_ARS
   ! ARS based on ars4x32_R with 5 rounds
   interface
      subroutine ars2x64_u01( state, res ) bind( C, name='ars2x64_u01' )
         use, intrinsic :: iso_c_binding, only: c_double, c_int64_t
         implicit none
         integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
         real( kind = c_double ), dimension( 2 ), intent( inout )  :: res
      end subroutine
   end interface
#else
   ! Threefry based on threefry2x64_R with 13 rounds
   interface
      subroutine threefry2x64_u01( state, res ) bind( C, name='threefry2x64_u01')
         use, intrinsic :: iso_c_binding, only: c_double, c_int64_t
         implicit none
         integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
         real( kind = c_double ), dimension( 2 ), intent( inout )  :: res
      end subroutine
   end interface
#endif

contains
   ! generate size(res) random numbers using ARS
   subroutine frand123Dble( state, res )
      implicit none
      integer( kind = state_kind ), dimension( state_size ), intent( inout ) :: state
      real( kind = res_kind ), dimension(:), intent( inout ) :: res

      integer :: len_res, safe_it, i
      real( kind = res_kind ), dimension( 2 ) :: buffer

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
      if ( i .lt. len_res ) then
#ifdef USE_ARS
         call ars2x64_u01( state, buffer )
#else
         call threefry2x64_u01( state, buffer )
#endif
         res( len_res ) = buffer( 1 )
      endif
   end subroutine
      ! interface for C implementation

   ! initialize the state as follows:
   ! counter: first 64 bits:  first entry of seed
   !          second 64 bits: second entry of seed
   ! key:     first 64 bits:  rank
   !          second 64 bits: threadID
   subroutine seed_rand( state, rank, threadID, seed )
      implicit none
      integer( kind = state_kind ), dimension( state_size ), intent( inout ) :: state
      integer, intent( in ) :: rank
      integer, intent( in ) :: threadID
      integer( kind = state_kind ), dimension( 2 ), intent( in ) :: seed

      ! set state
      state( 1 ) = seed( 1 )
      state( 2 ) = seed( 2 )
      
      ! set key
      state( 3 ) = rank
      state( 4 ) = threadID
   end subroutine
end module
