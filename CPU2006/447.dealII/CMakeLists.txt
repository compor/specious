# cmake file

set(BMK_NAME "447.dealII")
set(PROJECT_NAME "dealII")

set(SOURCES
  auto_derivative_function.cc
  block_sparse_matrix.cc
  block_sparse_matrix_ez.cc
  block_sparsity_pattern.cc
  block_vector.cc
  compressed_sparsity_pattern.cc
  data_out.cc
  data_out_base.cc
  data_out_faces.cc
  data_out_rotation.cc
  data_out_stack.cc
  derivative_approximation.cc
  dof_accessor.cc
  dof_constraints.cc
  dof_handler.cc
  dof_levels.cc
  dof_renumbering.cc
  dof_tools.cc
  error_estimator.cc
  exceptions.cc
  fe.cc
  fe_data.cc
  fe_dgp.cc
  fe_dgp_1d.cc
  fe_dgp_2d.cc
  fe_dgp_3d.cc
  fe_dgp_nonparametric.cc
  fe_dgq.cc
  fe_dgq_1d.cc
  fe_dgq_2d.cc
  fe_dgq_3d.cc
  fe_nedelec.cc
  fe_nedelec_1d.cc
  fe_nedelec_2d.cc
  fe_nedelec_3d.cc
  fe_q.cc
  fe_q_1d.cc
  fe_q_2d.cc
  fe_q_3d.cc
  fe_q_hierarchical.cc
  fe_raviart_thomas.cc
  fe_system.cc
  fe_tools.cc
  fe_values.cc
  filtered_matrix.cc
  full_matrix-double.cc
  full_matrix-float.cc
  function.cc
  function_derivative.cc
  function_lib.cc
  function_lib_cutoff.cc
  function_time.cc
  geometry_info.cc
  grid_generator.cc
  grid_in.cc
  grid_out-all_dimensions.cc
  grid_out.cc
  grid_refinement.cc
  grid_reordering.cc
  histogram.cc
  intergrid_map.cc
  job_identifier.cc
  log.cc
  mapping.cc
  mapping_c1.cc
  mapping_cartesian.cc
  mapping_q.cc
  mapping_q1.cc
  mapping_q1_eulerian.cc
  matrices-all_dimensions.cc
  matrices.cc
  matrix_lib.cc
  matrix_out.cc
  memory_consumption.cc
  mg_base.cc
  mg_dof_accessor.cc
  mg_dof_handler.cc
  mg_dof_tools.cc
  mg_smoother.cc
  mg_transfer_block.cc
  mg_transfer_prebuilt.cc
  mg_transfer_block-all_dimensions.cc
  multigrid.all_dimensions.cc
  multithread_info.cc
  parameter_handler.cc
  persistent_tria.cc
  polynomial.cc
  polynomial_space.cc
  programid.cc
  quadrature.cc
  quadrature_lib.cc
  solution_transfer.cc
  solver_control.cc
  sparse_matrix-double.cc
  sparse_matrix-float.cc
  sparse_matrix_ez-double.cc
  sparse_matrix_ez-float.cc
  sparsity_pattern.cc
  step-14.cc
  subscriptor.cc
  swappable_vector.cc
  tensor.cc
  tensor_product_polynomials.cc
  tria-all_dimensions.cc
  tria.cc
  tria_accessor.cc
  tria_boundary.cc
  tria_boundary_lib.cc
  vector.cc
  vector-long_double.cc
  vectors.cc
  vectors-all_dimensions.cc
  fe_dgp_monomial.cc
  fe_poly.cc
  polynomials_bdm.cc
  polynomials_p.cc)

add_executable(${PROJECT_NAME} ${SOURCES})

# this property is required by our parasitic targets
set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE CXX)

add_definitions(-DBOOST_DISABLE_THREADS)
add_definitions(-Ddeal_II_dimension=3)

target_include_directories(${PROJECT_NAME} PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/")
target_include_directories(${PROJECT_NAME} PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/include/")

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
  if(EXISTS ${FRAGMENT})
    include(${FRAGMENT})
  endif()
endforeach()

