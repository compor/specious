# cmake file

set(BMK_NAME "464.h264ref")
set(PROJECT_NAME "h264ref")

check_bmk_processing(hasSrcDir)

if(NOT ${hasSrcDir})
  message(STATUS "skipping project: ${PROJECT_NAME}") 
  return()
endif()

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

add_prefix(SOURCES "${PROJECT_BMK_SOURCE_SUBDIR}/" "${SOURCES}")

add_executable(${PROJECT_NAME} ${SOURCES})

target_include_directories(${PROJECT_NAME} PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_BMK_SOURCE_SUBDIR}")

target_link_libraries(${PROJECT_NAME} m)


# this property is required by our parasitic targets
set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE C)

# this property is used internally by our harness 
# because benchmark names and their main targets have different names
set_target_properties(${PROJECT_NAME} PROPERTIES BMK_NAME ${BMK_NAME})


foreach(FRAGMENT ${PROJECT_CMAKE_FRAGMENT_FILES})
  include(${FRAGMENT})
endforeach()

