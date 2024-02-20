## Run as a shell script using `sh cleanup.sh`. 
LICENCEPLATES=(eca693 ecac3f c2a206 be8d7e ede379 e1f581 aa15e2 c0571b bc454e bba23e b353f4 cf8581 ef3c25 c37719 fe64f4 eb7e66 b80657 e3fa55 f73ace b51b5b cb1c00 b90f3e a6eb7f a98b55 b08a99 a16599)
SUFFIXES=(-dev -test -tools -prod)
OBJECTS=(all secret configmap pvc el route svc netpol pipelines pipelineruns tasks pdb triggerBindings triggerTemplates hpa vpa)

for licenceplate in ${LICENCEPLATES[@]}; do
  for suffix in ${SUFFIXES[@]}; do
    for object in "${OBJECTS[@]}"; do
      oc -n "${licenceplate}${suffix}" delete "$object" --all
    done
  done
done
