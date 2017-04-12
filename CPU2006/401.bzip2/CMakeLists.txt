# cmake file

set(BMK_NAME "401.bzip2")
set(PROJECT_NAME "bzip2")

check_bmk_processing(hasSrcDir)

if(NOT ${hasSrcDir})
  message(STATUS "skipping project: ${PROJECT_NAME}") 
  return()
endif()

set(SOURCES
  spec.c
  blocksort.c
  bzip2.c
  bzlib.c
  compress.c
  crctable.c 
  decompress.c
  huffman.c
  randtable.c)

add_prefix(SOURCES "${PROJECT_BMK_SOURCE_SUBDIR}/" "${SOURCES}")

add_executable(${PROJECT_NAME} ${SOURCES})

add_definitions(-DSPEC_BZIP)

# this property is required by our parasitic targets
set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE C)

target_include_directories(${PROJECT_NAME} PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_BMK_SOURCE_SUBDIR}")

target_link_libraries(${PROJECT_NAME} m)


include_fragments("${PROJECT_CMAKE_FRAGMENT_FILES}")

