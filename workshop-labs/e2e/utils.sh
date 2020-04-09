function title() {
  title=$1
  printf "================================================ \n\n"
  printf "=================$title==================== \n\n"
  printf "================================================ \n\n"
}

function prompt() {
  msg=$1
  printf "\n --> $msg \n"
}

function exitNicely {
  printf "\n\n Exiting :) \n\n"
  rm ${temp_bc_file}
  rm ${temp_dc_file}
  exit 1
}


function checkDevAndToolsNamespaceAreSet {
  
  prompt "Checking DEV_NAMESPACE and TOOLS_NAMESPACE variables \n\n"

  if [ -z ${DEV_NAMESPACE+x} ]; 
    then 
      echo "DEV_NAMESPACE not set. Exiting"
      exitNicely
    else prompt "DEV_NAMESPACE set to ${DEV_NAMESPACE} \n\n" 
  fi

  if [ -z ${TOOLS_NAMESPACE+x} ]; 
    then 
      echo "TOOLS_NAMESPACE not set. Exiting"
      exitNicely
    else prompt "TOOLS_NAMESPACE set to ${TOOLS_NAMESPACE} \n\n" 
  fi

}

function checkNamespaceValidity {
  prompt "Checking the namespaces are valid \n\n"

  NAMESPACES=$(oc projects)

  if [ -z $(echo "$NAMESPACES" | grep -w "${DEV_NAMESPACE}") ]
  then
    echo "DEV_NAMESPACE doesn't exist. Exiting"
    exitNicely
  else prompt "DEV_NAMESPACE exists \n\n" 
  fi


  if [ -z $(echo "$NAMESPACES" | grep -w "${TOOLS_NAMESPACE}") ]
  then
    echo "TOOLS_NAMESPACE doesn't exist. Exiting"
    exitNicely
  else prompt "TOOLS_NAMESPACE exists \n\n" 
  fi

}