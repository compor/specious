# cmake file

message(STATUS "setting up pipeline: BmkBasicInstall")

function(BmkBasicInstall trgt)
  get_property(bmk_name TARGET ${trgt} PROPERTY BMK_NAME)

  set(DEST_DIR "CPU2006/${bmk_name}")

  install(TARGETS ${trgt} RUNTIME DESTINATION ${DEST_DIR} OPTIONAL)
  install(DIRECTORY "./data" DESTINATION ${DEST_DIR})
endfunction()

