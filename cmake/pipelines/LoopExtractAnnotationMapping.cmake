# cmake file

macro(LoopExtractAnnotationMappingPipelineSetupNames)
  set(PIPELINE_NAME "LoopExtractAnnotationMapping")
  set(PIPELINE_INSTALL_TARGET "${PIPELINE_NAME}-install")
endmacro()


macro(LoopExtractAnnotationMappingPipelineSetup)
  LoopExtractAnnotationMappingPipelineSetupNames()

  message(STATUS "setting up pipeline LoopExtractAnnotationMapping")

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

  find_package(AnnotateLoops CONFIG)

  if(NOT AnnotateLoops_FOUND)
    message(FATAL_ERROR "package AnnotateLoops was not found")
  endif()

  get_target_property(ANNOTATELOOPS_LIB_LOCATION LLVMAnnotateLoopsPass LOCATION)
endmacro()

LoopExtractAnnotationMappingPipelineSetup()

#

function(LoopExtractAnnotationMappingPipeline trgt)
  LoopExtractAnnotationMappingPipelineSetupNames()

  if(NOT TARGET ${PIPELINE_NAME})
    add_custom_target(${PIPELINE_NAME})
  endif()

  set(PIPELINE_SUBTARGET "${PIPELINE_NAME}_${trgt}")
  set(PIPELINE_PREFIX ${PIPELINE_SUBTARGET})

  set(DEPENDEE_TRGT "AnnotateLoops_${trgt}_opt2")

  ## pipeline targets and chaining

  file(TO_CMAKE_PATH "$ENV{HARNESS_REPORT_DIR}/${BMK_NAME}-${PIPELINE_NAME}.txt"
    REPORT_FILE)

  llvmir_attach_opt_pass_target(${PIPELINE_PREFIX}_le
    ${DEPENDEE_TRGT}
    -loop-extract)
  add_dependencies(${PIPELINE_PREFIX}_le ${DEPENDEE_TRGT})

  llvmir_attach_opt_pass_target(${PIPELINE_PREFIX}_le_al
    ${PIPELINE_PREFIX}_le
    -load ${ANNOTATELOOPS_LIB_LOCATION}
    -annotate-loops
    -al-mode=read
    -al-stats=${REPORT_FILE})
  add_dependencies(${PIPELINE_PREFIX}_le_al ${PIPELINE_PREFIX}_le)

  llvmir_attach_executable(${PIPELINE_PREFIX}_bc_exe ${PIPELINE_PREFIX}_le_al)
  add_dependencies(${PIPELINE_PREFIX}_bc_exe ${PIPELINE_PREFIX}_le_al)

  target_link_libraries(${PIPELINE_PREFIX}_bc_exe m)

  ## pipeline aggregate targets
  add_custom_target(${PIPELINE_SUBTARGET} DEPENDS
    ${DEPENDEE_TRGT}
    ${PIPELINE_PREFIX}_le
    ${PIPELINE_PREFIX}_le_al
    ${PIPELINE_PREFIX}_bc_exe)

  add_dependencies(${PIPELINE_NAME} ${PIPELINE_SUBTARGET})


  # installation
  get_property(bmk_name TARGET ${trgt} PROPERTY BMK_NAME)
  set(DEST_DIR "CPU2006/${bmk_name}")

  install(TARGETS ${PIPELINE_PREFIX}_bc_exe
    DESTINATION ${DEST_DIR} OPTIONAL)

  set(BMK_BIN_NAME "${PIPELINE_PREFIX}_bc_exe")

  set(BMK_BIN_PREAMBLE
    "\"valgrind --tool=callgrind --callgrind-out-file=${BMK_BIN_NAME}.callgrind\"")

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
  InstallLoopExtractAnnotationMappingPipelineLLVMIR(${PIPELINE_PREFIX}_le_al
    ${bmk_name})
endfunction()


function(InstallLoopExtractAnnotationMappingPipelineLLVMIR pipeline_part_trgt bmk_name)
  LoopExtractAnnotationMappingPipelineSetupNames()

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


