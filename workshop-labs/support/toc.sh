#!/bin/bash
find "$1" -type f -name '*.md' | sort | while read -r path; do
  header="$(head -1 "${path}" | sed -e 's/^#[[:space:]]*//' -e 's/[[:space:]]*$//')"
  echo "* [$header](${path:2})"
done;