function testRandDouble()
   f = fopen( 'tests/rand_double.out' );
   a = fread( f, Inf, 'double' );
   fclose( f );
   if( runstest( a, 'Method', 'exact' ) == 0 )
      disp('Test passed' )
   else
      disp('Test tests/testRandDouble.x failed' )
   end
end
