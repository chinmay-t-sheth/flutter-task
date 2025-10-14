CREATE DATABASE IF NOT EXISTS career_guideline;
USE career_guideline;

CREATE TABLE chinmay_login (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(100) UNIQUE,
  password VARCHAR(100),
  role ENUM('admin','student','contributor') DEFAULT 'student'
);

CREATE TABLE chinmay_category (
  id INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(100)
);

CREATE TABLE chinmay_career (
  id INT AUTO_INCREMENT PRIMARY KEY,
  category_id INT,
  career_name VARCHAR(100),
  description TEXT
);

CREATE TABLE chinmay_college (
  id INT AUTO_INCREMENT PRIMARY KEY,
  college_name VARCHAR(150),
  stream VARCHAR(100),
  admission_process TEXT,
  future_scope TEXT
);

CREATE TABLE chinmay_question (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT,
  question_text TEXT
);

CREATE TABLE chinmay_answer (
  id INT AUTO_INCREMENT PRIMARY KEY,
  question_id INT,
  contributor_id INT,
  answer_text TEXT
);

CREATE TABLE chinmay_test_questions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  question_text TEXT
);

CREATE TABLE chinmay_test_results (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT,
  score INT,
  suggestion TEXT
);

CREATE TABLE chinmay_contribution (
  id INT AUTO_INCREMENT PRIMARY KEY,
  contributor_name VARCHAR(100),
  title VARCHAR(200),
  content TEXT
);
