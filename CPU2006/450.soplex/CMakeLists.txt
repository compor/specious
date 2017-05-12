# cmake file

set(BMK_NAME "450.soplex")
set(PROJECT_NAME "soplex")

check_bmk_processing(hasSrcDir)

if(NOT ${hasSrcDir})
  message(STATUS "skipping project: ${PROJECT_NAME}") 
  return()
endif()

set(SOURCES
  changesoplex.cc
  didxset.cc
  dsvector.cc
  dvector.cc
  enter.cc
  example.cc
  factor.cc
  forest.cc
  idxset.cc
  leave.cc
  lpcolset.cc
  lprow.cc
  lprowset.cc
  message.cc
  mpsinput.cc
  nameset.cc
  slufactor.cc
  solve.cc
  soplex.cc
  spxaggregatesm.cc
  spxbasis.cc
  spxbounds.cc
  spxchangebasis.cc
  spxdefaultpr.cc
  spxdefaultrt.cc
  spxdefines.cc
  spxdesc.cc
  spxdevexpr.cc
  spxequilisc.cc
  spxfastrt.cc
  spxgeneralsm.cc
  spxharrisrt.cc
  spxhybridpr.cc
  spxid.cc
  spxio.cc
  spxlp.cc
  spxlpfread.cc
  spxmpsread.cc
  spxmpswrite.cc
  spxparmultpr.cc
  spxquality.cc
  spxredundantsm.cc
  spxrem1sm.cc
  spxscaler.cc
  spxshift.cc
  spxsolve.cc
  spxsolver.cc
  spxstarter.cc
  spxsteeppr.cc
  spxsumst.cc
  spxvecs.cc
  spxvectorst.cc
  spxweightpr.cc
  spxweightst.cc
  ssvector.cc
  svector.cc
  svset.cc
  timer.cc
  unitvector.cc
  update.cc
  updatevector.cc
  vector.cc
  vsolve.cc)

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


foreach(FRAGMENT ${PROJECT_CMAKE_FRAGMENT_FILES})
  include(${FRAGMENT})
endforeach()

