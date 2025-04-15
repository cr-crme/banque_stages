/* Use the database (create if not exist) */
USE dev_db;

/* Clear the database */
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS entities;
DROP TABLE IF EXISTS persons;
DROP TABLE IF EXISTS phone_numbers;
DROP TABLE IF EXISTS addresses;

DROP TABLE IF EXISTS teaching_groups;
DROP TABLE IF EXISTS teachers;

DROP TABLE IF EXISTS enterprises;

SET FOREIGN_KEY_CHECKS = 1;


/***********/
/* GENERIC */
/***********/

CREATE TABLE entities (
    shared_id VARCHAR(36) NOT NULL PRIMARY KEY
);



/*************************/
/* People related tables */
/*************************/

/**** Generic persons ****/

CREATE TABLE persons (
    id VARCHAR(36) NOT NULL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    last_name VARCHAR(50) NOT NULL,
    date_birthday DATE,
    email VARCHAR(100) NOT NULL,
    FOREIGN KEY (id) REFERENCES entities(shared_id) ON DELETE CASCADE
);


/**** Teachers ****/

CREATE TABLE teachers (
    id VARCHAR(36) NOT NULL PRIMARY KEY,
    school_id VARCHAR(50) NOT NULL, 
    FOREIGN KEY (id) REFERENCES persons(id) ON DELETE CASCADE
);

CREATE TABLE teaching_groups (
    id VARCHAR(36) NOT NULL,
    group_name VARCHAR(20) NOT NULL, 
    FOREIGN KEY (id) REFERENCES teachers(id) ON DELETE CASCADE
);


/**** Students ****/
/* TODO */



/**** Addresses ****/

CREATE TABLE addresses (
    id VARCHAR(36) NOT NULL PRIMARY KEY,
    entity_id VARCHAR(36) NOT NULL,
    civic INT,
    street VARCHAR(100),
    apartment VARCHAR(20),
    city VARCHAR(50),
    postal_code VARCHAR(10),
    FOREIGN KEY (entity_id) REFERENCES entities(shared_id) ON DELETE CASCADE
);


/**** Phone numbers ****/

CREATE TABLE phone_numbers (
    id VARCHAR(36) NOT NULL PRIMARY KEY,
    entity_id VARCHAR(36) NOT NULL,
    phone_number VARCHAR(20) NOT NULL, 
    FOREIGN KEY (entity_id) REFERENCES entities(shared_id) ON DELETE CASCADE
);


/*************************/
/* People related tables */
/*************************/

CREATE TABLE enterprises (
    id VARCHAR(36) NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    recruted_by VARCHAR(36) NOT NULL, 
    FOREIGN KEY (id) REFERENCES entities(shared_id) ON DELETE CASCADE
);

