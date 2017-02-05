#!/usr/bin/env bash

# initialize configuration vars

SHOW_HELP=0
BMK_SOURCE_DIR=""
BMK_TARGET_DIR=""


# parse and check cmd line options

CMDOPTS=":f:s:t:h"

HELP_STRING="Usage: ${0} OPTIONS

-f file    benchmark config file
-s dir     benchmark source directory
-t dir     benchmark target directory
-h         help
"

while getopts $CMDOPTS cmdopt; do
  case $cmdopt in
    f)
      BMK_CONFIG_FILE=$OPTARG
      ;;
    s)
      BMK_SOURCE_DIR=$OPTARG
      ;;
    t)
      BMK_TARGET_DIR=$OPTARG
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

if [ -z "$BMK_SOURCE_DIR" -a ! -e "$BMK_SOURCE_DIR" ]; then
  echo "error: benchmark source dir was not provided or does not exist" >&2

  exit 1
fi

if [ -z "$BMK_TARGET_DIR" -a ! -e "$BMK_TARGET_DIR" ]; then
  echo "error: benchmark target dir was not provided or does not exist" >&2

  exit 1
fi


# print configuration vars

echo "info: printing configuration vars"
echo "info: benchmark config file: ${BMK_CONFIG_FILE}"
echo "info: benchmark source dir: ${BMK_SOURCE_DIR}"
echo "info: benchmark target dir: ${BMK_TARGET_DIR}"
echo ""


# operations

readarray BENCHMARKS < ${BMK_CONFIG_FILE}

for BMK in ${BENCHMARKS}; do
  BMK_SOURCE="${SOURCE_BMK_DIR}/${BMK}/src"
  [ ! -d ${BMK_SOURCE} ] && continue

  pushd "${BMK_TARGET_DIR}/${BMK}"

  ln -sf ${BMK_SOURCE}

  popd
done


exit $?

