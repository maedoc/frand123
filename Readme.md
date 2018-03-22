# The frand123 Fortran wrapper for the Random123 C library

The frand123 wrapper Fortran wrapper for the Random123 C library provides random number generators (RNG) to Fortran using the random bits generated using functions of the Random123 C library.

The Random123 C library (see [publication](http://dx.doi.org/10.1145/2063384.2063405) and [code](https://www.deshawresearch.com/resources_random123.html)) offer the following features:
* Perfect parallelization due to counter-based design with minimal state
* At least 2^64 unique streams with a period of at least 2^128
* Resistent to the BigCrush randomness test in TestU01 (see [publication](http://dx.doi.org/10.1145/1268776.1268777) and [code](http://simul.iro.umontreal.ca/testu01/tu01.html)
* ARS RNG implemented using Intel AES-NI instructions
