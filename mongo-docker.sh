#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
PURPLE="\033[0;35m" 
LIGHTBLUE="\033[0;36m"
LIGHTBLUEB="\033[1;36m"
YELLOWB="\033[1;33m"
NC='\033[0m' # No Color

PASSWORD=""
VOLUMEPATH=""
DIRECTORY=""

usage() { 
    printf "MongoDB Docker Deployment\n\n"
    printf "The script will create a docker container of MongoDB. The path that you pass should be an absolute path."
    printf "Options:\n\n"
    echo "-o [ i | install ] - Create a docker container & volume to attach to"
    echo "-o [ c | cleanup ] - Clean up installation, including docker image"
    printf "\nArguments (install):\n\n"
    echo "-p - Add a user assigned password for your DB"
    echo "-d - Add a directory that you want to create the mongo-data folder in"
    printf "\nArguments (cleanup):\n\n"
    echo "-d - Add the path of your mongo-data directory that you want the script to delete"

    exit 1; 
}

function folderCheck() {
    if [ -d "${VOLUMEPATH}/mongo-data" ];
        then
            printf "Directory mongo-data exists. Assigning as volume to docker image.\n"
        else
            echo "Error: Directory mongo-data was not found. Creating directory now. ${NC}"
            mkdir ${VOLUMEPATH}/mongo-data
    fi
}

function dockerContainerSetup() {
    echo -e "${GREEN}########################################################${NC}"
    echo -e "${GREEN}############# PULLING MONGODB DOCKER IMAGE #############${NC}"
    echo -e "${GREEN}########################################################${NC}\n"

    docker pull mongo

    echo -e "${GREEN}############################################################${NC}"
    echo -e "${GREEN}############# STARTING MONGODB DOCKER CONTAINER ############${NC}"
    echo -e "${GREEN}############################################################${NC}\n"

    docker run -it -v ${VOLUMEPATH}/mongo-data:/data/db --name mongo -d -p 27017:27017 mongo mongod --replSet my-mongo-set

}

function dockerExecCommands() {
    
    isDockerRunning=$(docker inspect -f {{.State.Running}} mongo) 

    sleep 1

    if [ "$isDockerRunning" = true ];
    then

        docker exec -it mongo mongo --eval "rs.initiate()"

        sleep 1

        docker exec -it mongo mongo --eval "cdr = db.getSiblingDB('cdr');cdr.createUser({ user: 'mongo', pwd: '$PASSWORD', roles: [ { role: 'readWrite', db: 'cdr' } ]})"
        
        echo -e "${LIGHTBLUEB}Your connection url is${YELLOWB} mongodb://localhost:27017/cdr${NC}. Your username is${LIGHTBLUEB} mongo${NC} & your password is ${LIGHTBLUEB}$PASSWORD${NC} "
    else
        echo "There was an error starting mongo. Check the logs or error output from Docker."
    fi
}

function checkLastCharacterOfVolumePath() {
    if [[ -n "$VOLUMEPATH" ]]; then 
        lastCharacter=${VOLUMEPATH: -1}
        if [[ $lastCharacter == "/" ]]; then
         echo $lastCharacter $VOLUMEPATH
            cleanedText=${VOLUMEPATH:0:-1}
            $VOLUMEPATH=cleanedText
        fi
    fi
}

function cleanup() {
    printf "Running cleanup\n"
    echo ""

    docker stop mongo
    echo ""

    docker rm mongo
    echo ""

    docker rmi mongo
    # echo ""

    if [ -d "${VOLUMEPATH}/mongo-data" ];
    then
        echo "Directory mongo-data exists. Removing."
        rm -rf "${VOLUMEPATH}/mongo-data"
    else
        echo "Directory mongo-data was not found. No further action required."
    fi

    echo "done."
}

while getopts o:p:d: flag
do
    case "${flag}" in
        o) OPTION=${OPTARG};;
        p) ARGUMENT=${OPTARG};;
        d) DIRECTORY=${OPTARG};;
        *) usage;;
    esac
done

if [[ -z "$OPTION" && -z "$DIRECTORY" ]]; then
    usage
fi

if [[ -n "$OPTION" ]]; then 

    VOLUMEPATH=$DIRECTORY

    checkLastCharacterOfVolumePath

    if [[ $OPTION =~ ^i(nstall)?$ ]] && [[ -n "$ARGUMENT" ]]; then
        folderCheck
    
        dockerContainerSetup

        PASSWORD=$ARGUMENT

        dockerExecCommands
    elif [[ $OPTION =~ ^c(leanup)?$ ]] && [[ -n "$DIRECTORY" ]]; then
        cleanup
    else 
        usage
    fi

fi
