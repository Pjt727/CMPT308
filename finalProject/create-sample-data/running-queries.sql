--  upsert meetings example:
-- SELECT upsert_meetings_in_section('201L', 'ITAL', '111', 'Fall 2024', 
--     ARRAY['14:00:00','14:00:00']::TIME[], ARRAY['Tuesday','Monday']::dayOfWeek[], 
--     ARRAY['75m','75m']::INTERVAL[]);
-- SELECT * FROM Meetings WHERE courseNumber='201L' AND subjectCode='ITAL';
-- SELECT upsert_meetings_in_section('201L', 'ITAL', '111', 'Fall 2024', 
--     ARRAY[]::TIME[], ARRAY[]::dayOfWeek[], ARRAY[]::INTERVAL[]);
-- SELECT * FROM Meetings WHERE courseNumber='201L' AND subjectCode='ITAL';
-- SELECT upsert_meetings_in_section('201L', 'ITAL', '111', 'Fall 2024', 
--     ARRAY['14:00:00','14:00:00']::TIME[], ARRAY['Tuesday','Friday']::dayOfWeek[],
--     ARRAY['75m','75m']::INTERVAL[]);
-- SELECT * FROM Meetings WHERE courseNumber='201L' AND subjectCode='ITAL';
-- SELECT upsert_meetings_in_section('201L', 'ITAL', '111', 'Fall 2024',
--     ARRAY['14:00:00']::TIME[], ARRAY['Thursday']::dayOfWeek[],
--     ARRAY['75m','75m']::INTERVAL[]);
-- SELECT * FROM Meetings WHERE courseNumber='201L' AND subjectCode='ITAL';
-- SELECT * FROM PreferredEnrollments;
-- SELECT * FROM Sections WHERE
-- courseNumber='422N' AND
-- subjectCode='CMPT'
-- ;

-- basic exmapling queries:
-- DELETE FROM Sections;
-- SELECT * FROM courseMeeting;
-- SELECT * FROM messages;
-- SELECT * WHERE
-- SELECT unnest(ARRAY['14:00:00','14:00:00']::TIME[]), unnest(ARRAY['Tuesday','Friday']::dayOfWeek[]);
-- SELECT EXISTS (
--     SELECT 1
--     FROM Meetings m
--     WHERE 
--     -- Remove records matching to inserted meetings
--     --   it is important that this query is ran for each iteration
--     --   because as the meetings could be updated in prior iterations
--         (m.startTime, m.day) IN (
--            SELECT unnest(ARRAY['14:00:00','14:00:00']::TIME[]), unnest(ARRAY['Tuesday','Friday']::dayOfWeek[])
--    )
-- );
-- SELECT * FROM
-- Sections s
-- WHERE s.primaryProfessor = 'Alan.Labouseur@marist.edu'
-- SELECT * FROM Sections


SELECT schoolName, Count(*) as sectionCount
FROM schoolCourse 
GROUP BY schoolName;










