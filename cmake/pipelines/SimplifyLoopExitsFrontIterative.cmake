# cmake file

find_package(SimplifyLoopExitsFront CONFIG)

if(NOT SimplifyLoopExitsFront_FOUND)
  message(WARNING "package SimplifyLoopExitsFront was not found; skipping.")

  return()
endif()

get_target_property(SLEF_LIB_LOCATION LLVMSimplifyLoopExitsFrontPass LOCATION)
get_target_property(DEPENDEE LLVMSimplifyLoopExitsFrontPass DEPENDEE)

# configuration

macro(SimplifyLoopExitsFrontIterativePipelineSetup)
  set(PIPELINE_NAME "SimplifyLoopExitsFrontIterative")
  set(PIPELINE_INSTALL_TARGET "${PIPELINE_NAME}-install")
endmacro()


function(SimplifyLoopExitsFrontIterativePipeline trgt)
  SimplifyLoopExitsFrontIterativePipelineSetup()

  if(NOT TARGET ${PIPELINE_NAME})
    add_custom_target(${PIPELINE_NAME})
  endif()

  set(PIPELINE_SUBTARGET "${PIPELINE_NAME}_${trgt}")
  set(PIPELINE_PREFIX ${PIPELINE_SUBTARGET})

  set(DEPENDEE_TRGT "AnnotateLoops_${trgt}_opt2")

  ## pipeline targets and chaining

  set(LOAD_DEPENDENCY_CMDLINE_ARG "")
  if(DEPENDEE)
    foreach(dep ${DEPENDEE})
      list(APPEND LOAD_DEPENDENCY_CMDLINE_ARG -load;${dep})
    endforeach()
  endif()

  set(PIPELINE_INPUT_FILE
    "$ENV{HARNESS_INPUT_DIR}${BMK_NAME}/$ENV{SLEFI_LOOP_ID_WHITELIST_FILE}")

  set(LoopIDs "")
  if(EXISTS ${PIPELINE_INPUT_FILE})
    file(STRINGS ${PIPELINE_INPUT_FILE} LoopIDs)
  else()
    message(STATUS "could not find file: ${PIPELINE_INPUT_FILE}")
  endif()

  add_custom_target(${PIPELINE_SUBTARGET} DEPENDS ${DEPENDEE_TRGT})

  foreach(id ${LoopIDs})
    llvmir_attach_opt_pass_target(${PIPELINE_PREFIX}_link_${id}
      ${DEPENDEE_TRGT}
      ${LOAD_DEPENDENCY_CMDLINE_ARG}
      -load ${SLEF_LIB_LOCATION}
      -simplify-loop-exits-front
      -slef-loop-depth-ub=1
      -slef-loop-exiting-block-depth-ub=1
      -slef-loop-id=${id})
    add_dependencies(${PIPELINE_PREFIX}_link_${id} ${DEPENDEE_TRGT})

    llvmir_attach_executable(${PIPELINE_PREFIX}_bc_exe_${id} ${PIPELINE_PREFIX}_link_${id})
    add_dependencies(${PIPELINE_PREFIX}_bc_exe_${id} ${PIPELINE_PREFIX}_link_${id})

    target_link_libraries(${PIPELINE_PREFIX}_bc_exe_${id} m)

    ## pipeline aggregate targets
    add_dependencies(${PIPELINE_SUBTARGET} ${PIPELINE_PREFIX}_link_${id})
    add_dependencies(${PIPELINE_SUBTARGET} ${PIPELINE_PREFIX}_bc_exe_${id})
  endforeach()

  add_dependencies(${PIPELINE_NAME} ${PIPELINE_SUBTARGET})


  # installation
  get_property(bmk_name TARGET ${trgt} PROPERTY BMK_NAME)

  #InstallSimplifyLoopExitsFrontIterativePipelineLLVMIR(${PIPELINE_PREFIX}_link ${bmk_name})
endfunction()


function(InstallSimplifyLoopExitsFrontIterativePipelineLLVMIR pipeline_part_trgt bmk_name)
  SimplifyLoopExitsFrontIterativePipelineSetup()

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


