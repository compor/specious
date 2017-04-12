# cmake file fragment

# configuration

set(PIPELINE_NAME "loopc14n")
add_custom_target(${PIPELINE_NAME})

set(PIPELINE_INSTALL_TARGET "${PIPELINE_NAME}-install")
add_custom_target(${PIPELINE_INSTALL_TARGET})


function(AttachLoopC14NPipeline trgt)
  set(PIPELINE_SUBTARGET "${PIPELINE_NAME}_${trgt}")
  set(PIPELINE_PREFIX ${PIPELINE_SUBTARGET})

  ## pipeline targets and chaining
  attach_llvmir_bc_target(${PIPELINE_PREFIX}_bc ${trgt})
  add_dependencies(${PIPELINE_PREFIX}_bc ${trgt})

  attach_llvmir_opt_pass_target(${PIPELINE_PREFIX}_opt
    ${PIPELINE_PREFIX}_bc
    -mem2reg
    -mergereturn
    -simplifycfg
    -loop-simplify)
  add_dependencies(${PIPELINE_PREFIX}_opt ${PIPELINE_PREFIX}_bc)

  attach_llvmir_link_target(${PIPELINE_PREFIX}_link ${PIPELINE_PREFIX}_opt)
  add_dependencies(${PIPELINE_PREFIX}_link ${PIPELINE_PREFIX}_opt)

  attach_llvmir_executable(${PIPELINE_PREFIX}_bc_exe ${PIPELINE_PREFIX}_link)
  add_dependencies(${PIPELINE_PREFIX}_bc_exe ${PIPELINE_PREFIX}_link)

  target_link_libraries(${PIPELINE_PREFIX}_bc_exe m)

  ## pipeline aggregate targets
  add_custom_target(${PIPELINE_SUBTARGET} DEPENDS
    ${PIPELINE_PREFIX}_bc
    ${PIPELINE_PREFIX}_opt
    ${PIPELINE_PREFIX}_link
    ${PIPELINE_PREFIX}_bc_exe)

  add_dependencies(${PIPELINE_NAME} ${PIPELINE_SUBTARGET})


  # installation
  get_property(bmk_name TARGET ${trgt} PROPERTY BMK_NAME)
  get_property(llvmir_dir TARGET ${PIPELINE_PREFIX}_link PROPERTY LLVMIR_DIR)

  set(PIPELINE_INSTALL_SUBTARGET "${PIPELINE_NAME}_${trgt}-install")
  set(PIPELINE_DEST_SUBDIR ${CMAKE_INSTALL_PREFIX}/CPU2006/${bmk_name}/llvm-ir)

  add_custom_target(${PIPELINE_INSTALL_SUBTARGET}
    COMMAND ${CMAKE_COMMAND} -E
    copy_directory ${llvmir_dir} ${PIPELINE_DEST_SUBDIR})

  add_dependencies(${PIPELINE_INSTALL_TARGET} ${PIPELINE_INSTALL_SUBTARGET})
endfunction()

