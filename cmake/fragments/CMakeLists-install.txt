# cmake file fragment

# attachments on first target

set(DEST_DIR "CPU2006/${BMK_NAME}")

install(TARGETS ${PROJECT_NAME} RUNTIME DESTINATION ${DEST_DIR}/exe/)

install(DIRECTORY "./data" DESTINATION ${DEST_DIR})

