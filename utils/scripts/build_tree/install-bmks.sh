#!/usr/bin/env bash

#set -x

# internal vars

OUTS='/dev/stdout'
ERRS='/dev/stderr'

# initialize configuration vars

SHOW_HELP=0
SUITE_CONFIG_FILE=""
SUITE_BUILD_DIR=""
SUITE_INSTALL_DIR=""

# parse and check cmd line options

CMDOPTS=":c:b:i:qh"

HELP_STRING="\
Usage: ${0} OPTIONS

-c file    suite config file
-b dir     suite build directory
-i dir     suite install directory
-q         silent mode (no output)
-h         help
"

while getopts ${CMDOPTS} cmdopt; do
  case $cmdopt in
    c)
      SUITE_CONFIG_FILE=$OPTARG
      ;;
    b)
      SUITE_BUILD_DIR=$OPTARG
      ;;
    i)
      SUITE_INSTALL_DIR=$OPTARG
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


[[ $SHOW_HELP -ne 0 ]] && echo "$HELP_STRING" > $ERRS && exit 0


# print configuration vars

INFO_STR="\
info: printing configuration vars
info: suite config file: ${SUITE_CONFIG_FILE}
info: suite build dir: ${SUITE_BUILD_DIR}
info: suite install dir: ${SUITE_INSTALL_DIR}
"

echo "$INFO_STR" > $OUTS

if [[ -z $SUITE_CONFIG_FILE || ! -e $SUITE_CONFIG_FILE ]]; then
  echo "error: suite config file was not provided or does not exist" > $ERRS
  exit 1
fi

if [[ -z $SUITE_BUILD_DIR || ! -e $SUITE_BUILD_DIR ]]; then
  echo "error: suite build dir was not provided or does not exist" > $ERRS
  exit 1
fi


# operations

mkdir -p "${SUITE_INSTALL_DIR}"

# check if out dir location is given in relative form
[[ ${SUITE_INSTALL_DIR} == ${SUITE_INSTALL_DIR#/} ]] && SUITE_INSTALL_DIR="$(pwd)/${SUITE_INSTALL_DIR}"

readarray BENCHMARKS < ${SUITE_CONFIG_FILE}

for BMK in ${BENCHMARKS[@]}; do
  # trim whitespace
  BMK=$(echo $BMK | xargs)

  # cut off the numbers ###.bmk
  BMK_EXE=${BMK##*.} 

  BMK_BUILD_DIR=${SUITE_BUILD_DIR}/${BMK}
  BMK_INSTALL_DIR=${SUITE_INSTALL_DIR}/${BMK}

  mkdir -p ${BMK_INSTALL_DIR}

  rsync -cq ${BMK_BUILD_DIR}/${BMK_EXE} ${BMK_INSTALL_DIR}

  [[ $? -eq 0 ]] && echo "installed ${BMK}" > $OUTS
done

exit 0
