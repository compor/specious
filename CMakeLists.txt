# cmake file

cmake_minimum_required(VERSION 3.0)

project(spec-cpu2006 C CXX)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(Util)

add_definitions(-DSPEC_CPU_LINUX)
add_definitions(-DSPEC_CPU_LINUX_X64)

add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/CPU2006/470.lbm/src/)

