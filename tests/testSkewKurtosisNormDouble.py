import numpy as np
import scipy.stats as stats
import argparse

# parse arguments
parser = argparse.ArgumentParser(description='Carry out statistical tests for skew and kurtosis' )
parser.add_argument( '--hastings', action = 'store_true', help = 'use values for inverse transformation sampling by Hasting. Otherwise, Box-Muller transformation is assumed.' )
parser.add_argument( '--mu', help = 'expectation. default: 0', default = 0, type = float )
parser.add_argument( '--sigma', help = 'variance. default: 1', default = 1, type = float )
args = parser.parse_args()

# read data from file
rnd_var = np.fromfile( 'tests/rand_norm_double.out', 'double' )

# choose appropriate upper limits
if( args.hastings ):
   pLimSkew = 0.8
   pLimKurtosis = 0.02
else:
   pLimSkew = 0.8
   pLimKurtosis = 0.1

# run skewtest
res = stats.skewtest( rnd_var )

if( res.pvalue < pLimSkew ):
   if( args.hastings ):
      print( 'Skew test for Hastings with mu = %e and sigma = %e failed.\np-value: %e' % ( args.mu, args.sigma, res.pvalue ) )
      sys.exit( 1 )
   else:
      print( 'Skew test for Box-Muller with mu = %e and sigma = %e failed.\np-value: %e' % ( args.mu, args.sigma, res.pvalue ) )
      sys.exit( 1 )

# run kurtosistest
res = stats.kurtosistest( rnd_var )

if( res.pvalue < pLimKurtosis ):
   if( args.hastings ):
      print( 'Kurtosis test for Hastings with mu = %e and sigma = %e failed.\np-value: %e' % ( args.mu, args.sigma, res.pvalue ) )
      sys.exit( 1 )
   else:
      print( 'Kurtosis test for Box-Muller with mu = %e and sigma = %e failed.\np-value: %e' % ( args.mu, args.sigma, res.pvalue ) )
      sys.exit( 1 )

# successful
if( args.hastings ):
   print( 'Both tests for Hastings with mu = %e and sigma = %e were successful.' % ( args.mu, args.sigma ) )
else:
   print( 'Both tests for Box-Muller with mu = %e and sigma = %e were successful.' % ( args.mu, args.sigma ) )
