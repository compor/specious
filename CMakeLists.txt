# cmake file

cmake_minimum_required(VERSION 3.0)

project(spec-cpu2006 C CXX)

add_definitions(-DSPEC_CPU)
add_definitions(-DSPEC_CPU_LINUX)
add_definitions(-DSPEC_CPU_LINUX_X64)

if(${USE_LLVM})
  find_package(LLVM REQUIRED CONFIG)
endif()

if(${LLVM_FOUND})
  set(LLVM_LIB_DIR ${LLVM_TOOLS_BINARY_DIR}/../lib/)

  list(APPEND CMAKE_MODULE_PATH 
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/llvm-ir-cmake-utils/cmake/")

  include(LLVM-IR-Util)

  message(STATUS "LLVM IR Utils version: ${LLVM_IR_UTIL_VERSION_STRING}")
endif()

list(APPEND PROJECT_END_FRAGMENT_FILES "CMakeLists-install.txt")

message(STATUS "C compiler: ${CMAKE_C_COMPILER}")
message(STATUS "CXX compiler: ${CMAKE_CXX_COMPILER}")


# c projects
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/400.perlbench/src/)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/401.bzip2/src/)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/403.gcc/src/)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/429.mcf/src/)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/433.milc/src/)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/445.gobmk/src/)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/456.hmmer/src/)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/462.libquantum/src/)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/464.h264ref/src/)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/470.lbm/src/)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/482.sphinx3/src/)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/998.specrand/src/)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/999.specrand/src/)

# cxx projects
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/444.namd/src/)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/447.dealII/src/)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/450.soplex/src/)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/453.povray/src/)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/471.omnetpp/src/)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/473.astar/src/)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/483.xalancbmk/src/)

