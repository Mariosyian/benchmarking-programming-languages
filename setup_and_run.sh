#!/bin/bash

if ! command -v docker
then
    echo "Docker is not currently installed on this system, or is not on your PATH variable."
    echo "Would you like to run `sudo apt install docker -y` and install docker (requires sudo)? y/N"
    read CHOICE
    if [ $CHOICE == "" | $CHOICE == "N" | $CHOICE == "n"]
    then
        echo "Please install docker manually and rerun the setup script."
    elif [ $CHOICE == "Y" | $CHOICE == "y" ]
    then
        sudo apt isntall docker -Y
        echo "Docker was install at ${command -v docker}"
    else
        echo "Invalid input. Please rerun the setup script."
fi

if ! systemctl is-active --quiet docker
then
    echo "The docker service is down."
    echo "Would you like to run `sudo systemctl start docker` to start the docker service (requires sudo)? y/N"
    read CHOICE
    if [ $CHOICE == "" | $CHOICE == "N" | $CHOICE == "n"]
    then
        echo "Please start the docker service manually and rerun the setup script."
    elif [ $CHOICE == "Y" | $CHOICE == "y" ]
    then
        sudo systemctl start docker
        echo "The Docker has been started."
    else
        echo "Invalid input. Please rerun the setup script."
fi

cd /home/benchmarking-programming-languages/

docker-compose up .

chmod +x ./benchmark.sh

./benchmark.sh
