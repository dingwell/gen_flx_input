#!/bin/bash
# Takes a list of files as argument,
# Will print contents of a matching flexpart AVAILABLE file to stdout
#
# ** Assumes that files are named after the following format:
# ** Assumes that files with a year >50 represent years <2000
#
# AAyymmddHH
#
# Where   "AA" is a two-letter prefix
#         "yy" is a two-digit year
#         "mm" is a two-digit month
#         "dd" is a two-digit day
#         "HH" is a two-digit hour
#
# Usage:
#   ./files2available.sh

FILES=$@

echo "DATE     TIME        FILENAME              SPECIFICATIONS"
echo "YYYYMMDD HHMMSS"
echo "________ ______      __________ __________ __________"

for i in $FILES; do
  i=${i##*/}  # Remove path from $i (e.g. A=/aa/bb/cc.txt; echo ${A##*/} -> "cc.txt")
  yy=${i:2:2}
  if [[ $yy > 50 ]]; then
    yyyy="19$yy"
  else
    yyyy="20$yy"
  fi
  mm=${i:4:2}
  dd=${i:6:2}
  HH=${i:8:2}
  echo "${yyyy}${mm}${dd} ${HH}0000      $i            ON DISK"
done
