# cmake file

find_package(SimplifyLoopExits CONFIG)

if(NOT SimplifyLoopExits_FOUND)
  message(WARNING "package ClassifyLoops was not found; skipping.")

  return()
endif()

get_target_property(SLE_LIB_LOCATION LLVMSimplifyLoopExitsPass LOCATION)
get_target_property(DEPENDEE LLVMSimplifyLoopExitsPass DEPENDEE)

# configuration

macro(SimplifyLoopExitsWithIdPipelineSetup)
  set(PIPELINE_NAME "SimplifyLoopExitsWithId")
  set(PIPELINE_INSTALL_TARGET "${PIPELINE_NAME}-install")
endmacro()


function(SimplifyLoopExitsWithIdPipeline trgt)
  SimplifyLoopExitsWithIdPipelineSetup()

  if(NOT TARGET ${PIPELINE_NAME})
    add_custom_target(${PIPELINE_NAME})
  endif()

  set(PIPELINE_SUBTARGET "${PIPELINE_NAME}_${trgt}")
  set(PIPELINE_PREFIX ${PIPELINE_SUBTARGET})

  set(DEPENDEE_TRGT "AnnotateLoops_${trgt}_opt2")

  ## pipeline targets and chaining
  llvmir_attach_bc_target(${PIPELINE_PREFIX}_bc ${trgt})
  add_dependencies(${PIPELINE_PREFIX}_bc ${trgt})

  llvmir_attach_opt_pass_target(${PIPELINE_PREFIX}_opt1
    ${PIPELINE_PREFIX}_bc
    -mem2reg
    -mergereturn
    -simplifycfg
    -loop-simplify)
  add_dependencies(${PIPELINE_PREFIX}_opt1 ${PIPELINE_PREFIX}_bc)

  llvmir_attach_link_target(${PIPELINE_PREFIX}_link ${PIPELINE_PREFIX}_opt1)
  add_dependencies(${PIPELINE_PREFIX}_link ${PIPELINE_PREFIX}_opt1)

  set(LOAD_DEPENDENCY_CMDLINE_ARG "")
  if(DEPENDEE)
    foreach(dep ${DEPENDEE})
      list(APPEND LOAD_DEPENDENCY_CMDLINE_ARG -load;${dep})
    endforeach()
  endif()

  llvmir_attach_opt_pass_target(${PIPELINE_PREFIX}_link
    ${DEPENDEE_TRGT}
    ${LOAD_DEPENDENCY_CMDLINE_ARG}
    -load ${SLE_LIB_LOCATION}
    -simplify-loop-exits
    -slef-loop-depth-ub=1
    -slef-loop-exiting-block-depth-ub=1
    -slef-stats=${HARNESS_REPORT_DIR}/${BMK_NAME}-${PIPELINE_NAME}.txt)
  add_dependencies(${PIPELINE_PREFIX}_opt2 ${PIPELINE_PREFIX}_link)

  llvmir_attach_executable(${PIPELINE_PREFIX}_bc_exe ${PIPELINE_PREFIX}_link)
  add_dependencies(${PIPELINE_PREFIX}_bc_exe ${PIPELINE_PREFIX}_link)

  target_link_libraries(${PIPELINE_PREFIX}_bc_exe m)

  ## pipeline aggregate targets
  add_custom_target(${PIPELINE_SUBTARGET} DEPENDS
    ${DEPENDEE_TRGT}
    ${PIPELINE_PREFIX}_link
    ${PIPELINE_PREFIX}_bc_exe)

  add_dependencies(${PIPELINE_NAME} ${PIPELINE_SUBTARGET})


  # installation
  get_property(bmk_name TARGET ${trgt} PROPERTY BMK_NAME)

  InstallSimplifyLoopExitsWithIdPipelineLLVMIR(${PIPELINE_PREFIX}_link ${bmk_name})
endfunction()


function(InstallSimplifyLoopExitsWithIdPipelineLLVMIR pipeline_part_trgt bmk_name)
  SimplifyLoopExitsWithIdPipelineSetup()

  if(NOT TARGET ${PIPELINE_INSTALL_TARGET})
    add_custom_target(${PIPELINE_INSTALL_TARGET})
  endif()

  get_property(llvmir_dir TARGET ${pipeline_part_trgt} PROPERTY LLVMIR_DIR)

  # strip trailing slashes
  string(REGEX REPLACE "(.*[^/]+)(//*)$" "\\1" llvmir_stripped_dir ${llvmir_dir})
  get_filename_component(llvmir_part_dir ${llvmir_stripped_dir} NAME)

  set(PIPELINE_DEST_SUBDIR
    ${CMAKE_INSTALL_PREFIX}/CPU2006/${bmk_name}/llvm-ir/${llvmir_part_dir})

  set(PIPELINE_PART_INSTALL_TARGET "${pipeline_part_trgt}-install")

  add_custom_target(${PIPELINE_PART_INSTALL_TARGET}
    COMMAND ${CMAKE_COMMAND} -E
    copy_directory ${llvmir_dir} ${PIPELINE_DEST_SUBDIR})

  add_dependencies(${PIPELINE_PART_INSTALL_TARGET} ${pipeline_part_trgt})
  add_dependencies(${PIPELINE_INSTALL_TARGET} ${PIPELINE_PART_INSTALL_TARGET})
endfunction()


