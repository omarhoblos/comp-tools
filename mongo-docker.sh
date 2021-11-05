#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
PURPLE="\033[0;35m" 
LIGHTBLUE="\033[0;36m"
LIGHTBLUEB="\033[1;36m"
YELLOWB="\033[1;33m"
NC='\033[0m' # No Color

DIR="${HOME}/mongo-data"

echo "What do you want to do?"
echo "install | i) Install mongodb"
echo "cleanup | c) Cleanup mongo image, container & folders generated from this script"
echo "Enter any other key to escape"
echo ""
read choice

case "$choice" in
    c | cleanup)
        echo "Running cleanup"
        echo ""

        docker stop mongo
        echo ""

        docker rm mongo
        echo ""

        docker rmi mongo
        # echo ""

        if [ -d "$DIR" ] 
        then
            echo "Directory mongo-data exists. Removing."
            rm -rf ${HOME}/mongo-data
        else
            echo "Directory mongo-data was not found. No further action required."
        fi

        echo "done."
        ;;
    i | install)
        if [ -d "${HOME}/mongo-data" ] 
        then
            echo "Directory mongo-data exists. Assigning as volume to docker image."
            echo ""
        else
            echo "Error: Directory mongo-data was not found. Creating directory now.${NC}\n"
            mkdir ${HOME}/mongo-data
        fi

        echo -e "${GREEN}########################################################${NC}"
        echo -e "${GREEN}############# PULLING MONGODB DOCKER IMAGE #############${NC}"
        echo -e "${GREEN}########################################################${NC}\n"

        docker pull mongo

        echo
        echo -e "${GREEN}############################################################${NC}"
        echo -e "${GREEN}############# STARTING MONGODB DOCKER CONTAINER ############${NC}"
        echo -e "${GREEN}############################################################${NC}\n"

        docker run -it -v ${HOME}/mongo-data:/data/db --name mongo -d -p 27017:27017 mongo mongod --replSet my-mongo-set

        echo ""


        isDockerRunning=$(docker inspect -f {{.State.Running}} mongo) 

        sleep 1

        if [ "$isDockerRunning" = true ];
        then

            docker exec -it mongo mongo --eval "rs.initiate()"

            sleep 1

            docker exec -it mongo mongo --eval "cdr = db.getSiblingDB('cdr');cdr.createUser({ user: 'mongo', pwd: <PASSWORD>, roles: [ { role: 'readWrite', db: 'cdr' } ]})"
            
            echo -e "${LIGHTBLUEB}Your connection url is${YELLOWB} mongodb://localhost:27017/cdr${NC}"
        else
            echo "There was an error starting mongo. Check the logs or error output from Docker."
        fi
        ;;

    *)
        echo "Exiting."
        ;;
esac

