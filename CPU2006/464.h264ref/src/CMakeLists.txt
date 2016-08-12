# cmake file

set(BMK_NAME "464.h264ref")
set(PROJECT_NAME "h264ref")

set(SOURCES
  annexb.c
  biariencode.c
  block.c
  cabac.c
  configfile.c
  context_ini.c
  decoder.c
  explicit_gop.c
  fast_me.c
  filehandle.c
  fmo.c
  header.c
  image.c
  intrarefresh.c
  leaky_bucket.c
  lencod.c
  loopFilter.c
  macroblock.c
  mb_access.c
  mbuffer.c
  memalloc.c
  mv-search.c
  nal.c
  nalu.c
  nalucommon.c
  output.c
  parset.c
  parsetcommon.c
  q_matrix.c
  q_offsets.c
  ratectl.c
  rdopt.c
  rdopt_coding_state.c
  rdpicdecision.c
  refbuf.c
  rtp.c
  sei.c
  slice.c
  transform8x8.c
  vlc.c
  weighted_prediction.c
  specrand.c)


add_executable(${PROJECT_NAME} ${SOURCES})

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
  set(frag "${CMAKE_CURRENT_SOURCE_DIR}/${FRAGMENT}")
  if(EXISTS ${frag})
    include(${frag})
  endif()
endforeach()

