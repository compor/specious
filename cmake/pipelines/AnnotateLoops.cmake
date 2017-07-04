# cmake file

find_package(AnnotateLoops CONFIG)

if(NOT AnnotateLoops_FOUND)
  message(WARNING "package AnnotateLoops was not found; skipping.")

  return()
endif()

get_target_property(ANNOTLOOPS_LIB_LOCATION LLVMAnnotateLoopsPass LOCATION)

# configuration

macro(AnnotateLoopsPipelineSetup)
  set(PIPELINE_NAME "AnnotateLoops")
  set(PIPELINE_INSTALL_TARGET "${PIPELINE_NAME}-install")
endmacro()


function(AnnotateLoopsPipeline trgt)
  AnnotateLoopsPipelineSetup()

  if(NOT TARGET ${PIPELINE_NAME})
    add_custom_target(${PIPELINE_NAME})
  endif()

  set(PIPELINE_SUBTARGET "${PIPELINE_NAME}_${trgt}")
  set(PIPELINE_PREFIX ${PIPELINE_SUBTARGET})

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

  get_target_property(LINKER_LANG ${PIPELINE_PREFIX}_link LINKER_LANGUAGE)

  set(PIPELINE_INPUT_FILE
    "$ENV{HARNESS_INPUT_DIR}${BMK_NAME}/cxx_user_functions.txt")

  if(LINK_LANGUAGE EQUAL "CXX")
    if(EXISTS ${PIPELINE_INPUT_FILE})
      set(PIPELINE_CMDLINE_ARG "-al-fn-whitelist=${PIPELINE_INPUT_FILE}")
    else()
      message(STATUS "could not find file: ${PIPELINE_INPUT_FILE}")
    endif()
  endif()

  llvmir_attach_opt_pass_target(${PIPELINE_PREFIX}_opt2
    ${PIPELINE_PREFIX}_link
    -load ${ANNOTLOOPS_LIB_LOCATION}
    -annotate-loops
    -al-loop-start-id=2
    -al-loop-id-interval=4
    -al-stats=${HARNESS_REPORT_DIR}/${BMK_NAME}-${PIPELINE_NAME}.txt
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
  AnnotateLoopsPipelineSetup()

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


