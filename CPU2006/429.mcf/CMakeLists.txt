# cmake file

set(BMK_NAME "429.mcf")
set(BMK_PROJECT_NAME "mcf")

check_bmk_processing(hasSrcDir)

if(NOT ${hasSrcDir})
  message(STATUS "skipping project: ${BMK_PROJECT_NAME}")
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

add_prefix(SOURCES "${HARNESS_BMK_SOURCE_SUBDIR}/" "${SOURCES}")

add_executable(${BMK_PROJECT_NAME} ${SOURCES})

target_compile_definitions(${BMK_PROJECT_NAME} PUBLIC -DWANT_STDC_PROTO)

target_include_directories(${BMK_PROJECT_NAME} PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/${HARNESS_BMK_SOURCE_SUBDIR}")

target_link_libraries(${BMK_PROJECT_NAME} m)


set_target_properties(${BMK_PROJECT_NAME}
  PROPERTIES LINKER_LANGUAGE C # existing property required by harness
  BMK_NAME ${BMK_NAME} # optional custom property used by our harness
  RUNTIME_OUTPUT_DIRECTORY exe
  )


foreach(FRAGMENT ${HARNESS_CMAKE_FRAGMENT_FILES})
  include(${FRAGMENT})
endforeach()

