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

   interface frand123Init
      module procedure frand123Init_int64
      module procedure frand123Init_int32
   end interface frand123Init

contains
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

   subroutine frand123Init_int32( state, rank, threadId, seed )
      use, intrinsic :: iso_c_binding, only: c_int64_t, c_ptr, c_loc, c_null_ptr
      implicit none
      integer( kind = c_int64_t ), dimension( 4 ), intent( inout ) :: state
      integer, value, intent( in ) :: rank
      integer, value, intent( in ) :: threadId
      integer( kind = c_int64_t ), dimension( 2 ), target, optional, intent( in ) :: seed

      ! is optional seed given
      if( present( seed ) ) then
         call frand123Init( state, int( rank, c_int64_t ), int( threadId, c_int64_t), seed )
      else
         call frand123Init( state, int( rank, c_int64_t ), int( threadId, c_int64_t ) )
      endif
   end subroutine frand123Init_int32
end module frand123
