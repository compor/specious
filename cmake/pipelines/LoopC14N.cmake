# cmake file

include(CMakeParseArguments)

# configuration

macro(LoopC14NPipelineSetupNames)
  set(PIPELINE_NAME "LoopC14N")
  string(TOUPPER "${PIPELINE_NAME}" PIPELINE_NAME_UPPER)
  set(PIPELINE_INSTALL_TARGET "${PIPELINE_NAME}-install")
endmacro()


macro(LoopC14NPipelineSetup)
  LoopC14NPipelineSetupNames()

  message(STATUS "setting up pipeline ${PIPELINE_NAME}")
endmacro()

LoopC14NPipelineSetup()

#

function(LoopC14NPipeline)
  LoopC14NPipelineSetupNames()

  set(options)
  set(oneValueArgs DEPENDS)
  set(multiValueArgs)
  cmake_parse_arguments(${PIPELINE_NAME_UPPER}
    "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if("${${PIPELINE_NAME_UPPER}_DEPENDS}" STREQUAL "")
    set(BW_COMPATIBILITY TRUE)
  endif()

  set(TRGT ${${PIPELINE_NAME_UPPER}_DEPENDS})

  # apply defaults
  if(BW_COMPATIBILITY)
    list(GET ${PIPELINE_NAME_UPPER}_UNPARSED_ARGUMENTS 0 TRGT)
    list(REMOVE_AT ${PIPELINE_NAME_UPPER}_UNPARSED_ARGUMENTS 0)

    if("${TRGT}" STREQUAL "")
      message(FATAL_ERROR "pipeline ${PIPELINE_NAME}: missing DEPENDS target")
    endif()
  endif()

  list(LENGTH ${PIPELINE_NAME_UPPER}_UNPARSED_ARGUMENTS UNPARSED_ARGS_LEN)
  if(${UNPARSED_ARGS_LEN} GREATER 0)
    message(FATAL_ERROR "pipeline ${PIPELINE_NAME}: has extraneous arguments \
    ${${PIPELINE_NAME_UPPER}_UNPARSED_ARGUMENTS}"
  endif()

  if(NOT TARGET ${TRGT})
    message(FATAL_ERROR "pipeline ${PIPELINE_NAME}: ${TRGT} is not a target")
  endif()

  if(NOT TARGET ${PIPELINE_NAME})
    add_custom_target(${PIPELINE_NAME})
  endif()

  set(PIPELINE_SUBTARGET "${PIPELINE_NAME}_${TRGT}")
  set(PIPELINE_PREFIX ${PIPELINE_SUBTARGET})

  ## pipeline targets and chaining
  llvmir_attach_bc_target(${PIPELINE_PREFIX}_bc ${TRGT})
  add_dependencies(${PIPELINE_PREFIX}_bc ${TRGT})

  llvmir_attach_opt_pass_target(${PIPELINE_PREFIX}_opt
    ${PIPELINE_PREFIX}_bc
    -mem2reg
    -mergereturn
    -simplifycfg
    -loop-simplify)
  add_dependencies(${PIPELINE_PREFIX}_opt ${PIPELINE_PREFIX}_bc)

  llvmir_attach_link_target(${PIPELINE_PREFIX}_link ${PIPELINE_PREFIX}_opt)
  add_dependencies(${PIPELINE_PREFIX}_link ${PIPELINE_PREFIX}_opt)

  llvmir_attach_executable(${PIPELINE_PREFIX}_bc_exe ${PIPELINE_PREFIX}_link)
  add_dependencies(${PIPELINE_PREFIX}_bc_exe ${PIPELINE_PREFIX}_link)

  target_link_libraries(${PIPELINE_PREFIX}_bc_exe m)

  ## pipeline aggregate targets
  add_custom_target(${PIPELINE_SUBTARGET} DEPENDS
    ${PIPELINE_PREFIX}_bc
    ${PIPELINE_PREFIX}_opt
    ${PIPELINE_PREFIX}_link
    ${PIPELINE_PREFIX}_bc_exe)

  add_dependencies(${PIPELINE_NAME} ${PIPELINE_SUBTARGET})


  # installation
  get_property(bmk_name TARGET ${TRGT} PROPERTY BMK_NAME)

  InstallLoopC14NPipelineLLVMIR(${PIPELINE_PREFIX}_link ${bmk_name})
endfunction()


function(InstallLoopC14NPipelineLLVMIR pipeline_part_trgt bmk_name)
  LoopC14NPipelineSetupNames()

  set(options)
  set(oneValueArgs TARGET)
  set(multiValueArgs)
  cmake_parse_arguments(${PIPELINE_NAME_UPPER}
    "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

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

