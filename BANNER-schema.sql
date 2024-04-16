DROP TABLE IF EXISTS Professor;
DROP TYPE IF EXISTS dayOfWeek;
CREATE TYPE dayOfWeek AS ENUM ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday ', 'Sunday');

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
    schoolCode char(2) REFERENCES Schools(code),
);

CREATE TABLE Courses (
    number char(4) PRIMARY KEY,
    subjectCode char(4) PRIMARY KEY REFERENCES Subject(code),
    bannerId text, -- Never trust others
    name text, 
);

CREATE TABLE Sections (
    courseNumber char(4) PRIMARY KEY REFERENCES Courses(number),
    subjectCode char(4) PRIMARY KEY REFERENCES Courses(code),
    number char(4) PRIMARY KEY,
    term text PRIMARY KEY, 
    bannerId text, -- Never trust others
    primaryProfessor int REFERENCES Professor(id),
);

CREATE TABLE Meetings (
    courseNumber char(4) PRIMARY KEY REFERENCES Sections(courseNumber),
    subjectCode char(4) PRIMARY KEY REFERENCES Sections(subjectCode),
    sectionNumber char(4) PRIMARY KEY REFERENCES Sections(number),
    term text PRIMARY KEY REFERENCES Sections(term), 
    startTime TIME PRIMARY KEY,
    day dayOfWeek PRIMARY KEY,
    duration INTERVAL,
);

