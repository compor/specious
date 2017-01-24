#!/bin/bash

# initialize configuration vars

BMK_SOURCE_DIR=""
OUTPUT_FILENAME="project_files.txt"

BENCHMARKS=(
  "400.perlbench"
  "401.bzip2"
  "403.gcc"
  "429.mcf"
  "433.milc"
  "444.namd"
  "445.gobmk"
  "447.dealII"
  "450.soplex"
  "453.povray"
  "456.hmmer"
  "458.sjeng"
  "462.libquantum"
  "464.h264ref"
  "470.lbm"
  "471.omnetpp"
  "473.astar"
  "482.sphinx3"
  "483.xalancbmk"
)

# set configuration vars

if [ -z "$1" ]; then 
  echo "error: benchmark source directory was not provided" 

  exit 1
fi

BMK_SOURCE_DIR=$1


if [ -z "$2" ]; then 
  echo "error: output file name was not provided" 

  exit 2
fi

OUTPUT_FILENAME=$2


# print configuration vars

echo "info: printing configuration vars"
echo "info: benchmark source dir: ${BMK_SOURCE_DIR}"
echo "info: output file name: ${OUTPUT_FILENAME}"
echo ""


for bmk in ${BENCHMARKS[@]}; do
  pushd $BMK_SOURCE_DIR/${bmk}/src/
  find . -name '*.h' \
    -o -name '*.hpp' \
    -o -name '*.hxx' \
    -o -name '*.C' \
    -o -name '*.c' \
    -o -name '*.cpp' \
    -o -name '*.cxx' > ../${OUTPUT_FILENAME}
  popd
done

echo ""
echo "Done!"

