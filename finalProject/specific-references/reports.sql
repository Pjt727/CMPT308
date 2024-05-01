-- all meeting times where the professor firstName starts with Al
SELECT p.firstName, cm.courseName, cm.sectionNumber, cm.day, cm.startTime, cm.duration
FROM courseMeeting cm
INNER JOIN Professors p ON p.email = cm.primaryProfessor
WHERE p.firstName ILIKE 'Al%';

-- all in-person cmpt courses courses that have no friday classes AND no 8ams
--   could easily make more performant by having filters on the subqueries to reduce the IN checks
SELECT c.name as courseName, s.number as sectionNumber
FROM Courses c
INNER JOIN Sections s ON
   c.number = s.courseNumber AND
   c.subjectCode = s.subjectCode
WHERE 
    c.subjectCode='CMPT' AND
    (c.number, c.subjectCode, s.term, s.number) NOT IN (
        SELECT m.courseNumber, m.subjectCode, m.term, m.sectionNumber
        FROM Meetings m 
        WHERE
        startTime = '08:00:00' OR
        day = 'Friday'
    )
    -- must have some meetings
    AND (c.number, c.subjectCode, s.term, s.number) IN (
        SELECT m.courseNumber, m.subjectCode, m.term, m.sectionNumber FROM Meetings m
    )
;

-- All information for courses Alan Jr prefers
SELECT sc.schoolCode, sc.schoolName, sc.subjectCode, sc.subjectName, sc.courseName
FROM schoolCourse sc
INNER JOIN Sections se ON 
    sc.courseNumber = se.courseNumber AND
    sc.subjectCode = se.subjectCode
INNER JOIN PreferredEnrollments p ON 
    sc.courseNumber = p.courseNumber AND
    se.number = p.sectionNumber AND
    sc.subjectCode = p.subjectCode AND
    se.term = p.term
INNER JOIN Students st ON st.id = p.studentId
WHERE st.firstName = 'Alan Jr'
;
