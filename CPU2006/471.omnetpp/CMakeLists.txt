# cmake file

set(BMK_NAME "471.omnetpp")
set(BMK_PROJECT_NAME "omnetpp")

check_bmk_processing(hasSrcDir)

if(NOT ${hasSrcDir})
  message(STATUS "skipping project: ${BMK_PROJECT_NAME}")
  return()
endif()

set(SOURCES
  EtherAppCli.cc
  EtherAppCli_n.cc
  EtherAppSrv.cc
  EtherAppSrv_n.cc
  EtherApp_m.cc
  EtherBus.cc
  EtherBus_n.cc
  EtherCtrl_m.cc
  EtherEncap.cc
  EtherEncap_n.cc
  EtherFrame_m.cc
  EtherHost_n.cc
  EtherHub.cc
  EtherHub_n.cc
  EtherLLC.cc
  EtherLLC_n.cc
  EtherMAC.cc
  EtherMAC_n.cc
  EtherSwitch_n.cc
  LargeNet_n.cc
  MACAddress.cc
  MACAddress_m.cc
  MACRelayUnitBase.cc
  MACRelayUnitNP.cc
  MACRelayUnitNP_n.cc
  MACRelayUnitPP.cc
  MACRelayUnitPP_n.cc
  MACRelayUnit_n.cc
  Networks_n.cc
  eth-index_n.cc
  utils.cc
  libs/cmdenv/cmdenv.cc
  libs/cmdenv/enumstr.cc
  libs/cmdenv/heap.cc
  libs/envir/akoutvectormgr.cc
  libs/envir/args.cc
  libs/envir/cenvir.cc
  libs/envir/cinifile.cc
  libs/envir/filemgrs.cc
  libs/envir/main.cc
  libs/envir/omnetapp.cc
  libs/envir/patmatch.cc
  libs/envir/platdep.cc
  libs/envir/seeds.cc
  libs/envir/slaveapp.cc
  libs/envir/speedmtr.cc
  libs/sim/carray.cc
  libs/sim/cexception.cc
  libs/sim/cmessage.cc
  libs/sim/cpar.cc
  libs/sim/ctypes.cc
  libs/sim/task.cc
  libs/sim/cchannel.cc
  libs/sim/cfsm.cc
  libs/sim/cmodule.cc
  libs/sim/cpsquare.cc
  libs/sim/cvarhist.cc
  libs/sim/util.cc
  libs/sim/ccoroutine.cc
  libs/sim/cgate.cc
  libs/sim/cmsgheap.cc
  libs/sim/cqueue.cc
  libs/sim/cwatch.cc
  libs/sim/cdensity.cc
  libs/sim/chead.cc
  libs/sim/cnetmod.cc
  libs/sim/csimul.cc
  libs/sim/distrib.cc
  libs/sim/cdetect.cc
  libs/sim/chist.cc
  libs/sim/cobject.cc
  libs/sim/cstat.cc
  libs/sim/errmsg.cc
  libs/sim/cdispstr.cc
  libs/sim/cksplit.cc
  libs/sim/coutvect.cc
  libs/sim/cstruct.cc
  libs/sim/onstartup.cc
  libs/sim/cenum.cc
  libs/sim/cllist.cc
  libs/sim/cpacket.cc
  libs/sim/ctopo.cc
  libs/sim/random.cc
  libs/sim/std/netpack.cc
  libs/spec/spec_qsort.cc)

add_prefix(SOURCES "${HARNESS_BMK_SOURCE_SUBDIR}/" "${SOURCES}")

add_executable(${BMK_PROJECT_NAME} ${SOURCES})

target_include_directories(${BMK_PROJECT_NAME} PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/${HARNESS_BMK_SOURCE_SUBDIR}")
target_include_directories(${BMK_PROJECT_NAME} PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/${HARNESS_BMK_SOURCE_SUBDIR}/omnet_include/")
target_include_directories(${BMK_PROJECT_NAME} PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/${HARNESS_BMK_SOURCE_SUBDIR}/libs/sim/")
target_include_directories(${BMK_PROJECT_NAME} PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/${HARNESS_BMK_SOURCE_SUBDIR}/libs/cmdenv/")
target_include_directories(${BMK_PROJECT_NAME} PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/${HARNESS_BMK_SOURCE_SUBDIR}/libs/envir/")

target_link_libraries(${BMK_PROJECT_NAME} m)


set_target_properties(${BMK_PROJECT_NAME}
  PROPERTIES LINKER_LANGUAGE CXX # existing property required by harness
  BMK_NAME ${BMK_NAME} # optional custom property used by our harness
  RUNTIME_OUTPUT_DIRECTORY exe
  )


foreach(FRAGMENT ${HARNESS_CMAKE_FRAGMENT_FILES})
  include(${FRAGMENT})
endforeach()

