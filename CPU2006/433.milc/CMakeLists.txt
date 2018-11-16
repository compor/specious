# cmake file

set(BMK_NAME "433.milc")
set(BMK_PROJECT_NAME "milc")

check_bmk_processing(hasSrcDir)

if(NOT ${hasSrcDir})
  message(STATUS "skipping project: ${BMK_PROJECT_NAME}")
  return()
endif()


set(SOURCES
  control.c
  f_meas.c
  gauge_info.c
  setup.c
  update.c
  update_h.c
  update_u.c
  layout_hyper.c
  check_unitarity.c
  d_plaq4.c
  gaugefix2.c
  io_helpers.c
  io_lat4.c
  make_lattice.c
  path_product.c
  ploop3.c
  ranmom.c
  ranstuff.c
  reunitarize2.c
  gauge_stuff.c
  grsource_imp.c
  mat_invert.c
  quark_stuff.c
  rephase.c
  cmplx.c
  addmat.c
  addvec.c
  clear_mat.c
  clearvec.c
  m_amatvec.c
  m_mat_an.c
  m_mat_na.c
  m_mat_nn.c
  m_matvec.c
  make_ahmat.c
  rand_ahmat.c
  realtr.c
  s_m_a_mat.c
  s_m_a_vec.c
  s_m_s_mat.c
  s_m_vec.c
  s_m_mat.c
  su3_adjoint.c
  su3_dot.c
  su3_rdot.c
  su3_proj.c
  su3mat_copy.c
  submat.c
  subvec.c
  trace_su3.c
  uncmp_ahmat.c
  msq_su3vec.c
  sub4vecs.c
  m_amv_4dir.c
  m_amv_4vec.c
  m_mv_s_4dir.c
  m_su2_mat_vec_n.c
  l_su2_hit_n.c
  r_su2_hit_a.c
  m_su2_mat_vec_a.c
  gaussrand.c
  byterevn.c
  m_mat_hwvec.c
  m_amat_hwvec.c
  dslash_fn2.c
  d_congrad5_fn.c
  com_vanilla.c
  io_nonansi.c)

add_prefix(SOURCES "${HARNESS_BMK_SOURCE_SUBDIR}/" "${SOURCES}")

add_executable(${BMK_PROJECT_NAME} ${SOURCES})

target_compile_definitions(${BMK_PROJECT_NAME} PUBLIC -DCONGRAD_TMP_VECTORS)
target_compile_definitions(${BMK_PROJECT_NAME} PUBLIC -DDSLASH_TMP_LINKS)
target_compile_definitions(${BMK_PROJECT_NAME} PUBLIC -DFAST)
target_compile_definitions(${BMK_PROJECT_NAME} PUBLIC  -DFN)

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

