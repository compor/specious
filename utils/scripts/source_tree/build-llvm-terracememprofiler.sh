#!/usr/bin/env bash

PRJ_ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../" && pwd)"
SRC_DIR=${1:-$PRJ_ROOT_DIR}
INSTALL_PREFIX=${2:-../install/}

PIPELINE_CONFIG_FILE=${3:-${SRC_DIR}/config/pipelines/terracememprofiler.txt}
BMK_CONFIG_FILE=${4:-${SRC_DIR}/config/sets/groups/all_except_fortran.txt}

[[ -z "${ANNOTATELOOPS_DIR}" ]] && echo "ANNOTATELOOPS_DIR is not set" && exit 1
[[ -z "${TERRACE_DIR}" ]] && echo "error: TERRACE_DIR is not set" && exit 1
[[ -z "${MEMPROFILER_DIR}" ]] && echo "error: MEMPROFILER_DIR is not set" && exit 1
[[ -z "${COMMUTATIVITYRUNTIME_DIR}" ]] && echo "error: COMMUTATIVITYRUNTIME_DIR is not set"

LINKER_FLAGS="-Wl,-L$(llvm-config --libdir) -Wl,-rpath=$(llvm-config --libdir)"
LINKER_FLAGS="${LINKER_FLAGS} -lc++ -lc++abi"

CC=clang CXX=clang++ \
  cmake \
  -GNinja \
  -DCMAKE_POLICY_DEFAULT_CMP0056=NEW \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=On \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_CXX_FLAGS="-stdlib=libc++" \
  -DCMAKE_EXE_LINKER_FLAGS="${LINKER_FLAGS}" \
  -DCMAKE_SHARED_LINKER_FLAGS="${LINKER_FLAGS}" \
  -DCMAKE_MODULE_LINKER_FLAGS="${LINKER_FLAGS}" \
  -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
  -DHARNESS_USE_LLVM=On \
  -DHARNESS_PIPELINE_CONFIG_FILE="${PIPELINE_CONFIG_FILE}" \
  -DHARNESS_BMK_CONFIG_FILE="${BMK_CONFIG_FILE}" \
  -DTerrace_DIR="${ANNOTATELOOPS_DIR}" \
  -DTerrace_DIR="${TERRACE_DIR}" \
  -DMemProfiler_DIR="${MEMPROFILER_DIR}" \
  -DCommutativityRuntime_DIR="${COMMUTATIVITYRUNTIME_DIR}" \
  "${SRC_DIR}"

