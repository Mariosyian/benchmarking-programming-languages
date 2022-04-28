#!/bin/bash
if ! command -v docker -o ! command -v docker-compose; then
    echo "Docker is not currently installed on this system, or is not on your PATH variable."
    echo "Would you like to run `sudo apt install docker docker-compose -y` and install docker (requires sudo)? y/N [default=N]"
    read CHOICE
    if [ $CHOICE == "" | $CHOICE == "N" | $CHOICE == "n"]; then
        echo "Please install docker manually and rerun the setup script."
    elif [ $CHOICE == "Y" | $CHOICE == "y" ]; then
        sudo apt install docker docker-compose -y
        echo "Docker was installed at ${command -v docker}"
        echo "Docker compose was installed at ${command -v docker-compose}"
    else
        echo "Invalid input. Please rerun the setup script."
        exit 1
fi

if ! systemctl is-active --quiet docker; then
    echo "The docker service is down."
    echo "Would you like to run `sudo systemctl start docker` to start the docker service (requires sudo)? y/N [default=N]"
    read CHOICE
    if [ $CHOICE == "" | $CHOICE == "N" | $CHOICE == "n"]; then
        echo "Please start the docker service manually and rerun the setup script."
    elif [ $CHOICE == "Y" | $CHOICE == "y" ]; then
        sudo systemctl start docker
        echo "The Docker service has been started."
    else
        echo "Invalid input. Please rerun the setup script."
        exit 1
fi

if ! systemctl is-active --quiet docker; then
    docker run .
    exit 0
else
    echo "Something went wrong when attempting to start the docker service."
    echo "Please start the docker service manually and rerun the setup script."
    exit 2
