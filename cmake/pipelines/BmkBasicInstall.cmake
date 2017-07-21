# cmake file

message(STATUS "setting up pipeline: BmkBasicInstall")

function(BmkBasicInstallPipeline trgt)
  get_property(bmk_name TARGET ${trgt} PROPERTY BMK_NAME)

  set(DEST_DIR "CPU2006/${bmk_name}")
  set(BMK_BIN_NAME "${trgt}")

  install(TARGETS ${trgt} RUNTIME DESTINATION ${DEST_DIR} OPTIONAL)

  get_filename_component(ABS_DATA_DIR data REALPATH)
  set(BMK_DATA_DIR "data")

  install(DIRECTORY ${ABS_DATA_DIR}/ DESTINATION ${DEST_DIR}/${BMK_DATA_DIR})

  configure_file("scripts/run.sh.in" "scripts/${trgt}_run.sh" @ONLY)

  install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/scripts/
    DESTINATION ${DEST_DIR}
    PATTERN "*.sh"
    PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE)
endfunction()

