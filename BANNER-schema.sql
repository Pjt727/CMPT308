DROP TABLE IF EXISTS PreferredEnrollments;
DROP TABLE IF EXISTS Messages;
DROP TABLE IF EXISTS Meetings;
DROP TABLE IF EXISTS Sections;
DROP TABLE IF EXISTS Courses;
DROP TABLE IF EXISTS Subjects;
DROP TABLE IF EXISTS Schools;
DROP TABLE IF EXISTS Professors;
DROP TABLE IF EXISTS Students;

DROP TYPE IF EXISTS dayOfWeek CASCADE;
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
    name text,
    PRIMARY KEY(number, subjectCode)
);

CREATE TABLE Sections (
    courseNumber char(4),
    subjectCode char(4),
    number char(4),
    enrollment int,
    maximumEnrollment int,
    term text, 
    bannerId text UNIQUE, -- Never trust others
    -- only storing primary professor for simplicity
    primaryProfessor text REFERENCES Professors(email),
    FOREIGN KEY (courseNumber, subjectCode) REFERENCES Courses(number, subjectCode),
    PRIMARY KEY(courseNumber, subjectCode, number, term)
);

CREATE TABLE Students (
    id SERIAL PRIMARY KEY, 
    firstName text
);

CREATE TABLE PreferredEnrollments (
    courseNumber char(4),
    subjectCode char(4),
    sectionNumber char(4),
    term text,
    studentId int REFERENCES Students(id),
    FOREIGN KEY (courseNumber, subjectCode, sectionNumber, term)
        REFERENCES Sections(courseNumber, subjectCode, number, term) ON DELETE CASCADE,
    PRIMARY KEY(courseNumber, subjectCode, sectionNumber, term, studentId)
);

CREATE TABLE Messages (
    studentId int REFERENCES Students(id),
    message text
);

CREATE TABLE Meetings (
    courseNumber char(4),
    subjectCode char(4),
    sectionNumber char(4),
    term text, 
    startTime TIME,
    day dayOfWeek,
    duration INTERVAL,
    FOREIGN KEY (courseNumber, subjectCode, sectionNumber, term) 
        REFERENCES Sections(courseNumber, subjectCode, number, term) ON DELETE CASCADE,
    PRIMARY KEY(courseNumber, subjectCode, sectionNumber, term, startTime, day)
);
