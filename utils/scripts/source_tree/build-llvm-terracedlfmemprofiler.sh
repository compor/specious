#!/usr/bin/env bash

[[ -z ${1} ]] && echo "error: source directory was not provided" && exit 1
SRC_DIR=$1

INSTALL_PREFIX=${2:-../install/}

PIPELINE_CONFIG_FILE=${3:-${SRC_DIR}/configs/pipelines/terracedlfmemprofiler.txt}
BMK_CONFIG_FILE=${4:-${SRC_DIR}/configs/all_except_fortran.txt}
BMK_CONFIG_FILE=${4:-${SRC_DIR}/configs/lbm.txt}

[[ -z ${AnnotateLoops_DIR} ]] && echo "error: AnnotateLoops_DIR is not set"
[[ -z ${DecoupleLoopsFront_DIR} ]] && echo "error: DecoupleLoopsFront_DIR is not set"
[[ -z ${Terrace_DIR} ]] && echo "error: Terrace_DIR is not set"
[[ -z ${MemProfiler_DIR} ]] && echo "error: MemProfiler_DIR is not set"
[[ -z ${CommutativityRuntime_DIR} ]] && echo "error: CommutativityRuntime_DIR is not set"

#

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
  -DAnnotateLoops_DIR=${AnnotateLoops_DIR} \
  -DDecoupleLoopsFront_DIR=${DecoupleLoopsFront_DIR} \
  -DTerrace_DIR=${Terrace_DIR} \
  -DMemProfiler_DIR=${MemProfiler_DIR} \
  -DCommutativityRuntime_DIR=${CommutativityRuntime_DIR} \
  "${SRC_DIR}"

exit $?

