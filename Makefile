#########################
#### Intel Compilers ####
#########################
CC = icc
CFLAGS = -Iinclude/Random123 -fpic -ipo -O2
FC = ifort
FFLAGS = -fpic -module lib64 -ipo -O2
LD = ifort
LDFLAGS = -shared -ipo -O2
#######################
#### GNU Compilers ####
#######################
#CC = gcc
#CFLAGS = -Iinclude/Random123 -fPIC -flto -O3
#FC = gfortran
#FFLAGS = -fPIC -J lib64 -flto -O3
#LD = gcc
#LDFLAGS = -shared -fPIC -flto -O2
############################
#### For static library ####
############################
AR = ar
ARFLAGS = rc

# decide whether to use ARS or not (requires Intel AES-NI support)
ifeq ($(ars),y)
	CFLAGS += -DUSE_ARS -DR123_USE_AES_NI
	FFLAGS += -DUSE_ARS
endif

.PHONY: clean tests testRandSingle testRandDouble

build:
	mkdir build/

lib64:
	mkdir lib64/

clean:
	rm -rf build/
	rm -rf lib64/
	rm -f tests/*.x
	rm -rf tests/output

tests: testRandSingle testRandDouble

testRandSingle: tests/testRandSingle.x
	rm -f tests/rand_single.out
	mkfifo tests/rand_single.out
	./tests/testRandSingle.x & octave-cli --path ~/Downloads/statistics-1.3.0/inst/ --path tests --eval testRandSingle
	wait
	rm -f tests/rand_single.out

testRandDouble: tests/testRandDouble.x
	rm -f tests/rand_double.out
	mkfifo tests/rand_double.out
	./tests/testRandDouble.x & octave-cli --path ~/Downloads/statistics-1.3.0/inst/ --path tests --eval testRandDouble
	wait
	rm -f tests/rand_double.out

build/rand123wrapper.o: build wrapper/rand123wrapper.c Makefile
	$(CC) $(CFLAGS) -c wrapper/rand123wrapper.c -o build/rand123wrapper.o

build/frand123.o lib64/frand123.mod: build lib64 wrapper/frand123.F90 Makefile
	$(FC) $(FFLAGS) -c wrapper/frand123.F90 -o build/frand123.o 

lib64/frand123.so: build/frand123.o build/rand123wrapper.o Makefile
	$(LD) $(LDFLAGS) -o lib64/frand123.so build/frand123.o build/rand123wrapper.o

lib64/frand123.a: lib64/frand123.mod build/frand123.o build/rand123wrapper.o Makefile
	$(AR) $(ARFLAGS) lib64/frand123.a build/frand123.o build/rand123wrapper.o

tests/testRandDouble.x: lib64/frand123.a tests/testRandDouble.f90
	$(FC) $(FFLAGS) -o tests/testRandDouble.x tests/testRandDouble.f90 lib64/frand123.a

tests/testRandSingle.x: lib64/frand123.a tests/testRandSingle.f90
	$(FC) $(FFLAGS) -o tests/testRandSingle.x tests/testRandSingle.f90 lib64/frand123.a
