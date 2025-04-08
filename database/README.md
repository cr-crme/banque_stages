# Docker basics

## Linux

### Install

You can install docker using snap:
`sudo snap install docker`

Then you have to run the service:
`sudo snap start docker`

# Debug

If you are developping, you may want to run your own version of the database. 
To do so, use the `docker-compose.yml` file provide. 

You will need to copy-paste the `.env.default` file and fill it with the appropriate values. 
If you don't know the values, please ask your administrator. 

To interact with the database, you can run the following command: 
`sudo docker exec -it mysql_dev mysql -u devuser -p`


# Database structure

USE dev_db;

## Tables 

### Teachers

CREATE TABLE Teachers (
    ID int NOT NULL,
    Name varchar(255) NOT NULL,
    Age int
);
ALTER TABLE Teachers
    ADD PRIMARY KEY (ID);
