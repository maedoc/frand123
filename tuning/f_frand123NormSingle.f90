program f_frand123NormSingle
   use, intrinsic :: iso_c_binding, only: c_int64_t, c_float
   use :: frand123, only: frand123_state_kind, frand123_state_size, frand123Init
   implicit none

   ! the state
   integer( kind = frand123_state_kind ), dimension( frand123_state_size ) :: state

   ! command line arguments
   integer :: maxLength
   character( len = 100 ) :: compileCombination

   ! initialize the state
   call frand123Init( state, 0, 0 )

   ! get compileCombination
   if( command_argument_count() .lt. 1 ) then
      write(*,*) 'compiler name required as command line argument'
   endif
   maxLength = 100
   call get_command_argument( 1, compileCombination, maxLength )

   write(*,*) 'frand123 tuning script for the Fortran interface'

   ! time frand123NormSingle for scalar results
   call time_frand123NormSingle_scalar_runner( state, compileCombination )

   ! time frand123NormSingle for chunked results
   call time_frand123NormSingle_runner( state, compileCombination )

contains
   subroutine time_frand123NormSingle_scalar( state, num, timeElapsed, resultSum )
      use, intrinsic :: iso_c_binding, only: c_int64_t, c_float, c_double
      use :: frand123, only: frand123_state_kind, frand123_state_size, frand123NormSingle
      use :: omp_lib
      implicit none
      integer( kind = frand123_state_kind ), dimension( frand123_state_size ), intent( inout ) :: state
      integer( kind = c_int64_t ), intent( in ) :: num
      real( kind = c_double ), intent( out ) :: timeElapsed
      real( kind = c_float ), intent( out ) :: resultSum

      ! local variables
      integer( kind = c_int64_t ) :: i
      real( kind = c_double ) :: startTime, endTime
      real( kind = c_float ) :: dummySum
      real( kind = c_float ) :: randomNumber

      dummySum = 0.
      startTime = omp_get_wtime()
      do i = 0, num
         call frand123NormSingle( state, 0.23e0, 0.25e0, randomNumber )
         dummySum = dummySum + randomNumber
      enddo
      endTime = omp_get_wtime()
      timeElapsed = endTime - startTime
      resultSum = dummySum
   end subroutine time_frand123NormSingle_scalar

   subroutine time_frand123NormSingle_scalar_runner( state, compileCombination )
      use, intrinsic :: iso_c_binding, only: c_int64_t, c_float, c_double
      implicit none
      integer( kind = frand123_state_kind ), dimension( frand123_state_size ), intent( inout ) :: state
      character( len = 100 ), intent( in ) :: compileCombination

      ! local parameters
      integer, parameter :: it = c_int64_t
      integer( kind = it ), dimension( 8 ), parameter :: numbers = (/ 10_it, &
                                                                    & 100_it, &
                                                                    & 1000_it, &
                                                                    & 10000_it, &
                                                                    & 100000_it, &
                                                                    & 1000000_it, &
                                                                    & 10000000_it, &
                                                                    & 100000000_it /)

      ! local variables
      character( len = 200 ) :: filename
      integer :: fileHandler, stat, i, k
      integer( kind = it ) :: localNum
      real( kind = c_double ) :: meanTime, minTime, maxTime, timeElapsed
      real( kind = c_float ) :: resultSum

      ! create filename
      write( filename, '( "tuning/frand123NormSingle_scalar_f", A, ".dat" )' ) trim( compileCombination )

      ! open file
      open( newunit = fileHandler, file = filename, action = 'write', iostat = stat )
      if( stat .ne. 0 ) then
         write(*,*) 'error opening file in time_frand123NormSingle_scalar_runner Fortran version'
         stop
      endif

      do i = 1, 8
         localNum = numbers( i )
         meanTime = 0._c_double
         minTime = 100._c_double
         maxTime = 0._c_double
         do k = 0, 10
            call time_frand123NormSingle_scalar( state, localNum, timeElapsed, resultSum )
            meanTime = meanTime + timeElapsed
            minTime = min( minTime, timeElapsed )
            maxTime = max( maxTime, timeElapsed )
         enddo
         meanTime = meanTime / 10._c_double
         write( fileHandler, '( "frand123NormSingle_scalar,", I12, ",", E13.6, ",", E13.6, ",", E13.6 )' ) &
                & localNum, meanTime, minTime, maxTime
         write( *, '( "frand123NormSingle_scalar,", I12, ",", E13.6, ",", E13.6, ",", E13.6 )' ) & 
                & localNum, meanTime, minTime, maxTime
      enddo
      
      ! close file again
      close( fileHandler )
   end subroutine time_frand123NormSingle_scalar_runner

   subroutine time_frand123NormSingle( state, num, chunksize, timeElapsed, resultSum )
      use, intrinsic :: iso_c_binding, only: c_int64_t, c_float, c_double
      use :: frand123, only: frand123_state_kind, frand123_state_size, frand123NormSingle
      use :: omp_lib
      implicit none
      integer( kind = frand123_state_kind ), dimension( frand123_state_size ), intent( inout ) :: state
      integer( kind = c_int64_t ), intent( in ) :: num
      integer( kind = c_int64_t ), intent( in ) :: chunksize
      real( kind = c_double ), intent( out ) :: timeElapsed
      real( kind = c_float ), intent( out ) :: resultSum

      ! local variables
      integer( kind = c_int64_t ) :: i
      real( kind = c_double ) :: startTime, endTime
      real( kind = c_float ) :: dummySum
      real( kind = c_float ), dimension( chunksize ) :: randomNumber

      dummySum = 0.
      startTime = omp_get_wtime()
      do i = 0, num, chunksize
         call frand123NormSingle( state, 1.2e0, 1.456e0, randomNumber )
      enddo
      endTime = omp_get_wtime()
      timeElapsed = endTime - startTime
      resultSum = sum( randomNumber )
   end subroutine time_frand123NormSingle

   subroutine time_frand123NormSingle_runner( state, compileCombination )
      use, intrinsic :: iso_c_binding, only: c_int64_t, c_float, c_double
      implicit none
      integer( kind = frand123_state_kind ), dimension( frand123_state_size ), intent( inout ) :: state
      character( len = 100 ), intent( in ) :: compileCombination

      ! local parameters
      integer, parameter :: it = c_int64_t
      integer( kind = it ), dimension( 7 ), parameter :: numbers = (/ 10_it, &
                                                                    & 100_it, &
                                                                    & 1000_it, &
                                                                    & 10000_it, &
                                                                    & 100000_it, &
                                                                    & 1000000_it, &
                                                                    & 10000000_it /)
      integer( kind = it ), dimension( 9 ), parameter :: chunksizes = (/ 1_it, &
                                                                       & 2_it, &
                                                                       & 10_it, &
                                                                       & 100_it, &
                                                                       & 1000_it, &
                                                                       & 10000_it, &
                                                                       & 100000_it, &
                                                                       & 1000000_it, &
                                                                       & 10000000_it /)

      ! local variables
      character( len = 200 ) :: filename
      integer :: fileHandler, stat, i, j, k
      integer( kind = it ) :: localNum, localChunksize
      real( kind = c_double ) :: meanTime, minTime, maxTime, timeElapsed
      real( kind = c_float ) :: resultSum

      ! create filename
      write( filename, '( "tuning/frand123NormSingle_f", A, ".dat" )' ) trim( compileCombination )

      ! open file
      open( newunit = fileHandler, file = filename, action = 'write', iostat = stat )
      if( stat .ne. 0 ) then
         write(*,*) 'error opening file in time_frand123NormSingle_runner Fortran version'
         stop
      endif

      do i = 1, 8
         do j = 1, 9
            localNum = numbers( i )
            localChunksize = chunksizes( j )
            if( localChunksize .le. localNum ) then
               meanTime = 0._c_double
               minTime = 100._c_double
               maxTime = 0._c_double
               do k = 0, 10
                  call time_frand123NormSingle( state, localNum, localChunksize, timeElapsed, resultSum )
                  meanTime = meanTime + timeElapsed
                  minTime = min( minTime, timeElapsed )
                  maxTime = max( maxTime, timeElapsed )
               enddo
               meanTime = meanTime / 10._c_double
               write( fileHandler, '( "frand123NormSingle,", I12, ",", I12, ",", E13.6, ",", E13.6, ",", E13.6 )' ) &
                      & localNum, localChunksize, meanTime, minTime, maxTime
               write( *, '( "frand123NormSingle,", I12, ",", I12, ",", E13.6, ",", E13.6, ",", E13.6 )' ) &
                      & localNum, localChunksize, meanTime, minTime, maxTime
            endif
         enddo
      enddo
      
      ! close file again
      close( fileHandler )
   end subroutine time_frand123NormSingle_runner

end program f_frand123NormSingle
