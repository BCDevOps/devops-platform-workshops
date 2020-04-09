set -e
TEMPLATE_PATH="${LABS_BUILD_TEMPLATE_PATH}"

echo "Preparing source archive file"
pushd "${GIT_TOP_DIR}" > /dev/null
jq -rM '.objects[] | select(.kind == "BuildConfig") | [.metadata.name, .spec.source.contextDir] | @tsv' "${TEMPLATE_PATH}" | while read -r name path; do
  _gtar "--file=${SCRIPT_PATH}/${name}.source.tar.gz" '--exclude=*/node_modules' "$path"
done
popd > /dev/null

echo "Applying template"
oc -n "${NS_WORKBENCH}" process -f "${TEMPLATE_PATH}" -l "app=ocp101-labs" | oc -n "${NS_WORKBENCH}" apply -f - --overwrite=true

echo "Starting build"
jq -rM '.objects[] | select(.kind == "BuildConfig") | [.metadata.name, .spec.source.contextDir] | @tsv' "${TEMPLATE_PATH}" | while read -r name path; do
  oc -n "${NS_WORKBENCH}" start-build "$name" "--from-archive=${SCRIPT_PATH}/${name}.source.tar.gz" --wait
  echo rm "${SCRIPT_PATH}/${name}.source.tar.gz"
done;
