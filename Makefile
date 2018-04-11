# have a compiler suffix if necessary to pick specific version number
SUFFIX ?=

#########################
#### Intel Compilers ####
#########################
CC = icc$(SUFFIX)
CFLAGS = -Iinclude/Random123 -fpic -ipo -O2 -xHost -qopenmp
FC = ifort$(SUFFIX)
FFLAGS = -fpic -module lib64 -ipo -O2 -xHost
LD = ifort$(SUFFIX)
LDFLAGS = -shared -ipo -O2 -xHost
AR = ar
ARFLAGS = rc
#######################
#### GNU Compilers ####
#######################
ifeq ($(gcc),y)
CC = gcc$(SUFFIX)
CFLAGS = -Iinclude/Random123 -fPIC -flto -O3 -maes -mtune=native -march=native -fopenmp
FC = gfortran$(SUFFIX)
FFLAGS = -fPIC -J lib64 -flto -O3 -maes -mtune=native -march=native
LD = gcc$(SUFFIX)
LDFLAGS = -shared -fPIC -flto -O2 -mtune=native -march=native
AR = gcc-ar$(SUFFIX)
ARFLAGS = rc
endif
############################
#### For static library ####
############################

# decide whether to use ARS or not (requires Intel AES-NI support)
ifeq ($(ars),y)
	CFLAGS += -DUSE_ARS -DR123_USE_AES_NI
	FFLAGS += -DUSE_ARS
endif

# decide whether to use FMA instructions (requires Intel FMA3 support)
ifeq ($(fma),y)
	CFLAGS += -DUSE_FMA -mfma
	FFLAGS += -mfma
endif

# decide whether to use Hastings' inversion
ifeq ($(hastings),y)
	FFLAGS += -DUSE_HASTINGS
endif

# decide whether to use the Polar method
ifeq ($(polar),y)
	FFLAGS += -DUSE_POLAR
endif

# decide whether to use Wichura's AS241
ifeq ($(wichura),y)
	FFLAGS += -DUSE_WICHURA
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

tests: testAccuracyFloats testRandSingle testRandDouble testMomentsSingle testMomentsDouble testCentralMomentsSingle testCentralMomentsDouble

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
