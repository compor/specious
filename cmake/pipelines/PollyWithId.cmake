# cmake file

macro(PollyWithIdPipelineSetupNames)
  set(PIPELINE_NAME "PollyWithId")
  set(PIPELINE_INSTALL_TARGET "${PIPELINE_NAME}-install")
endmacro()

macro(PollyWithIdPipelineSetup)
  PollyWithIdPipelineSetupNames()

  message(STATUS "setting up pipeline ${PIPELINE_NAME}")

  if(NOT DEFINED ENV{HARNESS_REPORT_DIR})
    message(FATAL_ERROR
      "${PIPELINE_NAME} env variable HARNESS_REPORT_DIR is not defined")
  endif()

  if(NOT IS_DIRECTORY $ENV{HARNESS_REPORT_DIR})
    message(FATAL_ERROR "${PIPELINE_NAME} HARNESS_REPORT_DIR does not exist")
  endif()

  message(STATUS
    "${PIPELINE_NAME} uses env variable: HARNESS_REPORT_DIR=$ENV{HARNESS_REPORT_DIR}")

  #

  find_package(LLVMPolly REQUIRED)

  if(NOT LLVMPOLLY_FOUND)
    message(FATAL_ERROR "$PIPELINE_NAME} package Polly was not found")
  endif()
endmacro()

PollyWithIdPipelineSetup()

#

function(PollyWithIdPipeline trgt)
  PollyWithIdPipelineSetupNames()

  if(NOT TARGET ${PIPELINE_NAME})
    add_custom_target(${PIPELINE_NAME})
  endif()

  set(PIPELINE_SUBTARGET "${PIPELINE_NAME}_${trgt}")
  set(PIPELINE_PREFIX ${PIPELINE_SUBTARGET})

  set(DEPENDEE_TRGT "AnnotateLoops_${trgt}_opt2")

  ## pipeline targets and chaining

  file(TO_CMAKE_PATH "$ENV{HARNESS_REPORT_DIR}/${BMK_NAME}-${PIPELINE_NAME}.txt"
    REPORT_FILE)

  llvmir_attach_opt_pass_target(${PIPELINE_PREFIX}_link
    ${DEPENDEE_TRGT}
    -load ${LLVMPOLLY_SHARED_LIBRARY}
    -polly-canonicalize
    -polly-scops
    -polly-export-jscop
    -polly-codegen
    -polly-parallel
    -polly-export-parallel-id-loops=${REPORT_FILE})
  add_dependencies(${PIPELINE_PREFIX}_link ${DEPENDEE_TRGT})

  # do not produce binary because we need to link against a parallel lib
  #llvmir_attach_executable(${PIPELINE_PREFIX}_bc_exe ${PIPELINE_PREFIX}_link)
  #add_dependencies(${PIPELINE_PREFIX}_bc_exe ${PIPELINE_PREFIX}_link)
  #target_link_libraries(${PIPELINE_PREFIX}_bc_exe m)

  ## pipeline aggregate targets
  add_custom_target(${PIPELINE_SUBTARGET} DEPENDS
    ${DEPENDEE_TRGT}
    ${PIPELINE_PREFIX}_link)

  add_dependencies(${PIPELINE_NAME} ${PIPELINE_SUBTARGET})


  # installation
  get_property(bmk_name TARGET ${trgt} PROPERTY BMK_NAME)

  InstallPollyWithIdPipelineLLVMIR(${PIPELINE_PREFIX}_link ${bmk_name})
endfunction()


function(InstallPollyWithIdPipelineLLVMIR pipeline_part_trgt bmk_name)
  PollyWithIdPipelineSetupNames()

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

