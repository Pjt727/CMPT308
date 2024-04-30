-- SELECT upsert_meetings_in_section('201L', 'ITAL', '111', 'Fall 2024', ARRAY['14:00:00','14:00:00']::TIME[], ARRAY['Tuesday','Monday']::dayOfWeek[], ARRAY['75m','75m']::INTERVAL[]);
-- SELECT upsert_meetings_in_section('201L', 'ITAL', '111', 'Fall 2024', ARRAY['14:00:00','14:00:00']::TIME[], ARRAY['Tuesday','Friday']::dayOfWeek[], ARRAY['75m','75m']::INTERVAL[]);

-- SELECT upsert_meetings_in_section('201L', 'ITAL', '111', 'Fall 2024', ARRAY[]::TIME[], ARRAY[]::dayOfWeek[], ARRAY[]::INTERVAL[]);
-- SELECT upsert_meetings_in_section('201L', 'ITAL', '111', 'Fall 2024', ARRAY['14:00:00']::TIME[], ARRAY['Thursday']::dayOfWeek[], ARRAY['75m','75m']::INTERVAL[]);
-- SELECT * FROM Meetings;
-- SELECT * FROM Sections;

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

-- SELECT EXISTS (
--   SELECT *
--   FROM Meetings m
--   WHERE 
--   -- Remove records matching to inserted meetings
--   --   it is important that this query is ran for each iteration
--   --   because as the meetings could be updated in prior iterations
--       (m.startTime, m.day) NOT IN (
--          SELECT unnest(ARRAY['14:00:00', '14:00:00']::TIME[]), unnest(ARRAY['Monday', 'Tuesday']::dayOfWeek[]) 
--      ) AND
--     m.startTime != '14:00:00' AND
--     m.day != 'Tuesday';
--);

-- SELECT *
-- FROM Meetings m
-- WHERE 
-- -- Remove records matching to inserted meetings
-- --   it is important that this query is ran for each iteration
-- --   because as the meetings could be updated in prior iterations
--   (m.startTime, m.day) NOT IN (
--      SELECT unnest(ARRAY['14:00:00', '14:00:00']::TIME[]), unnest(ARRAY['Monday', 'Tuesday']::dayOfWeek[]) 
-- ) LIMIT 1;

-- DO $$
-- DECLARE
-- 	term text := 'Fall 2024';
-- 	banner_ids text[] := ARRAY['175517'];
-- 	course_numbers text[] := ARRAY['203N'];
-- 	enrollments int[] := ARRAY[6];
-- 	maximum_enrollments int[] := ARRAY[25];
-- 	subject_codes text[] := ARRAY['ACCT'];
-- 	numbers text[] := ARRAY['111'];
-- 	primary_professor_emails text[] := ARRAY['Michael.Craven@marist.edu'];
-- BEGIN
-- 	PERFORM upsert_sections_in_term(
-- 		term,
-- 		banner_ids,
-- 		course_numbers,
-- 		enrollments,
-- 		maximum_enrollments,
-- 		subject_codes,
-- 		numbers,
-- 		primary_professor_emails
-- 	);
-- END $$;

SELECT * FROM Sections s
WHERE s.bannerId = '175517';


UPDATE Sections
SET enrollment = 18
WHERE bannerId = '175517';

SELECT * FROM Sections s
WHERE s.bannerId = '175517';
