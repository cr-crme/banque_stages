/* Use the database (create if not exist) */
USE dev_db;

/* Clear the database */
SET FOREIGN_KEY_CHECKS = 0;

/*DROP TABLE IF EXISTS phone_numbers_students;*/
DROP TABLE IF EXISTS phone_numbers_teachers;
DROP TABLE IF EXISTS phone_numbers;

/*DROP TABLE IF EXISTS addresses_students;*/
DROP TABLE IF EXISTS addresses_teachers;
DROP TABLE IF EXISTS addresses;

DROP TABLE IF EXISTS teaching_groups;
DROP TABLE IF EXISTS teachers;

SET FOREIGN_KEY_CHECKS = 1;


/*************************/
/* People related tables */
/*************************/

/* Teachers */

CREATE TABLE teachers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    last_name VARCHAR(50) NOT NULL,
    school_id VARCHAR(50) NOT NULL, 
    email VARCHAR(100) NOT NULL
);

CREATE TABLE teaching_groups (
    id INT AUTO_INCREMENT PRIMARY KEY,
    teacher_id INT NOT NULL,
    group_name VARCHAR(20),
    FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE CASCADE
);


/* Students */
/* TODO */



/* Addresses */

CREATE TABLE addresses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    civic INT,
    street VARCHAR(100),
    appartment VARCHAR(20),
    city VARCHAR(50),
    postal_code VARCHAR(10)
);

/* TO ADD WHEN STUDENTS TABLE IS ADDED
CREATE TABLE addresses_students (
    student_id INT,
    address_id INT,
    PRIMARY KEY (student_id, address_id),
    FOREIGN KEY (student_id) REFERENCES students(id),
    FOREIGN KEY (address_id) REFERENCES addresses(id)
);
*/


/* Phone numbers */

CREATE TABLE phone_numbers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    number VARCHAR(20) NOT NULL
);

CREATE TABLE phone_numbers_teachers (
    teacher_id INT,
    phone_number_id INT,
    PRIMARY KEY (teacher_id, phone_number_id),
    FOREIGN KEY (teacher_id) REFERENCES teachers(id),
    FOREIGN KEY (phone_number_id) REFERENCES phone_numbers(id)
);

/* TO ADD WHEN STUDENTS TABLE IS ADDED
CREATE TABLE phone_numbers_students (
    student_id INT,
    phone_number_id INT,
    PRIMARY KEY (student_id, phone_number_id),
    FOREIGN KEY (student_id) REFERENCES students(id),
    FOREIGN KEY (phone_number_id) REFERENCES phone_numbers(id)
);
*/