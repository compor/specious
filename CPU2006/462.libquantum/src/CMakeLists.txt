# cmake file

set(BMK_NAME "462.libquantum")
set(PROJECT_NAME libquantum)

set(SOURCES
  classic.c
  complex.c
  decoherence.c
  expn.c
  gates.c
  matrix.c
  measure.c
  oaddn.c
  objcode.c
  omuln.c
  qec.c
  qft.c
  qureg.c
  shor.c
  version.c
  specrand.c)

add_executable(${PROJECT_NAME} ${SOURCES})

add_definitions(-DSPEC_CPU_LINUX)

# this property is required by our parasitic targets
set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE C)

target_include_directories(${PROJECT_NAME} PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/")

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

