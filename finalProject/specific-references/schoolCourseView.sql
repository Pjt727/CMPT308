CREATE OR REPLACE VIEW schoolCourse AS
SELECT sc.code as schoolCode, sc.name as schoolName, su.code as subjectCode, su.name as subjectName,
    c.name as courseName, c.number as courseNumber
FROM Schools sc
INNER JOIN Subjects su ON sc.code = su.schoolCode
INNER JOIN Courses c ON su.code = c.subjectCode;
