# I'm using this shell script to have a quick way to check learner progress across the multiple OpenShift 201 namespaces. 
# Namespaces without any resources are omitted from the output

NAMESPACES=(eca693 ecac3f c2a206 be8d7e ede379 e1f581 aa15e2 c0571b bc454e bba23e b353f4 cf8581 ef3c25 c37719 fe64f4 eb7e66 b80657 e3fa55 f73ace b51b5b cb1c00)
SUFFIXES=(-dev -tools -prod)
OBJECTS=(pods)

for namespace in ${NAMESPACES[@]}; do
  for suffix in ${SUFFIXES[@]}; do
    for object in "${OBJECTS[@]}"; do
      # run oc command and capture output
      output=$(oc -n "${namespace}${suffix}" get "$object" 2>&1)
      
      # check if output contains "No resources found" message
      if ! echo "$output" | grep -q "No resources found"; then
        # print output with namespace prefix if it does not contain "No resources found" message
        echo "NAMESPACE: ${namespace}${suffix}"
        echo "$output"
      fi
    done
  done
done