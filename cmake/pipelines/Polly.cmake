# cmake file

message(STATUS "setting up pipeline Polly")

if("$ENV{POLLY_LIB_LOCATION}" STREQUAL "")
  message(WARNING "package Polly was not found; skipping.")
  message(WARNING "POLLY_LIB_LOCATION was not set; skipping.")

  return()
endif()

# configuration

macro(PollyPipelineSetup)
  set(PIPELINE_NAME "Polly")
  set(PIPELINE_INSTALL_TARGET "${PIPELINE_NAME}-install")
endmacro()


function(PollyPipeline trgt)
  PollyPipelineSetup()

  if(NOT TARGET ${PIPELINE_NAME})
    add_custom_target(${PIPELINE_NAME})
  endif()

  set(PIPELINE_SUBTARGET "${PIPELINE_NAME}_${trgt}")
  set(PIPELINE_PREFIX ${PIPELINE_SUBTARGET})

  set(DEPENDEE_TRGT "LoopC14N_${trgt}_link")

  ## pipeline targets and chaining

  llvmir_attach_opt_pass_target(${PIPELINE_PREFIX}_link
    ${DEPENDEE_TRGT}
    -load $ENV{POLLY_LIB_LOCATION}
    -polly-canonicalize
    -polly-export-jscop)
  add_dependencies(${PIPELINE_PREFIX}_link ${DEPENDEE_TRGT})

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

  InstallPollyPipelineLLVMIR(${PIPELINE_PREFIX}_link ${bmk_name})
endfunction()


function(InstallPollyPipelineLLVMIR pipeline_part_trgt bmk_name)
  PollyPipelineSetup()

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

