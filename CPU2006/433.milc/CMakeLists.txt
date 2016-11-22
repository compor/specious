# cmake file

set(BMK_NAME "433.milc")
set(PROJECT_NAME "milc")

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

add_prefix(SOURCES "${BENCHMARK_SOURCE_DIR}/" "${SOURCES}")

add_executable(${PROJECT_NAME} ${SOURCES})

add_definitions(-DCONGRAD_TMP_VECTORS)
add_definitions(-DDSLASH_TMP_LINKS)
add_definitions(-DFAST)
add_definitions(-DFN)

# this property is required by our parasitic targets
set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE C)

target_include_directories(${PROJECT_NAME} PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/${BENCHMARK_SOURCE_DIR}")

target_link_libraries(${PROJECT_NAME} m)


include_fragments("${PROJECT_CMAKE_FRAGMENT_FILES}")

