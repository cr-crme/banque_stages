#!/usr/bash

# Make sure Docker is installed
sudo snap install docker
# Start the Docker service
sudo snap start docker

# Make sure Docker Compose is reinstalled
docker-compose down

# Start the Docker container for the database
docker-compose up -d

# Reset the database
docker exec -i dev_banque_stage mysql -u devuser < reset_database.sql
