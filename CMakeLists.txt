# cmake file

cmake_minimum_required(VERSION 3.0)

project(spec-cpu2006 C CXX)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/")
include(Specious-Utils)
include(Specious-Version)

get_version(SPECIOUS_VERSION)
message(STATUS "Specious harness version: ${SPECIOUS_VERSION}")

message(STATUS "C compiler: ${CMAKE_C_COMPILER}")
message(STATUS "CXX compiler: ${CMAKE_CXX_COMPILER}")


#
# project options
#

option(HARNESS_USE_LLVM "use LLVM bitcode processing tools" OFF)

set(CMAKE_SKIP_INSTALL_ALL_DEPENDENCY TRUE)

set(HARNESS_INPUT_DIR $ENV{HARNESS_INPUT_DIR})

set(HARNESS_REPORT_DIR $ENV{HARNESS_REPORT_DIR})

if(NOT HARNESS_REPORT_DIR)
  set(HARNESS_REPORT_DIR "${CMAKE_BINARY_DIR}/reports/")
  file(MAKE_DIRECTORY ${HARNESS_REPORT_DIR})
endif()

set(HARNESS_BMK_SOURCE_SUBDIR "src")

set(HARNESS_CMAKE_PIPELINE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/cmake/pipelines/")

# aggregate list variables for appending commands
# per each benchmark without editing each cmake file separately
set(HARNESS_CMAKE_FRAGMENT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/cmake/fragments/")
set(HARNESS_CMAKE_BINARY_FRAGMENT_DIR
  "${CMAKE_CURRENT_BINARY_DIR}/cmake/fragments/")
set(HARNESS_CMAKE_FRAGMENT_FILES "")

set(HARNESS_LLVMIR_CMAKE_FRAGMENT_FILES "")
set(HARNESS_END_CMAKE_FRAGMENT_FILES "")

set(HARNESS_BUILD_TREE_SCRIPTS_SRC_DIR
  "${CMAKE_CURRENT_SOURCE_DIR}/utils/scripts/build_tree/")

set(HARNESS_BUILD_TREE_SCRIPTS_DEST_DIR
  "${CMAKE_CURRENT_BINARY_DIR}/scripts/")

set(HARNESS_INSTALL_TREE_SCRIPTS_DIR
  "${CMAKE_CURRENT_SOURCE_DIR}/utils/scripts/install_tree/")

set(HARNESS_CONFIG_DIR "${CMAKE_CURRENT_SOURCE_DIR}/config")

set(HARNESS_INVOCATIONS_DIR
  "${CMAKE_CURRENT_SOURCE_DIR}/utils/invocations")

add_definitions(-DSPEC_CPU)
add_definitions(-DSPEC_CPU_LINUX)
if(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
  add_definitions(-DSPEC_CPU_LINUX_X64)
elseif(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "i686")
  #
endif()


# project options checks and processing

if(HARNESS_USE_LLVM)
  # finding LLVM modules is not currently required
  #find_package(LLVM REQUIRED CONFIG)

  #if(LLVM_FOUND)
  #set(LLVM_LIB_DIR ${LLVM_TOOLS_BINARY_DIR}/../lib/)
  #endif()

  list(APPEND CMAKE_MODULE_PATH
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/llvm-ir-cmake-utils/cmake/")

  include(LLVMIRUtil RESULT_VARIABLE LLVM_IR_UTIL_FOUND)

  if(NOT LLVM_IR_UTIL_FOUND)
    message(FATAL_ERROR "llvm-ir-cmake-utils were not found")
  endif()
endif()

list(APPEND CMAKE_MODULE_PATH "${HARNESS_CMAKE_PIPELINE_DIR}")
list(APPEND CMAKE_MODULE_PATH "${HARNESS_CMAKE_FRAGMENT_DIR}")
list(APPEND CMAKE_MODULE_PATH "${HARNESS_CMAKE_BINARY_FRAGMENT_DIR}")

include(BmkBasicInstall)


if(HARNESS_USE_LLVM)
  if(NOT HARNESS_PIPELINE_CONFIG_FILE)
    message(WARNING
      "Benchmark config file variable is not set: HARNESS_PIPELINE_CONFIG_FILE")
  elseif(NOT EXISTS ${HARNESS_PIPELINE_CONFIG_FILE})
    message(WARNING
      "Benchmark config file does not exist: ${HARNESS_PIPELINE_CONFIG_FILE}")
  else()
    file(STRINGS ${HARNESS_PIPELINE_CONFIG_FILE} PIPELINES)
  endif()

  foreach(PLINE ${PIPELINES})
    message(STATUS "including pipeline: ${PLINE}")
    include(${PLINE})
  endforeach()

  create_file_fragment(FILENAME
    ${HARNESS_CMAKE_BINARY_FRAGMENT_DIR}/BasicFragment.cmake
    PIPELINES ${PIPELINES})
endif()


#
# project user options
#

# project user options checks and processing

if(NOT HARNESS_BMK_CONFIG_FILE)
  message(FATAL_ERROR
    "Benchmark config file HARNESS_BMK_CONFIG_FILE is not set")
elseif(NOT EXISTS ${HARNESS_BMK_CONFIG_FILE})
  message(FATAL_ERROR
    "Benchmark config file does not exist: ${HARNESS_BMK_CONFIG_FILE}")
endif()


#
# configuration
#

set(CMAKE_INSTALL_MESSAGE "LAZY")

# concatenate fragment lists
if(HARNESS_USE_LLVM)
  set(HARNESS_CMAKE_FRAGMENT_FILES BasicFragment)
endif()

file(STRINGS ${HARNESS_BMK_CONFIG_FILE} BENCHMARKS)

foreach(BMK ${BENCHMARKS})
  message(STATUS "adding subdir: ${BMK}")
  add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/${BMK}/)
endforeach()


# installation

install(DIRECTORY ${HARNESS_INVOCATIONS_DIR}
  DESTINATION CPU2006
  USE_SOURCE_PERMISSIONS)
install(DIRECTORY ${HARNESS_CONFIG_DIR}
  DESTINATION .
  USE_SOURCE_PERMISSIONS)
install(DIRECTORY ${HARNESS_INSTALL_TREE_SCRIPTS_DIR}
  DESTINATION scripts
  USE_SOURCE_PERMISSIONS)

add_custom_target(install-build-scripts
  ALL
  COMMAND ${CMAKE_COMMAND} -E copy_directory
  ${HARNESS_BUILD_TREE_SCRIPTS_SRC_DIR}
  ${HARNESS_BUILD_TREE_SCRIPTS_DEST_DIR}
  COMMENT "copying build-tree related scripts")

