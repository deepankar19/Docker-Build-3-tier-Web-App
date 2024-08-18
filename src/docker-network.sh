#!/bin/bash

# build image function 
build_and_pull_image() {
    Build_image_name=$1
    IMAGE_NAME_BUILD="$Build_image_name:latest"
    # echo "Image Name: $IMAGE_NAME_BUILD"
    # echo "$Build_image_name"/Dockerfile

     if docker image inspect $IMAGE_NAME_BUILD > /dev/null 2>&1; then
        echo "Image $IMAGE_NAME_BUILD exists locally."
     else
        if docker pull "$IMAGE_NAME_BUILD"; then
            echo "Image pulled successfully"
        else
            echo "Failed to pull image, building locally"
            docker build -f "$Build_image_name"/Dockerfile -t "$IMAGE_NAME_BUILD" .
        fi
    fi
}


# Add Docker Custom Network

network_name="app-network" # Replace with the name of the network you want to check and add
driver="bridge" # Replace with the driver of the network you want to add

if docker network inspect "$network_name" >/dev/null 2>&1; then
    echo "Network $network_name exists."
else
    echo "Network $network_name does not exist."
    docker network create $network_name --driver=$driver 
    docker network ls
fi

# Add Docker Image 

MONGO_IMAGE="mongo:latest"
MONGO_EXPRESS_IMAGE="mongo-express:latest"

# Function to check and pull an image if not found locally
check_and_pull_image() {
    IMAGE_NAME=$1
    if docker image inspect $IMAGE_NAME > /dev/null 2>&1; then
        echo "Image $IMAGE_NAME exists locally."
    else
        echo "Image $IMAGE_NAME does not exist locally."
        docker pull $IMAGE_NAME
    fi
}

# Check and pull MongoDB image
check_and_pull_image $MONGO_IMAGE 
                or 
check_and_pull_image "mongo:latest"
   

# Check and pull Mongo Express image
check_and_pull_image $MONGO_EXPRESS_IMAGE
              or 
check_and_pull_image "mongo-express:latest"

# Volume name to check
VOLUME_NAME="app-volume"

# Check if the volume exists
VOLUME_EXISTS=$(docker volume ls -q --filter name=^${VOLUME_NAME}$)

if [ "$VOLUME_EXISTS" ]; then
    echo "Volume '$VOLUME_NAME' exists."
else
    echo "Volume '$VOLUME_NAME' does not exist."
    # Optionally, create the volume if it doesn't exist
    echo "Creating volume '$VOLUME_NAME'..."
    docker volume create $VOLUME_NAME
    echo "Volume '$VOLUME_NAME' created."
fi

# create a container 
# Function to run a Docker container
run_container() {
    IMAGE_NAME=$1
    CONTAINER_NAME=$2
    PORT_MAPPING=$3
    ENV_VARS=$4
    APP_VOLUME=$5

    # Check if a container with the given name already exists
    if [ "$(docker ps -aq -f name=^${CONTAINER_NAME}$)" ]; then
        echo "Container $CONTAINER_NAME already exists."
    else
        echo "Running container $CONTAINER_NAME..."

        # Check if the container name is "mongo"
        if [ "$CONTAINER_NAME" == "mongo" ]; then
            docker container run -d \
                -p $PORT_MAPPING \
                $ENV_VARS \
                --network app-network \
                --mount type=bind,source=C:/$APP_VOLUME/db,target=/data/db \
                --name $CONTAINER_NAME \
                $IMAGE_NAME

        else

            docker container run -d \
                -p $PORT_MAPPING \
                $ENV_VARS \
                --network app-network \
                --name $CONTAINER_NAME \
                $IMAGE_NAME
        fi
    fi
}

# Run MongoDB container
run_container "mongo" "mongo" "27017:27017" "-e MONGO_INITDB_ROOT_USERNAME=root -e MONGO_INITDB_ROOT_PASSWORD=password" "app-volume"

# Run Mongo Express container
run_container "mongo-express" "mongo-express" "8081:8081" "-e ME_CONFIG_MONGODB_ADMINUSERNAME=root -e ME_CONFIG_MONGODB_ADMINPASSWORD=password -e ME_CONFIG_MONGODB_SERVER=mongo"

# Creating app-server image 
build_and_pull_image "app-server"

# Run Continer app-server
run_container "app-server" "app-server" "3000:3000"


#mongo-express https://localhost:8081 server_username=admin,server_password=pass

# docker container run -it -d \
# -p 3000:3000 \
# --network app-network \
# --mount source=$APP_VOLUME,target=/data/db
# --name app-server \
# app-server


# docker container run -d \
#     -p 27017:27017 \
#     -e MONGO_INITDB_ROOT_USERNAME=root \
#     -e MONGO_INITDB_ROOT_PASSWORD=password \
#     --network app-network \
#     --mount type=bind,source=C:/docker-data/db,target=/data/db \
#     --name mongo \
#     mongo




# Example usage
build_and_pull_image "web-server"


run_container "web-server" "web-server" "80:80"