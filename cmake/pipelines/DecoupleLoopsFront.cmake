# cmake file

macro(DecoupleLoopsFrontPipelineSetupNames)
  set(PIPELINE_NAME "DecoupleLoopsFront")
  set(PIPELINE_INSTALL_TARGET "${PIPELINE_NAME}-install")
endmacro()


macro(DecoupleLoopsFrontPipelineSetup)
  DecoupleLoopsFrontPipelineSetupNames()

  message(STATUS "setting up pipeline DecoupleLoopsFront")

  if(NOT DEFINED ENV{HARNESS_REPORT_DIR})
    message(FATAL_ERROR
      "${PIPELINE_NAME} env variable HARNESS_REPORT_DIR is not defined")
  endif()

  file(TO_CMAKE_PATH $ENV{HARNESS_REPORT_DIR} HARNESS_REPORT_DIR)
  if(NOT EXISTS ${HARNESS_REPORT_DIR})
    file(MAKE_DIRECTORY ${HARNESS_REPORT_DIR})
  endif()

  message(STATUS
    "${PIPELINE_NAME} uses env variable: HARNESS_REPORT_DIR=${HARNESS_REPORT_DIR}")

  #

  find_package(DecoupleLoopsFront CONFIG)

  get_target_property(DLF_LIB_LOCATION LLVMDecoupleLoopsFrontPass LOCATION)
endmacro()

DecoupleLoopsFrontPipelineSetup()

#

function(DecoupleLoopsFrontPipeline trgt)
  DecoupleLoopsFrontPipelineSetupNames()

  if(NOT TARGET ${PIPELINE_NAME})
    add_custom_target(${PIPELINE_NAME})
  endif()

  set(PIPELINE_SUBTARGET "${PIPELINE_NAME}_${trgt}")
  set(PIPELINE_PREFIX ${PIPELINE_SUBTARGET})

  set(DEPENDEE_TRGT "AnnotateLoops_${trgt}_opt2")

  ## pipeline targets and chaining
  get_property(bmk_name TARGET ${trgt} PROPERTY BMK_NAME)
  file(TO_CMAKE_PATH ${HARNESS_REPORT_DIR} REPORT_DIR)
  file(TO_CMAKE_PATH ${REPORT_DIR}/${BMK_NAME} REPORT_DIR)
  file(MAKE_DIRECTORY ${REPORT_DIR})

  llvmir_attach_opt_pass_target(${PIPELINE_PREFIX}_le
    ${DEPENDEE_TRGT}
    -loop-extract)
  add_dependencies(${PIPELINE_PREFIX}_le ${DEPENDEE_TRGT})

  llvmir_attach_opt_pass_target(${PIPELINE_PREFIX}_dlf
    ${PIPELINE_PREFIX}_le
    -load ${DLF_LIB_LOCATION}
    -decouple-loops-front
    -dlf-debug
    -dlf-bb-annotate-type
    -dlf-bb-annotate-weight
    -dlf-bb-prefix-type
    -dlf-report ${HARNESS_REPORT_DIR}/${BMK_NAME}
    -dlf-dot-cfg-only
    -dlf-dot-dir ${REPORT_DIR})
  add_dependencies(${PIPELINE_PREFIX}_dlf ${PIPELINE_PREFIX}_le)

  llvmir_attach_executable(${PIPELINE_PREFIX}_bc_exe ${PIPELINE_PREFIX}_dlf)
  add_dependencies(${PIPELINE_PREFIX}_bc_exe ${PIPELINE_PREFIX}_dlf)

  target_link_libraries(${PIPELINE_PREFIX}_bc_exe m)

  ## pipeline aggregate targets
  add_custom_target(${PIPELINE_SUBTARGET} DEPENDS
    ${DEPENDEE_TRGT}
    ${PIPELINE_PREFIX}_le
    ${PIPELINE_PREFIX}_dlf
    ${PIPELINE_PREFIX}_bc_exe)

  add_dependencies(${PIPELINE_NAME} ${PIPELINE_SUBTARGET})


  # installation
  set(DEST_DIR "CPU2006/${bmk_name}")

  install(TARGETS ${PIPELINE_PREFIX}_bc_exe
    DESTINATION ${DEST_DIR} OPTIONAL)

  set(BMK_BIN_NAME "${PIPELINE_PREFIX}_bc_exe")

  set(BMK_BIN_PREAMBLE "")

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
  InstallDecoupleLoopsFrontPipelineLLVMIR(${PIPELINE_PREFIX}_le ${bmk_name})
endfunction()


function(InstallDecoupleLoopsFrontPipelineLLVMIR pipeline_part_trgt bmk_name)
  DecoupleLoopsFrontPipelineSetupNames()

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


