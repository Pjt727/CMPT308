DROP TABLE IF EXISTS Professor;
CREATE TABLE Professors (
    id SERIAL PRIMARY KEY,
    emailAddress text,
    bannerId text, -- Never trust others
    firstName text,
    lastName text,
    unique(emailAddress)
);

CREATE TABLE Schools (
    code char(2) PRIMARY KEY,
    name text,
);

CREATE TABLE Subject (
    code char(4) PRIMARY KEY,
    name text,
);

CREATE TABLE Courses (
    number char(4) PRIMARY KEY,
    subjectCode char(4) PRIMARY KEY,
    bannerId text, -- Never trust others
    name text, 
);

CREATE TABLE Sections (
    term text, 
    bannerId text, -- Never trust others
);

CREATE TABLE Meetings (

);

CREATE TABLE Term
