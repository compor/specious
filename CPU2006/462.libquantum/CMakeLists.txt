# cmake file

set(BMK_NAME "462.libquantum")
set(PROJECT_NAME libquantum)

check_bmk_processing(hasSrcDir)

if(NOT ${hasSrcDir})
  message(STATUS "skipping project: ${PROJECT_NAME}") 
  return()
endif()

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

add_prefix(SOURCES "${PROJECT_BMK_SOURCE_SUBDIR}/" "${SOURCES}")

add_executable(${PROJECT_NAME} ${SOURCES})

add_definitions(-DSPEC_CPU_LINUX)

target_include_directories(${PROJECT_NAME} PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_BMK_SOURCE_SUBDIR}")

target_link_libraries(${PROJECT_NAME} m)


# this property is required by our parasitic targets
set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE C)

# this property is used internally by our harness 
# because benchmark names and their main targets have different names
set_target_properties(${PROJECT_NAME} PROPERTIES BMK_NAME ${BMK_NAME})

if(COMMAND SetupBmkBasicInstall)
  SetupBmkBasicInstall(${PROJECT_NAME})
endif()

if(COMMAND AttachLoopC14NPipeline)
  AttachLoopC14NPipeline(${PROJECT_NAME})
endif()

