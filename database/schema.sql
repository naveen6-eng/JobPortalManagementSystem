-- =====================================================================
-- Job Portal Management System Database Schema & Initial Data
-- College Course Based Project (CBP)
-- Tech Stack: Java Servlets, JSP, JDBC, MySQL, Tomcat 10.1
-- =====================================================================

CREATE DATABASE IF NOT EXISTS job_portal;
USE job_portal;

-- Drop child tables first to respect foreign key constraints
DROP TABLE IF EXISTS applications;
DROP TABLE IF EXISTS jobs;
DROP TABLE IF EXISTS users;

-- ---------------------------------------------------------------------
-- 1. Users Table
-- Roles: 'JOB_SEEKER' or 'EMPLOYER'
-- Passwords stored as BCrypt hashes (never plain text)
-- ---------------------------------------------------------------------
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('JOB_SEEKER', 'EMPLOYER') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- 2. Jobs Table
-- Foreign key employer_id references users(id) with ON DELETE CASCADE
-- ---------------------------------------------------------------------
CREATE TABLE jobs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employer_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    company VARCHAR(150) NOT NULL,
    location VARCHAR(100) NOT NULL,
    salary VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    posted_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employer_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- 3. Applications Table
-- Foreign key references jobs(id) and users(id)
-- UNIQUE constraint (job_id, seeker_id) strictly prevents duplicate applications
-- ---------------------------------------------------------------------
CREATE TABLE applications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    job_id INT NOT NULL,
    seeker_id INT NOT NULL,
    application_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('PENDING', 'SHORTLISTED', 'REJECTED') NOT NULL DEFAULT 'PENDING',
    resume_path VARCHAR(255) NULL,
    full_name VARCHAR(150) NULL,
    email VARCHAR(150) NULL,
    mobile_number VARCHAR(25) NULL,
    current_location VARCHAR(150) NULL,
    why_hire_you TEXT NULL,
    has_experience VARCHAR(10) NULL,
    experience_details TEXT NULL,
    salary_expectation VARCHAR(100) NULL,
    why_this_job TEXT NULL,
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
    FOREIGN KEY (seeker_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT unique_job_seeker UNIQUE (job_id, seeker_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================================
-- Initial Seed Data for Testing & Viva Demonstration
-- Default password for all demo accounts below is: password123
-- BCrypt Hash: $2a$12$w5uAeFNoAN8nRTFJsjg7zeKb/y9xk0Nf7tgAnsiAgBXYNZwd.f5eq
-- (Generated using org.mindrot.jbcrypt.BCrypt with 12 rounds)
-- Note: Default applications are NOT seeded to preserve real application workflows.
-- =====================================================================

INSERT INTO users (id, name, email, password_hash, role) VALUES
(1, 'TechCorp Recruiter', 'employer@portal.com', '$2a$12$w5uAeFNoAN8nRTFJsjg7zeKb/y9xk0Nf7tgAnsiAgBXYNZwd.f5eq', 'EMPLOYER'),
(2, 'Alex Johnson', 'seeker@portal.com', '$2a$12$w5uAeFNoAN8nRTFJsjg7zeKb/y9xk0Nf7tgAnsiAgBXYNZwd.f5eq', 'JOB_SEEKER'),
(3, 'Google India Careers', 'recruiter@google.com', '$2a$12$w5uAeFNoAN8nRTFJsjg7zeKb/y9xk0Nf7tgAnsiAgBXYNZwd.f5eq', 'EMPLOYER');

INSERT INTO jobs (id, employer_id, title, company, location, salary, description) VALUES
(1, 1, 'Full Stack Java Developer', 'TechCorp Solutions', 'Bengaluru, Karnataka (Hybrid)', '₹10,00,000 - ₹15,00,000 / year', 
'We are looking for a skilled Java Developer to build high-performance web applications using Java Servlets, JSP, JDBC, and MySQL. Candidates should possess strong understanding of MVC architecture, SQL queries, and responsive web design with Bootstrap.'),

(2, 1, 'Junior Backend Engineer', 'TechCorp Solutions', 'Hyderabad, Telangana', '₹6,00,000 - ₹8,50,000 / year', 
'Great opportunity for freshers and early-career developers. Responsibilities include designing relational schemas, writing prepared statements, implementing session authentication, and building clean service layers in Java.'),

(3, 3, 'Cloud Solutions Architect', 'Google Cloud India', 'Mumbai / Remote', '₹22,00,000 - ₹30,00,000 / year', 
'Design scalable cloud application architectures. Expertise in high availability, database clustering, ACID transactions, and modern enterprise software patterns required.');

