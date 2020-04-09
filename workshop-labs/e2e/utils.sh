function title() {
  title=$1
  printf "\n================================================ \n\n"
  printf "=================$title==================== \n\n"
  printf "================================================ \n\n"
}

function prompt() {
  msg=$1
  printf "\n --> $msg \n"
}

# similar to mocha/chai style TDD
# this function is meant to describe a set of tests
# usage: describe {Int} {String}
# eg. describe 1 "Test Section" => "---> Describe: 1. Test Section"
function describe() {
  unitNumber=$1
  msg=$2
  prompt "Describe: $1. $2"
}

# similar to mocha/chai style TDD
# this function is meant to describe a assertion
# usage: describe {String}
# eg. assert "The Test Passed" => "---> Assert: The Test Passed"
function assert() {
  assertion=$1
  prompt "Assert: $1"
}

function exitNicely {
  printf "\n\n Exiting :) \n\n"
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

function checkWhoAmI {
  prompt "*reminder* You need to be logged in to run this e2e test\n"

  WHO_ARE_YOU=$(oc whoami)

  prompt "Logged in as $WHO_ARE_YOU \n\n"
}