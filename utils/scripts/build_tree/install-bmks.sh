#!/usr/bin/env bash

#set -x

# internal vars

OUTS='/dev/stdout'
ERRS='/dev/stderr'

# initialize configuration vars

SCRIPT_HELP=0
SUITE_CONFIG_FILE=""
SUITE_BUILD_DIR=""
SUITE_INSTALL_DIR=""

# parse and check cmd line options

CMDOPTS=":c:s:i:qh"

HELP_STRING=$(cat <<- END

Usage: ${0} OPTIONS

-c file    suite config file
-s dir     suite build directory
-i dir     suite install directory
-q         silent mode (no output)
-h         help

END
)

while getopts ${CMDOPTS} cmdopt; do
  case $cmdopt in
    c)
      SUITE_CONFIG_FILE=$OPTARG
      ;;
    s)
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
      SCRIPT_HELP=1
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


[[ $SCRIPT_HELP -ne 0 ]] && echo "$HELP_STRING" > $ERRS && exit 0


# print configuration vars

INFO_STR=$(cat <<- END
info: printing configuration vars
info: suite config file: ${SUITE_CONFIG_FILE}
info: suite build dir: ${SUITE_BUILD_DIR}
info: suite install dir: ${SUITE_INSTALL_DIR}
END
)

echo "$INFO_STR" > $OUTS

if [[ -z $SUITE_CONFIG_FILE || ! -e $SUITE_CONFIG_FILE ]]; then
  echo "error: suite config file was not provided or does not exist" > $ERRS
  exit 1
fi

if [[ -z $SUITE_BUILD_DIR || ! -e $SUITE_BUILD_DIR ]]; then
  echo "error: suite build dir was not provided or does not exist" > $ERRS
  exit 1
fi

if [[ ! -e $(which rsync) ]]; then
  echo "error: this script requires rsync" > $ERRS
  exit 1
fi

# operations

mkdir -p "${SUITE_INSTALL_DIR}"

# check if out dir location is given in relative form
[[ ${SUITE_INSTALL_DIR} == ${SUITE_INSTALL_DIR#/} ]] && SUITE_INSTALL_DIR="$(pwd)/${SUITE_INSTALL_DIR}"

readarray BENCHMARKS < ${SUITE_CONFIG_FILE}

for BMK in ${BENCHMARKS[@]}; do
  BMK=$(echo $BMK | tr -d [:space:])
  BMK_EXE=${BMK##*.}

  BMK_BUILD_DIR=${SUITE_BUILD_DIR}/${BMK}/exe
  BMK_INSTALL_DIR=${SUITE_INSTALL_DIR}/${BMK}/exe

  mkdir -p ${BMK_INSTALL_DIR}

  rsync -krcq ${BMK_BUILD_DIR}/${BMK_EXE} ${BMK_INSTALL_DIR}
  RC=$?

  MSG="installing ${BMK} binary"
  PRE_MSG="failure"
  [[ $RC -eq 0 ]] && PRE_MSG="success"
  echo "${PRE_MSG} ${MSG}" > $OUTS
done

exit 0
