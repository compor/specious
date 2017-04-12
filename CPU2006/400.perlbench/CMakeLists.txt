# cmake file

set(BMK_NAME "400.perlbench")
set(PROJECT_NAME "perlbench")

check_bmk_processing(hasSrcDir)

if(NOT ${hasSrcDir})
  message(STATUS "skipping project: ${PROJECT_NAME}") 
  return()
endif()

set(SOURCES
  av.c
  deb.c
  doio.c
  doop.c
  dump.c
  globals.c
  gv.c
  hv.c
  locale.c
  mg.c
  numeric.c
  op.c
  pad.c
  perl.c
  perlapi.c
  perlio.c
  perlmain.c
  perly.c
  pp.c
  pp_ctl.c
  pp_hot.c
  pp_pack.c
  pp_sort.c
  pp_sys.c
  regcomp.c
  regexec.c
  run.c
  scope.c
  sv.c
  taint.c
  toke.c
  universal.c
  utf8.c
  util.c
  xsutils.c
  Base64.c
  Cwd.c
  Dumper.c
  HiRes.c
  IO.c
  Peek.c
  attrs.c
  poll.c
  stdio.c
  DynaLoader.c
  MD5.c
  Storable.c
  Parser.c
  specrand.c
  Hostname.c
  Opcode.c)

add_prefix(SOURCES "${PROJECT_BMK_SOURCE_SUBDIR}/" "${SOURCES}")

add_executable(${PROJECT_NAME} ${SOURCES})

add_definitions(-DPERL_CORE)

target_include_directories(${PROJECT_NAME} PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_BMK_SOURCE_SUBDIR}")

target_link_libraries(${PROJECT_NAME} m)


# this property is required by our parasitic targets
set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE C)

# this property is used internally by our harness 
# because benchmark names and their main targets have different names
set_target_properties(${PROJECT_NAME} PROPERTIES BMK_NAME ${BMK_NAME})

if(COMMAND SetupBmkBasicInstall)
  SetupBmkBasicInstall(${PROJECT_NAME})
endif()

if(COMMAND AttachLoopC14NPipeline)
  AttachLoopC14NPipeline(${PROJECT_NAME})
endif()

