# cmake file

set(BMK_NAME "450.soplex")
set(BMK_PROJECT_NAME "soplex")

check_bmk_processing(hasSrcDir)

if(NOT ${hasSrcDir})
  message(STATUS "skipping project: ${BMK_PROJECT_NAME}")
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

add_prefix(SOURCES "${HARNESS_BMK_SOURCE_SUBDIR}/" "${SOURCES}")

add_executable(${BMK_PROJECT_NAME} ${SOURCES})

target_include_directories(${BMK_PROJECT_NAME} PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/${HARNESS_BMK_SOURCE_SUBDIR}")

target_link_libraries(${BMK_PROJECT_NAME} m)


set_target_properties(${BMK_PROJECT_NAME}
  PROPERTIES LINKER_LANGUAGE CXX # existing property required by harness
  BMK_NAME ${BMK_NAME} # optional custom property used by our harness
  RUNTIME_OUTPUT_DIRECTORY exe
  )


foreach(FRAGMENT ${HARNESS_CMAKE_FRAGMENT_FILES})
  include(${FRAGMENT})
endforeach()

