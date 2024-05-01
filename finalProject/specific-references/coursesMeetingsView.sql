CREATE OR REPLACE VIEW courseMeeting AS
SELECT c.name as courseName, m.courseNumber as courseNumber, m.subjectCode as subjectCode, 
    m.sectionNumber as sectionNumber, s.primaryProfessor as primaryProfessor, m.startTime as startTime,
    m.day as day, m.duration as duration, m.term as term
FROM Courses c
INNER JOIN Sections s ON
   c.number = s.courseNumber AND
   c.subjectCode = s.subjectCode
INNER JOIN Meetings m ON
   m.courseNumber = s.courseNumber AND
   m.subjectCode = s.subjectCode AND
   m.sectionNumber = s.number AND 
   m.term = s.term
ORDER BY m.term, m.courseNumber, m.subjectCode, m.sectionNumber, m.day
;
