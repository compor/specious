# cmake file

set(PROJECT_NAME "hmmer")

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

add_executable(${PROJECT_NAME} ${SOURCES})

# this property is required by our parasitic targets
set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE C)

target_include_directories(${PROJECT_NAME} PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/")

target_link_libraries(${PROJECT_NAME} m)

# attachments on first target

if(${USE_LLVM})
  attach_llvmir_target(${PROJECT_NAME}_bc ${PROJECT_NAME})

  include(CMakeLists-additional.txt)

  attach_llvmir_executable(${PROJECT_NAME}_bc_exe ${PROJECT_NAME}_link)
  target_link_libraries(${PROJECT_NAME}_bc_exe m)
endif()

