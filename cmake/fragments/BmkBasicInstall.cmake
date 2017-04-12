# cmake file fragment

function(SetupBmkBasicInstall trgt)
  get_property(bmk_name TARGET ${trgt} PROPERTY BMK_NAME)

  set(DEST_DIR "CPU2006/${bmk_name}")
  install(TARGETS ${trgt} RUNTIME DESTINATION ${DEST_DIR}/exe/)
  install(DIRECTORY "./data" DESTINATION ${DEST_DIR})
endfunction()

