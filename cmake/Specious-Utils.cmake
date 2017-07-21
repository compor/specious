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


function(create_file_fragment)
  set(options)
  set(oneValueArgs FILENAME)
  set(multiValueArgs PIPELINES)

  cmake_parse_arguments(cff "${options}" "${oneValueArgs}"
    "${multiValueArgs}" ${ARGN})

  set(file_contents "")
  set(txt_template "
if(COMMAND REPLACEMEPipeline)
  REPLACEMEPipeline(\${BMK_PROJECT_NAME})
else()
  message(WARNING \"Could not execute command: REPLACEMEPipeline\")
endif()
  ")

  foreach(pipeline ${cff_PIPELINES})
    string(REPLACE "REPLACEME" "${pipeline}" replaced_txt ${txt_template})
    string(CONCAT file_contents ${file_contents} ${replaced_txt})
  endforeach()

  file(WRITE ${cff_FILENAME} ${file_contents})
endfunction()

