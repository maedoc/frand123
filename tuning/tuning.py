import os
import csv
compiler_names = [ "gcc", "intel" ]
ars_switch = [ "n", "y" ]
fma_switch = [ "n", "y" ]
polar_switch = [ "n", "y" ]

resultsDoubleScalar = dict()
resultsDouble = dict()
resultsSingleScalar = dict()
resultsSingle = dict()
resultsNormDoubleScalar = dict()
resultsNormDouble = dict()
resultsNormSingleScalar = dict()
resultsNormSingle = dict()

resultsDoubleScalarFortran = dict()
resultsDoubleFortran = dict()
resultsSingleScalarFortran = dict()
resultsSingleFortran = dict()
resultsNormDoubleScalarFortran = dict()
resultsNormDoubleFortran = dict()
resultsNormSingleScalarFortran = dict()
resultsNormSingleFortran = dict()

# start with uniformly distributed double-precision random numbers
for compiler in compiler_names:
   for ars in ars_switch:

      # build make call and compileCombination
      make_cmd = "make"
      compileCombination = ""
      if compiler == "gcc":
         make_cmd += " gcc=y"
         compileCombination += "_gcc"
      else:
         compileCombination += "_intel"
      if ars == "y":
         make_cmd += " ars=y"
         compileCombination += "_ars=y"
      make_cmd += " tuning/c_frand123Double.x tuning/f_frand123Double.x"

      # call make command
      os.system( "make clean" )
      os.system( make_cmd )

      # call the compiled version
      os.system( "./tuning/c_frand123Double.x " + compileCombination )
      os.system( "./tuning/f_frand123Double.x " + compileCombination )

      # read results for frand123Double_scalar
      with open( 'tuning/frand123Double_scalar' + compileCombination + '.dat', 'r' ) as f:
         reader = csv.reader( f, 'unix' )
         tmpDict = dict()
         for rows in reader:
            tmpDict.update( { rows[ 1 ].strip() : [ float( rows[ 2 ] ), float( rows[ 3 ] ), float( rows[ 4 ] ) ] } )

      # read C results

      # store results for frand123Double_scalar in result dictionary
      resultsDoubleScalar.update( { 'frand123Double_scalar' + compileCombination: tmpDict } )

      # read results for frand123Double
      with open( 'tuning/frand123Double' + compileCombination + '.dat', 'r' ) as f:
         reader = csv.reader( f, 'unix' )
         tmpDict = dict()
         for rows in reader:
            if not rows[ 1 ].strip() in tmpDict:
               tmpDict.update( { rows[ 1 ].strip() : dict() } )
            tmpDict[ rows[ 1 ].strip() ].update( { rows[ 2 ].strip() : [ float( rows[ 3 ] ), float( rows[ 4 ] ), float( rows[ 5 ] ) ] } )

      # store results for frand123Double in result dictionary
      resultsDouble.update( { 'frand123Double' + compileCombination: tmpDict } )

      # read Fortran results

      # read results for frand123Double_scalar for Fortran
      with open( 'tuning/frand123Double_scalar_f' + compileCombination + '.dat', 'r' ) as f:
         reader = csv.reader( f, 'unix' )
         tmpDict = dict()
         for rows in reader:
            tmpDict.update( { rows[ 1 ].strip() : [ float( rows[ 2 ] ), float( rows[ 3 ] ), float( rows[ 4 ] ) ] } )

      # store results for frand123Double_scalar in result dictionary
      resultsDoubleScalarFortran.update( { 'frand123Double_scalar' + compileCombination: tmpDict } )

      # read results for frand123Double for Fortran
      with open( 'tuning/frand123Double_f' + compileCombination + '.dat', 'r' ) as f:
         reader = csv.reader( f, 'unix' )
         tmpDict = dict()
         for rows in reader:
            if not rows[ 1 ].strip() in tmpDict:
               tmpDict.update( { rows[ 1 ].strip() : dict() } )
            tmpDict[ rows[ 1 ].strip() ].update( { rows[ 2 ].strip() : [ float( rows[ 3 ] ), float( rows[ 4 ] ), float( rows[ 5 ] ) ] } )

      # store results for frand123Double in result dictionary
      resultsDoubleFortran.update( { 'frand123Double' + compileCombination: tmpDict } )

# proceed with uniformly distributed single-precision random numbers
for compiler in compiler_names:
   for ars in ars_switch:
      for fma in fma_switch:
         # build make call and compileCombination
         make_cmd = "make"
         compileCombination = ""
         if compiler == "gcc":
            make_cmd += " gcc=y"
            compileCombination += "gcc"
         else:
            compileCombination += "intel"
         if ars == "y":
            make_cmd += " ars=y"
            compileCombination += "_ars=y"
         if fma == "y":
            make_cmd += " fma=y"
            compileCombination += "_fma=y"
         make_cmd += " tuning/c_frand123Single.x tuning/f_frand123Single.x"
         # call make command
         os.system( "make clean" )
         os.system( make_cmd )
         # call the compiled version
         os.system( "./tuning/c_frand123Single.x " + compileCombination )
         os.system( "./tuning/f_frand123Single.x " + compileCombination )

         # results for C

         # read results for frand123Single_scalar
         with open( 'tuning/frand123Single_scalar' + compileCombination + '.dat', 'r' ) as f:
            reader = csv.reader( f, 'unix' )
            tmpDict = dict()
            for rows in reader:
               tmpDict.update( { rows[ 1 ].strip() : [ float( rows[ 2 ] ), float( rows[ 3 ] ), float( rows[ 4 ] ) ] } )

         # store results for frand123Single_scalar in result dictionary
         resultsSingleScalar.update( { 'frand123Single_scalar' + compileCombination: tmpDict } )

         # read results for frand123Single
         with open( 'tuning/frand123Single' + compileCombination + '.dat', 'r' ) as f:
            reader = csv.reader( f, 'unix' )
            tmpDict = dict()
            for rows in reader:
               if not rows[ 1 ].strip() in tmpDict:
                  tmpDict.update( { rows[ 1 ].strip() : dict() } )
               tmpDict[ rows[ 1 ].strip() ].update( { rows[ 2 ].strip() : [ float( rows[ 3 ] ), float( rows[ 4 ] ), float( rows[ 5 ] ) ] } )

         # store results for frand123Single in result dictionary
         resultsSingle.update( { 'frand123Single' + compileCombination: tmpDict } )

         # results for Fortran

         # read results for frand123Single_scalar
         with open( 'tuning/frand123Single_scalar_f' + compileCombination + '.dat', 'r' ) as f:
            reader = csv.reader( f, 'unix' )
            tmpDict = dict()
            for rows in reader:
               tmpDict.update( { rows[ 1 ].strip() : [ float( rows[ 2 ] ), float( rows[ 3 ] ), float( rows[ 4 ] ) ] } )

         # store results for frand123Single_scalar in result dictionary
         resultsSingleScalarFortran.update( { 'frand123Single_scalar' + compileCombination: tmpDict } )

         # read results for frand123Single
         with open( 'tuning/frand123Single_f' + compileCombination + '.dat', 'r' ) as f:
            reader = csv.reader( f, 'unix' )
            tmpDict = dict()
            for rows in reader:
               if not rows[ 1 ].strip() in tmpDict:
                  tmpDict.update( { rows[ 1 ].strip() : dict() } )
               tmpDict[ rows[ 1 ].strip() ].update( { rows[ 2 ].strip() : [ float( rows[ 3 ] ), float( rows[ 4 ] ), float( rows[ 5 ] ) ] } )

         # store results for frand123Single in result dictionary
         resultsSingleFortran.update( { 'frand123Single' + compileCombination: tmpDict } )

# start with uniformly distributed double-precision random numbers
for compiler in compiler_names:
   for ars in ars_switch:
      for polar in polar_switch:

         # build make call and compileCombination
         make_cmd = "make"
         compileCombination = ""
         if compiler == "gcc":
            make_cmd += " gcc=y"
            compileCombination += "gcc"
         else:
            compileCombination += "intel"
         if ars == "y":
            make_cmd += " ars=y"
            compileCombination += "_ars=y"
         if polar == "y":
            make_cmd += " use_polar=y"
            compileCombination += "_use_polar=y"
         make_cmd += " tuning/c_frand123NormDouble.x tuning/f_frand123NormDouble"

         # call make command
         os.system( "make clean" )
         os.system( make_cmd )

         # call the compiled version
         os.system( "./tuning/c_frand123NormDouble.x " + compileCombination )
         os.system( "./tuning/f_frand123NormDouble.x " + compileCombination )

         # results for C

         # read results for frand123NormDouble_scalar
         with open( 'tuning/frand123NormDouble_scalar' + compileCombination + '.dat', 'r' ) as f:
            reader = csv.reader( f, 'unix' )
            tmpDict = dict()
            for rows in reader:
               tmpDict.update( { rows[ 1 ].strip() : [ float( rows[ 2 ] ), float( rows[ 3 ] ), float( rows[ 4 ] ) ] } )

         # store results for frand123NormDouble_scalar in result dictionary
         resultsNormDoubleScalar.update( { 'frand123NormDouble_scalar' + compileCombination: tmpDict } )

         # read results for frand123NormDouble
         with open( 'tuning/frand123NormDouble' + compileCombination + '.dat', 'r' ) as f:
            reader = csv.reader( f, 'unix' )
            tmpDict = dict()
            for rows in reader:
               if not rows[ 1 ].strip() in tmpDict:
                  tmpDict.update( { rows[ 1 ].strip() : dict() } )
               tmpDict[ rows[ 1 ].strip() ].update( { rows[ 2 ].strip() : [ float( rows[ 3 ] ), float( rows[ 4 ] ), float( rows[ 5 ] ) ] } )

         # store results for frand123NormDouble in result dictionary
         resultsNormDouble.update( { 'frand123NormDouble' + compileCombination: tmpDict } )

         # results for Fortran

         # read results for frand123NormDouble_scalar
         with open( 'tuning/frand123NormDouble_scalar_f' + compileCombination + '.dat', 'r' ) as f:
            reader = csv.reader( f, 'unix' )
            tmpDict = dict()
            for rows in reader:
               tmpDict.update( { rows[ 1 ].strip() : [ float( rows[ 2 ] ), float( rows[ 3 ] ), float( rows[ 4 ] ) ] } )

         # store results for frand123NormDouble_scalar in result dictionary
         resultsNormDoubleScalarFortran.update( { 'frand123NormDouble_scalar' + compileCombination: tmpDict } )

         # read results for frand123NormDouble
         with open( 'tuning/frand123NormDouble_f' + compileCombination + '.dat', 'r' ) as f:
            reader = csv.reader( f, 'unix' )
            tmpDict = dict()
            for rows in reader:
               if not rows[ 1 ].strip() in tmpDict:
                  tmpDict.update( { rows[ 1 ].strip() : dict() } )
               tmpDict[ rows[ 1 ].strip() ].update( { rows[ 2 ].strip() : [ float( rows[ 3 ] ), float( rows[ 4 ] ), float( rows[ 5 ] ) ] } )

         # store results for frand123NormDouble in result dictionary
         resultsNormDoubleFortran.update( { 'frand123NormDouble' + compileCombination: tmpDict } )

# proceed with uniformly distributed single-precision random numbers
for compiler in compiler_names:
   for ars in ars_switch:
      for fma in fma_switch:

         # build make call and compileCombination
         make_cmd = "make"
         compileCombination = ""
         if compiler == "gcc":
            make_cmd += " gcc=y"
            compileCombination += "gcc"
         else:
            compileCombination += "intel"
         if ars == "y":
            make_cmd += " ars=y"
            compileCombination += "_ars=y"
         if fma == "y":
            make_cmd += " fma=y"
            compileCombination += "_fma=y"
         make_cmd += " tuning/c_frand123NormSingle.x tuning/f_frand123Single.x"

         # call make command
         os.system( "make clean" )
         os.system( make_cmd )

         # call the compiled version
         os.system( "./tuning/c_frand123NormSingle.x " + compileCombination )
         os.system( "./tuning/f_frand123NormSingle.x " + compileCombination )

         # results for C

         # read results for frand123NormSingle_scalar
         with open( 'tuning/frand123NormSingle_scalar' + compileCombination + '.dat', 'r' ) as f:
            reader = csv.reader( f, 'unix' )
            tmpDict = dict()
            for rows in reader:
               tmpDict.update( { rows[ 1 ].strip() : [ float( rows[ 2 ] ), float( rows[ 3 ] ), float( rows[ 4 ] ) ] } )

         # store results for frand123NormSingle_scalar in result dictionary
         resultsNormSingleScalar.update( { 'frand123NormSingle_scalar' + compileCombination: tmpDict } )

         # read results for frand123NormSingle
         with open( 'tuning/frand123NormSingle' + compileCombination + '.dat', 'r' ) as f:
            reader = csv.reader( f, 'unix' )
            tmpDict = dict()
            for rows in reader:
               if not rows[ 1 ].strip() in tmpDict:
                  tmpDict.update( { rows[ 1 ].strip() : dict() } )
               tmpDict[ rows[ 1 ].strip() ].update( { rows[ 2 ].strip() : [ float( rows[ 3 ] ), float( rows[ 4 ] ), float( rows[ 5 ] ) ] } )

         # store results for frand123NormSingle in result dictionary
         resultsNormSingle.update( { 'frand123NormSingle' + compileCombination: tmpDict } )

         # results for Fortran

         # read results for frand123NormSingle_scalar
         with open( 'tuning/frand123NormSingle_scalar_f' + compileCombination + '.dat', 'r' ) as f:
            reader = csv.reader( f, 'unix' )
            tmpDict = dict()
            for rows in reader:
               tmpDict.update( { rows[ 1 ].strip() : [ float( rows[ 2 ] ), float( rows[ 3 ] ), float( rows[ 4 ] ) ] } )

         # store results for frand123NormSingle_scalar in result dictionary
         resultsNormSingleScalarFortran.update( { 'frand123NormSingle_scalar' + compileCombination: tmpDict } )

         # read results for frand123NormSingle
         with open( 'tuning/frand123NormSingle_f' + compileCombination + '.dat', 'r' ) as f:
            reader = csv.reader( f, 'unix' )
            tmpDict = dict()
            for rows in reader:
               if not rows[ 1 ].strip() in tmpDict:
                  tmpDict.update( { rows[ 1 ].strip() : dict() } )
               tmpDict[ rows[ 1 ].strip() ].update( { rows[ 2 ].strip() : [ float( rows[ 3 ] ), float( rows[ 4 ] ), float( rows[ 5 ] ) ] } )

         # store results for frand123NormSingle in result dictionary
         resultsNormSingleFortran.update( { 'frand123NormSingle' + compileCombination: tmpDict } )

######################
#####            #####
##### EVALUATION #####
#####            #####
######################

#######################
##### C Interface #####
#######################

## frand123Double_scalar
#print( 'Ideal combinations of compilers and parameters for C function frand123Double_scalar for different numbers of uniformly distributed double precision random numbers:\n' )
#for n in [ 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000 ]:
#   minMeanTime = 1000.
#   minMinTime = 1000.
#   minMaxTime = 1000.
#   labelMinMeanTime = ''
#   for res in resultsDoubleScalar:
#      resRed = ', '.join( res.split( '_' )[ 2: ] )
#      if resultsDoubleScalar[ res ][ str( n ) ][ 0 ] < minMeanTime:
#         minMeanTime = resultsDoubleScalar[ res ][ str( n ) ][ 0 ]
#         labelMinMeanTime = resRed
#
#   # print result
#   print( 'For n = %d:' % n )
#   print( '\tminimum mean Time:\t%e\tcompilation combination:\t%s' % ( minMeanTime, labelMinMeanTime ) )
#
## frand123Double
#print( '\n\n' )
#print( 'Ideal combinations of compilers and parameters for C function frand123Double for different numbers of uniformly distributed double precision random numbers generated in chunks of chunksize:\n' )
#for n in [ 10, 100, 1000, 10000, 100000, 1000000, 10000000 ]:
#   print( '\nn = %d' % n )
#   for cs in [ 1, 2, 10, 100, 1000, 10000, 100000, 1000000, 10000000 ]:
#      if cs <= n:
#         minMeanTime = 1000.
#         labelMinMeanTime = ''
#         for res in resultsDouble:
#            resRed = ', '.join( res.split( '_' )[ 1: ] )
#            if resultsDouble[ res ][ str( n ) ][ str( cs ) ][ 0 ] < minMeanTime:
#               minMeanTime = resultsDouble[ res ][ str( n ) ][ str( cs ) ][ 0 ]
#               labelMinMeanTime = resRed
#         print( '\ncs = %d' % cs )
#         print( '\t\tminimum mean time: %e\tcompilation combination:\t%s' % ( minMeanTime, labelMinMeanTime ) )
#
## frand123Single_scalar
#print( '\n\n' )
#print( 'Ideal combinations of compilers and parameters for C function frand123Single_scalar for different numbers of uniformly distributed single precision random numbers:\n' )
#for n in [ 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000 ]:
#   minMeanTime = 1000.
#   minMinTime = 1000.
#   minMaxTime = 1000.
#   labelMinMeanTime = ''
#   for res in resultsSingleScalar:
#      resRed = ', '.join( res.split( '_' )[ 2: ] )
#      if resultsSingleScalar[ res ][ str( n ) ][ 0 ] < minMeanTime:
#         minMeanTime = resultsSingleScalar[ res ][ str( n ) ][ 0 ]
#         labelMinMeanTime = resRed
#
#   # print result
#   print( 'For n = %d:' % n )
#   print( '\tminimum mean Time:\t%e\tcompilation combination:\t%s' % ( minMeanTime, labelMinMeanTime ) )
#
## frand123Single
#print( '\n\n' )
#print( resultsSingle )
#print( 'Ideal combinations of compilers and parameters for C function frand123Single for different numbers of uniformly distributed single precision random numbers generated in chunks of chunksize:\n' )
#for n in [ 10, 100, 1000, 10000, 100000, 1000000, 10000000 ]:
#   print( '\nn = %d' % n )
#   for cs in [ 1, 2, 10, 100, 1000, 10000, 100000, 1000000, 10000000 ]:
#      if cs <= n:
#         minMeanTime = 1000.
#         labelMinMeanTime = ''
#         for res in resultsSingle:
#            resRed = ', '.join( res.split( '_' )[ 1: ] )
#            if resultsSingle[ res ][ str( n ) ][ str( cs ) ][ 0 ] < minMeanTime:
#               minMeanTime = resultsSingle[ res ][ str( n ) ][ str( cs ) ][ 0 ]
#               labelMinMeanTime = resRed
#         print( '\ncs = %d' % cs )
#         print( '\t\tminimum mean time: %e\tcompilation combination:\t%s' % ( minMeanTime, labelMinMeanTime ) )
#
## frand123NormDouble_scalar
#print( 'Ideal combinations of compilers and parameters for C function frand123NormDouble_scalar for different numbers of normally distributed double precision random numbers:\n' )
#for n in [ 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000 ]:
#   minMeanTime = 1000.
#   minMinTime = 1000.
#   minMaxTime = 1000.
#   labelMinMeanTime = ''
#   for res in resultsNormDoubleScalar:
#      resRed = ', '.join( res.split( '_' )[ 2: ] )
#      if resultsNormDoubleScalar[ res ][ str( n ) ][ 0 ] < minMeanTime:
#         minMeanTime = resultsNormDoubleScalar[ res ][ str( n ) ][ 0 ]
#         labelMinMeanTime = resRed
#
#   # print result
#   print( 'For n = %d:' % n )
#   print( '\tminimum mean Time:\t%e\tcompilation combination:\t%s' % ( minMeanTime, labelMinMeanTime ) )
#
## frand123NormDouble
#print( '\n\n' )
#print( 'Ideal combinations of compilers and parameters for C function frand123NormDouble for different numbers of normally distributed double precision random numbers generated in chunks of chunksize:\n' )
#for n in [ 10, 100, 1000, 10000, 100000, 1000000, 10000000 ]:
#   print( '\nn = %d' % n )
#   for cs in [ 1, 2, 10, 100, 1000, 10000, 100000, 1000000, 10000000 ]:
#      if cs <= n:
#         minMeanTime = 1000.
#         labelMinMeanTime = ''
#         for res in resultsNormDouble:
#            resRed = ', '.join( res.split( '_' )[ 1: ] )
#            if resultsNormDouble[ res ][ str( n ) ][ str( cs ) ][ 0 ] < minMeanTime:
#               minMeanTime = resultsNormDouble[ res ][ str( n ) ][ str( cs ) ][ 0 ]
#               labelMinMeanTime = resRed
#         print( '\ncs = %d' % cs )
#         print( '\t\tminimum mean time: %e\tcompilation combination:\t%s' % ( minMeanTime, labelMinMeanTime ) )
#
## frand123NormSingle_scalar
#print( '\n\n' )
#print( 'Ideal combinations of compilers and parameters for C function frand123NormSingle_scalar for different numbers of normally distributed single precision random numbers:\n' )
#for n in [ 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000 ]:
#   minMeanTime = 1000.
#   minMinTime = 1000.
#   minMaxTime = 1000.
#   labelMinMeanTime = ''
#   for res in resultsNormSingleScalar:
#      resRed = ', '.join( res.split( '_' )[ 2: ] )
#      if resultsNormSingleScalar[ res ][ str( n ) ][ 0 ] < minMeanTime:
#         minMeanTime = resultsNormSingleScalar[ res ][ str( n ) ][ 0 ]
#         labelMinMeanTime = resRed
#
#   # print result
#   print( 'For n = %d:' % n )
#   print( '\tminimum mean Time:\t%e\tcompilation combination:\t%s' % ( minMeanTime, labelMinMeanTime ) )
#
## frand123NormSingle
#print( '\n\n' )
#print( resultsSingle )
#print( 'Ideal combinations of compilers and parameters for C function frand123NormSingle for different numbers of normally distributed single precision random numbers generated in chunks of chunksize:\n' )
#for n in [ 10, 100, 1000, 10000, 100000, 1000000, 10000000 ]:
#   print( '\nn = %d' % n )
#   for cs in [ 1, 2, 10, 100, 1000, 10000, 100000, 1000000, 10000000 ]:
#      if cs <= n:
#         minMeanTime = 1000.
#         labelMinMeanTime = ''
#         for res in resultsNormSingle:
#            resRed = ', '.join( res.split( '_' )[ 1: ] )
#            if resultsNormSingle[ res ][ str( n ) ][ str( cs ) ][ 0 ] < minMeanTime:
#               minMeanTime = resultsNormSingle[ res ][ str( n ) ][ str( cs ) ][ 0 ]
#               labelMinMeanTime = resRed
#         print( '\ncs = %d' % cs )
#         print( '\t\tminimum mean time: %e\tcompilation combination:\t%s' % ( minMeanTime, labelMinMeanTime ) )
#
##############################
###### Fortran Interface #####
##############################
