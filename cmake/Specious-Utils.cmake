# cmake file

include(CMakeParseArguments)

function(add_prefix outvar prefix files)
  set(tmplist "")

  foreach(f ${files})
    list(APPEND tmplist "${prefix}${f}")
  endforeach()

  set(${outvar} "${tmplist}" PARENT_SCOPE)
endfunction()


function(check_bmk_processing outvar)
  set(hasSrcDir FALSE)

  if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/src")
    set(hasSrcDir TRUE)
  endif()

  set(${outvar} ${hasSrcDir} PARENT_SCOPE)
endfunction()

function(create_file_cmdline_arg)
  set(options)
  set(oneValueArgs CMDLINE_OPTION;FILENAME;CMDLINE_ARG)
  set(multiValueArgs)

  cmake_parse_arguments(cfca "${options}" "${oneValueArgs}"
    "${multiValueArgs}" ${ARGN})

  set(${cfca_CMDLINE_ARG} "" PARENT_SCOPE)

  if(NOT EXISTS ${cfca_FILENAME})
    message(STATUS "could not find file: ${cfca_FILENAME}")
    return()
  endif()

  set(${cfca_CMDLINE_ARG} "${cfca_CMDLINE_OPTION}=${cfca_FILENAME}" PARENT_SCOPE)
endfunction()

