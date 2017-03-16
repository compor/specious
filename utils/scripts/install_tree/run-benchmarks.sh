#!/usr/bin/env bash

# internal vars

OUTS='/dev/stdout'
ERRS='/dev/stderr'


# initialize configuration vars

SHOW_HELP=0
BMK_CONFIG_FILE=""
BMK_INSTALL_DIR=""
BMK_DATA_DIR=""
BMK_DATA_TYPEBMK_DATA_TYPE=""


# parse and check cmd line options

CMDOPTS=":c:i:d:t:qh"

HELP_STRING="\
Usage: ${0} OPTIONS

-c file    benchmark config file
-i dir     benchmark install directory
-d dir     data set dir
-t string  data set type
-q         silent mode (no output)
-h         help
"

while getopts ${CMDOPTS} cmdopt "${SCRIPT_ARGS[@]}"; do
  case $cmdopt in
    c)
      BMK_CONFIG_FILE=$OPTARG
      ;;
    i)
      BMK_INSTALL_DIR=$OPTARG
      ;;
    d)
      BMK_DATA_DIR=$OPTARG
      ;;
    t)
      BMK_DATA_TYPE=$OPTARG
      ;;
    q)
      OUTS="/dev/null"
      ERRS="/dev/null"
      ;;
    h)
      SHOW_HELP=1
      ;;
    \?)
      echo "error: invalid option: -$OPTARG" > $ERRS
      exit 1
      ;;
    :)
      echo "error: option -$OPTARG requires an argument" > $ERRS
      exit 1
      ;;
  esac
done


if [ "$SHOW_HELP" -ne 0 ]; then
  echo "$HELP_STRING" > $ERRS

  exit 0
fi


# print configuration vars

INFO_STR="\
info: printing configuration vars
info: benchmark config file: ${BMK_CONFIG_FILE}
info: benchmark install dir: ${BMK_INSTALL_DIR}
info: benchmark data set dir: ${BMK_DATA_DIR}
info: benchmark data set type: ${BMK_DATA_TYPE}
"

echo "$INFO_STR" > $OUTS

if [ -z "$BMK_CONFIG_FILE" -o ! -e "$BMK_CONFIG_FILE" ]; then
  echo "error: benchmark config file was not provided or does not exist" > $ERRS

  exit 1
fi

if [ -z "$BMK_INSTALL_DIR" -o ! -e "$BMK_INSTALL_DIR" ]; then
  echo "error: benchmark install dir was not provided or does not exist" > $ERRS

  exit 1
fi

if [ -z "$BMK_DATA_DIR" -o ! -e "$BMK_DATA_DIR" ]; then
  echo "error: benchmark data dir was not provided or does not exist" > $ERRS

  exit 1
fi

if [ -z "$BMK_DATA_TYPE" ]; then
  echo "error: benchmark data set type was not provided" > $ERRS

  exit 1
fi


# operations

# check if out dir location is given in relative form
if [ "${BMK_INSTALL_DIR}" == "${BMK_INSTALL_DIR#/}" ]; then 
  BMK_INSTALL_DIR="$(pwd)/${BMK_INSTALL_DIR}"
fi

if [ "${BMK_DATA_DIR}" == "${BMK_DATA_DIR#/}" ]; then 
  BMK_DATA_DIR="$(pwd)/${BMK_DATA_DIR}"
fi

readarray BENCHMARKS < ${BMK_CONFIG_FILE}

for BMK in ${BENCHMARKS[@]}; do
  # trim whitespace
  BMK=$(echo $BMK | xargs)

  BMK_EXE=${BMK##*.} # cut off the numbers ###.bmk

  #pushd ${BMK_INSTALL_DIR}/CPU2006/${BMK} > $OUTS

  # read command args file
  BMK_ARGS_FILE=${BMK_DATA_DIR}/invocations/${BMK_DATA_TYPE}/${BMK}.${BMK_DATA_TYPE}.cmd
  IFS=$'\n' read -d '' -r -a BMK_ARGS < ${BMK_ARGS_FILE}

  echo "running ${BMK}" > $OUTS

  pushd ${BMK_DATA_DIR}/CPU2006/${BMK}/data/${BMK_DATA_TYPE}/input/

  echo "${BMK_EXE} ${BMK_DATA_TYPE}" > $OUTS
  eval ${BMK_INSTALL_DIR}/CPU2006/${BMK}/exe/${BMK_EXE} ${BMK_ARGS}

  popd
done


exit 0

