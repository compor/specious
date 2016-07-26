# cmake file

set(PROJECT_NAME "mcf")

set(SOURCES
  mcf.c
  mcfutil.c
  readmin.c
  implicit.c
  pstart.c
  output.c
  treeup.c
  pbla.c
  pflowup.c
  psimplex.c
  pbeampp.c)


add_executable(${PROJECT_NAME} ${SOURCES})

add_definitions(-DWANT_STDC_PROTO)

# this property is required by our parasitic targets
set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE C)

target_include_directories(${PROJECT_NAME} PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/")

target_link_libraries(${PROJECT_NAME} m)

# attachments on first target

if(${USE_LLVM})
  attach_llvmir_target(${PROJECT_NAME}_bc ${PROJECT_NAME})

  include(CMakeLists-additional.txt)

  attach_llvmir_executable(${PROJECT_NAME}_bc_exe ${PROJECT_NAME}_link)
  target_link_libraries(${PROJECT_NAME}_bc_exe m)
endif()

