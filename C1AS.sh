printf '%s\n' "---------------------"
printf '%s\n' "     Adding C1AS     "
printf '%s\n' "---------------------"


function create_c1as_group {
# parm = ${1} = name of the app"
# Creating groups
# if a group object for this project-app already exists in c1as, then delete it first
export APP=${1}
[ ${VERBOSE} -eq 1 ] &&  echo "Reading existing group objects in C1AS"
readarray -t C1ASGROUPS <<< `curl --silent --location --request GET "${C1ASAPIURL}/accounts/groups" --header 'Content-Type: application/json' --header "${C1AUTHHEADER}" --header 'api-version: v1' | jq -r ".[].name"`
readarray -t DUMMYARRAYTOFIXSYNTAXCOLORINGINVSCODE <<< `pwd `
[ ${VERBOSE} -eq 1 ] &&  echo C1ASGROUPS[@] =  ${C1ASGROUPS[@]}
readarray -t C1ASGROUPIDS <<< `curl --silent --location --request GET "${C1ASAPIURL}/accounts/groups" --header 'Content-Type: application/json' --header "${C1AUTHHEADER}" --header 'api-version: v1' | jq -r ".[].group_id"`
readarray -t DUMMYARRAYTOFIXSYNTAXCOLORINGINVSCODE <<< `pwd `

for i in "${!C1ASGROUPS[@]}"
do
  [ ${VERBOSE} -eq 1 ] &&  printf "%s\n" "C1AS: found group ${C1ASGROUPS[$i]} with ID ${C1ASGROUPIDS[$i]}"
  if [[ "${C1ASGROUPS[$i]}" == "${C1PROJECT^^}-${APP^^}" ]]; 
  then
    printf "%s\n" "Deleting old Group object ${C1PROJECT^^}-${APP^^} in C1AS"
    curl --silent --location --request DELETE "${C1ASAPIURL}/accounts/groups/${C1ASGROUPIDS[$i]}"   --header 'Content-Type: application/json' --header "${C1AUTHHEADER}" --header 'api-version: v1' 
  fi
done 

export PAYLOAD="{ \"name\": \"${C1PROJECT^^}-${APP^^}\"  }"
printf "%s" "(Re-)creating Group object ${C1PROJECT^^}-${APP^^} in C1AS..."
export C1ASGROUPCREATERESULT=`\
curl --silent --location --request POST "${C1ASAPIURL}/accounts/groups/"   --header 'Content-Type: application/json' --header "${C1AUTHHEADER}" --header 'api-version: v1'  --data-raw "${PAYLOAD}" \
`
[ ${VERBOSE} -eq 1 ] &&  echo $C1ASGROUPCREATERESULT
APPSECKEY=`echo "$C1ASGROUPCREATERESULT" | jq   -r ".credentials.key"`
[ ${VERBOSE} -eq 1 ] &&  echo APPSECKEY=$APPSECKEY
APPSECRET=`echo "$C1ASGROUPCREATERESULT" | jq   -r ".credentials.secret"`
[ ${VERBOSE} -eq 1 ] &&  echo APPSECRET= $APPSECRET
if [[ "$APPSECKEY" == "null"  ]];then
   printf "\n%s\n" "Failed to create group object in C1AS for ${APP}"; 
   read -p "Press CTRL-C to exit script, or Enter to continue anyway (script will fail)"
else
  printf "%s\n" "OK"
fi
} 

#end of function

create_c1as_group $APP1 
export APP1KEY=${APPSECKEY}
export APP1SECRET=${APPSECRET}

create_c1as_group $APP2 
export APP2KEY=${APPSECKEY}
export APP2SECRET=${APPSECRET}

create_c1as_group $APP3 
export APP3KEY=${APPSECKEY}
export APP3SECRET=${APPSECRET}
