# cmake file

cmake_minimum_required(VERSION 3.0)

project(spec-cpu2006 C CXX)

add_definitions(-DSPEC_CPU)
add_definitions(-DSPEC_CPU_LINUX)
add_definitions(-DSPEC_CPU_LINUX_X64)

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


if(LLVM_IR_UTIL_FOUND)
  list(APPEND PROJECT_LLVMIR_FRAGMENT_FILES
    "${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists-loopcanon.txt")
endif()

list(APPEND PROJECT_END_FRAGMENT_FILES 
  "${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists-install.txt")

message(STATUS "C compiler: ${CMAKE_C_COMPILER}")
message(STATUS "CXX compiler: ${CMAKE_CXX_COMPILER}")


# c projects
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/400.perlbench/)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/401.bzip2/)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/403.gcc/)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/429.mcf/)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/433.milc/)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/445.gobmk/)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/456.hmmer/)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/462.libquantum/)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/464.h264ref/)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/470.lbm/)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/482.sphinx3/)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/998.specrand/)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/999.specrand/)

# cxx projects
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/444.namd/)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/447.dealII/)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/450.soplex/)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/453.povray/)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/471.omnetpp/)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/473.astar/)
#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/483.xalancbmk/)


# installation

install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/utils/invocations" DESTINATION .)

