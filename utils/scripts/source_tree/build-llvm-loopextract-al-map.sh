#!/usr/bin/env bash

# set configuration vars

[[ -z ${1} ]] && echo "error: source directory was not provided" && exit 1
SRC_DIR=$1

INSTALL_PREFIX=${2:-../install/}


PIPELINE_CONFIG_FILE="${SRC_DIR}/configs/pipelines/loopextract-al-map.txt"
BMK_CONFIG_FILE="${SRC_DIR}/configs/all_except_fortran.txt"

[[ -z ${AnnotateLoops_DIR} ]] && echo "error: AnnotateLoops_DIR is not set" && exit 2

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
  -DAnnotateLoops_DIR=${AnnotateLoops_DIR} \
  "${SRC_DIR}"

exit $?

