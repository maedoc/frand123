program testRandSingle
   use frand123
   implicit none
   integer, parameter :: numRndNbrs = 1000 * 1000 * 1000

   integer( kind = state_kind ), dimension( state_size ) :: state
   real( kind = res_kind_single ), dimension(:), allocatable :: res

   integer :: out_unit
   real :: startTime, stopTime

   call frand123Init( state, 0, 0 )
   
   allocate( res( numRndNbrs ) )

   call cpu_time(startTime)
   call frand123Single( state, res )
   call cpu_time(stopTime)

   write(*,'("time elapsed: ", e13.6)') stopTime - startTime

   open( newunit = out_unit, file = './tests/rand_single.out', access = 'stream', status = 'old' )
   write( out_unit ) res
   close( out_unit )
end program
