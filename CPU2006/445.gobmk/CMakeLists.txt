# cmake file

set(BMK_NAME "445.gobmk")
set(BMK_PROJECT_NAME "gobmk")

check_bmk_processing(hasSrcDir)

if(NOT ${hasSrcDir})
  message(STATUS "skipping project: ${BMK_PROJECT_NAME}") 
  return()
endif()

set(SOURCES
  sgf/sgf_utils.c
  sgf/sgftree.c
  sgf/sgfnode.c
  engine/aftermath.c
  engine/board.c
  engine/cache.c
  engine/combination.c
  engine/dragon.c
  engine/filllib.c
  engine/fuseki.c
  engine/genmove.c
  engine/hash.c
  engine/influence.c
  engine/interface.c
  engine/matchpat.c
  engine/move_reasons.c
  engine/movelist.c
  engine/optics.c
  engine/owl.c
  engine/printutils.c
  engine/readconnect.c
  engine/reading.c
  engine/score.c
  engine/semeai.c
  engine/sgfdecide.c
  engine/sgffile.c
  engine/shapes.c
  engine/showbord.c
  engine/utils.c
  engine/value_moves.c
  engine/worm.c
  engine/globals.c
  engine/persistent.c
  engine/handicap.c
  engine/surround.c
  interface/gtp.c
  interface/main.c
  interface/play_ascii.c
  interface/play_gtp.c
  interface/play_solo.c
  interface/play_test.c
  patterns/connections.c
  patterns/dfa.c
  patterns/helpers.c
  patterns/transform.c
  patterns/owl_attackpat.c
  patterns/conn.c
  patterns/patterns.c
  patterns/apatterns.c
  patterns/dpatterns.c
  patterns/owl_vital_apat.c
  patterns/eyes.c
  patterns/influence-pat.c
  patterns/barriers.c
  patterns/endgame.c
  patterns/aa_attackpat.c
  patterns/owl_defendpat.c
  patterns/fusekipat.c
  patterns/fuseki9.c
  patterns/fuseki13.c
  patterns/fuseki19.c
  patterns/josekidb.c
  patterns/handipat.c
  utils/getopt.c
  utils/getopt1.c
  utils/gg_utils.c
  utils/random.c)

add_prefix(SOURCES "${HARNESS_BMK_SOURCE_SUBDIR}/" "${SOURCES}")

add_executable(${BMK_PROJECT_NAME} ${SOURCES})

add_definitions(-DHAVE_CONFIG_H)

target_include_directories(${BMK_PROJECT_NAME} PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/${HARNESS_BMK_SOURCE_SUBDIR}")
target_include_directories(${BMK_PROJECT_NAME} PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/${HARNESS_BMK_SOURCE_SUBDIR}/include/")

target_link_libraries(${BMK_PROJECT_NAME} m)


# this property is required by our parasitic targets
set_target_properties(${BMK_PROJECT_NAME} PROPERTIES LINKER_LANGUAGE C)

# this property is used internally by our harness 
# because benchmark names and their main targets have different names
set_target_properties(${BMK_PROJECT_NAME} PROPERTIES BMK_NAME ${BMK_NAME})


foreach(FRAGMENT ${HARNESS_CMAKE_FRAGMENT_FILES})
  include(${FRAGMENT})
endforeach()

