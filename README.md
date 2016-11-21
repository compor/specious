# specious

## Introduction

This is a SPEC CPU2006 CMake build harness.

The actual source files for each benchmark are not included, since they are
distributed under a non-free license.

Features
- Support for building all `C` and `C++` benchmarks.


## How to use

1. Clone this repo.
2. Create links to each benchmark's `src` directory.
   This can be automates with the relevant script found in this repo's `scripts`
   directory.
3. Create a directory for an out-of-source build.
4. Run `cmake` and `make` from the previously created build directory.
   For examples and various options have a look in the `scripts` directory.
5. Optionally, run `make install` to install the benchmarks, depending on your
   desired configuration from the previous step.


## Not implemented

(Patches are welcome!)

- Support for `Fortran` benchmarks.

