# cmake file

cmake_minimum_required(VERSION 3.0)

project(spec-cpu2006 C CXX)

add_definitions(-DSPEC_CPU)
add_definitions(-DSPEC_CPU_LINUX)
add_definitions(-DSPEC_CPU_LINUX_X64)


list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/")
include(Specious-Utils)

set(PROJECT_CMAKE_FRAGMENT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/cmake/fragments/")
set(BENCHMARK_SOURCE_DIR "src")


if(NOT BMK_CONFIG_FILE)
  message(FATAL_ERROR "Benchmark config file BMK_CONFIG_FILE is not set")
elseif(NOT EXISTS ${BMK_CONFIG_FILE})
  message(FATAL_ERROR "Benchmark config file does not exist: ${BMK_CONFIG_FILE}")
endif()


if(USE_LLVM)
  find_package(LLVM REQUIRED CONFIG)
endif()

if(LLVM_FOUND)
  set(LLVM_LIB_DIR ${LLVM_TOOLS_BINARY_DIR}/../lib/)

  list(APPEND CMAKE_MODULE_PATH 
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/llvm-ir-cmake-utils/cmake/")

  include(LLVM-IR-Util RESULT_VARIABLE LLVM_IR_UTIL_FOUND)

  if(LLVM_IR_UTIL_FOUND)
    message(STATUS "LLVM IR Utils version: ${LLVM_IR_UTIL_VERSION_STRING}")
  endif()
endif()



# EDIT FRAGMENT FILES SECTION START

set(PROJECT_LLVMIR_CMAKE_FRAGMENT_FILES "")

if(LLVM_IR_UTIL_FOUND)
  list(APPEND PROJECT_LLVMIR_CMAKE_FRAGMENT_FILES
    "${PROJECT_CMAKE_FRAGMENT_DIR}/CMakeLists-loopcanon.txt")
endif()


set(PROJECT_END_CMAKE_FRAGMENT_FILES "")

list(APPEND PROJECT_END_CMAKE_FRAGMENT_FILES 
  "${PROJECT_CMAKE_FRAGMENT_DIR}/CMakeLists-install.txt")



# aggregate lists

set(PROJECT_CMAKE_FRAGMENT_FILES "")

list(APPEND PROJECT_CMAKE_FRAGMENT_FILES
  "${PROJECT_LLVMIR_CMAKE_FRAGMENT_FILES}"
  "${PROJECT_END_CMAKE_FRAGMENT_FILES}")


# EDIT FRAGMENT FILES SECTION END



message(STATUS "C compiler: ${CMAKE_C_COMPILER}")
message(STATUS "CXX compiler: ${CMAKE_CXX_COMPILER}")


file(STRINGS ${BMK_CONFIG_FILE} BENCHMARKS)

foreach(BMK ${BENCHMARKS})
  add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/${BMK}/)
endforeach()


# installation

install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/utils/invocations" DESTINATION .)

