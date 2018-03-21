function testRandDouble()
   pkg load statistics
   f = fopen( 'tests/rand_double.out' );
   a = fread( f, Inf, 'double' );
   fclose( f );
   if( runstest( a, 'Method', 'exact' ) == 0 )
      disp('Test passed' )
      exit( 0 )
   else
      disp('Test tests/testRandDouble.x failed' )
      exit( 1 )
   end
end
