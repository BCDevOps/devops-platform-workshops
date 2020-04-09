#!/bin/bash
#perl -0777 -ne 'while(m/```oc:cli(.+?)```/gsi){print "$1\n";}' 05_deployment.md


find "$1" -type f -name '*.md' | sort | while read -r path; do
  perl -0777 -ne 'while(m/```oc:cli(.+?)```/gsi){print "$1\n";}' "${path}" | awk '{$1=$1};1'
done;
