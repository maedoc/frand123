module frand123
   use, intrinsic :: iso_c_binding, only: c_float, c_double, c_int64_t, c_int32_t
   implicit none

   private

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

   public :: frand123Double
   public :: frand123Single
   public :: frand123Integer32
   public :: frand123Integer64
   public :: frand123Init

contains
   ! generate size(res) random double precision numbers
   !
   ! Arguments: state: state of the random number generator
   !                   the counter in the state is incremented in every call
   !            res:   array to be filled with random double precision reals in (0,1)
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

   ! generate size(res) random single precision numbers
   !
   ! Arguments: state: state of the random number generator
   !                   the counter in the state is incremented in every call
   !            res:   array to be filled with random single precision reals in (0,1)
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
         call threefry4x32_u01( state, res( 4*i-3:4*i ) )
#endif
      enddo
      ! finish remaining random numbers
      if( 4*i .lt. len_res ) then
#ifdef USE_ARS
         call ars4x32_u01( state, buffer )
#else
         call threefry4x32_u01( state, buffer )
#endif
         ! calc number of remaining random numbers
         remaining = len_res - 4 * i
         ! store calculated random numbers in res
         res( 4*i+1:len_res ) = buffer( 1:remaining )
      endif
   end subroutine frand123Single

   ! generate size(res) random 64 bit signed integers
   !
   ! Arguments: state: state of the random number generator
   !                   the counter in the state is incremented in every call
   !            res:   array to be filled with random 64 bit signed integers
   subroutine frand123Integer64( state, res )
      implicit none
      integer( kind = state_kind ), dimension( state_size ), intent( inout) :: state
      integer( kind = res_kind_int64 ), dimension(:), intent( inout ) :: res

      integer :: len_res, safe_it, i
      integer( kind = res_kind_int64 ), dimension( 2 ) :: buffer

      ! get length of res
      len_res = size( res )

      ! calc number of safe iterations
      safe_it = len_res / 2 

      ! generate sufficient number of random numbers
      do i = 1, safe_it
#ifdef USE_ARS
         call ars2x64_int( state, res( 2*i-1:2*i ) )
#else
         call threefry2x64_int( state, res( 2*i-1:2*i ) )
#endif
      enddo
      ! finish remaining random numbers
      if( 2*i .lt. len_res ) then
#ifdef USE_ARS
         call ars2x64_int( state, buffer )
#else
         call threefry2x64_int( state, buffer )
#endif
         res( len_res ) = buffer( 1 )
      endif
   end subroutine frand123Integer64

   ! generate size(res) random 32 bit signed integers
   !
   ! Arguments: state: state of the random number generator
   !                   the counter in the state is incremented in every call
   !            res:   array to be filled with random 32 bit signed integers
   subroutine frand123Integer32( state, res )
      implicit none
      integer( kind = state_kind ), dimension( state_size ), intent( inout ) :: state
      integer( kind = res_kind_int32 ), dimension(:), intent( inout ) :: res

      integer :: len_res, safe_it, i, remaining
      integer( kind = res_kind_int32 ), dimension( 4 ) :: buffer

      ! get length of res
      len_res = size( res )

      ! calc numver of safe iterations
      safe_it = len_res / 4

      ! generate sufficient number of random numbers
      do i = 1, safe_it
#ifdef USE_ARS
         call ars4x32_int( state, res( 4*i-3:4*i ) )
#else
         call threefry4x32_int( state, res( 4*i-3:4*i ) )
#endif
      enddo
      ! finish remaining random numbers
      if( 4*i .lt. len_res ) then
#ifdef USE_ARS
         call ars4x32_int( state, buffer )
#else
         call threefry4x32_int( state, buffer )
#endif
         ! calc number of remaining random numbers
         remaining = len_res - 4 * i
         ! store calculated random numbers in res
         res( 4*i+1:len_res ) = buffer( 1:remaining )
      endif
   end subroutine frand123Integer32

   ! initialize the state as follows:
   ! counter: first  64 bits: first entry of seed
   !          second 64 bits: second entry of seed
   ! key:     first  64 bits: rank
   !          second 64 bits: threadID
   !
   ! Arguments: state:    storage to hold the state of the random number generator
   !                      the state is handed over in each call to the random
   !                      number generators
   !            rank:     rank of the process using the random number generator
   !                      allows MPI-parallel use of the random number generator
   !                      If not in MPI situation, choose freely
   !            threadID: ID of the thread using the random number generator
   !                      allows thread-parallel use of the random number generator
   !                      If not in threaded situation, choose freely
   !            seed:     Seed for the random number generator to allow for
   !                      different or same random numbers with each run
   subroutine frand123Init( state, rank, threadID, seed )
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
   end subroutine frand123Init
end module
