module frand123
   use frand123CInterfaces
   implicit none

   ! interfaces allowing use with scalar and vector arguments
   interface frand123Double
      module procedure frand123Double_scalar
      module procedure frand123Double_vector
   end interface frand123Double

   interface frand123Single
      module procedure frand123Single_scalar
      module procedure frand123Single_vector
   end interface frand123Single

   interface frand123NormDouble
      module procedure frand123NormDouble_scalar
      module procedure frand123NormDouble_vector
   end interface frand123NormDouble

   interface frand123NormSingle
      module procedure frand123NormSingle_scalar
      module procedure frand123NormSingle_vector
   end interface frand123NormSingle

   interface frand123Integer64
      module procedure frand123Integer64_scalar
      module procedure frand123Integer64_vector
   end interface frand123Integer64

   interface frand123Integer32
      module procedure frand123Integer32_scalar
      module procedure frand123Integer32_vector
   end interface frand123Integer32

   public :: state_kind
   public :: state_size
   public :: res_kind_double
   public :: res_kind_single
   public :: res_kind_int64
   public :: res_kind_int32
   public :: frand123Double
   public :: frand123Single
   public :: frand123NormDouble
   public :: frand123NormSingle
   public :: frand123Integer32
   public :: frand123Integer64
   public :: frand123Init

contains

   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   !!!!!                           !!!!! 
   !!!!!  uniform double precision !!!!!
   !!!!!                           !!!!!
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

   ! generate single random double precision number
   !
   ! Arguments: state: state of the random number generator
   !                   the counter in the state is incremented in every call
   !            res:   scalar for random double precision reals in (0,1)
   subroutine frand123Double_scalar( state, res )
      implicit none
      integer( kind = state_kind ), dimension( state_size ), intent( inout ) :: state
      real( kind = res_kind_double ), intent( out ) :: res

      real( kind = res_kind_double ), dimension( 2 ) :: buffer

#ifdef USE_ARS
      call ars2x64_u01( state, buffer )
#else
      call threefry2x64_u01( state, buffer )
#endif
      res = buffer( 1 )
   end subroutine frand123Double_scalar

   ! generate size(res) random double precision numbers
   !
   ! Arguments: state: state of the random number generator
   !                   the counter in the state is incremented in every call
   !            res:   array to be filled with random double precision reals in (0,1)
   subroutine frand123Double_vector( state, res )
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
      if ( mod( len_res, 2 ) .eq. 1 ) then
#ifdef USE_ARS
         call ars2x64_u01( state, buffer )
#else
         call threefry2x64_u01( state, buffer )
#endif
         res( len_res ) = buffer( 1 )
      endif
   end subroutine frand123Double_vector

   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   !!!!!                           !!!!! 
   !!!!!  uniform single precision !!!!!
   !!!!!                           !!!!!
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

   ! generate a single random single precision numbers
   !
   ! Arguments: state: state of the random number generator
   !                   the counter in the state is incremented in every call
   !            res:  scalar for random single precision reals in (0,1)
   subroutine frand123Single_scalar( state, res )
      implicit none
      integer( kind = state_kind ), dimension( state_size ), intent( inout ) :: state
      real( kind = res_kind_single ), intent( out ) :: res

      real( kind = res_kind_single ), dimension( 4 ) :: buffer

#ifdef USE_ARS
      call ars4x32_u01( state, buffer )
#else
      call threefry4x32_u01( state, buffer )
#endif
      res = buffer( 1 )
   end subroutine frand123Single_scalar

   ! generate size(res) random single precision numbers
   !
   ! Arguments: state: state of the random number generator
   !                   the counter in the state is incremented in every call
   !            res:   array to be filled with random single precision reals in (0,1)
   subroutine frand123Single_vector( state, res )
      implicit none
      integer( kind = state_kind ), dimension( state_size ), intent( inout ) :: state
      real( kind = res_kind_single ), dimension(:), intent( inout ) :: res

      integer :: len_res, safe_it, i, mod_len_res
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
      mod_len_res = mod( len_res, 4 )
      if( mod_len_res .ne. 0 ) then
#ifdef USE_ARS
         call ars4x32_u01( state, buffer )
#else
         call threefry4x32_u01( state, buffer )
#endif
         ! store calculated random numbers in res
         res( len_res-mod_len_res+1:len_res ) = buffer( 1:mod_len_res )
      endif
   end subroutine frand123Single_vector

   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   !!!!!                          !!!!! 
   !!!!!  normal double precision !!!!!
   !!!!!                          !!!!!
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

   ! generate single normally distributedrandom double precision numbers
   !
   ! Arguments: state: state of the random number generator
   !                   the counter in the state is incremented in every call
   !            mu:    expected value
   !            sigma: variance
   !            res:   scalar random double precision reals
   subroutine frand123NormDouble_scalar( state, mu, sigma, res )
      implicit none
      integer( kind = state_kind ), dimension( state_size ), intent( inout ) :: state
      real( kind = res_kind_double ), intent( in ) :: mu
      real( kind = res_kind_double ), intent( in ) :: sigma
      real( kind = res_kind_double ), intent( out ) :: res

      real( kind = res_kind_double ), dimension( 2 ) :: buffer
#ifdef USE_POLAR
      call polar2x64( state, mu, sigma, buffer )
#else
      call wichura2x64( state, mu, sigma, buffer )
#endif
      res = buffer( 1 )
   end subroutine frand123NormDouble_scalar

   ! generate size(res) normally distributedrandom double precision numbers
   !
   ! Arguments: state: state of the random number generator
   !                   the counter in the state is incremented in every call
   !            mu:    expected value
   !            sigma: variance
   !            res:   array to be filled with random double precision reals
   subroutine frand123NormDouble_vector( state, mu, sigma, res )
      implicit none
      integer( kind = state_kind ), dimension( state_size ), intent( inout ) :: state
      real( kind = res_kind_double ), intent( in ) :: mu
      real( kind = res_kind_double ), intent( in ) :: sigma
      real( kind = res_kind_double ), dimension(:), intent( inout ) :: res

      integer :: len_res, safe_it, i
      real( kind = res_kind_double ), dimension( 2 ) :: buffer

      ! get length of res
      len_res = size( res )
      
      ! calc number of safe iterations
      safe_it = len_res / 2
  
      ! generate sufficient number of random numbers
      do i = 1, safe_it
#if defined( USE_POLAR )
         call polar2x64( state, mu, sigma, res( 2*i-1:2*i ) )
#elif defined( USE_WICHURA )
         call wichura2x64( state, mu, sigma, res( 2*i-1:2*i ) )
#endif

      enddo
      ! finish in case of odd number of random numbers
      if( mod( len_res, 2 ) .eq. 1 ) then
#if defined( USE_POLAR )
         call polar2x64( state, mu, sigma, buffer )
#elif defined( USE_WICHURA )
         call wichura2x64( state, mu, sigma, buffer )
#endif
         res( len_res ) = buffer( 1 )
      endif
   end subroutine frand123NormDouble_vector

   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   !!!!!                          !!!!! 
   !!!!!  normal single precision !!!!!
   !!!!!                          !!!!!
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

   ! generate single normally distributedrandom single precision numbers
   ! 
   ! Note: The single precision version always uses the polar form of Box-Muller
   !       as this turned out to be on par with Wichura's PPND7 w.r.t.
   !       performance and excels w.r.t. quality of the random numbers
   !
   ! Arguments: state: state of the random number generator
   !                   the counter in the state is incremented in every call
   !            mu:    expected value
   !            sigma: variance
   !            res:   scalar for random single precision reals
   subroutine frand123NormSingle_scalar( state, mu, sigma, res )
      implicit none
      integer( kind = state_kind ), dimension( state_size ), intent( inout ) :: state
      real( kind = res_kind_single ), intent( in ) :: mu
      real( kind = res_kind_single ), intent( in ) :: sigma
      real( kind = res_kind_single ), intent( out ) :: res

      real( kind = res_kind_single ), dimension( 2 ) :: buffer

      ! call different C function as performance of polar rejection method can
      ! be improved by allowing for a single pair of uniform random numbers to
      ! lie within the unit circle
      call polar4x32_two( state, mu, sigma, buffer )
      res = buffer( 1 )
   end subroutine frand123NormSingle_scalar

   ! generate size(res) normally distributedrandom single precision numbers
   ! 
   ! Note: The single precision version always uses the polar form of Box-Muller
   !       as this turned out to be on par with Wichura's PPND7 w.r.t.
   !       performance and excels w.r.t. quality of the random numbers
   !
   ! Arguments: state: state of the random number generator
   !                   the counter in the state is incremented in every call
   !            mu:    expected value
   !            sigma: variance
   !            res:   array to be filled with random single precision reals
   subroutine frand123NormSingle_vector( state, mu, sigma, res )
      implicit none
      integer( kind = state_kind ), dimension( state_size ), intent( inout ) :: state
      real( kind = res_kind_single ), intent( in ) :: mu
      real( kind = res_kind_single ), intent( in ) :: sigma
      real( kind = res_kind_single ), dimension(:), intent( inout ) :: res

      integer :: len_res, safe_it, i, mod_len_res
      real( kind = res_kind_single ), dimension( 4 ) :: buffer

      ! get length of res
      len_res = size( res )

      ! handle case of only two random numbers more efficiently
      if( len_res .eq. 2 ) then
         call polar4x32_two( state, mu, sigma, res )
      else
         ! calc number of safe iterations
         safe_it = len_res / 4
     
         ! generate sufficient number of random numbers
         do i = 1, safe_it
            call polar4x32( state, mu, sigma, res( 4*i-3:4*i ) )
         enddo
         ! finish in case of odd number of random numbers
         mod_len_res = mod( len_res, 4 )
         if( mod_len_res .ne. 0 ) then
            call polar4x32( state, mu, sigma, buffer )
            ! store calculated random numbers in res
            res( len_res-mod_len_res+1:len_res ) = buffer( 1:mod_len_res )
         endif
      endif
   end subroutine frand123NormSingle_vector

   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   !!!!!                                !!!!! 
   !!!!!  random 64 bit signed integers !!!!!
   !!!!!                                !!!!!
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

   ! generate single random 64 bit signed integers
   !
   ! Arguments: state: state of the random number generator
   !                   the counter in the state is incremented in every call
   !            res:   scalar random 64 bit signed integers
   subroutine frand123Integer64_scalar( state, res )
      implicit none
      integer( kind = state_kind ), dimension( state_size ), intent( inout) :: state
      integer( kind = res_kind_int64 ), intent( out ) :: res

      integer( kind = res_kind_int64 ), dimension( 2 ) :: buffer

#ifdef USE_ARS
      call ars2x64_int( state, buffer )
#else
      call threefry2x64_int( state, buffer )
#endif
      res = buffer( 1 )
   end subroutine frand123Integer64_scalar

   ! generate size(res) random 64 bit signed integers
   !
   ! Arguments: state: state of the random number generator
   !                   the counter in the state is incremented in every call
   !            res:   array to be filled with random 64 bit signed integers
   subroutine frand123Integer64_vector( state, res )
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
      if( mod( len_res, 2 ) .eq. 1 ) then
#ifdef USE_ARS
         call ars2x64_int( state, buffer )
#else
         call threefry2x64_int( state, buffer )
#endif
         res( len_res ) = buffer( 1 )
      endif
   end subroutine frand123Integer64_vector

   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   !!!!!                                !!!!! 
   !!!!!  random 32 bit signed integers !!!!!
   !!!!!                                !!!!!
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

   ! generate single random 32 bit signed integers
   !
   ! Arguments: state: state of the random number generator
   !                   the counter in the state is incremented in every call
   !            res:   scalar for random 32 bit signed integers
   subroutine frand123Integer32_scalar( state, res )
      implicit none
      integer( kind = state_kind ), dimension( state_size ), intent( inout ) :: state
      integer( kind = res_kind_int32 ), intent( out ) :: res

      integer( kind = res_kind_int32 ), dimension( 4 ) :: buffer

#ifdef USE_ARS
      call ars4x32_int( state, buffer )
#else
      call threefry4x32_int( state, buffer )
#endif
      res = buffer( 1 )
   end subroutine frand123Integer32_scalar

   ! generate size(res) random 32 bit signed integers
   !
   ! Arguments: state: state of the random number generator
   !                   the counter in the state is incremented in every call
   !            res:   array to be filled with random 32 bit signed integers
   subroutine frand123Integer32_vector( state, res )
      implicit none
      integer( kind = state_kind ), dimension( state_size ), intent( inout ) :: state
      integer( kind = res_kind_int32 ), dimension(:), intent( inout ) :: res

      integer :: len_res, safe_it, i, mod_len_res
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
      mod_len_res = mod( len_res, 4 )
      if( mod_len_res .ne. 0 ) then
#ifdef USE_ARS
         call ars4x32_int( state, buffer )
#else
         call threefry4x32_int( state, buffer )
#endif
         ! store calculated random numbers in res
         res( len_res-mod_len_res+1:len_res ) = buffer( 1:mod_len_res )
      endif
   end subroutine frand123Integer32_vector

   !!!!!!!!!!!!!!!!!!!!!!!!!!!!
   !!!!!                  !!!!! 
   !!!!!  Initialization  !!!!!
   !!!!!                  !!!!!
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!

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
