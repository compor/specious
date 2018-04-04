# Specious - A SPEC CPU2006 benchmarks cmake harness

## Introduction

This is a CMake build harness for the [SPEC CPU2006][1].

The actual source files for each benchmark are not included, since they are distributed under a non-free/restrictive 
license.


### Features

- Building of all `C/C++` programs of the suite
- Out-of-source builds thanks to [cmake][2]
- Capability to create LLVM bitcode files thanks to [llvm-ir-cmake-utils][3] and LLVM `opt` pass pipelines (see the
  `config/pipelines` subdirectory).
- Capability to configure and build any desired subset of the programs by using the corresponding configuration (see the
  `suite_*` files in the `config` subdirectory).


## Requirements

- cmake 3.0.0 or later
- a sensible C/C++ compiler


## How to use

1. `git clone --recursive` this repo and also have available the benchmark source.
2. Create symlinks to the `src` subdirectory of each benchmark program.
   This can be automated with the relevant script found in the `utils/scripts/source_tree` subdirectory of this repo, 
   for example:

   `create-symlink-bmk-subdir.sh -c suite_all.txt -s [path-to]/CPU2006/ -t [path-to]/specious/CPU2006 -l src`

3. Create a directory for an out-of-source build and `cd` into it.
4. Run `cmake` and `cmake --build .` with that appropriate options.
   For examples on the various options have a look at the build scripts (provided for convenience) located in the
   `utils/scripts/source_tree` subdirectory.
5. Optionally, you can install the benchmarks by

   `cmake -DCMAKE_INSTALL_PREFIX=[path-to-install] -P cmake_install.cmake`

   Omitting `CMAKE_INSTALL_PREFIX` will use the `../install/` directory relative to the build directory.


## Benchmark-specific configuration options

TODO


## How the harness works

For a general description on how this harness operates please have a look [here][4].


## Not implemented

- Support for `Fortran` benchmarks (patches are welcome!).


[1]: https://www.spec.org/cpu2006/
[2]: https://cmake.org
[3]: https://github.com/compor/llvm-ir-cmake-utils
[4]: doc/harness.md

