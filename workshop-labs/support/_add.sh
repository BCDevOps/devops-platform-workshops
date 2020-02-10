#!/bin/bash
# Rename files between $1 and $2 by incrementing by one
seq $2 -1 $1 | while read -r num path; do
  num2=$(($num + 1))
  prefix="$(printf '%02d' $num)"
  prefix2="$(printf '%02d' $num2)"
  file="$(find . -type f -name "${prefix}_*")"
  file2="./${prefix2}${file:4}"
  git mv "${file:2}" "${file2:2}"
done