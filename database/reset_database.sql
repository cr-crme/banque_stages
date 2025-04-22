/* Use the database (create if not exist) */
USE dev_db;

/* Clear the database */
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS entities;
DROP TABLE IF EXISTS phone_numbers;
DROP TABLE IF EXISTS addresses;

DROP TABLE IF EXISTS persons;

DROP TABLE IF EXISTS student_contacts;
DROP TABLE IF EXISTS students;

DROP TABLE IF EXISTS teaching_groups;
DROP TABLE IF EXISTS teacher_itineraries;
DROP TABLE IF EXISTS teacher_itinerary_waypoints;
DROP TABLE IF EXISTS teachers;

DROP TABLE IF EXISTS enterprise_addresses;
DROP TABLE IF EXISTS enterprise_headquarter_addresses;
DROP TABLE IF EXISTS enterprise_phone_numbers;
DROP TABLE IF EXISTS enterprise_fax_numbers;
DROP TABLE IF EXISTS enterprise_activity_types;
DROP TABLE IF EXISTS enterprise_contacts;
DROP TABLE IF EXISTS enterprise_jobs;
DROP TABLE IF EXISTS enterprise_job_photo_urls;
DROP TABLE IF EXISTS enterprise_job_comments;
DROP TABLE IF EXISTS enterprise_job_pre_internship_requests;
DROP TABLE IF EXISTS enterprise_job_uniforms;
DROP TABLE IF EXISTS enterprise_job_protections;
DROP TABLE IF EXISTS enterprise_job_incidents;
DROP TABLE IF EXISTS enterprise_job_sst_evaluation_questions;
DROP TABLE IF EXISTS enterprises;

DROP TABLE IF EXISTS internships_supervising_teachers;
DROP TABLE IF EXISTS internships_extra_specializations;
DROP TABLE IF EXISTS internships;

SET FOREIGN_KEY_CHECKS = 1;


/***********/
/* GENERIC */
/***********/

CREATE TABLE entities (
    shared_id VARCHAR(36) NOT NULL PRIMARY KEY
);


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

CREATE TABLE phone_numbers (
    id VARCHAR(36) NOT NULL PRIMARY KEY,
    entity_id VARCHAR(36) NOT NULL,
    phone_number VARCHAR(20) NOT NULL, 
    FOREIGN KEY (entity_id) REFERENCES entities(shared_id) ON DELETE CASCADE
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
    email VARCHAR(100),
    FOREIGN KEY (id) REFERENCES entities(shared_id) ON DELETE CASCADE
);


/**** Students ****/

CREATE TABLE students (
    id VARCHAR(36) NOT NULL PRIMARY KEY,
    version VARCHAR(36) NOT NULL,
    photo VARCHAR(255) NOT NULL,
    program INT NOT NULL,
    group_name VARCHAR(20) NOT NULL,
    contact_link VARCHAR(255) NOT NULL,
    FOREIGN KEY (id) REFERENCES persons(id) ON DELETE CASCADE
);

CREATE TABLE student_contacts (
    student_id VARCHAR(36) NOT NULL,
    contact_id VARCHAR(36) NOT NULL,
    FOREIGN KEY (contact_id) REFERENCES persons(id),
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
);


/**** Teachers ****/

CREATE TABLE teachers (
    id VARCHAR(36) NOT NULL PRIMARY KEY,
    school_id VARCHAR(50) NOT NULL, 
    FOREIGN KEY (id) REFERENCES persons(id) ON DELETE CASCADE
);

CREATE TABLE teaching_groups (
    teacher_id VARCHAR(36) NOT NULL,
    group_name VARCHAR(20) NOT NULL, 
    FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE CASCADE
);

CREATE TABLE teacher_itineraries (
    id VARCHAR(36) NOT NULL PRIMARY KEY,
    teacher_id VARCHAR(36) NOT NULL,
    date BIGINT NOT NULL,
    FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE CASCADE
);

CREATE TABLE teacher_itinerary_waypoints (
    step_index INT NOT NULL,
    itinerary_id VARCHAR(36) NOT NULL,
    title VARCHAR(50) NOT NULL,
    subtitle VARCHAR(50) NOT NULL,
    latitude FLOAT NOT NULL,
    longitude FLOAT NOT NULL,
    address_civic INT,
    address_street VARCHAR(100),
    address_apartment VARCHAR(20),
    address_city VARCHAR(50),
    address_postal_code VARCHAR(10),
    visiting_priority INT NOT NULL,
    FOREIGN KEY (itinerary_id) REFERENCES teacher_itineraries(id) ON DELETE CASCADE
);


/******************************/
/* Enterprises related tables */
/******************************/

CREATE TABLE enterprises (
    id VARCHAR(36) NOT NULL PRIMARY KEY,
    version VARCHAR(36) NOT NULL,
    name VARCHAR(50) NOT NULL,
    recruiter_id VARCHAR(36) NOT NULL, 
    contact_function VARCHAR(255) NOT NULL,
    website VARCHAR(255) NOT NULL,
    neq VARCHAR(50) NOT NULL,
    FOREIGN KEY (id) REFERENCES entities(shared_id) ON DELETE CASCADE
);

CREATE TABLE enterprise_contacts(
    enterprise_id VARCHAR(36) NOT NULL,
    contact_id VARCHAR(36) NOT NULL,
    FOREIGN KEY (contact_id) REFERENCES persons(id),
    FOREIGN KEY (enterprise_id) REFERENCES enterprises(id) ON DELETE CASCADE
);

CREATE TABLE enterprise_addresses(
    enterprise_id VARCHAR(36) NOT NULL,
    address_id VARCHAR(36) NOT NULL,
    FOREIGN KEY (address_id) REFERENCES addresses(id),
    FOREIGN KEY (enterprise_id) REFERENCES enterprises(id) ON DELETE CASCADE
);

CREATE TABLE enterprise_headquarter_addresses(
    enterprise_id VARCHAR(36) NOT NULL,
    address_id VARCHAR(36) NOT NULL,
    FOREIGN KEY (address_id) REFERENCES addresses(id),
    FOREIGN KEY (enterprise_id) REFERENCES enterprises(id) ON DELETE CASCADE
);

CREATE TABLE enterprise_phone_numbers(
    enterprise_id VARCHAR(36) NOT NULL,
    phone_number_id VARCHAR(36) NOT NULL,
    FOREIGN KEY (phone_number_id) REFERENCES phone_numbers(id),
    FOREIGN KEY (enterprise_id) REFERENCES enterprises(id) ON DELETE CASCADE
);

CREATE TABLE enterprise_fax_numbers(
    enterprise_id VARCHAR(36) NOT NULL,
    fax_number_id VARCHAR(36) NOT NULL,
    FOREIGN KEY (fax_number_id) REFERENCES phone_numbers(id),
    FOREIGN KEY (enterprise_id) REFERENCES enterprises(id) ON DELETE CASCADE
);

CREATE TABLE enterprise_activity_types(
    enterprise_id VARCHAR(36) NOT NULL,
    activity_type INT NOT NULL,
    FOREIGN KEY (enterprise_id) REFERENCES enterprises(id) ON DELETE CASCADE
);

CREATE TABLE enterprise_jobs(
    id VARCHAR(36) NOT NULL PRIMARY KEY,
    version VARCHAR(36) NOT NULL,
    enterprise_id VARCHAR(36) NOT NULL,
    specialization_id VARCHAR(36) NOT NULL,
    positions_offered INT NOT NULL,
    minimum_age INT NOT NULL,
    FOREIGN KEY (enterprise_id) REFERENCES enterprises(id) ON DELETE CASCADE
);

CREATE TABLE enterprise_job_photo_urls(
    job_id VARCHAR(36) NOT NULL,
    photo_url VARCHAR(255) NOT NULL,
    FOREIGN KEY (job_id) REFERENCES enterprise_jobs(id) ON DELETE CASCADE
);

CREATE TABLE enterprise_job_comments(
    job_id VARCHAR(36) NOT NULL,
    comment VARCHAR(255) NOT NULL,
    FOREIGN KEY (job_id) REFERENCES enterprise_jobs(id) ON DELETE CASCADE
);

CREATE TABLE enterprise_job_pre_internship_requests(
    job_id VARCHAR(36) NOT NULL,
    request INT NOT NULL,
    FOREIGN KEY (job_id) REFERENCES enterprise_jobs(id) ON DELETE CASCADE
);

CREATE TABLE enterprise_job_uniforms(
    job_id VARCHAR(36) NOT NULL,
    status INT NOT NULL,
    uniform VARCHAR(255) NOT NULL,
    FOREIGN KEY (job_id) REFERENCES enterprise_jobs(id) ON DELETE CASCADE
);

CREATE TABLE enterprise_job_protections(
    job_id VARCHAR(36) NOT NULL,
    status INT NOT NULL,
    protection VARCHAR(255) NOT NULL,
    FOREIGN KEY (job_id) REFERENCES enterprise_jobs(id) ON DELETE CASCADE
);

CREATE TABLE enterprise_job_incidents(
    job_id VARCHAR(36) NOT NULL,
    incident_type VARCHAR(20) NOT NULL,
    incident VARCHAR(1000) NOT NULL,
    date BIGINT NOT NULL,
    FOREIGN KEY (job_id) REFERENCES enterprise_jobs(id) ON DELETE CASCADE
);

CREATE TABLE enterprise_job_sst_evaluation_questions(
    job_id VARCHAR(36) NOT NULL,
    question VARCHAR(255) NOT NULL,
    answers VARCHAR(1000) NOT NULL,
    date BIGINT NOT NULL,
    FOREIGN KEY (job_id) REFERENCES enterprise_jobs(id) ON DELETE CASCADE
);


/******************************/
/* Internships related tables */
/******************************/

CREATE TABLE internships (
    id VARCHAR(36) NOT NULL PRIMARY KEY,
    student_id VARCHAR(36) NOT NULL,
    enterprise_id VARCHAR(36) NOT NULL,
    job_id VARCHAR(36) NOT NULL,
    expected_duration INT NOT NULL,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
);

CREATE TABLE internships_supervising_teachers (
    internship_id VARCHAR(36) NOT NULL,
    teacher_id VARCHAR(36) NOT NULL,
    is_signatory_teacher BOOLEAN NOT NULL,
    FOREIGN KEY (internship_id) REFERENCES internships(id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE CASCADE
);

CREATE TABLE internships_extra_specializations (
    internship_id VARCHAR(36) NOT NULL,
    specialization_id VARCHAR(36) NOT NULL,
    FOREIGN KEY (internship_id) REFERENCES internships(id) ON DELETE CASCADE
);