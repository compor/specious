# cmake file fragment

attach_llvmir_bc_target(${PROJECT_NAME}_bc ${PROJECT_NAME})

attach_llvmir_link_target(${PROJECT_NAME}_link
  ${PROJECT_NAME}_bc)

attach_llvmir_executable(${PROJECT_NAME}_bc_exe ${PROJECT_NAME}_link)
target_link_libraries(${PROJECT_NAME}_bc_exe m)

