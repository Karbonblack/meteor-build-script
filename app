#!/bin/bash

############
# SETTINGS #
############
URL=http://www.yourdomain.com
DB=test
PORT=3010
SMTP=smtp://localhost















################################
# DO NOT CHANGE ANYTHING BELOW #
# ##############################

BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

install()
{
    if ! type 'pv' > /dev/null; then
        echo "${BLUE}Installing: ${GREEN}pv ${NC}"
        apt-get install pv
        echo "${BLUE}Installed: ${GREEN}pv ${NC}"
    fi

    if ! type 'forever' > /dev/null; then
        echo "${BLUE}Installing: ${GREEN}forever ${NC}"
        npm install -g forever
        echo "${BLUE}Installed: ${GREEN}forever ${NC}"
    fi

    # Extract bundle
    echo "${BLUE}Extracting... ${NC}"
    pv bundle.tar.gz | tar xzf - -C $PWD
    echo "${BLUE}Extracted. ${NC}"

    # Install node modules
    echo "${BLUE}Installing: ${GREEN}node modules${NC}"
    /bin/sh -c 'cd $PWD/bundle/programs/server && npm install'
    echo "${BLUE}Installed. ${NC}"

    # Rebuild
    # if [ -d "$PWD/bundle/programs/server/npm/node_modules/bcrypt" ]; then
    # echo "${BLUE}Installing node modules... ${NC}"
    # fi
}



# Run meteor server
start_meteor()
{
    # Export variables
    export ROOT_URL=$URL
    export MONGO_URL=mongodb://127.0.0.1:27017/$DB
    export PORT=$PORT
    export MAIL_URL=$SMTP

    if [ -e '$PWD/bundle/settings.json' ]; then
        export METEOR_SETTINGS=$(cat $PWD/bundle/settings.json)
        echo "Loading settings.json"
    else
        echo "No settings.json found."
    fi

    echo  "${BLUE}Starting app...${GREEN}" $ROOT_URL:$PORT "${NC}"
    forever start $PWD/bundle/main.js
    echo "${GREEN}Started${NC}"
}

# Stop meteor app
stop_meteor()
{
    echo  "${BLUE}Stopping...${NC}"
    forever stop $PWD/bundle/main.js
    echo "${GREEN}Stopped${NC}"
}

# Print help texts
help_txt()
{
    echo "-> ${GREEN}install ${NC}: ${BLUE}Install meteor app.${NC}"
    echo "-> ${GREEN}start   ${NC}: ${BLUE}Start the meteor app.${NC}"
    echo "-> ${GREEN}stop    ${NC}: ${BLUE}Stop the meteor app.${NC}"
    echo "-> ${GREEN}test    ${NC}: ${BLUE}Test run meteor app.${NC}"
    echo "-> ${GREEN}help    ${NC}: ${BLUE}Shows this message.${NC}"

}

# Test run
test_meteor()
{
    echo  "${BLUE}Test run...${NC}"
    node $PWD/bundle/main.js
    echo "${BLUE}Check now..${GREEN}" $ROOT_URL:$PORT "${NC}"
}

# Handle
if [ "$1" != "" ]; then
    if [ "$1" = "stop" ]; then
        stop_meteor
    elif [ "$1" = "install" ]; then
        install
    elif [ "$1" = "help" ]; then
        help_txt    
    elif [ "$1" = "start" ]; then
        start_meteor
    elif [ "$1" = "test" ]; then
        test_meteor
    fi
else
    start_meteor
fi
