project(frand123)
cmake_minimum_required(VERSION 3.16)
enable_language(Fortran)

include_directories(Random123)
set(src wrapper/frand123.F90 wrapper/frand123.c)
add_library(frand123 ${src})
