# cmake file

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

