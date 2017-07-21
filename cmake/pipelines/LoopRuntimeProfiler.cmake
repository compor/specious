# cmake file

message(STATUS "setting up pipeline LoopRuntimeProfiler")

find_package(LoopRuntimeProfiler CONFIG)

if(NOT LoopRuntimeProfiler_FOUND)
  message(WARNING "package LoopRuntimeProfiler was not found; skipping.")

  return()
endif()

get_target_property(LRP_LIB_LOCATION LLVMLoopRuntimeProfilerPass LOCATION)

# configuration

macro(LoopRuntimeProfilerPipelineSetup)
  set(PIPELINE_NAME "LoopRuntimeProfiler")
  set(PIPELINE_INSTALL_TARGET "${PIPELINE_NAME}-install")
endmacro()


function(LoopRuntimeProfilerPipeline trgt)
  LoopRuntimeProfilerPipelineSetup()

  if(NOT TARGET ${PIPELINE_NAME})
    add_custom_target(${PIPELINE_NAME})
  endif()

  set(PIPELINE_SUBTARGET "${PIPELINE_NAME}_${trgt}")
  set(PIPELINE_PREFIX ${PIPELINE_SUBTARGET})

  set(DEPENDEE_TRGT "SimplifyLoopExitsFront_${trgt}_link")

  ## pipeline targets and chaining

  set(PIPELINE_INPUT_FILE
    "$ENV{HARNESS_INPUT_DIR}${BMK_NAME}/$ENV{LRP_LOOP_ID_WHITELIST_FILE}")

  if(EXISTS ${PIPELINE_INPUT_FILE})
    set(PIPELINE_CMDLINE_ARG "-lrp-loop-id-whitelist=${PIPELINE_INPUT_FILE}")
  else()
    message(STATUS "could not find file: ${PIPELINE_INPUT_FILE}")
  endif()

  llvmir_attach_opt_pass_target(${PIPELINE_PREFIX}_link
    ${DEPENDEE_TRGT}
    -load ${LRP_LIB_LOCATION}
    -loop-runtime-profiler
    -lrp-loop-depth-ub=1
    ${PIPELINE_CMDLINE_ARG})

  #-slef-stats=${HARNESS_REPORT_DIR}/${BMK_NAME}-${PIPELINE_NAME}.txt

  llvmir_attach_executable(${PIPELINE_PREFIX}_bc_exe ${PIPELINE_PREFIX}_link)
  add_dependencies(${PIPELINE_PREFIX}_bc_exe ${PIPELINE_PREFIX}_link)

  target_link_libraries(${PIPELINE_PREFIX}_bc_exe lrp_rt m)

  ## pipeline aggregate targets
  add_custom_target(${PIPELINE_SUBTARGET} DEPENDS
    ${DEPENDEE_TRGT}
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
  InstallLoopRuntimeProfilerPipelineLLVMIR(${PIPELINE_PREFIX}_link ${bmk_name})
endfunction()


function(InstallLoopRuntimeProfilerPipelineLLVMIR pipeline_part_trgt bmk_name)
  LoopRuntimeProfilerPipelineSetup()

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


