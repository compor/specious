#!/usr/bin/env bash

# initialize configuration vars

SHOW_HELP=0
BMK_CONFIG_FILE=""
BMK_DIR=""
CMAKE_FRAGMENT_FILE=""


# parse and check cmd line options

CMDOPTS=":c:s:f:h"

HELP_STRING="Usage: ${0} OPTIONS

-c file    benchmark config file
-s dir     benchmark source directory
-f file    cmake fragment file
-h         help
"

while getopts $CMDOPTS cmdopt; do
  case $cmdopt in
    c)
      BMK_CONFIG_FILE=$OPTARG
      ;;
    s)
      BMK_SOURCE_DIR=$OPTARG
      ;;
    f)
      CMAKE_FRAGMENT_FILE=$OPTARG
      ;;
    h)
      SHOW_HELP=1
      ;;
    \?)
      echo "error: invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "error: option -$OPTARG requires an argument" >&2
      exit 1
      ;;
  esac
done


if [ "$SHOW_HELP" -ne 0 ]; then
  echo "$HELP_STRING" >&2

  exit 0
fi

if [ -z "$BMK_CONFIG_FILE" -a ! -e "$BMK_CONFIG_FILE" ]; then
  echo "error: benchmark config file was not provided or does not exist" >&2

  exit 1
fi

if [ -z "$BMK_DIR" -a ! -e "$BMK_DIR" ]; then
  echo "error: benchmark dir was not provided or does not exist" >&2

  exit 1
fi

if [ -z "$CMAKE_FRAGMENT_FILE" -a ! -e "$CMAKE_FRAGMENT_FILE" ]; then
  echo "error: cmake fragment file was not provided or does not exist" >&2

  exit 1
fi


# print configuration vars

echo "info: printing configuration vars"
echo "info: benchmark config file: ${BMK_CONFIG_FILE}"
echo "info: benchmark dir: ${BMK_DIR}"
echo "info: cmake fragment file: ${CMAKE_FRAGMENT_FILE}"
echo ""


# operations

readarray BENCHMARKS < ${BMK_CONFIG_FILE}

pushd ${BMK_DIR}

for BMK in ${BENCHMARKS}; do
  [ ! -d ${BMK} ] && continue

  pushd ${BMK}/src/
    ln -sf ../../../${CMAKE_FRAGMENT_FILE} ${CMAKE_FRAGMENT_FILE}
  popd
done

popd


exit $?

