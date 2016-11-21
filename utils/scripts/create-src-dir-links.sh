#!/usr/bin/env bash

# initialize configuration vars

BENCHMARKS=(
  #"400.perlbench"
  #"401.bzip2"
  #"403.gcc"
  #"429.mcf"
  #"433.milc"
  #"444.namd"
  #"445.gobmk"
  #"447.dealII"
  #"450.soplex"
  #"453.povray"
  #"456.hmmer"
  #"458.sjeng"
  #"462.libquantum"
  #"464.h264ref"
  "470.lbm"
  #"471.omnetpp"
  #"473.astar"
  #"482.sphinx3"
  #"483.xalancbmk"
)


SOURCE_BMK_DIR=""


# set configuration vars

if [ -z "$1" ]; then 
  echo "error: source benchmark directory was not provided" 

  exit 1
fi

SOURCE_BMK_DIR=$1


if [ -z "$2" ]; then 
  echo "error: target benchmark directory was not provided" 

  exit 2
fi

TARGET_BMK_DIR=$2


# print configuration vars

echo "info: printing configuation vars"
echo "info: source benchmark dir: ${SOURCE_BMK_DIR}"
echo "info: target benchmark dir: ${TARGET_BMK_DIR}"
echo ""




for bmk in ${BENCHMARKS}; do
  source_bmk="${SOURCE_BMK_DIR}/${bmk}/src"
  [ ! -d ${source_bmk} ] && continue

  pushd "${TARGET_BMK_DIR}/${bmk}"

  ln -sf ${source_bmk}

  popd
done


exit $?

