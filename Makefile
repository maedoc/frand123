# have a compiler suffix if necessary to pick specific version number
SUFFIX ?=
VECTORWIDHT ?= 1

#########################
#### Intel Compilers ####
#########################
CC = icc$(SUFFIX)
CFLAGS = -IRandom123 -fpic -ipo -O2 -xHost -qopenmp -qopt-report=5 -no-inline-min-size
FC = ifort$(SUFFIX)
FFLAGS = -fpic -module lib64 -ipo -O2 -xHost -qopenmp -qopt-report=5 -no-inline-min-size
LD = ifort$(SUFFIX)
LDFLAGS = -shared -ipo -O2 -xHost -qopenmp -qopt-report=5 -no-inline-min-size
AR = xiar
ARFLAGS = rc
CMAINFLAGS = -nofor_main
OPENMPFLAGS = -qopenmp
#######################
#### GNU Compilers ####
#######################
ifeq ($(gcc),y)
CC = gcc$(SUFFIX) -std=c99
CFLAGS = -IRandom123 -Jlib64 -fPIC -flto -O3 -maes -mtune=native -march=native -fopenmp -lm -ffree-form -ffixed-line-length-none#-flto-report
FC = gfortran$(SUFFIX) -std=f2008
FFLAGS = $(CFLAGS)
LD = gcc$(SUFFIX)
LDFLAGS = -shared -fPIC -flto -O2 -mtune=native -march=native #-flto-report
AR = gcc-ar$(SUFFIX)
ARFLAGS = rc
CMAINFLAGS =
OPENMPFLAGS = -fopenmp
endif
############################
#### For static library ####
############################

# decide whether to use ARS or not (requires Intel AES-NI support)
ifeq ($(ars),y)
	CFLAGS += -DUSE_ARS -DR123_USE_AES_NI
	FFLAGS += -DUSE_ARS
	TESTNORMSINGLEPYFLAGS = --ars
else
	TESTNORMSINGLEPYFLAGS = --threefry
endif

# decide whether to use FMA instructions (requires Intel FMA3 support)
ifeq ($(fma),y)
	CFLAGS += -DUSE_FMA -mfma
	FFLAGS += -mfma
endif

# decide whether to use the Polar or Wichura's AS 241 method
ifeq ($(use_polar),y)
	FFLAGS += -DUSE_POLAR
	CFLAGS += -DUSE_POLAR
	TESTNORMDOUBLEPYFLAGS = --polar
else
	FFLAGS += -DUSE_WICHURA
	CFLAGS += -DUSE_WICHURA
	TESTNORMDOUBLEPYFLAGS = --wichura
endif

# decide whether to activate assertions in c functions
ifeq ($(use_assertions),y)
else
	CFLAGS += -DNDEBUG
endif


.PHONY: all clean tests examples examplesC exampleFortran testAccuracyFloats testRandSingle testRandDouble testMomentsSingle testMomentsDouble testCentralMomentsSingle testCentralMomentsDouble testEquivalence testOdd

all: lib64/libfrand123.a lib64/libfrand123.so

clean:
	rm -rf build/
	rm -rf lib64/
	rm -f tests/*.x
	rm -f tests/rand_*.out
	rm -f tests/input*.in
	rm -f tests/*optrpt
	rm -f examples/C/*.x
	rm -f examples/C/*optrpt
	rm -f examples/Fortran/*.x
	rm -f examples/Fortran/*optrpt
	rm -f tuning/*.x
	rm -f tuning/*optrpt

tests: testAccuracyFloats testRandSingle testRandDouble testMomentsSingle testMomentsDouble testCentralMomentsSingle testCentralMomentsDouble testWichura2x64Kernel testRandNormDoublePython testNormDoublePerformance testRandNormSinglePython testNormSinglePerformance testCentralMomentsNormDouble testEquivalence testOdd

examples: examplesC exampleFortran

examplesC: examples/C/piDouble.x examples/C/piSingle.x examples/C/kurtosisDouble.x examples/C/kurtosisSingle.x examples/C/integer64.x examples/C/integer32.x

examplesFortran: examples/Fortran/piDouble.x examples/Fortran/piSingle.x examples/Fortran/kurtosisDouble.x examples/Fortran/kurtosisSingle.x examples/Fortran/integer64.x examples/Fortran/integer32.x examples/Fortran/unifiedInterface.x

testAccuracyFloats: tests/testAccuracyFloats.x
	set -e ./tests/testAccuracyFloats.x

testRandSingle: tests/testRandSingle.x tests/testRandSingle.m
	rm -f tests/rand_single.out
	./tests/testRandSingle.x
	set -e; octave-cli --path ~/Downloads/statistics-1.3.0/inst/ --path tests --eval testRandSingle
	rm -f tests/rand_single.out

testRandDouble: tests/testRandDouble.x tests/testRandDouble.m
	rm -f tests/rand_double.out
	./tests/testRandDouble.x
	set -e; octave-cli --path ~/Downloads/statistics-1.3.0/inst/ --path tests --eval testRandDouble
	rm -f tests/rand_double.out

testMomentsSingle: tests/testRandSingle.x tests/testMomentsSingle.m
	rm -f tests/rand_single.out
	./tests/testRandSingle.x
	set -e; octave-cli --path tests --eval testMomentsSingle
	rm -f tests/rand_single.out

testMomentsDouble: tests/testRandDouble.x tests/testMomentsDouble.m
	rm -f tests/rand_double.out
	./tests/testRandDouble.x
	set -e; octave-cli --path tests --eval testMomentsDouble
	rm -f tests/rand_double.out

testCentralMomentsSingle: tests/testRandSingle.x tests/testCentralMomentsSingle.m
	rm -f tests/rand_single.out
	./tests/testRandSingle.x
	set -e; octave-cli --path tests --eval testCentralMomentsSingle
	rm -f tests/rand_single.out

testCentralMomentsDouble: tests/testRandDouble.x tests/testCentralMomentsDouble.m
	rm -f tests/rand_double.out
	./tests/testRandDouble.x
	set -e; octave-cli --path tests --eval testCentralMomentsDouble
	rm -f tests/rand_double.out

testWichura2x64Kernel: tests/testWichura2x64Kernel.x tests/as241ReferenceDouble.x tests/testRandDouble.x
	rm -rf tests/rand_double.out
	./tests/testRandDouble.x
	./tests/as241ReferenceDouble.x
	set -e; ./tests/testWichura2x64Kernel.x
	rm -rf tests/rand_double.out
	rm -rf tests/input_testWichura2x64Kernel.in

testRandNormDoublePython: tests/testSkewKurtosisNormDouble.py tests/testRandNormDouble.x
	rm -rf tests/rand_norm_double.out
	./tests/testRandNormDouble.x
	set -e; python3 tests/testSkewKurtosisNormDouble.py $(TESTNORMDOUBLEPYFLAGS)
	rm -rf tests/rand_norm_double.out

testNormDoublePerformance: tests/testNormDoublePerformance.x
	./tests/testNormDoublePerformance.x

testCentralMomentsNormDouble: tests/testCentralMomentsNormDouble.x
	set -e; ./tests/testCentralMomentsNormDouble.x

testRandNormSinglePython: tests/testSkewKurtosisNormSingle.py tests/testRandNormSingle.x
	rm -rf tests/rand_norm_single.out
	./tests/testRandNormSingle.x
	set -e; python3 tests/testSkewKurtosisNormSingle.py $(TESTNORMSINGLEPYFLAGS)
	rm -rf tests/rand_norm_single.out

testNormSinglePerformance: tests/testNormSinglePerformance.x
	./tests/testNormSinglePerformance.x

testEquivalence: tests/testEquivalence.x
	set -e; ./tests/testEquivalence.x

testOdd: tests/testOdd.x
	set -e; ./tests/testOdd.x

build/frand123_c.o: wrapper/frand123.c wrapper/rand123wrapper.h Makefile
	mkdir -p build
	$(CC) $(CFLAGS) -c wrapper/frand123.c -o build/frand123_c.o

build/frand123.o lib64/frand123.mod: wrapper/frand123.f90 Makefile
	mkdir -p build/ lib64/ 
	$(FC) $(FFLAGS) -c wrapper/frand123.f90 -o build/frand123.o 

lib64/libfrand123.so: build/frand123.o lib64/frand123.mod build/frand123_c.o Makefile
	$(LD) $(LDFLAGS) -o lib64/libfrand123.so build/frand123.o build/frand123_c.o

lib64/libfrand123.a: lib64/frand123.mod build/frand123.o build/frand123_c.o Makefile
	$(AR) $(ARFLAGS) lib64/libfrand123.a build/frand123.o build/frand123_c.o

tests/testAccuracyFloats.x: tests/testAccuracyFloats.c wrapper/frand123enlarger.h Makefile
	$(CC) $(CFLAGS) -o tests/testAccuracyFloats.x tests/testAccuracyFloats.c

tests/testRandDouble.x: lib64/libfrand123.a tests/testRandDouble.f90 Makefile
	$(FC) $(FFLAGS) -o tests/testRandDouble.x tests/testRandDouble.f90 lib64/libfrand123.a

tests/testRandSingle.x: lib64/libfrand123.a tests/testRandSingle.f90 Makefile
	$(FC) $(FFLAGS) -o tests/testRandSingle.x tests/testRandSingle.f90 lib64/libfrand123.a

tests/testRandNormDouble.x: lib64/libfrand123.a tests/testRandNormDouble.f90 Makefile
	$(FC) $(FFLAGS) -o tests/testRandNormDouble.x tests/testRandNormDouble.f90 lib64/libfrand123.a

tests/testWichura2x64Kernel.x: lib64/libfrand123.a tests/testWichura2x64Kernel.c Makefile
	$(CC) $(CFLAGS) -o tests/testWichura2x64Kernel.x tests/testWichura2x64Kernel.c lib64/libfrand123.a

tests/as241ReferenceDouble.x: tests/as241ReferenceDouble.c Makefile
	$(CC) $(CFLAGS) -lm -o tests/as241ReferenceDouble.x tests/as241ReferenceDouble.c

tests/testNormDoublePerformance.x: tests/testNormDoublePerformance.f90 lib64/libfrand123.a Makefile
	$(FC) $(FFLAGS) $(OPENMPFLAGS) -o tests/testNormDoublePerformance.x tests/testNormDoublePerformance.f90 lib64/libfrand123.a

tests/testRandNormSingle.x: lib64/libfrand123.a tests/testRandNormSingle.f90 Makefile
	$(FC) $(FFLAGS) -o tests/testRandNormSingle.x tests/testRandNormSingle.f90 lib64/libfrand123.a

tests/as241ReferenceSingle.x: tests/as241.c tests/as241ReferenceSingle.c Makefile
	$(CC) $(CFLAGS) -lm -o tests/as241ReferenceSingle.x tests/as241.c tests/as241ReferenceSingle.c

tests/testNormSinglePerformance.x: tests/testNormSinglePerformance.f90 lib64/libfrand123.a Makefile
	$(FC) $(FFLAGS) $(OPENMPFLAGS) -o tests/testNormSinglePerformance.x tests/testNormSinglePerformance.f90 lib64/libfrand123.a

tests/testCentralMomentsNormDouble.x: tests/testCentralMomentsNormDouble.c lib64/libfrand123.a Makefile
	$(CC) $(CFLAGS) -DVECTOR_WIDTH=$(VECTORWIDTH) -o tests/testCentralMomentsNormDouble.x tests/testCentralMomentsNormDouble.c lib64/libfrand123.a -lm

tests/testEquivalence.x: tests/testEquivalence.f90 lib64/libfrand123.a Makefile
	$(FC) $(FFLAGS) -o tests/testEquivalence.x tests/testEquivalence.f90 lib64/libfrand123.a

tests/testOdd.x: tests/testOdd.f90 lib64/libfrand123.a Makefile
	$(FC) $(FFLAGS) -o tests/testOdd.x tests/testOdd.f90 lib64/libfrand123.a

examples/C/piDouble.x: examples/C/piDouble.c lib64/libfrand123.a Makefile
	$(CC) $(CFLAGS) -o examples/C/piDouble.x examples/C/piDouble.c lib64/libfrand123.a

examples/C/piSingle.x: examples/C/piSingle.c lib64/libfrand123.a Makefile
	$(CC) $(CFLAGS) -o examples/C/piSingle.x examples/C/piSingle.c lib64/libfrand123.a

examples/C/kurtosisDouble.x: examples/C/kurtosisDouble.c lib64/libfrand123.a Makefile
	$(CC) $(CFLAGS) -o examples/C/kurtosisDouble.x examples/C/kurtosisDouble.c lib64/libfrand123.a

examples/C/kurtosisSingle.x: examples/C/kurtosisSingle.c lib64/libfrand123.a Makefile
	$(CC) $(CFLAGS) -o examples/C/kurtosisSingle.x examples/C/kurtosisSingle.c lib64/libfrand123.a

examples/C/integer64.x: examples/C/integer64.c lib64/libfrand123.a Makefile
	$(CC) $(CFLAGS) -o examples/C/integer64.x examples/C/integer64.c lib64/libfrand123.a

examples/C/integer32.x: examples/C/integer32.c lib64/libfrand123.a Makefile
	$(CC) $(CFLAGS) -o examples/C/integer32.x examples/C/integer32.c lib64/libfrand123.a

examples/Fortran/piDouble.x: examples/Fortran/piDouble.f90 lib64/libfrand123.a Makefile
	$(FC) $(FFLAGS) -o examples/Fortran/piDouble.x examples/Fortran/piDouble.f90 lib64/libfrand123.a

examples/Fortran/piSingle.x: examples/Fortran/piSingle.f90 lib64/libfrand123.a Makefile
	$(FC) $(FFLAGS) -o examples/Fortran/piSingle.x examples/Fortran/piSingle.f90 lib64/libfrand123.a

examples/Fortran/kurtosisDouble.x: examples/Fortran/kurtosisDouble.f90 lib64/libfrand123.a Makefile
	$(FC) $(FFLAGS) -o examples/Fortran/kurtosisDouble.x examples/Fortran/kurtosisDouble.f90 lib64/libfrand123.a

examples/Fortran/kurtosisSingle.x: examples/Fortran/kurtosisSingle.f90 lib64/libfrand123.a Makefile
	$(FC) $(FFLAGS) -o examples/Fortran/kurtosisSingle.x examples/Fortran/kurtosisSingle.f90 lib64/libfrand123.a

examples/Fortran/integer64.x: examples/Fortran/integer64.f90 lib64/libfrand123.a Makefile
	$(FC) $(FFLAGS) -o examples/Fortran/integer64.x examples/Fortran/integer64.f90 lib64/libfrand123.a

examples/Fortran/integer32.x: examples/Fortran/integer32.f90 lib64/libfrand123.a Makefile
	$(FC) $(FFLAGS) -o examples/Fortran/integer32.x examples/Fortran/integer32.f90 lib64/libfrand123.a

examples/Fortran/unifiedInterface.x: examples/Fortran/unifiedInterface.f90 lib64/libfrand123.a
	$(FC) $(FFLAGS) -o examples/Fortran/unifiedInterface.x examples/Fortran/unifiedInterface.f90 lib64/libfrand123.a

tuning/c_frand123Double.x: tuning/c_frand123Double.c lib64/libfrand123.a
	$(CC) $(CFLAGS) -o tuning/c_frand123Double.x tuning/c_frand123Double.c lib64/libfrand123.a

tuning/c_frand123Single.x: tuning/c_frand123Single.c lib64/libfrand123.a
	$(CC) $(CFLAGS) -o tuning/c_frand123Single.x tuning/c_frand123Single.c lib64/libfrand123.a

tuning/c_frand123NormDouble.x: tuning/c_frand123NormDouble.c lib64/libfrand123.a
	$(CC) $(CFLAGS) -o tuning/c_frand123NormDouble.x tuning/c_frand123NormDouble.c lib64/libfrand123.a

tuning/c_frand123NormSingle.x: tuning/c_frand123NormSingle.c lib64/libfrand123.a
	$(CC) $(CFLAGS) -o tuning/c_frand123NormSingle.x tuning/c_frand123NormSingle.c lib64/libfrand123.a

tuning/f_frand123Double.x: tuning/f_frand123Double.f90 lib64/libfrand123.a
	$(FC) $(FFLAGS) -o tuning/f_frand123Double.x tuning/f_frand123Double.f90 lib64/libfrand123.a

tuning/f_frand123Single.x: tuning/f_frand123Single.f90 lib64/libfrand123.a
	$(FC) $(FFLAGS) -o tuning/f_frand123Single.x tuning/f_frand123Single.f90 lib64/libfrand123.a

tuning/f_frand123NormDouble.x: tuning/f_frand123NormDouble.f90 lib64/libfrand123.a
	$(FC) $(FFLAGS) -o tuning/f_frand123NormDouble.x tuning/f_frand123NormDouble.f90 lib64/libfrand123.a

tuning/f_frand123NormSingle.x: tuning/f_frand123NormSingle.f90 lib64/libfrand123.a
	$(FC) $(FFLAGS) -o tuning/f_frand123NormSingle.x tuning/f_frand123NormSingle.f90 lib64/libfrand123.a
