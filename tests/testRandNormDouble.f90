program testRandNormDouble
   use frand123
   use, intrinsic :: iso_c_binding, only: c_double, c_int64_t
   implicit none

   integer, parameter :: numRndNbrs = 1000 * 1000 * 100
   real( kind = c_double ), parameter :: mu = 0.d0
   real( kind = c_double ), parameter :: sigma = 1.d0

   type( frand123State_t ) :: state
   integer( kind = c_int64_t ), dimension( 2 ) :: seed
   real( kind = c_double ), dimension(:), allocatable :: res

   integer :: out_unit
   real :: startTime, stopTime

   seed = (/ 0, 0 /)
   call frand123Init( state, 0, 0, seed )
   
   allocate( res( numRndNbrs ) )

   call cpu_time(startTime)
   call frand123NormDouble( state, mu, sigma, res )
   call cpu_time(stopTime)

   write(*,'("time elapsed: ", e13.6)') stopTime - startTime

   open( newunit = out_unit, file = './tests/rand_norm_double.out', access = 'stream' )
   write( out_unit ) res
   close( out_unit )
end program
