# cmake file fragment

# configuration

set(PIPELINE_NAME "loopcanon")
set(PIPELINE_PREFIX "${PROJECT_NAME}_${PIPELINE_NAME}")

set(PIPELINE_INSTALL_TARGET "${PIPELINE_NAME}-install")
set(PIPELINE_LOCAL_INSTALL_TARGET "${PIPELINE_NAME}-${PROJECT_NAME}-install")

set(PIPELINE_LOCAL_DEST_DIR ${CMAKE_INSTALL_PREFIX}/CPU2006/${BMK_NAME}/llvm-ir)


# pipeline of attachments on first target

#
# expected target name under PROJECT_NAME variable
#

attach_llvmir_bc_target(${PIPELINE_PREFIX}_bc ${PROJECT_NAME})
add_dependencies(${PIPELINE_PREFIX}_bc ${PROJECT_NAME})

attach_llvmir_opt_pass_target(${PIPELINE_PREFIX}_opt
  ${PIPELINE_PREFIX}_bc
  -mem2reg
  -mergereturn
  -simplifycfg
  -loop-simplify)
add_dependencies(${PIPELINE_PREFIX}_opt ${PIPELINE_PREFIX}_bc)

attach_llvmir_link_target(${PROJECT_NAME}_${PIPELINE_NAME}_link
  ${PIPELINE_PREFIX}_opt)
add_dependencies(${PROJECT_NAME}_${PIPELINE_NAME}_link ${PIPELINE_PREFIX}_opt)

attach_llvmir_executable(${PIPELINE_PREFIX}_bc_exe
  ${PIPELINE_PREFIX}_link)
add_dependencies(${PIPELINE_PREFIX}_bc_exe ${PIPELINE_PREFIX}_link)

target_link_libraries(${PIPELINE_PREFIX}_bc_exe m)


# installation

#
# the dummy global target that aggregates the local targets must be added only
# once, although this fragment file is added by each benchmark cmake file
#

if(NOT TARGET ${PIPELINE_INSTALL_TARGET})
  add_custom_target(${PIPELINE_INSTALL_TARGET})
endif()


get_property(CUR_LLVMIR_DIR TARGET ${PIPELINE_PREFIX}_link
  PROPERTY LLVMIR_DIR)

add_custom_target(${PIPELINE_LOCAL_INSTALL_TARGET}
  COMMAND ${CMAKE_COMMAND} -E
  copy_directory ${CUR_LLVMIR_DIR} ${PIPELINE_LOCAL_DEST_DIR})

add_dependencies(${PIPELINE_INSTALL_TARGET} ${PIPELINE_LOCAL_INSTALL_TARGET})

