-- manage the meetings for a given section by matching all of them
-- impossible to know the change (for example delete then create versus an update) 
--   update so a guess needs to be made for the correct trigger
CREATE OR REPLACE FUNCTION upsert_meetings_in_section(
    course_number text,
    subject_code text,
    section_number text,
    term_text text,
    start_times TIME[],
    days dayOfWeek[],
    duration INTERVAL[]
)
RETURNS void AS $$
DECLARE
    i int;
    meeting_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO meeting_count FROM Meetings m
    WHERE
         m.courseNumber = course_number AND
         m.subjectCode = subject_code AND
         m.sectionNumber = section_number AND
         m.term = term_text
    ;
    -- If adding count is 0 delete everything
    IF meeting_count = 0 THEN
        DELETE FROM Meetings m
        WHERE
            m.courseNumber = course_number AND
            m.subjectCode = subject_code AND
            m.sectionNumber = section_number AND
            m.term = term_text
        ;
    -- If the counts are equal only update
    ELSIF meeting_count = array_length(start_times) THEN
        FOR i IN 1..array_length(start_times, 1) LOOP
            UPDATE Meetings
            SET 
                startTime = start_times[i],
                day = days[i]
            WHERE
                m.courseNumber = course_number AND
                m.subjectCode = subject_code AND
                m.sectionNumber = section_number AND
                m.term = term_text AND
                -- how do I remove the records of other meetings??
                NOT (

                )
                ;

        END LOOP
    -- If the adding count is more only create/ update
    ELSIF meeting_count < array_length(startTime) THEN
    -- If the adding count is less only delete/ update
    ELSE 
    END IF;
END;
$$ LANGUAGE plpgsql;
