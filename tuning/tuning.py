import os
import csv
import json
import pprint

pp = pprint.PrettyPrinter( depth = 6 )

#compiler_names = [ "gcc", "intel" ]
#ars_switch = [ "n", "y" ]
#fma_switch = [ "n", "y" ]
#polar_switch = [ "n", "y" ]
#
#resultsDoubleScalar = dict()
#resultsDouble = dict()
#resultsSingleScalar = dict()
#resultsSingle = dict()
#resultsNormDoubleScalar = dict()
#resultsNormDouble = dict()
#resultsNormSingleScalar = dict()
#resultsNormSingle = dict()
#
#resultsDoubleScalarFortran = dict()
#resultsDoubleFortran = dict()
#resultsSingleScalarFortran = dict()
#resultsSingleFortran = dict()
#resultsNormDoubleScalarFortran = dict()
#resultsNormDoubleFortran = dict()
#resultsNormSingleScalarFortran = dict()
#resultsNormSingleFortran = dict()
#
#os.system( 'mkdir -p tuning/timings' )
#
## start with uniformly distributed double-precision random numbers
#for compiler in compiler_names:
#   for ars in ars_switch:
#
#      # build make call and compileCombination
#      make_cmd = "make"
#      compileCombination = ""
#      if compiler == "gcc":
#         make_cmd += " gcc=y"
#         compileCombination += "_gcc"
#      else:
#         compileCombination += "_intel"
#      if ars == "y":
#         make_cmd += " ars=y"
#         compileCombination += "_ars=y"
#      make_cmd += " tuning/c_frand123Double.x tuning/f_frand123Double.x"
#
#      # call make command
#      os.system( "make clean" )
#      os.system( make_cmd )
#
#      # call the compiled version
#      os.system( "./tuning/c_frand123Double.x " + compileCombination )
#      os.system( "./tuning/f_frand123Double.x " + compileCombination )
#
#      # read C results
#
#      # read results for frand123Double_scalar
#      with open( 'tuning/timings/frand123Double_scalar' + compileCombination + '.dat', 'r' ) as f:
#         reader = csv.reader( f, 'unix' )
#         tmpDict = dict()
#         for rows in reader:
#            tmpDict.update( { rows[ 1 ].strip() : [ float( rows[ 2 ] ), float( rows[ 3 ] ), float( rows[ 4 ] ) ] } )
#
#
#      # store results for frand123Double_scalar in result dictionary
#      resultsDoubleScalar.update( { 'frand123Double_scalar' + compileCombination: tmpDict } )
#
#      # read results for frand123Double
#      with open( 'tuning/timings/frand123Double' + compileCombination + '.dat', 'r' ) as f:
#         reader = csv.reader( f, 'unix' )
#         tmpDict = dict()
#         for rows in reader:
#            if not rows[ 1 ].strip() in tmpDict:
#               tmpDict.update( { rows[ 1 ].strip() : dict() } )
#            tmpDict[ rows[ 1 ].strip() ].update( { rows[ 2 ].strip() : [ float( rows[ 3 ] ), float( rows[ 4 ] ), float( rows[ 5 ] ) ] } )
#
#      # store results for frand123Double in result dictionary
#      resultsDouble.update( { 'frand123Double' + compileCombination: tmpDict } )
#
#      # read Fortran results
#
#      # read results for frand123Double_scalar for Fortran
#      with open( 'tuning/timings/frand123Double_scalar_f' + compileCombination + '.dat', 'r' ) as f:
#         reader = csv.reader( f, 'unix' )
#         tmpDict = dict()
#         for rows in reader:
#            tmpDict.update( { rows[ 1 ].strip() : [ float( rows[ 2 ] ), float( rows[ 3 ] ), float( rows[ 4 ] ) ] } )
#
#      # store results for frand123Double_scalar in result dictionary
#      resultsDoubleScalarFortran.update( { 'frand123Double_scalar' + compileCombination: tmpDict } )
#
#      # read results for frand123Double for Fortran
#      with open( 'tuning/timings/frand123Double_f' + compileCombination + '.dat', 'r' ) as f:
#         reader = csv.reader( f, 'unix' )
#         tmpDict = dict()
#         for rows in reader:
#            if not rows[ 1 ].strip() in tmpDict:
#               tmpDict.update( { rows[ 1 ].strip() : dict() } )
#            tmpDict[ rows[ 1 ].strip() ].update( { rows[ 2 ].strip() : [ float( rows[ 3 ] ), float( rows[ 4 ] ), float( rows[ 5 ] ) ] } )
#
#      # store results for frand123Double in result dictionary
#      resultsDoubleFortran.update( { 'frand123Double' + compileCombination: tmpDict } )
#
## proceed with uniformly distributed single-precision random numbers
#for compiler in compiler_names:
#   for ars in ars_switch:
#      for fma in fma_switch:
#         # build make call and compileCombination
#         make_cmd = "make"
#         compileCombination = ""
#         if compiler == "gcc":
#            make_cmd += " gcc=y"
#            compileCombination += "_gcc"
#         else:
#            compileCombination += "_intel"
#         if ars == "y":
#            make_cmd += " ars=y"
#            compileCombination += "_ars=y"
#         if fma == "y":
#            make_cmd += " fma=y"
#            compileCombination += "_fma=y"
#         make_cmd += " tuning/c_frand123Single.x tuning/f_frand123Single.x"
#         # call make command
#         os.system( "make clean" )
#         os.system( make_cmd )
#         # call the compiled version
#         os.system( "./tuning/c_frand123Single.x " + compileCombination )
#         os.system( "./tuning/f_frand123Single.x " + compileCombination )
#
#         # results for C
#
#         # read results for frand123Single_scalar
#         with open( 'tuning/timings/frand123Single_scalar' + compileCombination + '.dat', 'r' ) as f:
#            reader = csv.reader( f, 'unix' )
#            tmpDict = dict()
#            for rows in reader:
#               tmpDict.update( { rows[ 1 ].strip() : [ float( rows[ 2 ] ), float( rows[ 3 ] ), float( rows[ 4 ] ) ] } )
#
#         # store results for frand123Single_scalar in result dictionary
#         resultsSingleScalar.update( { 'frand123Single_scalar' + compileCombination: tmpDict } )
#
#         # read results for frand123Single
#         with open( 'tuning/timings/frand123Single' + compileCombination + '.dat', 'r' ) as f:
#            reader = csv.reader( f, 'unix' )
#            tmpDict = dict()
#            for rows in reader:
#               if not rows[ 1 ].strip() in tmpDict:
#                  tmpDict.update( { rows[ 1 ].strip() : dict() } )
#               tmpDict[ rows[ 1 ].strip() ].update( { rows[ 2 ].strip() : [ float( rows[ 3 ] ), float( rows[ 4 ] ), float( rows[ 5 ] ) ] } )
#
#         # store results for frand123Single in result dictionary
#         resultsSingle.update( { 'frand123Single' + compileCombination: tmpDict } )
#
#         # results for Fortran
#
#         # read results for frand123Single_scalar
#         with open( 'tuning/timings/frand123Single_scalar_f' + compileCombination + '.dat', 'r' ) as f:
#            reader = csv.reader( f, 'unix' )
#            tmpDict = dict()
#            for rows in reader:
#               tmpDict.update( { rows[ 1 ].strip() : [ float( rows[ 2 ] ), float( rows[ 3 ] ), float( rows[ 4 ] ) ] } )
#
#         # store results for frand123Single_scalar in result dictionary
#         resultsSingleScalarFortran.update( { 'frand123Single_scalar' + compileCombination: tmpDict } )
#
#         # read results for frand123Single
#         with open( 'tuning/timings/frand123Single_f' + compileCombination + '.dat', 'r' ) as f:
#            reader = csv.reader( f, 'unix' )
#            tmpDict = dict()
#            for rows in reader:
#               if not rows[ 1 ].strip() in tmpDict:
#                  tmpDict.update( { rows[ 1 ].strip() : dict() } )
#               tmpDict[ rows[ 1 ].strip() ].update( { rows[ 2 ].strip() : [ float( rows[ 3 ] ), float( rows[ 4 ] ), float( rows[ 5 ] ) ] } )
#
#         # store results for frand123Single in result dictionary
#         resultsSingleFortran.update( { 'frand123Single' + compileCombination: tmpDict } )
#
## start with uniformly distributed double-precision random numbers
#for compiler in compiler_names:
#   for ars in ars_switch:
#      for polar in polar_switch:
#
#         # build make call and compileCombination
#         make_cmd = "make"
#         compileCombination = ""
#         if compiler == "gcc":
#            make_cmd += " gcc=y"
#            compileCombination += "_gcc"
#         else:
#            compileCombination += "_intel"
#         if ars == "y":
#            make_cmd += " ars=y"
#            compileCombination += "_ars=y"
#         if polar == "y":
#            make_cmd += " use_polar=y"
#            compileCombination += "_use_polar=y"
#         make_cmd += " tuning/c_frand123NormDouble.x tuning/f_frand123NormDouble.x"
#
#         # call make command
#         os.system( "make clean" )
#         os.system( make_cmd )
#
#         # call the compiled version
#         os.system( "./tuning/c_frand123NormDouble.x " + compileCombination )
#         os.system( "./tuning/f_frand123NormDouble.x " + compileCombination )
#
#         # results for C
#
#         # read results for frand123NormDouble_scalar
#         with open( 'tuning/timings/frand123NormDouble_scalar' + compileCombination + '.dat', 'r' ) as f:
#            reader = csv.reader( f, 'unix' )
#            tmpDict = dict()
#            for rows in reader:
#               tmpDict.update( { rows[ 1 ].strip() : [ float( rows[ 2 ] ), float( rows[ 3 ] ), float( rows[ 4 ] ) ] } )
#
#         # store results for frand123NormDouble_scalar in result dictionary
#         resultsNormDoubleScalar.update( { 'frand123NormDouble_scalar' + compileCombination: tmpDict } )
#
#         # read results for frand123NormDouble
#         with open( 'tuning/timings/frand123NormDouble' + compileCombination + '.dat', 'r' ) as f:
#            reader = csv.reader( f, 'unix' )
#            tmpDict = dict()
#            for rows in reader:
#               if not rows[ 1 ].strip() in tmpDict:
#                  tmpDict.update( { rows[ 1 ].strip() : dict() } )
#               tmpDict[ rows[ 1 ].strip() ].update( { rows[ 2 ].strip() : [ float( rows[ 3 ] ), float( rows[ 4 ] ), float( rows[ 5 ] ) ] } )
#
#         # store results for frand123NormDouble in result dictionary
#         resultsNormDouble.update( { 'frand123NormDouble' + compileCombination: tmpDict } )
#
#         # results for Fortran
#
#         # read results for frand123NormDouble_scalar
#         with open( 'tuning/timings/frand123NormDouble_scalar_f' + compileCombination + '.dat', 'r' ) as f:
#            reader = csv.reader( f, 'unix' )
#            tmpDict = dict()
#            for rows in reader:
#               tmpDict.update( { rows[ 1 ].strip() : [ float( rows[ 2 ] ), float( rows[ 3 ] ), float( rows[ 4 ] ) ] } )
#
#         # store results for frand123NormDouble_scalar in result dictionary
#         resultsNormDoubleScalarFortran.update( { 'frand123NormDouble_scalar' + compileCombination: tmpDict } )
#
#         # read results for frand123NormDouble
#         with open( 'tuning/timings/frand123NormDouble_f' + compileCombination + '.dat', 'r' ) as f:
#            reader = csv.reader( f, 'unix' )
#            tmpDict = dict()
#            for rows in reader:
#               if not rows[ 1 ].strip() in tmpDict:
#                  tmpDict.update( { rows[ 1 ].strip() : dict() } )
#               tmpDict[ rows[ 1 ].strip() ].update( { rows[ 2 ].strip() : [ float( rows[ 3 ] ), float( rows[ 4 ] ), float( rows[ 5 ] ) ] } )
#
#         # store results for frand123NormDouble in result dictionary
#         resultsNormDoubleFortran.update( { 'frand123NormDouble' + compileCombination: tmpDict } )
#
## proceed with uniformly distributed single-precision random numbers
#for compiler in compiler_names:
#   for ars in ars_switch:
#      for fma in fma_switch:
#
#         # build make call and compileCombination
#         make_cmd = "make"
#         compileCombination = ""
#         if compiler == "gcc":
#            make_cmd += " gcc=y"
#            compileCombination += "_gcc"
#         else:
#            compileCombination += "_intel"
#         if ars == "y":
#            make_cmd += " ars=y"
#            compileCombination += "_ars=y"
#         if fma == "y":
#            make_cmd += " fma=y"
#            compileCombination += "_fma=y"
#         make_cmd += " tuning/c_frand123NormSingle.x tuning/f_frand123NormSingle.x"
#
#         # call make command
#         os.system( "make clean" )
#         os.system( make_cmd )
#
#         # call the compiled version
#         os.system( "./tuning/c_frand123NormSingle.x " + compileCombination )
#         os.system( "./tuning/f_frand123NormSingle.x " + compileCombination )
#
#         # results for C
#
#         # read results for frand123NormSingle_scalar
#         with open( 'tuning/timings/frand123NormSingle_scalar' + compileCombination + '.dat', 'r' ) as f:
#            reader = csv.reader( f, 'unix' )
#            tmpDict = dict()
#            for rows in reader:
#               tmpDict.update( { rows[ 1 ].strip() : [ float( rows[ 2 ] ), float( rows[ 3 ] ), float( rows[ 4 ] ) ] } )
#
#         # store results for frand123NormSingle_scalar in result dictionary
#         resultsNormSingleScalar.update( { 'frand123NormSingle_scalar' + compileCombination: tmpDict } )
#
#         # read results for frand123NormSingle
#         with open( 'tuning/timings/frand123NormSingle' + compileCombination + '.dat', 'r' ) as f:
#            reader = csv.reader( f, 'unix' )
#            tmpDict = dict()
#            for rows in reader:
#               if not rows[ 1 ].strip() in tmpDict:
#                  tmpDict.update( { rows[ 1 ].strip() : dict() } )
#               tmpDict[ rows[ 1 ].strip() ].update( { rows[ 2 ].strip() : [ float( rows[ 3 ] ), float( rows[ 4 ] ), float( rows[ 5 ] ) ] } )
#
#         # store results for frand123NormSingle in result dictionary
#         resultsNormSingle.update( { 'frand123NormSingle' + compileCombination: tmpDict } )
#
#         # results for Fortran
#
#         # read results for frand123NormSingle_scalar
#         with open( 'tuning/timings/frand123NormSingle_scalar_f' + compileCombination + '.dat', 'r' ) as f:
#            reader = csv.reader( f, 'unix' )
#            tmpDict = dict()
#            for rows in reader:
#               tmpDict.update( { rows[ 1 ].strip() : [ float( rows[ 2 ] ), float( rows[ 3 ] ), float( rows[ 4 ] ) ] } )
#
#         # store results for frand123NormSingle_scalar in result dictionary
#         resultsNormSingleScalarFortran.update( { 'frand123NormSingle_scalar' + compileCombination: tmpDict } )
#
#         # read results for frand123NormSingle
#         with open( 'tuning/timings/frand123NormSingle_f' + compileCombination + '.dat', 'r' ) as f:
#            reader = csv.reader( f, 'unix' )
#            tmpDict = dict()
#            for rows in reader:
#               if not rows[ 1 ].strip() in tmpDict:
#                  tmpDict.update( { rows[ 1 ].strip() : dict() } )
#               tmpDict[ rows[ 1 ].strip() ].update( { rows[ 2 ].strip() : [ float( rows[ 3 ] ), float( rows[ 4 ] ), float( rows[ 5 ] ) ] } )
#
#         # store results for frand123NormSingle in result dictionary
#         resultsNormSingleFortran.update( { 'frand123NormSingle' + compileCombination: tmpDict } )
#
#os.system( 'make clean' )
#
#######################
######            #####
###### EVALUATION #####
######            #####
#######################
#
## store results in one large dictionary
#results = dict()
#results.update( { 'C' : { 'scalar' : dict(), 'array' : dict() } } )
#results.update( { 'Fortran' : { 'scalar' : dict(), 'array' : dict() } } )
#results[ 'C' ][ 'scalar' ].update( { 'frand123Double' : resultsDoubleScalar } )
#results[ 'C' ][ 'scalar' ].update( { 'frand123Single' : resultsSingleScalar } )
#results[ 'C' ][ 'scalar' ].update( { 'frand123NormDouble' : resultsNormDoubleScalar } )
#results[ 'C' ][ 'scalar' ].update( { 'frand123NormSingle' : resultsNormSingleScalar } )
#results[ 'C' ][ 'array' ].update( { 'frand123Double' : resultsDouble } )
#results[ 'C' ][ 'array' ].update( { 'frand123Single' : resultsSingle } )
#results[ 'C' ][ 'array' ].update( { 'frand123NormDouble' : resultsNormDouble } )
#results[ 'C' ][ 'array' ].update( { 'frand123NormSingle' : resultsNormSingle } )
#results[ 'Fortran' ][ 'scalar' ].update( { 'frand123Double' : resultsDoubleScalar } )
#results[ 'Fortran' ][ 'scalar' ].update( { 'frand123Single' : resultsSingleScalar } )
#results[ 'Fortran' ][ 'scalar' ].update( { 'frand123NormDouble' : resultsNormDoubleScalar } )
#results[ 'Fortran' ][ 'scalar' ].update( { 'frand123NormSingle' : resultsNormSingleScalar } )
#results[ 'Fortran' ][ 'array' ].update( { 'frand123Double' : resultsDouble } )
#results[ 'Fortran' ][ 'array' ].update( { 'frand123Single' : resultsSingle } )
#results[ 'Fortran' ][ 'array' ].update( { 'frand123NormDouble' : resultsNormDouble } )
#results[ 'Fortran' ][ 'array' ].update( { 'frand123NormSingle' : resultsNormSingle } )
#os.system( 'mkdir -p tuning/results' )
#with open( 'tuning/results/results.json', 'w' ) as f:
#   f.write( json.dumps( results ) )

with open( 'tuning/results/results.json', 'r' ) as f:
   results = json.load( f )

####################################
###### evaluate scalar results #####
####################################

best = { 'C' : dict(), 'Fortran' : dict() }
for lang in results:
   best[ lang ] = { 'scalar' : dict(), 'array' : dict() }
   for func in results[ lang ][ 'scalar' ]:
      # simplify work
      local = results[ lang ][ 'scalar' ][ func ]

      # add entry to dictionary
      best[ lang ][ 'scalar' ].update( { func : dict() } )

      # iterate over number of random numbers
      for n in [ 10, 100, 1000, 10000, 100000, 1000000 ]:
         # add entry to dictionary
         best[ lang ][ 'scalar' ][ func ].update( { str( n ) : dict() } )

         # reset minima
         best[ lang ][ 'scalar' ][ func ][ str( n ) ][ 'minMeanTime' ] = { 'time' : 1000., 'combination' : '' }
         best[ lang ][ 'scalar' ][ func ][ str( n ) ][ 'minMinTime' ] = { 'time' : 1000., 'combination' : '' }
         best[ lang ][ 'scalar' ][ func ][ str( n ) ][ 'minMaxTime' ] = { 'time' : 1000., 'combination' : '' }
         combination = ''
         for setting in local:
            settingRed = ' '.join( setting.split( '_' )[ 2: ] )
            if local[ setting ][ str( n ) ][ 0 ] < best[ lang ][ 'scalar' ][ func ][ str( n ) ][ 'minMeanTime' ][ 'time' ]:
               best[ lang ][ 'scalar' ][ func ][ str( n ) ][ 'minMeanTime' ] = { 'time' : local[ setting ][ str( n ) ][ 0 ], 'combination' : settingRed }
            if local[ setting ][ str( n ) ][ 0 ] < best[ lang ][ 'scalar' ][ func ][ str( n ) ][ 'minMinTime' ][ 'time' ]:
               best[ lang ][ 'scalar' ][ func ][ str( n ) ][ 'minMinTime' ] = { 'time' : local[ setting ][ str( n ) ][ 1 ], 'combination' : settingRed }
            if local[ setting ][ str( n ) ][ 2 ] < best[ lang ][ 'scalar' ][ func ][ str( n ) ][ 'minMaxTime' ][ 'time' ]:
               best[ lang ][ 'scalar' ][ func ][ str( n ) ][ 'minMaxTime' ] = { 'time' : local[ setting ][ str( n ) ][ 2 ], 'combination' : settingRed }

##################################
##### evaluate array results #####
##################################

for lang in results:
   for func in results[ lang ][ 'array' ]:
      # simplify work
      local = results[ lang ][ 'array' ][ func ]

      # add entry to dictionary
      best[ lang ][ 'array' ].update( { func : dict() } )

      # iterate over number of random numbers
      for n in [ 10, 100, 1000, 10000, 100000, 1000000 ]:
         # add entry to dictionary
         best[ lang ][ 'array' ][ func ].update( { str( n ) : dict() } )

         # iterate over chunk sizes
         for cs in [ 1, 2, 10, 100, 1000, 10000, 100000, 1000000 ]:
         # is this a realistic case
            if cs <= n:
               # add entry to dictionary
               best[ lang ][ 'array' ][ func ][ str( n ) ].update( { str( cs ) : dict() } )

               # reset minima
               best[ lang ][ 'array' ][ func ][ str( n ) ][ str( cs ) ][ 'minMeanTime' ] = { 'time' : 1000., 'combination' : '' }
               best[ lang ][ 'array' ][ func ][ str( n ) ][ str( cs ) ][ 'minMinTime' ] = { 'time' : 1000., 'combination' : '' }
               best[ lang ][ 'array' ][ func ][ str( n ) ][ str( cs ) ][ 'minMaxTime' ] = { 'time' : 1000., 'combination' : '' }
               combination = ''
               for setting in local:
                  settingRed = ' '.join( setting.split( '_' )[ 1: ] )
                  if local[ setting ][ str( n ) ][ str( cs ) ][ 0 ] < best[ lang ][ 'array' ][ func ][ str( n ) ][ str( cs ) ][ 'minMeanTime' ][ 'time' ]:
                     best[ lang ][ 'array' ][ func ][ str( n ) ][ str( cs ) ][ 'minMeanTime' ] = { 'time' : local[ setting ][ str( n ) ][ str( cs ) ][ 0 ], 'combination' : settingRed }
                  if local[ setting ][ str( n ) ][ str( cs ) ][ 0 ] < best[ lang ][ 'array' ][ func ][ str( n ) ][ str( cs ) ][ 'minMinTime' ][ 'time' ]:
                     best[ lang ][ 'array' ][ func ][ str( n ) ][ str( cs ) ][ 'minMinTime' ] = { 'time' : local[ setting ][ str( n ) ][ str( cs ) ][ 1 ], 'combination' : settingRed }
                  if local[ setting ][ str( n ) ][ str( cs ) ][ 2 ] < best[ lang ][ 'array' ][ func ][ str( n ) ][ str( cs ) ][ 'minMaxTime' ][ 'time' ]:
                     best[ lang ][ 'array' ][ func ][ str( n ) ][ str( cs ) ][ 'minMaxTime' ] = { 'time' : local[ setting ][ str( n ) ][ str( cs ) ][ 2 ], 'combination' : settingRed }

#########################################
##### save the results as json file #####
#########################################

with open( 'tuning/results/best.json', 'w' ) as f:
   f.write( json.dumps( best ) )

##################################################
##### write out scalar results as text files #####
##################################################

for lang in best:
   for func in best[ lang ][ 'scalar' ]:
      with open( 'tuning/results/' + lang + '_' + func + '_scalar.txt', 'w' ) as f:
         f.write( 'Minimum mean time of 20 runs\n' )
         for n in [ 10, 100, 1000, 10000, 100000, 1000000 ]:
            f.write( ', '.join( [ str( n ), str( best[ lang ][ 'scalar' ][ func ][ str( n ) ][ 'minMeanTime' ][ 'time' ] ), best[ lang ][ 'scalar' ][ func ][ str( n ) ][ 'minMeanTime' ][ 'combination' ], '\n' ] ) )
         f.write( '\n\n\nMinimum minimal time of 20 runs\n' )
         for n in [ 10, 100, 1000, 10000, 100000, 1000000 ]:
            f.write( ', '.join( [ str( n ), str( best[ lang ][ 'scalar' ][ func ][ str( n ) ][ 'minMinTime' ][ 'time' ] ), best[ lang ][ 'scalar' ][ func ][ str( n ) ][ 'minMinTime' ][ 'combination' ], '\n' ] ) )
         f.write( '\n\nMinimum maximal time of 20 runs\n' )
         for n in [ 10, 100, 1000, 10000, 100000, 1000000 ]:
            f.write( ', '.join( [ str( n ), str( best[ lang ][ 'scalar' ][ func ][ str( n ) ][ 'minMaxTime' ][ 'time' ] ), best[ lang ][ 'scalar' ][ func ][ str( n ) ][ 'minMaxTime' ][ 'combination' ], '\n' ] ) )

#################################################
##### write out array results as text files #####
#################################################

for lang in best:
   for func in best[ lang ][ 'array' ]:
      with open( 'tuning/results/' + lang + '_' + func + '_array.txt', 'w' ) as f:
         f.write( 'Minimum mean time of 20 runs\n' )
         for n in [ 10, 100, 1000, 10000, 100000, 1000000 ]:
            for cs in [ 1, 2, 10, 100, 1000, 10000, 100000, 1000000 ]:
               if cs <= n:
                  f.write( ', '.join( [ str( n ), str( cs ), str( best[ lang ][ 'array' ][ func ][ str( n ) ][ str( cs ) ][ 'minMeanTime' ][ 'time' ] ), best[ lang ][ 'array' ][ func ][ str( n ) ][ str( cs ) ][ 'minMeanTime' ][ 'combination' ], '\n' ] ) )
         f.write( '\n\nMinimum minimal time of 20 runs\n' )
         for n in [ 10, 100, 1000, 10000, 100000, 1000000 ]:
            for cs in [ 1, 2, 10, 100, 1000, 10000, 100000, 1000000 ]:
               if cs <= n:
                  f.write( ', '.join( [ str( n ), str( cs ), str( best[ lang ][ 'array' ][ func ][ str( n ) ][ str( cs ) ][ 'minMinTime' ][ 'time' ] ), best[ lang ][ 'array' ][ func ][ str( n ) ][ str( cs ) ][ 'minMinTime' ][ 'combination' ], '\n' ] ) )
         f.write( '\n\nMinimum maximal time of 20 runs\n' )
         for n in [ 10, 100, 1000, 10000, 100000, 1000000 ]:
            for cs in [ 1, 2, 10, 100, 1000, 10000, 100000, 1000000 ]:
               if cs <= n:
                  f.write( ', '.join( [ str( n ), str( cs ), str( best[ lang ][ 'array' ][ func ][ str( n ) ][ str( cs ) ][ 'minMaxTime' ][ 'time' ] ), best[ lang ][ 'array' ][ func ][ str( n ) ][ str( cs ) ][ 'minMaxTime' ][ 'combination' ], '\n' ] ) )
