#!/usr/bin/env bash

# initialize configuration vars

SRC_DIR=""
INSTALL_PREFIX=""


# set configuration vars

[[ -z $1 ]] && echo "error: source directory was not provided" 
SRC_DIR=$1

INSTALL_PREFIX=${2:-../install/}


PIPELINE_CONFIG_FILE="${SRC_DIR}/configs/pipelines/terracememprofiler.txt"
BMK_CONFIG_FILE="${SRC_DIR}/configs/all_except_fortran.txt"

[[ -z ${AnnotateLoops_DIR} ]] && echo "error: AnnotateLoops_DIR is not set"
[[ -z ${Terrace_DIR} ]] && echo "error: Terrace_DIR is not set"
[[ -z ${MemProfiler_DIR} ]] && echo "error: MemProfiler_DIR is not set"
[[ -z ${CommutativityRuntime_DIR} ]] && echo "error: CommutativityRuntime_DIR is not set"

# print configuration vars

echo "info: printing configuration vars"
echo "info: source dir: ${SRC_DIR}"
echo "info: install dir: ${INSTALL_PREFIX}"
echo ""


LINKER_FLAGS="-Wl,-L$(llvm-config --libdir) -Wl,-rpath=$(llvm-config --libdir)"
LINKER_FLAGS="${LINKER_FLAGS} -lc++ -lc++abi" 

CC=clang CXX=clang++ \
  cmake \
  -DCMAKE_POLICY_DEFAULT_CMP0056=NEW \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=On \
  -DLLVM_DIR=$(llvm-config --prefix)/share/llvm/cmake/ \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_CXX_FLAGS="-stdlib=libc++" \
  -DCMAKE_EXE_LINKER_FLAGS="${LINKER_FLAGS}" \
  -DCMAKE_SHARED_LINKER_FLAGS="${LINKER_FLAGS}" \
  -DCMAKE_MODULE_LINKER_FLAGS="${LINKER_FLAGS}" \
  -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
  -DHARNESS_USE_LLVM=On \
  -DHARNESS_PIPELINE_CONFIG_FILE=${PIPELINE_CONFIG_FILE} \
  -DHARNESS_BMK_CONFIG_FILE=${BMK_CONFIG_FILE} \
  -DTerrace_DIR=${AnnotateLoops_DIR} \
  -DTerrace_DIR=${Terrace_DIR} \
  -DMemProfiler_DIR=${MemProfiler_DIR} \
  -DCommutativityRuntime_DIR=${CommutativityRuntime_DIR} \
  "${SRC_DIR}"


exit $?

