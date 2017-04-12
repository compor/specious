# cmake file

set(BMK_NAME "453.povray")
set(PROJECT_NAME povray)

check_bmk_processing(hasSrcDir)

if(NOT ${hasSrcDir})
  message(STATUS "skipping project: ${PROJECT_NAME}") 
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


add_prefix(SOURCES "${PROJECT_BMK_SOURCE_SUBDIR}/" "${SOURCES}")

add_executable(${PROJECT_NAME} ${SOURCES})

target_include_directories(${PROJECT_NAME} PUBLIC 
  "${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_BMK_SOURCE_SUBDIR}/")

target_link_libraries(${PROJECT_NAME} m)


# this property is required by our parasitic targets
set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE CXX)

# this property is used internally by our harness 
# because benchmark names and their main targets have different names
set_target_properties(${PROJECT_NAME} PROPERTIES BMK_NAME ${BMK_NAME})

if(COMMAND SetupBmkBasicInstall)
  SetupBmkBasicInstall(${PROJECT_NAME})
endif()

if(COMMAND AttachLoopC14NPipeline)
  AttachLoopC14NPipeline(${PROJECT_NAME})
endif()

