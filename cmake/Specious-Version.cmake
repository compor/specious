# cmake file

function(get_version version)
  execute_process(COMMAND git describe --tags --long --always
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    OUTPUT_VARIABLE ver
    OUTPUT_STRIP_TRAILING_WHITESPACE)

  set(${version} "${ver}" PARENT_SCOPE)
endfunction()


