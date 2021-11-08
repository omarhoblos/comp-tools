#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
PURPLE="\033[0;35m" 
LIGHTBLUE="\033[0;36m"
LIGHTBLUEB="\033[1;36m"
YELLOWB="\033[1;33m"
NC='\033[0m' # No Color

usage() { 
    printf "${PURPLE}MongoDB Docker Deployment${NC}\n\n"
    printf "The script will create a docker container of MongoDB.\n\nThe path that you pass should be an absolute path.\n\n"
    printf "${YELLOWB}NOTE - Docker changes ownership of your data folder to root. \nIf you need to run the cleanup script, run this script with${NC} ${LIGHTBLUEB}sudo${NC}\n\n"
    printf "Options:\n\n"
    echo "-o [ i | install ] - Create a docker container & volume to attach to"
    echo "-o [ c | cleanup ] - Clean up installation, including docker image"
    printf "\nArguments (install):\n\n"
    echo "-p - Add a user assigned password for your DB"
    echo "-d - Add a path to the directory that you want to create the mongo-data folder in"
    printf "\nArguments (cleanup):\n\n"
    echo "-d - Add the path of your mongo-data directory that you want the script to delete"

    exit 1; 
}

function folderCheck() {
    if [ -d "$1" ]; then
        if [ -d "$1/mongo-data" ]; then
            printf "Directory mongo-data exists. Assigning as volume to docker image.\n"
        else
            printf "${RED}Error: Directory mongo-data was not found. Creating directory now.${NC}\n"
            mkdir "$1"/mongo-data
        fi
    else 
        printf "${RED}Error: Directory could not be resolved. Exiting${NC}\n"
        exit 1;
    fi
}

function dockerMongoContainerSetup() {
    echo -e "${GREEN}########################################################${NC}"
    echo -e "${GREEN}############# PULLING MONGODB DOCKER IMAGE #############${NC}"
    echo -e "${GREEN}########################################################${NC}\n"

    docker pull mongo

    echo -e "${GREEN}############################################################${NC}"
    echo -e "${GREEN}############# STARTING MONGODB DOCKER CONTAINER ############${NC}"
    echo -e "${GREEN}############################################################${NC}\n"

    docker run -it -v "$1"/mongo-data:/data/db --name mongo -d -p 27017:27017 mongo mongod --replSet my-mongo-set
}

function dockerMongoExecCommands() {
    
    isDockerRunning=$(docker inspect -f "{{.State.Running}}" mongo) 

    sleep 1

    if [ "$isDockerRunning" = true ]; then
        docker exec -it mongo mongo --eval "rs.initiate()"

        sleep 1

        docker exec -it mongo mongo --eval "cdr = db.getSiblingDB('cdr');cdr.createUser({ user: 'mongo', pwd: '$1', roles: [ { role: 'readWrite', db: 'cdr' } ]})"
        
        echo -e "${LIGHTBLUEB}Your connection url is${YELLOWB} mongodb://localhost:27017/cdr${NC}. Your username is${LIGHTBLUEB} mongo${NC} & your password is ${LIGHTBLUEB}$1${NC}"
    else
        printf "${RED}There was an error starting mongo. Check the logs or error output from Docker.${NC}\n"
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
    echo ""

    if [ -d "$1/mongo-data" ];
    then
        echo "Directory mongo-data exists. Removing."
        rm -rf "$1/mongo-data"
    else
        echo "Directory mongo-data was not found. No further action required."
    fi

    echo "done."
}

while getopts o:p:d:db: flag
do
    case "${flag}" in
        o) OPTION=${OPTARG};;
        p) ARGUMENT=${OPTARG};;
        d) DIRECTORY=${OPTARG};;
        db) DATABASETYPE=${OPTARG};;
        *) usage;;
    esac
done

if [[ -z "$OPTION" && -z "$DIRECTORY" ]]; then
    echo "$OPTION" "$DIRECTORY"
    usage
fi

if [[ -n "$OPTION" ]]; then 

    if [[ $OPTION =~ ^i(nstall)?$ ]] && [[ -n "$ARGUMENT" ]]; then
        folderCheck $DIRECTORY
    
        dockerMongoContainerSetup $DIRECTORY

        dockerMongoExecCommands $ARGUMENT
    elif [[ $OPTION =~ ^c(leanup)?$ ]] && [[ -n "$DIRECTORY" ]]; then
        cleanup
    fi

fi
