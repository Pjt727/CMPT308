DROP TABLE IF EXISTS Meetings;
DROP TABLE IF EXISTS Sections;
DROP TABLE IF EXISTS Courses;
DROP TABLE IF EXISTS Subjects;
DROP TABLE IF EXISTS Schools;
DROP TABLE IF EXISTS Professors;

DROP TYPE IF EXISTS dayOfWeek;
CREATE TYPE dayOfWeek AS ENUM ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');

CREATE TABLE Professors (
    -- sort of bad practice to use email because it might change but it
    --     makes the data entry easier
    email text PRIMARY KEY,
    firstName text,
    lastName text
);

CREATE TABLE Schools (
    code char(2) PRIMARY KEY,
    name text
);

CREATE TABLE Subjects (
    code char(4) PRIMARY KEY,
    name text,
    schoolCode char(2) REFERENCES Schools(code)
);

CREATE TABLE Courses (
    number char(10),
    subjectCode char(10) REFERENCES Subjects(code),
    bannerId text UNIQUE,-- Never trust others
    description text,
    name text,
    PRIMARY KEY(number, subjectCode)
);

CREATE TABLE Sections (
    courseNumber char(4),
    subjectCode char(4),
    number char(4),
    term text, 
    bannerId text UNIQUE, -- Never trust others
    -- only storing primary professor for simplicity
    primaryProfessor text REFERENCES Professors(email),
    FOREIGN KEY (courseNumber, subjectCode) REFERENCES Courses(number, subjectCode),
    PRIMARY KEY(courseNumber, subjectCode, number, term)
);

CREATE TABLE Meetings (
    courseNumber char(4),
    subjectCode char(3),
    sectionNumber char(4),
    term text, 
    startTime TIME,
    day dayOfWeek,
    duration INTERVAL,
    FOREIGN KEY (courseNumber, subjectCode, sectionNumber, term) 
        REFERENCES Sections(courseNumber, subjectCode, number, term),
    PRIMARY KEY(courseNumber, subjectCode, sectionNumber, term, startTime, day)
);

