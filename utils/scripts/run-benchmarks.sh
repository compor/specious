#!/bin/bash

# initialize configuration vars

BMK_INSTALL_DIR=""
INPUT_TYPE="test"

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

# set configuration vars

if [ -z "$1" ]; then 
  echo "error: benchmark directory was not provided" 

  exit 1
fi

BMK_INSTALL_DIR=$1


if [ -z "$2" ]; then 
  echo "error: cmake target fragment file was not provided" 

  exit 2
fi

INPUT_TYPE=$2


# print configuration vars

echo "info: printing configuation vars"
echo "info: benchmark install dir: ${BMK_INSTALL_DIR}"
echo "info: input type: ${INPUT_TYPE}"
echo ""


for b in ${BENCHMARKS[@]}; do
  cd $BMK_INSTALL_DIR/${b}
  SHORT_EXE=${b##*.} # cut off the numbers ###.short_exe

  # read the command file
  IFS=$'\n' read -d '' -r -a commands < ../invocations/${b}.${INPUT_TYPE}.cmd

  for input in "${commands[@]}"; do
    if [[ ${input:0:1} != '#' ]]; then # allow us to comment out lines in the cmd files
      echo "~~~Running ${b}"
      pushd data/${INPUT_TYPE}/input/
      echo "  ${RUN} ${SHORT_EXE} ${input}"
      eval ${RUN} ../../../exe/${SHORT_EXE} ${input}
      popd
    fi
  done
done

echo ""
echo "Done!"

