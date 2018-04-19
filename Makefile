# have a compiler suffix if necessary to pick specific version number
SUFFIX ?=

#########################
#### Intel Compilers ####
#########################
CC = icc$(SUFFIX)
CFLAGS = -Iinclude/Random123 -fpic -ipo -O2 -xHost -qopenmp -qopt-report=2
FC = ifort$(SUFFIX)
FFLAGS = -fpic -module lib64 -ipo -O2 -xHost -qopenmp -qopt-report=2
LD = ifort$(SUFFIX)
LDFLAGS = -shared -ipo -O2 -xHost -qopenmp -qopt-report=2
AR = xiar
ARFLAGS = rc
CMAINFLAGS = -nofor_main
OPENMPFLAGS = -qopenmp
#######################
#### GNU Compilers ####
#######################
ifeq ($(gcc),y)
CC = gcc$(SUFFIX)
CFLAGS = -Iinclude/Random123 -fPIC -flto -O3 -maes -mtune=native -march=native -fopenmp -lm #-flto-report
FC = gfortran$(SUFFIX)
FFLAGS = -fPIC -J lib64 -flto -O3 -maes -mtune=native -march=native #-flto-report
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
	TESTNORMDOUBLEPYFLAGS = --polar
else
	FFLAGS += -DUSE_WICHURA
	TESTNORMDOUBLEPYFLAGS = --wichura
endif

.PHONY: all clean tests testAccuracyFloats testRandSingle testRandDouble testMomentsSingle testMomentsDouble testCentralMomentsSingle testCentralMomentsDouble

all: lib64/libfrand123.a lib64/libfrand123.so

build:
	mkdir build/

lib64:
	mkdir lib64/

clean:
	rm -rf build/
	rm -rf lib64/
	rm -f tests/*.x
	rm -f tests/rand_*.out
	rm -f tests/input*.in

tests: testAccuracyFloats testRandSingle testRandDouble testMomentsSingle testMomentsDouble testCentralMomentsSingle testCentralMomentsDouble testWichura2x64Kernel testRandNormDoublePython testNormDoublePerformance testRandNormSinglePython testNormSinglePerformance

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

testRandNormSinglePython: tests/testSkewKurtosisNormSingle.py tests/testRandNormSingle.x
	rm -rf tests/rand_norm_single.out
	./tests/testRandNormSingle.x
	set -e; python3 tests/testSkewKurtosisNormSingle.py $(TESTNORMSINGLEPYFLAGS)
	rm -rf tests/rand_norm_single.out

testNormSinglePerformance: tests/testNormSinglePerformance.x
	./tests/testNormSinglePerformance.x

build/rand123wrapper.o: build wrapper/rand123wrapper.c wrapper/frand123enlarger.h Makefile
	$(CC) $(CFLAGS) -c wrapper/rand123wrapper.c -o build/rand123wrapper.o

build/frand123.o lib64/frand123.mod: build lib64 wrapper/frand123.F90 Makefile
	$(FC) $(FFLAGS) -c wrapper/frand123.F90 -o build/frand123.o 

lib64/libfrand123.so: build/frand123.o build/rand123wrapper.o Makefile
	$(LD) $(LDFLAGS) -o lib64/libfrand123.so build/frand123.o build/rand123wrapper.o

lib64/libfrand123.a: lib64/frand123.mod build/frand123.o build/rand123wrapper.o Makefile
	$(AR) $(ARFLAGS) lib64/libfrand123.a build/frand123.o build/rand123wrapper.o

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
	$(CC) $(CFLAGS) -o tests/testCentralMomentsNormDouble.x tests/testCentralMomentsNormDouble.c lib64/libfrand123.a -lm
