# cmake file

set(BMK_NAME "473.astar")
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

add_prefix(SOURCES "${PROJECT_BMK_SOURCE_SUBDIR}/" "${SOURCES}")

add_executable(${PROJECT_NAME} ${SOURCES})

# this property is required by our parasitic targets
set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE CXX)

target_include_directories(${PROJECT_NAME} PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_BMK_SOURCE_SUBDIR}")

target_link_libraries(${PROJECT_NAME} m)


include_fragments("${PROJECT_CMAKE_FRAGMENT_FILES}")

