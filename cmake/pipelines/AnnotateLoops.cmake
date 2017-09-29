# cmake file

macro(AnnotateLoopsPipelineSetupNames)
  set(PIPELINE_NAME "AnnotateLoops")
  set(PIPELINE_INSTALL_TARGET "${PIPELINE_NAME}-install")
endmacro()

macro(AnnotateLoopsPipelineSetup)
  AnnotateLoopsPipelineSetupNames()

  message(STATUS "setting up pipeline ${PIPELINE_NAME}")

  if(NOT DEFINED ENV{HARNESS_INPUT_DIR})
    message(FATAL_ERROR
      "${PIPELINE_NAME} env variable HARNESS_INPUT_DIR is not defined")
  endif()

  if(NOT DEFINED ENV{HARNESS_REPORT_DIR})
    message(FATAL_ERROR
      "${PIPELINE_NAME} env variable HARNESS_REPORT_DIR is not defined")
  endif()

  if(NOT DEFINED ENV{ANNOTATELOOPS_WHITELIST_FILE})
    message(FATAL_ERROR
      "${PIPELINE_NAME} env variable ANNOTATELOOPS_WHITELIST_FILE is not defined")
  endif()

  file(TO_CMAKE_PATH $ENV{HARNESS_INPUT_DIR} HARNESS_INPUT_DIR)
  if(NOT IS_DIRECTORY ${HARNESS_INPUT_DIR})
    message(FATAL_ERROR "${PIPELINE_NAME} HARNESS_INPUT_DIR does not exist")
  endif()

  file(TO_CMAKE_PATH $ENV{HARNESS_REPORT_DIR} HARNESS_REPORT_DIR)
  if(NOT EXISTS ${HARNESS_REPORT_DIR})
    file(MAKE_DIRECTORY ${HARNESS_REPORT_DIR})
  endif()

  message(STATUS
    "${PIPELINE_NAME} uses env variable: HARNESS_INPUT_DIR=${HARNESS_INPUT_DIR}")
  message(STATUS
    "${PIPELINE_NAME} uses env variable: HARNESS_REPORT_DIR=${HARNESS_REPORT_DIR}")
  message(STATUS
    "${PIPELINE_NAME} uses env variable: ANNOTATELOOPS_WHITELIST_FILE=$ENV{ANNOTATELOOPS_WHITELIST_FILE}")

  #

  find_package(AnnotateLoops CONFIG)

  if(NOT AnnotateLoops_FOUND)
    message(FATAL_ERROR "package AnnotateLoops was not found")
  endif()

  get_target_property(ANNOTATELOOPS_LIB_LOCATION LLVMAnnotateLoopsPass LOCATION)
endmacro()

AnnotateLoopsPipelineSetup()

#

function(AnnotateLoopsPipeline trgt)
  AnnotateLoopsPipelineSetupNames()

  if(NOT TARGET ${PIPELINE_NAME})
    add_custom_target(${PIPELINE_NAME})
  endif()

  set(PIPELINE_SUBTARGET "${PIPELINE_NAME}_${trgt}")
  set(PIPELINE_PREFIX ${PIPELINE_SUBTARGET})

  ## pipeline targets and chaining

  file(TO_CMAKE_PATH "${HARNESS_REPORT_DIR}/${BMK_NAME}-${PIPELINE_NAME}.txt"
    REPORT_FILE)

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

  get_target_property(LINKER_LANG ${PIPELINE_PREFIX}_link LINKER_LANGUAGE)

  file(TO_CMAKE_PATH
    "${HARNESS_INPUT_DIR}/${BMK_NAME}/$ENV{ANNOTATELOOPS_WHITELIST_FILE}"
    PIPELINE_INPUT_FILE)

  if(LINK_LANGUAGE EQUAL "CXX")
    if(EXISTS ${PIPELINE_INPUT_FILE})
      set(PIPELINE_CMDLINE_ARG "-al-fn-whitelist=${PIPELINE_INPUT_FILE}")
    else()
      message(STATUS "could not find file: ${PIPELINE_INPUT_FILE}")
    endif()
  endif()

  llvmir_attach_opt_pass_target(${PIPELINE_PREFIX}_opt2
    ${PIPELINE_PREFIX}_link
    -load ${ANNOTATELOOPS_LIB_LOCATION}
    -annotate-loops
    -al-loop-start-id=2
    -al-loop-id-interval=4
    -al-stats=${REPORT_FILE}
    ${PIPELINE_CMDLINE_ARG})
  add_dependencies(${PIPELINE_PREFIX}_opt2 ${PIPELINE_PREFIX}_link)

  llvmir_attach_executable(${PIPELINE_PREFIX}_bc_exe ${PIPELINE_PREFIX}_opt2)
  add_dependencies(${PIPELINE_PREFIX}_bc_exe ${PIPELINE_PREFIX}_opt2)

  target_link_libraries(${PIPELINE_PREFIX}_bc_exe m)

  ## pipeline aggregate targets
  add_custom_target(${PIPELINE_SUBTARGET} DEPENDS
    ${PIPELINE_PREFIX}_bc
    ${PIPELINE_PREFIX}_opt1
    ${PIPELINE_PREFIX}_link
    ${PIPELINE_PREFIX}_opt2
    ${PIPELINE_PREFIX}_bc_exe)

  add_dependencies(${PIPELINE_NAME} ${PIPELINE_SUBTARGET})


  # installation
  get_property(bmk_name TARGET ${trgt} PROPERTY BMK_NAME)

  InstallAnnotateLoopsPipelineLLVMIR(${PIPELINE_PREFIX}_link ${bmk_name})
endfunction()


function(InstallAnnotateLoopsPipelineLLVMIR pipeline_part_trgt bmk_name)
  AnnotateLoopsPipelineSetupNames()

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


