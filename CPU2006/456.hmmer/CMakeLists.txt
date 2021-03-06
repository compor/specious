# cmake file

set(BMK_NAME "456.hmmer")
set(BMK_PROJECT_NAME "hmmer")

check_bmk_processing(hasSrcDir)

if(NOT ${hasSrcDir})
  message(STATUS "skipping project: ${BMK_PROJECT_NAME}")
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

add_prefix(SOURCES "${HARNESS_BMK_SOURCE_SUBDIR}/" "${SOURCES}")

add_executable(${BMK_PROJECT_NAME} ${SOURCES})

target_include_directories(${BMK_PROJECT_NAME} PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/${HARNESS_BMK_SOURCE_SUBDIR}")

target_link_libraries(${BMK_PROJECT_NAME} m)


set_target_properties(${BMK_PROJECT_NAME}
  PROPERTIES LINKER_LANGUAGE C # existing property required by harness
  BMK_NAME ${BMK_NAME} # optional custom property used by our harness
  RUNTIME_OUTPUT_DIRECTORY exe
  )


foreach(FRAGMENT ${HARNESS_CMAKE_FRAGMENT_FILES})
  include(${FRAGMENT})
endforeach()

