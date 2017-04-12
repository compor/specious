# cmake file

set(BMK_NAME "429.mcf")
set(PROJECT_NAME "mcf")

check_bmk_processing(hasSrcDir)

if(NOT ${hasSrcDir})
  message(STATUS "skipping project: ${PROJECT_NAME}") 
  return()
endif()

set(SOURCES
  mcf.c
  mcfutil.c
  readmin.c
  implicit.c
  pstart.c
  output.c
  treeup.c
  pbla.c
  pflowup.c
  psimplex.c
  pbeampp.c)

add_prefix(SOURCES "${PROJECT_BMK_SOURCE_SUBDIR}/" "${SOURCES}")

add_executable(${PROJECT_NAME} ${SOURCES})

add_definitions(-DWANT_STDC_PROTO)

# this property is required by our parasitic targets
set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE C)

target_include_directories(${PROJECT_NAME} PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_BMK_SOURCE_SUBDIR}")

target_link_libraries(${PROJECT_NAME} m)


include_fragments("${PROJECT_CMAKE_FRAGMENT_FILES}")

