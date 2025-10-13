CREATE DATABASE IF NOT EXISTS career_guideline;
USE career_guideline;
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(100) UNIQUE,
  password_hash VARCHAR(255),
  role ENUM('student','admin','contributor') DEFAULT 'student',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE careers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(150),
  short_desc TEXT,
  stream VARCHAR(100),
  tags VARCHAR(255),
  future_scope TEXT,
  approved TINYINT(1) DEFAULT 1
);
CREATE TABLE colleges (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150),
  stream VARCHAR(100),
  admission_procedure TEXT,
  website VARCHAR(255)
);
CREATE TABLE psychometric_questions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  question TEXT,
  option_a VARCHAR(255),
  option_b VARCHAR(255),
  option_c VARCHAR(255),
  option_d VARCHAR(255),
  correct_option CHAR(1)
);
CREATE TABLE psychometric_results (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  score INT,
  submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);