#########################
#### Intel Compilers ####
#########################
#CC = icc
#CFLAGS = -Iinclude/Random123 -fpic -ipo -O2
#F90 = ifort
#FFLAGS = -fpic -module lib64 -ipo -O2
#LD = ifort
#LDFLAGS = -shared -ipo -O2
#######################
#### GNU Compilers ####
#######################
CC = gcc
CFLAGS = -Iinclude/Random123 -fPIC -flto -O3
F90 = gfortran
FFLAGS = -fPIC -J lib64 -flto -O3
LD = gcc
LDFLAGS = -shared -fPIC -flto -O2
############################
#### For static library ####
############################
AR = ar
ARFLAGS = rc

# decide whether to use ARS or not (requires Intel AES-NI support)
ifeq ($(ars),y)
	CFLAGS += -DUSE_ARS -DR123_USE_AES_NI
endif

.PHONY: clean

build:
	mkdir build/

lib64:
	mkdir lib64/

clean:
	rm -rf build/
	rm -rf lib64/

build/rand123wrapper.o: build lib64 wrapper/rand123wrapper.c Makefile
	$(CC) $(CFLAGS) -c wrapper/rand123wrapper.c -o build/rand123wrapper.o

build/frand123.o build/frand123.mod: build lib64 wrapper/frand123.F90 Makefile
	$(F90) $(FFLAGS) -c wrapper/frand123.F90 -o build/frand123.o 

lib64/frand123.so: lib64 build/frand123.o build/rand123wrapper.o Makefile
	$(LD) $(LDFLAGS) -o lib64/frand123.so build/frand123.o build/rand123wrapper.o

lib64/frand123.a: lib64 build/frand123.o build/rand123wrapper.o Makefile
	$(AR) $(ARFLAGS) lib64/frand123.a build/frand123.o build/rand123wrapper.o
