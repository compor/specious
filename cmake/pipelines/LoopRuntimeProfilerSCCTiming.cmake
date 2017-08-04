# cmake file

macro(LoopRuntimeProfilerSCCTimingPipelineSetupNames)
  set(PIPELINE_NAME "LoopRuntimeProfilerSCCTiming")
  set(PIPELINE_INSTALL_TARGET "${PIPELINE_NAME}-install")
endmacro()


macro(LoopRuntimeProfilerSCCTimingPipelineSetup)
  LoopRuntimeProfilerSCCTimingPipelineSetupNames()

  message(STATUS "setting up pipeline LoopRuntimeProfilerSCCTiming")

  if(NOT DEFINED ENV{HARNESS_INPUT_DIR})
    message(FATAL_ERROR
      "${PIPELINE_NAME} env variable HARNESS_INPUT_DIR is not defined")
  endif()

  if(NOT DEFINED ENV{HARNESS_REPORT_DIR})
    message(FATAL_ERROR
      "${PIPELINE_NAME} env variable HARNESS_REPORT_DIR is not defined")
  endif()

  if(NOT DEFINED ENV{LRP_LOOP_ID_WHITELIST_FILE})
    message(FATAL_ERROR
      "${PIPELINE_NAME} env variable LRP_LOOP_ID_WHITELIST_FILE is not defined")
  endif()

  if(NOT IS_DIRECTORY $ENV{HARNESS_INPUT_DIR})
    message(FATAL_ERROR "${PIPELINE_NAME} HARNESS_INPUT_DIR does not exist")
  endif()

  if(NOT IS_DIRECTORY $ENV{HARNESS_REPORT_DIR})
    message(FATAL_ERROR "${PIPELINE_NAME} HARNESS_REPORT_DIR does not exist")
  endif()

  message(STATUS
    "${PIPELINE_NAME} uses env variable: HARNESS_REPORT_DIR=$ENV{HARNESS_REPORT_DIR}")
  message(STATUS
    "${PIPELINE_NAME} uses env variable: HARNESS_INPUT_DIR=$ENV{HARNESS_INPUT_DIR}")
  message(STATUS
    "${PIPELINE_NAME} uses env variable: LRP_LOOP_ID_WHITELIST_FILE=$ENV{LRP_LOOP_ID_WHITELIST_FILE}")

  #

  find_package(LoopRuntimeProfiler CONFIG)

  if(NOT LoopRuntimeProfiler_FOUND)
    message(FATAL_ERROR
      "${PIPELINE_NAME} package LoopRuntimeProfiler was not found")
  endif()

  get_target_property(LRP_LIB_LOCATION LLVMLoopRuntimeProfilerPass LOCATION)
endmacro()

LoopRuntimeProfilerSCCTimingPipelineSetup()

#

function(LoopRuntimeProfilerSCCTimingPipeline trgt)
  LoopRuntimeProfilerSCCTimingPipelineSetupNames()

  if(NOT TARGET ${PIPELINE_NAME})
    add_custom_target(${PIPELINE_NAME})
  endif()

  set(PIPELINE_SUBTARGET "${PIPELINE_NAME}_${trgt}")
  set(PIPELINE_PREFIX ${PIPELINE_SUBTARGET})

  set(DEPENDEE_TRGT "SimplifyLoopExitsFront_${trgt}_link")

  ## pipeline targets and chaining

  file(TO_CMAKE_PATH
    "$ENV{HARNESS_INPUT_DIR}/${BMK_NAME}/$ENV{LRP_LOOP_ID_WHITELIST_FILE}"
    PIPELINE_INPUT_FILE)

  if(EXISTS ${PIPELINE_INPUT_FILE})
    set(PIPELINE_CMDLINE_ARG "-lrp-loop-id-whitelist=${PIPELINE_INPUT_FILE}")
  else()
    message(FATAL_ERROR "could not find file: ${PIPELINE_INPUT_FILE}")
  endif()

  file(TO_CMAKE_PATH "$ENV{HARNESS_REPORT_DIR}/${BMK_NAME}-${PIPELINE_NAME}"
    REPORT_FILE_PREFIX)

  llvmir_attach_opt_pass_target(${PIPELINE_PREFIX}_le
    ${DEPENDEE_TRGT}
    -loop-extract)
  add_dependencies(${PIPELINE_PREFIX}_le ${DEPENDEE_TRGT})

  llvmir_attach_opt_pass_target(${PIPELINE_PREFIX}_link
    ${PIPELINE_PREFIX}_le
    -load ${LRP_LIB_LOCATION}
    -loop-runtime-profiler
    -lrp-mode=cgscc
    -lrp-scc-start-id=3
    -lrp-scc-id-interval=5
    -lrp-report=${REPORT_FILE_PREFIX}
    ${PIPELINE_CMDLINE_ARG})
  add_dependencies(${PIPELINE_PREFIX}_link ${PIPELINE_PREFIX}_le)

  llvmir_attach_executable(${PIPELINE_PREFIX}_bc_exe ${PIPELINE_PREFIX}_link)
  add_dependencies(${PIPELINE_PREFIX}_bc_exe ${PIPELINE_PREFIX}_link)

  target_link_libraries(${PIPELINE_PREFIX}_bc_exe lrp_scc_timing_rt m)

  ## pipeline aggregate targets
  add_custom_target(${PIPELINE_SUBTARGET} DEPENDS
    ${DEPENDEE_TRGT}
    ${PIPELINE_PREFIX}_le
    ${PIPELINE_PREFIX}_link
    ${PIPELINE_PREFIX}_bc_exe)

  add_dependencies(${PIPELINE_NAME} ${PIPELINE_SUBTARGET})


  # installation
  get_property(bmk_name TARGET ${trgt} PROPERTY BMK_NAME)
  set(DEST_DIR "CPU2006/${bmk_name}")

  install(TARGETS ${PIPELINE_PREFIX}_bc_exe
    DESTINATION ${DEST_DIR} OPTIONAL)

  set(BMK_BIN_NAME "${PIPELINE_PREFIX}_bc_exe")

  get_filename_component(ABS_DATA_DIR data REALPATH)
  set(BMK_DATA_DIR "${PIPELINE_NAME}_data")

  install(DIRECTORY ${ABS_DATA_DIR}/ DESTINATION
    ${DEST_DIR}/${BMK_DATA_DIR})

  configure_file("scripts/run.sh.in" "scripts/${PIPELINE_PREFIX}_run.sh" @ONLY)

  install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/scripts/
    DESTINATION ${DEST_DIR}
    PATTERN "*.sh"
    PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE)

  # IR installation
  InstallLoopRuntimeProfilerSCCTimingPipelineLLVMIR(${PIPELINE_PREFIX}_link ${bmk_name})
endfunction()


function(InstallLoopRuntimeProfilerSCCTimingPipelineLLVMIR pipeline_part_trgt bmk_name)
  LoopRuntimeProfilerSCCTimingPipelineSetupNames()

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


