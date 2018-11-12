# cmake file

set(BMK_NAME "482.sphinx3")
set(BMK_PROJECT_NAME "sphinx3")

check_bmk_processing(hasSrcDir)

if(NOT ${hasSrcDir})
  message(STATUS "skipping project: ${BMK_PROJECT_NAME}")
  return()
endif()

set(SOURCES
  spec_main_live_pretend.c
  parse_args_file.c
  live.c
  agc.c
  approx_cont_mgau.c
  ascr.c
  beam.c
  bio.c
  case.c
  ckd_alloc.c
  cmd_ln.c
  cmn.c
  cmn_prior.c
  cont_mgau.c
  dict.c
  dict2pid.c
  err.c
  feat.c
  fillpen.c
  glist.c
  gs.c
  hash.c
  heap.c
  hmm.c
  io.c
  kb.c
  kbcore.c
  lextree.c
  lm.c
  lmclass.c
  logs3.c
  mdef.c
  new_fe.c
  new_fe_sp.c
  profile.c
  specrand.c
  str2words.c
  subvq.c
  tmat.c
  unlimit.c
  utt.c
  vector.c
  vithist.c
  wid.c)

add_prefix(SOURCES "${HARNESS_BMK_SOURCE_SUBDIR}/" "${SOURCES}")

add_executable(${BMK_PROJECT_NAME} ${SOURCES})

target_compile_definitions(${BMK_PROJECT_NAME} PUBLIC -DHAVE_CONFIG_H)

target_include_directories(${BMK_PROJECT_NAME} PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/${HARNESS_BMK_SOURCE_SUBDIR}")
target_include_directories(${BMK_PROJECT_NAME} PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/${HARNESS_BMK_SOURCE_SUBDIR}/libutil")

target_link_libraries(${BMK_PROJECT_NAME} m)


# this property is required by our parasitic targets
set_target_properties(${BMK_PROJECT_NAME} PROPERTIES LINKER_LANGUAGE C)

# this property is used internally by our harness
# because benchmark names and their main targets have different names
set_target_properties(${BMK_PROJECT_NAME} PROPERTIES BMK_NAME ${BMK_NAME})


foreach(FRAGMENT ${HARNESS_CMAKE_FRAGMENT_FILES})
  include(${FRAGMENT})
endforeach()

