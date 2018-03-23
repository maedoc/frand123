# The frand123 Fortran wrapper for the Random123 C library

The frand123 Fortran wrapper for the Random123 C library provides random number generators (RNG) to Fortran using the random bits generated using functions of the Random123 C library.

The Random123 C library (see [publication](http://dx.doi.org/10.1145/2063384.2063405) and [code](https://www.deshawresearch.com/resources_random123.html)) offer the following features:
* Perfect parallelization due to counter-based design with minimal state
* At least 2^64 unique streams with a period of at least 2^128
* Resistent to the BigCrush randomness test in TestU01 (see [publication](http://dx.doi.org/10.1145/1268776.1268777) and [code](http://simul.iro.umontreal.ca/testu01/tu01.html))
* High-performance ARS RNG implemented using Intel AES-NI instructions
* High-performance Threefry RNG implemented in plain C
* Permissive 3-clause BSD-type license (see file "License")

The frand123 Fortran wrapper provides the following capabilities:
* Perfect parallelization due to counter-based design with minimal state
* Generation of uniformly distributed:
    * signed 32-bit integers
    * signed 64-bit integers
    * single precision reals in (0,1)
    * double precision reals in (0,1)
* Comfortable interface for generating arbitrarily sized vectors of random numbers
* Interface for initializing the state of the RNG

## Reference

### frand123Single( state, res )
#### Description
* Fill vector res with single precision real random numbers uniformly distributed in (0,1)
* The counter within the state is incremented appropriately
* Uses either Threefry or ARS for generation of random bits
* Random numbers are always generated in chunks of 4

#### Arguments
* __state__: state used by the RNG
    * dimension: _state_size_
    * kind: integer of kind _state_kind_
    * intent: _inout_
* __res__: memory to which random numbers are stored to
    * dimension: arbitrary
    * kind: real of kind _res_kind_single_
    * intent: _inout_

### frand123Double( state, res )
#### Description
* Fill vector res with double precision real random numbers uniformly distributed in (0,1)
* The counter within the state is incremented appropriately
* Uses either Threefry or ARS for generation of random bits
* Random numvers are always generated in chunks of 2

#### Arguments
* __state__: state used by the RNG
    * dimension: _state_size_
    * kind: integer of kind _state_kind_
    * intent: _inout_
* __res__: memory to which random numbers are stored to
    * dimension: arbitrary
    * kind: real of kind _res_kind_double_
    * intent: _inout_

### frand123Integer32( state, res )
#### Description
* Fill vector res with signed 32-bit integer random numbers uniformly distributed between (iclusive) INT32_MIN and INT32_MAX
* The counter within the state is incremented appropriately
* Uses either Threefry or ARS for generation of random bits
* Random numbers are always generated in chunks of 4

#### Arguments
* __state__: state used by the RNG
    * dimension: _state_size_
    * kind: integer of kind _state_kind_
    * intent: _inout_
* __res__: memory to which random numbers are stored to
    * dimension: arbitrary
    * kind: real of kind _res_kind_int32
    * intent: _inout_

### frand123Integer64( state, res )
#### Description
* Fill vector res with signed 64-bit integer random numbers uniformly distributed between (iclusive) INT64_MIN and INT64_MAX
* The counter within the state is incremented appropriately
* Uses either Threefry or ARS for generation of random bits
* Random numbers are always generated in chunks of 2

#### Arguments
* __state__: state used by the RNG
    * dimension: _state_size_
    * kind: integer of kind _state_kind_
    * intent: _inout_
* __res__: memory to which random numbers are stored to
    * dimension: arbitrary
    * kind: real of kind _res_kind_int64
    * intent: _inout_

### frand123Init( state, rank, threadID, seed )
#### Description
* Initialize state for use in serial, MPI-parallel, thread-parallel, and MPI- and thread-parallel settings
* The key is initialized as follows:
    * first  64 bits: rank
    * second 64 bits: threadID
* The counter is initialized as follows:
    * first  64 bits: first element of seed
    * second 64 bits: second element of seed

#### Arguments
* __state__: memory in which to initialize state in
    * dimension: _state_size_
    * kind: integer of kind _state_kind_
    * intent: _inout_
* __rank__: MPI rank of the caller
    * dimension: scalar
    * kind: integer
    * intent: _in_
* __threadID__: thread ID of the thread using the RNG
    * dimension: scalar
    * kind: integer
    * intent: _in_
* __seed__: seed to be used to initialize the counter
    * dimension: 2
    * kind: integer of kind _state_kind_
    * intent: _in_

## Installation
The Makefile was tested with:
* gcc + gfortran 7.3.0
* icc + ifortran 17.0.2

### Build options
* static library only: _make lib64/libfrand123.a_
* dynamic library only: _make lib64/libfrand123.so_
* static and dynamic libraries: _make all_
* run tests: _make tests_

### Enabling features
* use ARS: add _ars=y_ to _make_ command
* use FMA3 in ARS: add _ars=y fma=y_ to _make_ command
* use gcc: add _gcc=y_ to _make_ command

## Examples
For examples, please consult the tests subdirectory

## Tests
### testRandSingle.f90
#### Description
This test consists of three stages:
1. Write out an array of 10^8 single precision uniformly distributed real random numbers to disk
2. Read random numbers into octave
3. Test the null hypothesis on randomness of the numbers against the alternative hypothesis that they are not random with significance level 10^{-5} (runstest, cf. MATLAB documentation)

### testRandDouble.f90
#### Description
This test consists of three stages:
1. Write out an array of 10^8 double precision uniformly distributed real random numbers to disk
2. Read random numbers into octave
3. Test the null hypothesis on randomness of the numbers against the alternative hypothesis that they are not random with significance level 10^{-5} (runstest, cf. MATLAB documentation)

### testAccuracyFloats.f90
#### Description
This test assesses that the value added onto UINT32_MAX in the mapping onto the interval (0,1) is sufficiently large.
