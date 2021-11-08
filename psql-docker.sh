#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "What do you want to do?"
echo "install | i) Install postgres"
echo "cleanup | c) Cleanup postgres image, container & folders generated from this script"
echo "Enter any other key to escape"
echo ""
read choice

case "$choice" in
    c | cleanup)
        echo "Running cleanup"
        echo ""

        docker stop postgres
        echo ""

        docker rm postgres
        echo ""

        docker rmi postgres
        echo ""

        if [ -d "${HOME}/postgres-data" ] 
        then
            echo "Directory postgres-data exists. Removing."
            rm -rf ${HOME}/postgres-data
        else
            echo "Directory postgres-data was not found. No further action required."
        fi

        echo "done."
        ;;
    i | install)
        if [ -d "${HOME}/postgres-data" ] 
        then
            echo -e "${GREEN}Directory postgres-data exists. Assigning as volume to docker image${NC}"
            echo ""
        else
            echo ""
            echo -e "${RED}Error: Directory postgres-data was not found. Creating directory now.${NC}"
            mkdir ${HOME}/postgres-data
            echo ""
        fi

        echo -e "${GREEN}#########################################################${NC}"
        echo -e "${GREEN}############# PULLING POSTGRES DOCKER IMAGE #############${NC}"
        echo -e "${GREEN}#########################################################${NC}"
        echo

        docker pull postgres

        echo
        echo -e "${GREEN}##########################################################${NC}"
        echo -e "${GREEN}############# STARTING POSTGRES DOCKER IMAGE #############${NC}"
        echo -e "${GREEN}##########################################################${NC}"
        echo

        docker run --name postgres -e POSTGRES_PASSWORD=password -v ${HOME}/postgres-data/:/var/lib/postgresql/data -d -p 5432:5432 postgres

        echo
        echo -e "${GREEN}Postgres should now run on localhost:5432${NC}"
        echo -e "${GREEN}Username is ${NC}" postgres "${GREEN}, Password is${NC}" password
        echo
        ;;
    *)
        echo "Exiting."
        ;;
esac