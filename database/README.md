# Docker basics

## Linux

### Install

You can install docker using snap:
`sudo snap install docker`

Then you have to run the service:
`sudo snap start docker`

# Debug

If you are developping, you may want to run your own version of the database. 
To do so, use the `docker-compose.yml` file provide by running the following command from the ROOT/database directory:
`docker-compose up -d`

To stop the database, you can run the following command:
`docker-compose down`

To interact with the database, you can run the following command: 
`docker exec -it banque_stage_container mysql -u devuser -p`


# Database structure

## Tables 

The see the database structure, please refer to `reset_database.sql` file.
This file contains the SQL commands to create the database and all the tables.

## Reset the database

To reset the database, you can run the following command:
`docker exec -i banque_stage_container mysql -u root -proot < reset_database.sql`
Make sure not to put space between the `-p` and the password.
This will drop the database and create it again with the tables defined in the `reset_database.sql` file.
