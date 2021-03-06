# cmake file

set(BMK_NAME "453.povray")
set(BMK_PROJECT_NAME povray)

check_bmk_processing(hasSrcDir)

if(NOT ${hasSrcDir})
  message(STATUS "skipping project: ${BMK_PROJECT_NAME}")
  return()
endif()

set(SOURCES
  atmosph.cpp
  bbox.cpp
  bcyl.cpp
  bezier.cpp
  blob.cpp
  boxes.cpp
  bsphere.cpp
  camera.cpp
  chi2.cpp
  colour.cpp
  colutils.cpp
  cones.cpp
  csg.cpp
  defaultplatformbase.cpp
  defaultrenderfrontend.cpp
  discs.cpp
  express.cpp
  fileinputoutput.cpp
  fncode.cpp
  fnintern.cpp
  fnpovfpu.cpp
  fnsyntax.cpp
  fpmetric.cpp
  fractal.cpp
  function.cpp
  hcmplx.cpp
  hfield.cpp
  histogra.cpp
  iff.cpp
  image.cpp
  interior.cpp
  isosurf.cpp
  lathe.cpp
  lbuffer.cpp
  lightgrp.cpp
  lighting.cpp
  mathutil.cpp
  matrices.cpp
  media.cpp
  mesh.cpp
  messageoutput.cpp
  normal.cpp
  objects.cpp
  octree.cpp
  optout.cpp
  parse.cpp
  parsestr.cpp
  parstxtr.cpp
  pattern.cpp
  pgm.cpp
  photons.cpp
  pigment.cpp
  planes.cpp
  point.cpp
  poly.cpp
  polygon.cpp
  polysolv.cpp
  pov_mem.cpp
  pov_util.cpp
  povms.cpp
  povmscpp.cpp
  povmsend.cpp
  povmsrec.cpp
  povray.cpp
  ppm.cpp
  prism.cpp
  processoptions.cpp
  processrenderoptions.cpp
  quadrics.cpp
  quatern.cpp
  rad_data.cpp
  radiosit.cpp
  ray.cpp
  rendctrl.cpp
  render.cpp
  renderfrontend.cpp
  renderio.cpp
  sor.cpp
  specrand.cpp
  spec_qsort.cpp
  spheres.cpp
  sphsweep.cpp
  splines.cpp
  statspov.cpp
  stringutilities.cpp
  super.cpp
  targa.cpp
  textstream.cpp
  textstreambuffer.cpp
  texture.cpp
  tokenize.cpp
  torus.cpp
  triangle.cpp
  truetype.cpp
  txttest.cpp
  userdisp.cpp
  userio.cpp
  vbuffer.cpp
  vlbuffer.cpp
  warps.cpp)


add_prefix(SOURCES "${HARNESS_BMK_SOURCE_SUBDIR}/" "${SOURCES}")

add_executable(${BMK_PROJECT_NAME} ${SOURCES})

target_include_directories(${BMK_PROJECT_NAME} PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/${HARNESS_BMK_SOURCE_SUBDIR}/")

if(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
  target_compile_definitions(${BMK_PROJECT_NAME} PUBLIC -DSPEC_CPU_LP64)
elseif(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "i686")
  #
else()
  #
endif()

target_link_libraries(${BMK_PROJECT_NAME} m)


set_target_properties(${BMK_PROJECT_NAME}
  PROPERTIES LINKER_LANGUAGE CXX # existing property required by harness
  BMK_NAME ${BMK_NAME} # optional custom property used by our harness
  RUNTIME_OUTPUT_DIRECTORY exe
  )


foreach(FRAGMENT ${HARNESS_CMAKE_FRAGMENT_FILES})
  include(${FRAGMENT})
endforeach()

