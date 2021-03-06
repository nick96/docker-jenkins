#!/usr/bin/env bash

usage() {
    echo <<EOF
$0 IMAGE_NAME CONTAINER_NAME
EOF
}

cleanup() {
    docker stop $CONTAINER_NAME
}
trap cleanup EXIT

IMAGE_NAME=$1
if [ -z "$IMAGE_NAME" ]
then
    usage
    exit 1
fi
CONTAINER_NAME=${2:-jenkins}


docker run --detach --name $CONTAINER_NAME "${IMAGE_NAME}:latest" >/dev/null
if [ $? -ne 0 ]
then
   echo "Error: Expected to start '$CONTAINER_NAME'"
   exit 1
fi

echo "Checking container status..."
while [ $(docker inspect --format "{{json .State.Health.Status}}" $CONTAINER_NAME) -eq "starting" ]
do
    sleep 3
done

if [ $(docker inspect --format "{{json .State.Health.Status}}" $CONTAINER_NAME) -ne "healthy"]
then
    echo "Error: Expected healthy status for container '$CONTAINER_NAME" >/dev/stderr
    exit 1
fi


echo "Checking installed applications..."
for app in terraform ansible
do
    docker exec $CONTAINER_NAME which $app
    if [ $? -ne 0 ]
    then
	echo "Error: Expected $app to be installed"
	exit 1
    fi
done
