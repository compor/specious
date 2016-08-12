# cmake file

set(BMK_NAME "400.perlbench")
set(PROJECT_NAME "perlbench")

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

add_executable(${PROJECT_NAME} ${SOURCES})

add_definitions(-DPERL_CORE)

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

