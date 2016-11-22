# cmake file

function(add_prefix outvar prefix files)
   set(tmplist "")

   foreach(f ${files})
      list(APPEND tmplist "${prefix}${f}")
   endforeach()

   set(${outvar} "${tmplist}" PARENT_SCOPE)
endfunction()


function(include_fragments fragments)
  foreach(FRAGMENT ${fragments})
    include(${FRAGMENT})
  endforeach()
endfunction()

