# cmake file

set(BMK_NAME "450.soplex")
set(PROJECT_NAME "soplex")

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

add_executable(${PROJECT_NAME} ${SOURCES})

# this property is required by our parasitic targets
set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE CXX)

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
  set(frag "${CMAKE_CURRENT_SOURCE_DIR}/${FRAGMENT}")
  if(EXISTS ${frag})
    include(${frag})
  endif()
endforeach()

