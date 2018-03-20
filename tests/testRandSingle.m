function testRandSingle()
   f = fopen( './tests/rand_single.out' );
   a = fread( f, Inf, 'single' );
   fclose( f );
   if( runstest( a, 'Method', 'exact' ) == 0 )
      disp('Test passed' )
   else
      disp('Test tests/testRandSingle.x failed' )
   end
end
