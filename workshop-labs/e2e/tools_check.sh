printf "===========Running Tools Check===========\n\n\n"

function exitNicely {
  printf "\n\n Exiting :) \n\n"
  rm ${temp_bc_file}
  rm ${temp_dc_file}
  exit 1
}

printf "Checking helm \n\n"
if [ -z $(which helm) ];
then
  printf "helm cannot be found"
  exitNicely
fi

printf "Checking jq \n\n"

if [ -z $(which jq) ];
then
  printf "jq cannot be found"
  exitNicely
fi


printf "Checking sponge \n\n"

if [ -z $(which sponge) ];
then
  printf "sponge cannot be found"
  exitNicely
fi

printf "Checking oc \n\n"
if [ -z $(which oc) ];
then
  printf "oc cannot be found"
  exitNicely
fi

printf "Checking tput \n\n"
BLUE=""
if [ -z $(which tput) ];
then
  printf "tput cannot be found. it is used for color formatting."
  BLUE=$(tput setaf 4)
fi

printf "===========Tools Check Complete===========\n\n\n"