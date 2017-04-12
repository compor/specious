# cmake file

set(BMK_NAME "482.sphinx3")
set(PROJECT_NAME "sphinx3")

check_bmk_processing(hasSrcDir)

if(NOT ${hasSrcDir})
  message(STATUS "skipping project: ${PROJECT_NAME}") 
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

add_prefix(SOURCES "${PROJECT_BMK_SOURCE_SUBDIR}/" "${SOURCES}")

add_executable(${PROJECT_NAME} ${SOURCES})

add_definitions(-DHAVE_CONFIG_H)

# this property is required by our parasitic targets
set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE C)

target_include_directories(${PROJECT_NAME} PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_BMK_SOURCE_SUBDIR}")
target_include_directories(${PROJECT_NAME} PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_BMK_SOURCE_SUBDIR}/libutil")

target_link_libraries(${PROJECT_NAME} m)


include_fragments("${PROJECT_CMAKE_FRAGMENT_FILES}")

