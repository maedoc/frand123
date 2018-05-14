module frand123
   use, intrinsic :: iso_c_binding, only: c_int64_t
   implicit none
   integer, parameter :: frand123_state_kind = c_int64_t
   integer, parameter :: frand123_state_size = 4

   ! interfaces to C functions
   interface
      subroutine frand123Double_C( state, lenRes, res ) bind( C, name='frand123Double' )
         use, intrinsic :: iso_c_binding, only: c_int64_t, c_double
         implicit none
         integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
         integer( kind = c_int64_t ), value, intent( in ) :: lenRes
         real( kind = c_double ), dimension( * ), intent( inout ) :: res
      end subroutine frand123Double_C
      subroutine frand123Single_C( state, lenRes, res ) bind( C, name='frand123Single' )
         use, intrinsic :: iso_c_binding, only: c_int64_t, c_float
         implicit none
         integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
         integer( kind = c_int64_t ), value, intent( in ) :: lenRes
         real( kind = c_float ), dimension( * ), intent( inout ) :: res
      end subroutine frand123Single_C
      subroutine frand123NormDouble_C( state, mu, sigma, lenRes, res ) bind( C, name='frand123NormDouble' )
         use, intrinsic :: iso_c_binding, only: c_int64_t, c_double
         implicit none
         integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
         real( kind = c_double ), value, intent( in ) :: mu
         real( kind = c_double ), value, intent( in ) :: sigma
         integer( kind = c_int64_t ), value, intent( in ) :: lenRes
         real( kind = c_double ), dimension( * ), intent( inout ) :: res
      end subroutine frand123NormDouble_C
      function frand123NormSingle_scalar_C( state, mu, sigma ) result( res ) bind( C, name='frand123NormSingle_scalar' )
         use, intrinsic :: iso_c_binding, only: c_int64_t, c_float
         implicit none
         integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
         real( kind = c_float ), value, intent( in ) :: mu
         real( kind = c_float ), value, intent( in ) :: sigma
         real( kind = c_float ) :: res 
      end function frand123NormSingle_scalar_C
      subroutine frand123NormSingle_C( state, mu, sigma, lenRes, res ) bind( C, name='frand123NormSingle' )
         use, intrinsic :: iso_c_binding, only: c_int64_t, c_float
         implicit none
         integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
         real( kind = c_float ), value, intent( in ) :: mu
         real( kind = c_float ), value, intent( in ) :: sigma
         integer( kind = c_int64_t ), value, intent( in ) :: lenRes
         real( kind = c_float ), dimension( * ), intent( inout ) :: res
      end subroutine frand123NormSingle_C
      subroutine frand123Integer64_C( state, lenRes, res ) bind( C, name='frand123Integer64' )
         use, intrinsic :: iso_c_binding, only: c_int64_t
         implicit none
         integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
         integer( kind = c_int64_t ), value, intent( in ) :: lenRes
         integer( kind = c_int64_t ), dimension( * ), intent( inout ) :: res
      end subroutine frand123Integer64_C
      subroutine frand123Integer32_C( state, lenRes, res ) bind( C, name='frand123Integer32' )
         use, intrinsic :: iso_c_binding, only: c_int64_t, c_int32_t
         implicit none
         integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
         integer( kind = c_int64_t ), value, intent( in ) :: lenRes
         integer( kind = c_int32_t ), dimension( * ), intent( inout ) :: res
      end subroutine frand123Integer32_C
      subroutine frand123Init_C( state, rank, threadId, seed ) bind( C, name='frand123Init' )
         use, intrinsic :: iso_c_binding, only: c_int64_t, c_ptr
         implicit none
         integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
         integer( kind = c_int64_t ), value, intent( in ) :: rank
         integer( kind = c_int64_t ), value, intent( in ) :: threadID
         type( c_ptr ), value :: seed
      end subroutine frand123Init_C
   end interface

   ! interfaces for more generic use of functions
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

   interface frand123Init
      module procedure frand123Init_int64
      module procedure frand123Init_int32
   end interface frand123Init

   ! make only generic interfaces public
   public :: frand123_state_kind
   public :: frand123_state_size
   public :: frand123Double
   public :: frand123Single
   public :: frand123NormDouble
   public :: frand123NormSingle
   public :: frand123Integer32
   public :: frand123Integer64
   public :: frand123Init

   ! keep different implementations private
   private :: frand123Double_scalar
   private :: frand123Double_vector
   private :: frand123Single_scalar
   private :: frand123Single_vector
   private :: frand123NormDouble_scalar
   private :: frand123NormDouble_vector
   private :: frand123NormSingle_scalar
   private :: frand123NormSingle_vector
   private :: frand123Integer32_scalar
   private :: frand123Integer32_vector
   private :: frand123Integer64_scalar
   private :: frand123Integer64_vector
   private :: frand123Init_int64
   private :: frand123Init_int32

contains
   ! generate single random double precision number
   !
   ! Arguments: state: state of the random number generator
   !                   the counter in the state is incremented in every call
   !            res:   scalar for random double precision reals in (0,1)
   subroutine frand123Double_scalar( state, res )
      use, intrinsic :: iso_c_binding, only: c_int64_t, c_double
      implicit none
      integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
      real( kind = c_double ), intent( inout ) :: res

      ! use vector version
      real( kind = c_double ), dimension( 1 ) :: buffer
      call frand123Double( state, buffer )
      res = buffer( 1 )
   end subroutine frand123Double_scalar

   ! generate size(res) random double precision numbers
   !
   ! Arguments: state: state of the random number generator
   !                   the counter in the state is incremented in every call
   !            res:   array to be filled with random double precision reals in (0,1)
   subroutine frand123Double_vector( state, res )
      use, intrinsic :: iso_c_binding, only: c_int64_t, c_double
      implicit none
      integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
      real( kind = c_double ), dimension( : ), intent( inout ) :: res

      ! size of array
      integer( kind = c_int64_t ) :: lenRes
      lenRes = size( res )

      ! call C implementation
      call frand123Double_C( state, lenRes, res )
   end subroutine frand123Double_vector

   ! generate a single random single precision numbers
   !
   ! Arguments: state: state of the random number generator
   !                   the counter in the state is incremented in every call
   !            res:   scalar for random single precision reals in (0,1)
   subroutine frand123Single_scalar( state, res )
      use, intrinsic :: iso_c_binding, only: c_int64_t, c_float
      implicit none
      integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
      real( kind = c_float ), intent( inout ) :: res

      ! use vector version
      real( kind = c_float ), dimension( 1 ) :: buffer
      call frand123Single( state, buffer )
      res = buffer( 1 )
   end subroutine frand123Single_scalar

   ! generate size(res) random single precision numbers
   !
   ! Arguments: state: state of the random number generator
   !                   the counter in the state is incremented in every call
   !            res:   array to be filled with random single precision reals in (0,1)
   subroutine frand123Single_vector( state, res )
      use, intrinsic :: iso_c_binding, only: c_int64_t, c_float
      implicit none
      integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
      real( kind = c_float ), dimension( : ), intent( inout ) :: res

      ! size of array
      integer( kind = c_int64_t ) :: lenRes
      lenRes = size( res )

      ! call C implementation
      call frand123Single_C( state, lenRes, res )
   end subroutine frand123Single_vector

   ! generate single normally distributedrandom double precision numbers
   !
   ! Arguments: state: state of the random number generator
   !                   the counter in the state is incremented in every call
   !            mu:    expected value
   !            sigma: variance
   !            res:   scalar random double precision reals
   subroutine frand123NormDouble_scalar( state, mu, sigma, res )
      use, intrinsic :: iso_c_binding, only: c_int64_t, c_double
      implicit none
      integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
      real( kind = c_double ), value, intent( in ) :: mu
      real( kind = c_double ), value, intent( in ) :: sigma
      real( kind = c_double ), intent( inout ) :: res

      ! use vector version
      real( kind = c_double ), dimension( 1 ) :: buffer
      call frand123NormDouble( state, mu, sigma, buffer )
      res = buffer( 1 )
   end subroutine frand123NormDouble_scalar

   ! generate size(res) normally distributedrandom double precision numbers
   !
   ! Arguments: state: state of the random number generator
   !                   the counter in the state is incremented in every call
   !            mu:    expected value
   !            sigma: variance
   !            res:   array to be filled with random double precision real
   subroutine frand123NormDouble_vector( state, mu, sigma, res )
      use, intrinsic :: iso_c_binding, only: c_int64_t, c_double
      implicit none
      integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
      real( kind = c_double ), value, intent( in ) :: mu
      real( kind = c_double ), value, intent( in ) :: sigma
      real( kind = c_double ), dimension( : ), intent( inout ) :: res

      ! size of array
      integer( kind = c_int64_t ) :: lenRes
      lenRes = size( res )

      ! call C implementation
      call frand123NormDouble_C( state, mu, sigma, lenRes, res )
   end subroutine frand123NormDouble_vector

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
      use, intrinsic :: iso_c_binding, only: c_int64_t, c_float
      implicit none
      integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
      real( kind = c_float ), value, intent( in ) :: mu
      real( kind = c_float ), value, intent( in ) :: sigma
      real( kind = c_float ), intent( inout ) :: res

      ! use optimized C version with reduced number of calls to RNG
      res = frand123NormSingle_scalar_C( state, mu, sigma )
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
      use, intrinsic :: iso_c_binding, only: c_int64_t, c_float
      implicit none
      integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
      real( kind = c_float ), value, intent( in ) :: mu
      real( kind = c_float ), value, intent( in ) :: sigma
      real( kind = c_float ), dimension( : ), intent( inout ) :: res

      ! size of array
      integer( kind = c_int64_t ) :: lenRes
      lenRes = size( res )

      ! call C implementation
      call frand123NormSingle_C( state, mu, sigma, lenRes, res )
   end subroutine frand123NormSingle_vector

   ! generate single random 64 bit signed integers
   !
   ! Arguments: state: state of the random number generator
   !                   the counter in the state is incremented in every call
   !            res:   scalar random 64 bit signed integers
   subroutine frand123Integer64_scalar( state, res )
      use, intrinsic :: iso_c_binding, only: c_int64_t
      implicit none
      integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
      integer( kind = c_int64_t ), intent( inout ) :: res

      ! use vector version
      integer( kind = c_int64_t ), dimension( 1 ) :: buffer
      call frand123Integer64( state, buffer )
      res = buffer( 1 )
   end subroutine frand123Integer64_scalar

   ! generate size(res) random 64 bit signed integers
   !
   ! Arguments: state: state of the random number generator
   !                   the counter in the state is incremented in every call
   !            res:   array to be filled with random 64 bit signed integers
   subroutine frand123Integer64_vector( state, res )
      use, intrinsic :: iso_c_binding, only: c_int64_t
      implicit none
      integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
      integer( kind = c_int64_t ), dimension( : ), intent( inout ) :: res

      ! size of array
      integer( kind = c_int64_t ) :: lenRes
      lenRes = size( res )

      ! call C implementation
      call frand123Integer64_C( state, lenRes, res )
   end subroutine frand123Integer64_vector

   ! generate single random 32 bit signed integers
   !
   ! Arguments: state: state of the random number generator
   !                   the counter in the state is incremented
   !            res:   scalar for random 32 bit signed integer
   subroutine frand123Integer32_scalar( state, res )
      use, intrinsic :: iso_c_binding, only: c_int64_t, c_int32_t
      implicit none
      integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
      integer( kind = c_int32_t ), intent( inout ) :: res

      ! use vector version
      integer( kind = c_int32_t ), dimension( 1 ) :: buffer
      call frand123Integer32( state, buffer )
      res = buffer( 1 )
   end subroutine frand123Integer32_scalar

   ! generate size(res) random 32 bit signed integers
   !
   ! Arguments: state: state of the random number generator
   !                   the counter in the state is incremented in every call
   !            res:   array to be filled with random 32 bit signed integer
   subroutine frand123Integer32_vector( state, res )
      use, intrinsic :: iso_c_binding, only: c_int64_t, c_int32_t
      implicit none
      integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
      integer( kind = c_int32_t ), dimension( : ), intent( inout ) :: res

      ! size of array
      integer( kind = c_int64_t ) :: lenRes
      lenRes = size( res )

      ! call C implementation
      call frand123Integer32_C( state, lenRes, res )
   end subroutine frand123Integer32_vector

   ! initialization of the random number generators using 64 bit integers for rank and threadID
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
   subroutine frand123Init_int64( state, rank, threadId, seed )
      use, intrinsic :: iso_c_binding, only: c_int64_t, c_ptr, c_loc, c_null_ptr
      implicit none
      integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
      integer( kind = c_int64_t ), value, intent( in ) :: rank
      integer( kind = c_int64_t ), value, intent( in ) :: threadId
      integer( kind = c_int64_t ), dimension( 2 ), target, optional, intent( in ) :: seed

      ! need ptr to allow for seed and no seed
      type( c_ptr ) :: seed_ptr
      
      ! is optional seed given
      if( present( seed ) ) then
         seed_ptr = c_loc( seed )
      else
         seed_ptr = c_null_ptr
      endif

      ! call C implementation
      call frand123Init_C( state, rank, threadID, seed_ptr )
   end subroutine frand123Init_int64

   ! initialization of the random number generators using 32 bit integers for rank and threadID
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
   subroutine frand123Init_int32( state, rank, threadId, seed )
      use, intrinsic :: iso_c_binding, only: c_int32_t, c_int64_t, c_ptr, c_loc, c_null_ptr
      implicit none
      integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
      integer( kind = c_int32_t ), value, intent( in ) :: rank
      integer( kind = c_int32_t ), value, intent( in ) :: threadId
      integer( kind = c_int64_t ), dimension( 2 ), target, optional, intent( in ) :: seed

      ! is optional seed given
      if( present( seed ) ) then
         call frand123Init( state, int( rank, c_int64_t ), int( threadId, c_int64_t), seed )
      else
         call frand123Init( state, int( rank, c_int64_t ), int( threadId, c_int64_t ) )
      endif
   end subroutine frand123Init_int32
end module frand123
