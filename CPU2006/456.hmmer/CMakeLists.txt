# cmake file

set(BMK_NAME "456.hmmer")
set(PROJECT_NAME "hmmer")

check_bmk_processing(hasSrcDir)

if(NOT ${hasSrcDir})
  message(STATUS "skipping project: ${PROJECT_NAME}") 
  return()
endif()

set(SOURCES
  alphabet.c
  core_algorithms.c
  debug.c
  display.c
  emit.c
  emulation.c
  fast_algorithms.c
  histogram.c
  hmmio.c
  hmmcalibrate.c
  hmmsearch.c
  mathsupport.c
  masks.c
  misc.c
  modelmakers.c
  plan7.c
  plan9.c
  postprob.c
  prior.c
  tophits.c
  trace.c 
  ucbqsort.c
  a2m.c
  aligneval.c
  alignio.c
  clustal.c
  cluster.c
  dayhoff.c
  eps.c
  file.c
  getopt.c
  gki.c
  gsi.c
  hsregex.c
  iupac.c
  msa.c
  msf.c
  phylip.c
  revcomp.c
  rk.c
  selex.c
  seqencode.c
  shuffle.c
  sqerror.c
  sqio.c
  squidcore.c
  sre_ctype.c
  sre_math.c
  sre_random.c
  sre_string.c
  ssi.c
  stack.c
  stockholm.c
  translate.c
  types.c
  vectorops.c
  weight.c)

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

