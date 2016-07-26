#!/usr/bin/env bash

# initialize configuration vars

BMK_DIR=""


# set configuration vars

if [ -z "$1" ]; then 
  echo "error: benchmark directory was not provided" 

  exit 1
fi

BMK_DIR=$1


if [ -z "$2" ]; then 
  echo "error: cmake source fragment file was not provided" 

  exit 2
fi

CMAKE_SOURCE_FRAGMENT_FILE=$2


CMAKE_TARGET_FRAGMENT_FILE="CMakeLists-additional.txt"


# print configuration vars

echo "info: printing configuation vars"
echo "info: benchmark dir: ${BMK_DIR}"
echo "info: cmake source fragment file: ${CMAKE_SOURCE_FRAGMENT_FILE}"
echo "info: cmake target fragment file: ${CMAKE_TARGET_FRAGMENT_FILE}"
echo ""

pushd ${BMK_DIR}

BMKS=$(ls -1 .)

for bmk in ${BMKS}; do
  pushd ${bmk}/src/
    ln -sf ../../../${CMAKE_SOURCE_FRAGMENT_FILE} ${CMAKE_TARGET_FRAGMENT_FILE}
  popd
done

popd


exit $?

