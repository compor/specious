#!/usr/bin/env bash

PRJ_ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../" && pwd)"
SRC_DIR=${1:-$PRJ_ROOT_DIR}
INSTALL_PREFIX=${2:-../install/}

BMK_CONFIG_FILE="${SRC_DIR}/config/sets/groups/all_except_fortran.txt"

COMPILE_FLAGS=""
COMPILE_FLAGS="${COMPILE_FLAGS} -O2" # this is provided by release cmake builds
#COMPILE_FLAGS="${COMPILE_FLAGS} -DNDEBUG" # this is provided by release cmake builds
COMPILE_FLAGS="${COMPILE_FLAGS} -fno-omit-frame-pointer"
COMPILE_FLAGS="${COMPILE_FLAGS} -fno-inline-functions"
COMPILE_FLAGS="${COMPILE_FLAGS} -fno-inline-functions-called-once"
COMPILE_FLAGS="${COMPILE_FLAGS} -fno-optimize-sibling-calls"

C_FLAGS=${COMPILE_FLAGS}

CXX_FLAGS=${COMPILE_FLAGS}

LINKER_FLAGS=""

CC=gcc CXX=g++ \
  cmake \
  -DCMAKE_POLICY_DEFAULT_CMP0056=NEW \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=On \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_C_FLAGS="${C_FLAGS}" \
  -DCMAKE_CXX_FLAGS="${CXX_FLAGS}" \
  -DCMAKE_EXE_LINKER_FLAGS="${LINKER_FLAGS}" \
  -DCMAKE_SHARED_LINKER_FLAGS="${LINKER_FLAGS}" \
  -DCMAKE_MODULE_LINKER_FLAGS="${LINKER_FLAGS}" \
  -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
  -DHARNESS_BMK_CONFIG_FILE="${BMK_CONFIG_FILE}" \
  "${SRC_DIR}"

