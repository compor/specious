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

target_include_directories(${PROJECT_NAME} PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_BMK_SOURCE_SUBDIR}")

target_link_libraries(${PROJECT_NAME} m)


# this property is required by our parasitic targets
set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE CXX)

# this property is used internally by our harness 
# because benchmark names and their main targets have different names
set_target_properties(${PROJECT_NAME} PROPERTIES BMK_NAME ${BMK_NAME})

if(COMMAND SetupBmkBasicInstall)
  SetupBmkBasicInstall(${PROJECT_NAME})
endif()

if(COMMAND AttachLoopC14NPipeline)
  AttachLoopC14NPipeline(${PROJECT_NAME})
endif()
