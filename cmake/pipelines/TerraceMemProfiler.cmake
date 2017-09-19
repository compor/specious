# cmake file

message(STATUS "setting up pipeline TerraceMemProfiler")

find_package(Terrace CONFIG)

if(NOT Terrace_FOUND)
  message(WARNING "package Terrace was not found; skipping.")

  return()
endif()

find_package(MemProfiler CONFIG)

if(NOT MemProfiler_FOUND)
  message(FATAL_ERROR "package MemProfiler was not found")

  return()
endif()

get_target_property(MEMPROFILER_LIB_LOCATION LLVMMemProfilerPass LOCATION)

find_package(CommutativityRuntime CONFIG)

if(NOT CommutativityRuntime_FOUND)
  message(FATAL_ERROR "package CommutativityRuntime was not found")

  return()
endif()

get_target_property(TERRACE_LIB_LOCATION LLVMTerracePass LOCATION)
get_target_property(DEPENDEE LLVMTerracePass DEPENDEE)

# configuration

macro(TerraceMemProfilerPipelineSetup)
  set(PIPELINE_NAME "TerraceMemProfiler")
  set(PIPELINE_INSTALL_TARGET "${PIPELINE_NAME}-install")
endmacro()


function(TerraceMemProfilerPipeline trgt)
  TerraceMemProfilerPipelineSetup()

  if(NOT TARGET ${PIPELINE_NAME})
    add_custom_target(${PIPELINE_NAME})
  endif()

  set(PIPELINE_SUBTARGET "${PIPELINE_NAME}_${trgt}")
  set(PIPELINE_PREFIX ${PIPELINE_SUBTARGET})

  ## pipeline targets and chaining
  set(LOAD_DEPENDENCY_CMDLINE_ARG "")
  if(DEPENDEE)
    foreach(dep ${DEPENDEE})
      list(APPEND LOAD_DEPENDENCY_CMDLINE_ARG -load;${dep})
    endforeach()
  endif()

  set(DEPENDEE_TRGT "AnnotateLoops_${trgt}_opt2")

  llvmir_attach_opt_pass_target(${PIPELINE_PREFIX}_opt1
    ${DEPENDEE_TRGT}
    ${LOAD_DEPENDENCY_CMDLINE_ARG}
    -load ${TERRACE_LIB_LOCATION}
    -terrace)
  add_dependencies(${PIPELINE_PREFIX}_opt1 ${DEPENDEE_TRGT})

  llvmir_attach_opt_pass_target(${PIPELINE_PREFIX}_opt2
    ${PIPELINE_PREFIX}_opt1
    -load ${MEMPROFILER_LIB_LOCATION}
    -dynapar-memprof -memprof-instrument-control=false)
  add_dependencies(${PIPELINE_PREFIX}_opt2 ${PIPELINE_PREFIX}_opt1)

  llvmir_attach_executable(${PIPELINE_PREFIX}_bc_exe ${PIPELINE_PREFIX}_opt2)
  add_dependencies(${PIPELINE_PREFIX}_bc_exe ${PIPELINE_PREFIX}_opt2)

  target_link_libraries(${PIPELINE_PREFIX}_bc_exe CommutativityRuntime m)

  ## pipeline aggregate targets
  add_custom_target(${PIPELINE_SUBTARGET} DEPENDS
    ${DEPENDEE_TRGT}
    ${PIPELINE_PREFIX}_opt1
    ${PIPELINE_PREFIX}_opt2
    ${PIPELINE_PREFIX}_bc_exe)

  add_dependencies(${PIPELINE_NAME} ${PIPELINE_SUBTARGET})


  # installation
  get_property(bmk_name TARGET ${trgt} PROPERTY BMK_NAME)

  InstallTerraceMemProfilerPipelineLLVMIR(${PIPELINE_PREFIX}_opt2 ${bmk_name})
endfunction()


function(InstallTerraceMemProfilerPipelineLLVMIR pipeline_part_trgt bmk_name)
  TerraceMemProfilerPipelineSetup()

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


