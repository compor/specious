# cmake file

set(PROJECT_NAME "astar")

set(SOURCES
  CreateWay_.cpp
  Places_.cpp
  RegBounds_.cpp
  RegMng_.cpp
  Way2_.cpp
  WayInit_.cpp
  Library.cpp
  Random.cpp
  Region_.cpp
  RegWay_.cpp
  Way_.cpp) 

add_executable(${PROJECT_NAME} ${SOURCES})

# this property is required by our parasitic targets
set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE CXX)

target_include_directories(${PROJECT_NAME} PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/")

target_link_libraries(${PROJECT_NAME} m)

# attachments on first target

if(${USE_LLVM})
  attach_llvmir_target(${PROJECT_NAME}_bc ${PROJECT_NAME})

  include(CMakeLists-additional.txt)

  attach_llvmir_executable(${PROJECT_NAME}_bc_exe ${PROJECT_NAME}_link)
  target_link_libraries(${PROJECT_NAME}_bc_exe m)
endif()

