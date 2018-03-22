# The frand123 Fortran wrapper for the Random123 C library

The frand123 Fortran wrapper for the Random123 C library provides random number generators (RNG) to Fortran using the random bits generated using functions of the Random123 C library.

The Random123 C library (see [publication](http://dx.doi.org/10.1145/2063384.2063405) and [code](https://www.deshawresearch.com/resources_random123.html)) offer the following features:
* Perfect parallelization due to counter-based design with minimal state
* At least 2^64 unique streams with a period of at least 2^128
* Resistent to the BigCrush randomness test in TestU01 (see [publication](http://dx.doi.org/10.1145/1268776.1268777) and [code](http://simul.iro.umontreal.ca/testu01/tu01.html))
* High-performance ARS RNG implemented using Intel AES-NI instructions
* High-performance Threefry RNG implemented in plain C

The frand123 Fortran wrapper provides the following capabilities:
* Perfect parallelization due to counter-based design with minimal state
* Generation of uniformly distributed signed 32-bit integers
* Generation of uniformly distributed signed 64-bit integers
* Generation of uniformly distributed single precision reals in (0,1)
* Generation of uniformly distributed double precision reals in (0,1)
* Comfortable interface for generating arbitrarily sized vectors of random numbers
* Interface for initializing the state of the RNG

## Reference

### frand123Double( state, res )
#### Description
* Fill vector res with double precision real random numbers uniformly distributed in (0,1)
* The counter within the state is incremented appropriately
#### Arguments
* __state__: state used by the RNG
    * dimension: _state_size_
    * kind: integer of kind _state_kind_
    * intent: _in_
* __res__: memory to which random numbers are stored to
    * dimension: arbitrary
    * kind: real of kind _res_kind_double_
    * intent: _inout_
