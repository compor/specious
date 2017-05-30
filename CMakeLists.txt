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
set(HARNESS_CMAKE_FRAGMENT_FILES "")

set(HARNESS_LLVMIR_CMAKE_FRAGMENT_FILES "")
set(HARNESS_END_CMAKE_FRAGMENT_FILES "")

set(HARNESS_BUILD_TREE_SCRIPTS_SRC_DIR
  "${CMAKE_CURRENT_SOURCE_DIR}/utils/scripts/build_tree/")

set(HARNESS_BUILD_TREE_SCRIPTS_DEST_DIR
  "${CMAKE_CURRENT_BINARY_DIR}/scripts/")

set(HARNESS_INSTALL_TREE_SCRIPTS_DIR
  "${CMAKE_CURRENT_SOURCE_DIR}/utils/scripts/install_tree/")

set(HARNESS_CONFIGS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/configs")

set(HARNESS_INVOCATIONS_DIR 
  "${CMAKE_CURRENT_SOURCE_DIR}/utils/invocations")

add_definitions(-DSPEC_CPU)
add_definitions(-DSPEC_CPU_LINUX)
add_definitions(-DSPEC_CPU_LINUX_X64)


# project options checks and processing

if(HARNESS_USE_LLVM)
  find_package(LLVM REQUIRED CONFIG)

  if(LLVM_FOUND)
    set(LLVM_LIB_DIR ${LLVM_TOOLS_BINARY_DIR}/../lib/)

    list(APPEND CMAKE_MODULE_PATH 
      "${CMAKE_CURRENT_SOURCE_DIR}/cmake/llvm-ir-cmake-utils/cmake/")

    include(LLVMIRUtil RESULT_VARIABLE LLVM_IR_UTIL_FOUND)
  endif()
endif()

# use Intel ICC specific flags
if(CMAKE_C_COMPILER_ID STREQUAL "Intel" 
    OR CMAKE_CXX_COMPILER_ID STREQUAL "Intel")
  set(ICC_FLAGS "${ICC_FLAGS} -O2")
  set(ICC_FLAGS "${ICC_FLAGS} -parallel")
  set(ICC_FLAGS "${ICC_FLAGS} -ipo")
  set(ICC_FLAGS "${ICC_FLAGS} -xT -axT")
  set(ICC_FLAGS "${ICC_FLAGS} -par-threshold0")
  set(ICC_FLAGS "${ICC_FLAGS} -qopt-report=5")
  set(ICC_FLAGS "${ICC_FLAGS} -qopt-report-phase=par")
  #set(ICC_FLAGS "${ICC_FLAGS} -qopt-report-phase=par,loop")
  set(ICC_FLAGS "${ICC_FLAGS} -qopt-report-file=report.txt")

  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${ICC_FLAGS}")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${ICC_FLAGS}")
endif()

list(APPEND CMAKE_MODULE_PATH "${HARNESS_CMAKE_PIPELINE_DIR}")
list(APPEND CMAKE_MODULE_PATH "${HARNESS_CMAKE_FRAGMENT_DIR}")

include(BmkBasicInstall)

if(LLVM_IR_UTIL_FOUND)
  include(BasicBitcodeGen)
  include(LoopC14N)
  include(ApplyIOAttribute)
  include(PropagateAttributes)
  include(MixedPropagateAttributes)
  include(SimplifyLoopExits)
  include(AnnotateLoops)
endif()


#
# project user options
#

# project user options checks and processing

if(NOT HARNESS_BMK_CONFIG_FILE)
  message(FATAL_ERROR "Benchmark config file HARNESS_BMK_CONFIG_FILE is not set")
elseif(NOT EXISTS ${HARNESS_BMK_CONFIG_FILE})
  message(FATAL_ERROR "Benchmark config file does not exist: ${HARNESS_BMK_CONFIG_FILE}")
endif()


#
# configuration
#

# concatenate fragment lists
set(HARNESS_CMAKE_FRAGMENT_FILES BasicFragment)

file(STRINGS ${HARNESS_BMK_CONFIG_FILE} BENCHMARKS)

foreach(BMK ${BENCHMARKS})
  message(STATUS "adding subdir: ${BMK}")
  add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/${BMK}/)
endforeach()


# installation

install(DIRECTORY ${HARNESS_INVOCATIONS_DIR} DESTINATION .)
install(DIRECTORY ${HARNESS_CONFIGS_DIR} DESTINATION .)
install(DIRECTORY ${HARNESS_INSTALL_TREE_SCRIPTS_DIR} DESTINATION scripts)

add_custom_target(install-build-scripts 
  ALL
  COMMAND ${CMAKE_COMMAND} -E copy_directory 
  ${HARNESS_BUILD_TREE_SCRIPTS_SRC_DIR}
  ${HARNESS_BUILD_TREE_SCRIPTS_DEST_DIR}
  COMMENT "copying build-tree related scripts")

