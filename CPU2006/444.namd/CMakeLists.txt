# cmake file

set(BMK_NAME "444.namd")
set(PROJECT_NAME "namd")

check_bmk_processing(hasSrcDir)

if(NOT ${hasSrcDir})
  message(STATUS "skipping project: ${PROJECT_NAME}") 
  return()
endif()

set(SOURCES
  Compute.C
  ComputeList.C
  ComputeNonbondedUtil.C
  LJTable.C
  Molecule.C
  Patch.C
  PatchList.C
  ResultSet.C
  SimParameters.C
  erf.C
  spec_namd.C)

add_prefix(SOURCES "${PROJECT_BMK_SOURCE_SUBDIR}/" "${SOURCES}")

add_executable(${PROJECT_NAME} ${SOURCES})

# this property is required by our parasitic targets
set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE CXX)

target_include_directories(${PROJECT_NAME} PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_BMK_SOURCE_SUBDIR}")

target_link_libraries(${PROJECT_NAME} m)


include_fragments("${PROJECT_CMAKE_FRAGMENT_FILES}")

