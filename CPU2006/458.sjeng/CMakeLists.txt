# cmake file

set(BMK_NAME "458.sjeng")
set(PROJECT_NAME "sjeng")

check_bmk_processing(hasSrcDir)

if(NOT ${hasSrcDir})
  message(STATUS "skipping project: ${PROJECT_NAME}") 
  return()
endif()

set(SOURCES
  attacks.c
  book.c
  crazy.c
  draw.c
  ecache.c
  epd.c
  eval.c
  leval.c
  moves.c
  neval.c
  partner.c
  proof.c 
  rcfile.c
  search.c
  see.c
  seval.c
  sjeng.c
  ttable.c 
  utils.c)

add_prefix(SOURCES "${PROJECT_BMK_SOURCE_SUBDIR}/" "${SOURCES}")

add_executable(${PROJECT_NAME} ${SOURCES})

target_include_directories(${PROJECT_NAME} PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_BMK_SOURCE_SUBDIR}")

target_link_libraries(${PROJECT_NAME} m)


# this property is required by our parasitic targets
set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE C)

# this property is used internally by our harness 
# because benchmark names and their main targets have different names
set_target_properties(${PROJECT_NAME} PROPERTIES BMK_NAME ${BMK_NAME})


foreach(FRAGMENT ${PROJECT_CMAKE_FRAGMENT_FILES})
  include(${FRAGMENT})
endforeach()

