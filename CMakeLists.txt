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

option(PROJECT_USE_LLVM "use LLVM bitcode processing tools" OFF)

set(PROJECT_BMK_SOURCE_SUBDIR "src")

# aggregate list variables for appending commands 
# per each benchmark without editing each cmake file separately
set(PROJECT_CMAKE_FRAGMENT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/cmake/fragments/")
set(PROJECT_CMAKE_FRAGMENT_FILES "")

set(PROJECT_LLVMIR_CMAKE_FRAGMENT_FILES "")
set(PROJECT_END_CMAKE_FRAGMENT_FILES "")

set(PROJECT_BUILD_TREE_SCRIPTS_SRC_DIR
  "${CMAKE_CURRENT_SOURCE_DIR}/utils/scripts/build_tree/")

set(PROJECT_BUILD_TREE_SCRIPTS_DEST_DIR
  "${CMAKE_CURRENT_BINARY_DIR}/scripts/")

set(PROJECT_INSTALL_TREE_SCRIPTS_DIR
  "${CMAKE_CURRENT_SOURCE_DIR}/utils/scripts/install_tree/")

set(PROJECT_CONFIGS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/configs")

set(PROJECT_INVOCATIONS_DIR 
  "${CMAKE_CURRENT_SOURCE_DIR}/utils/invocations")

add_definitions(-DSPEC_CPU)
add_definitions(-DSPEC_CPU_LINUX)
add_definitions(-DSPEC_CPU_LINUX_X64)


# project options checks and processing

if(PROJECT_USE_LLVM)
  find_package(LLVM REQUIRED CONFIG)

  if(LLVM_FOUND)
    set(LLVM_LIB_DIR ${LLVM_TOOLS_BINARY_DIR}/../lib/)

    list(APPEND CMAKE_MODULE_PATH 
      "${CMAKE_CURRENT_SOURCE_DIR}/cmake/llvm-ir-cmake-utils/cmake/")

    include(LLVM-IR-Util RESULT_VARIABLE LLVM_IR_UTIL_FOUND)
  endif()
endif()


#
# project user options
#

#set(PROJECT_BMK_CONFIG_FILE "")

# EDIT FRAGMENT FILES SECTION START

if(LLVM_IR_UTIL_FOUND)
  list(APPEND PROJECT_LLVMIR_CMAKE_FRAGMENT_FILES
    "${PROJECT_CMAKE_FRAGMENT_DIR}/CMakeLists-loopcanon.txt")
endif()

list(APPEND PROJECT_END_CMAKE_FRAGMENT_FILES 
  "${PROJECT_CMAKE_FRAGMENT_DIR}/CMakeLists-install.txt")

# EDIT FRAGMENT FILES SECTION END


# project user options checks and processing

if(NOT PROJECT_BMK_CONFIG_FILE)
  message(FATAL_ERROR "Benchmark config file PROJECT_BMK_CONFIG_FILE is not set")
elseif(NOT EXISTS ${PROJECT_BMK_CONFIG_FILE})
  message(FATAL_ERROR "Benchmark config file does not exist: ${PROJECT_BMK_CONFIG_FILE}")
endif()


#
# configuration
#

# concatenate fragment lists

list(APPEND PROJECT_CMAKE_FRAGMENT_FILES
  "${PROJECT_LLVMIR_CMAKE_FRAGMENT_FILES}"
  "${PROJECT_END_CMAKE_FRAGMENT_FILES}")

file(STRINGS ${PROJECT_BMK_CONFIG_FILE} BENCHMARKS)

foreach(BMK ${BENCHMARKS})
  add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/${BMK}/)
endforeach()


# installation

install(DIRECTORY ${PROJECT_INVOCATIONS_DIR} DESTINATION .)
install(DIRECTORY ${PROJECT_CONFIGS_DIR} DESTINATION .)
install(DIRECTORY ${PROJECT_INSTALL_TREE_SCRIPTS_DIR} DESTINATION scripts)

add_custom_target(install-build-scripts 
  ALL
  COMMAND ${CMAKE_COMMAND} -E copy_directory 
  ${PROJECT_BUILD_TREE_SCRIPTS_SRC_DIR}
  ${PROJECT_BUILD_TREE_SCRIPTS_DEST_DIR}
  COMMENT "copying build-tree related scripts")

