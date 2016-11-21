# cmake file

set(BMK_NAME "401.bzip2")
set(PROJECT_NAME "bzip2")

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

add_prefix(SOURCES "${BENCHMARK_SOURCE_DIR}/" "${SOURCES}")

add_executable(${PROJECT_NAME} ${SOURCES})

add_definitions(-DSPEC_BZIP)

# this property is required by our parasitic targets
set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE C)

target_include_directories(${PROJECT_NAME} PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/${BENCHMARK_SOURCE_DIR}")

target_link_libraries(${PROJECT_NAME} m)

# attachments on first target

if(${USE_LLVM})
  foreach(FRAGMENT in ${PROJECT_LLVMIR_FRAGMENT_FILES})
    if(EXISTS ${FRAGMENT})
      include(${FRAGMENT})
    endif()
  endforeach()
endif()


foreach(FRAGMENT in ${PROJECT_END_FRAGMENT_FILES})
  if(EXISTS ${FRAGMENT})
    include(${FRAGMENT})
  endif()
endforeach()
