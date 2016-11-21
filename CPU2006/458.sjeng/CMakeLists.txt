# cmake file

set(BMK_NAME "458.sjeng")
set(PROJECT_NAME "sjeng")

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

add_prefix(SOURCES "${BENCHMARK_SOURCE_DIR}/" "${SOURCES}")

add_executable(${PROJECT_NAME} ${SOURCES})

# this property is required by our parasitic targets
set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE C)

target_include_directories(${PROJECT_NAME} PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/${BENCHMARK_SOURCE_DIR}")

target_link_libraries(${PROJECT_NAME} m)

# attachments on first target

if(USE_LLVM)
  foreach(FRAGMENT in ${PROJECT_LLVMIR_FRAGMENT_FILES})
    if(EXISTS FRAGMENT)
      include(${FRAGMENT})
    endif()
  endforeach()
endif()


foreach(FRAGMENT in ${PROJECT_END_FRAGMENT_FILES})
  if(EXISTS FRAGMENT)
    include(${FRAGMENT})
  endif()
endforeach()

