program testRand
   use frand123
   use omp_lib
   implicit none

   integer, parameter :: numRndNbrs = 1000 * 1000 * 1000

   integer( kind = state_kind ), dimension( state_size ) :: state
   real( kind = res_kind ), dimension(:), allocatable :: res
   integer( kind = state_kind ), dimension( 2 ) :: seed

   double precision :: startTime, stopTime

   call seed_rand( state, 0, 0, seed )
   
   allocate( res( numRndNbrs ) )

   startTime = omp_get_wtime()
   call frand123Dble( state, res )
   stopTime = omp_get_wtime()

   write(*,'("time elapsed: ", D13.6)') stopTime - startTime

   !write(*,*) res

   open( unit = 124, file = 'rand.out', access = 'stream', status = 'replace' )
   write( 124 ) res
   close( 124 )
end program
