# cmake file

set(PROJECT_NAME "sjeng")

set(SOURCES
  attacks.c
  book.c
  crazy.c
  draw.c
  ecache.c
  epd.c
  eval.c
  leval.c
  moves.c
  neval.c
  partner.c
  proof.c 
  rcfile.c
  search.c
  see.c
  seval.c
  sjeng.c
  ttable.c 
  utils.c)


add_executable(${PROJECT_NAME} ${SOURCES})

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

