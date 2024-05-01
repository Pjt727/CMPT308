-- Yes it would be way easier to delete all meeting for the section then add the given ones
--     BUT then we would not trigger the right change (delete, create, update)
-- Is that really that important? maybe not... maybe I should have spent my time doing
--     a more interesting procedure like taking a cursor of meeting and returning whether they overlappign
--     oh well...
-- manage the meetings for a given section by matching all of them
-- impossible to know the change (for example delete then create versus an update) 
--   update so a guess needs to be made for the correct trigger
-- Obviously optimizations could be made
CREATE OR REPLACE FUNCTION upsert_meetings_in_section(
    course_number text,
    subject_code text,
    section_number text,
    term_text text,
    start_times TIME[],
    days dayOfWeek[],
    durations INTERVAL[]
)
RETURNS void AS $$
DECLARE
    i int;
    do_create_index boolean;
    dont_update boolean;
    meeting_count INTEGER;
    created_indices int[];
    -- work around to update a single record bc you can not limit on an update
    start_time_to_update TIME;
    day_to_update dayOfWeek;
    debugging RECORD;
BEGIN
    SELECT COUNT(*) INTO meeting_count FROM Meetings m
    WHERE
         m.courseNumber = course_number AND
         m.subjectCode = subject_code AND
         m.sectionNumber = section_number AND
         m.term = term_text
    ;

    -- If adding count is 0 delete everything
    IF cardinality(start_times) = 0 THEN
        DELETE FROM Meetings m
        WHERE
            m.courseNumber = course_number AND
            m.subjectCode = subject_code AND
            m.sectionNumber = section_number AND
            m.term = term_text
        ;
    -- If the counts are equal only update
    ELSIF meeting_count = cardinality(start_times) THEN
        FOR i IN 1..array_length(start_times, 1) LOOP
            -- Skip if meeting is already in the section
            IF 
            EXISTS (
                SELECT 1
                FROM Meetings m
                WHERE
                    m.courseNumber = course_number AND
                    m.subjectCode = subject_code AND
                    m.sectionNumber = section_number AND
                    m.term = term_text AND
                    m.startTime = start_times[i] AND 
                    m.day = days[i]
                )
                THEN
                CONTINUE;
            END IF;
            -- Update the first meeting that has changed
            SELECT m.day, m.startTime
            INTO day_to_update, start_time_to_update
            FROM Meetings m
            WHERE
                m.courseNumber = course_number AND
                m.subjectCode = subject_code AND
                m.sectionNumber = section_number AND
                m.term = term_text AND
                -- Remove records matching to inserted meetings
                --   it is important that this query is ran for each iteration
                --   because as the meetings could be updated in prior iterations
               (m.startTime, m.day) NOT IN (
                  SELECT unnest(start_times), unnest(days)
                )
            LIMIT 1;

            UPDATE Meetings m
            SET
                startTime = start_times[i],
                duration = durations[i],
                day = days[i]
            WHERE 
                m.courseNumber = course_number AND
                m.subjectCode = subject_code AND
                m.sectionNumber = section_number AND
                m.term = term_text AND
                m.startTime = start_time_to_update AND 
                m.day = day_to_update
            ;
        END LOOP;
    -- If the adding count is more only create/ update
    ELSIF meeting_count < cardinality(start_times) THEN
        -- finds the first one that does not match and then changes it
        FOR i IN 1..array_length(start_times, 1) LOOP
            -- done creating new meetings now only consider updating
            IF cardinality(created_indices) >= ABS(cardinality(start_times) - meeting_count) THEN
                RETURN;
            END IF;
            SELECT EXISTS (
                SELECT 1
                FROM Meetings m
                WHERE 
                    m.courseNumber = course_number AND
                    m.subjectCode = subject_code AND
                    m.sectionNumber = section_number AND
                    m.term = term_text AND
                    -- see if start_time/ day is already in the db
                    m.startTime = start_times[i] AND
                    m.day = days[i]
            ) 
            INTO do_create_index;

            IF not do_create_index THEN
                created_indices := array_append(created_indices, i);
                INSERT INTO Meetings (courseNumber, subjectCode, sectionNumber, term, startTime, day, duration) 
                VALUES (course_number, subject_code, section_number, term_text, start_times[i], days[i], durations[i])
                ;
            END IF;
        END LOOP;
        -- interpret the rest as possible updates
        FOR i IN 1..array_length(start_times, 1) LOOP
            -- skip if this one was already created
            IF i != ANY(created_indices) THEN
                -- possibly update a meeting

                -- SELECT m.day, m.startTime
                -- INTO day_to_update, start_time_to_update
                -- FROM Meetings m
                -- WHERE
                --     m.courseNumber = course_number AND
                --     m.subjectCode = subject_code AND
                --     m.sectionNumber = section_number AND
                --     m.term = term_text AND
                --     NOT EXISTS (
                --         SELECT 1
                --         FROM (
                --             SELECT unnest(start_times) AS startTime, unnest(days) AS day
                --         ) existing
                --         WHERE m.startTime = existing.startTime AND m.day = existing.day
                --     )
                -- LIMIT 1;

                SELECT m.day, m.startTime
                INTO day_to_update, start_time_to_update
                FROM Meetings m
                WHERE 
                    m.courseNumber = course_number AND
                    m.subjectCode = subject_code AND
                    m.sectionNumber = section_number AND
                    m.term = term_text AND
                -- Remove records matching to inserted meetings
                --   it is important that this query is ran for each iteration
                --   because as the meetings could be updated in prior iterations
                    (m.startTime, m.day) NOT IN (
                        SELECT unnest(start_times), unnest(days)
                    )
                LIMIT 1;

                UPDATE Meetings m
                SET
                    startTime = start_times[i],
                    duration = durations[i],
                    day = days[i]
                WHERE 
                    m.courseNumber = course_number AND
                    m.subjectCode = subject_code AND
                    m.sectionNumber = section_number AND
                    m.term = term_text AND
                    m.startTime = start_time_to_update AND 
                    m.day = day_to_update
                ;
            END IF;
        END LOOP;
    -- If the adding count is less only delete/ update
    ELSE
        -- delete every meeting that does not match BUT limit based off
        --    of difference because we may delete some and then update others
        --    have to use for loop because you cannot delete based off limit
        FOR i IN 1..ABS(cardinality(start_times) - meeting_count) LOOP
            SELECT m.day, m.startTime
            INTO day_to_update, start_time_to_update
            FROM Meetings m
            WHERE
                m.courseNumber = course_number AND
                m.subjectCode = subject_code AND
                m.sectionNumber = section_number AND
                m.term = term_text AND
                -- Remove records matching to inserted meetings
                --   it is important that this query is ran for each iteration
                --   because as the meetings could be updated in prior iterations
                NOT EXISTS (
                    SELECT 1
                    FROM (
                        SELECT unnest(start_times) AS startTime, unnest(days) AS day
                    ) existing
                    WHERE m.startTime = existing.startTime AND m.day = existing.day
                )
            LIMIT 1;
            DELETE FROM Meetings m 
            WHERE
                m.courseNumber = course_number AND
                m.subjectCode = subject_code AND
                m.sectionNumber = section_number AND
                m.term = term_text AND
                m.startTime = start_time_to_update AND 
                m.day = day_to_update;
        END LOOP;

        -- do possible updates
        FOR i IN 1..array_length(start_times, 1) LOOP
            -- Update the first meeting that has changed
            SELECT m.day, m.startTime
            INTO day_to_update, start_time_to_update
            FROM Meetings m
            WHERE
                m.courseNumber = course_number AND
                m.subjectCode = subject_code AND
                m.sectionNumber = section_number AND
                m.term = term_text AND
                -- Remove records matching to inserted meetings
                --   it is important that this query is ran for each iteration
                --   because as the meetings could be updated in prior iterations
                NOT EXISTS (
                    SELECT 1
                    FROM (
                        SELECT unnest(start_times) AS startTime, unnest(days) AS day
                    ) existing
                    WHERE m.startTime = existing.startTime AND m.day = existing.day
                )
            LIMIT 1;

            UPDATE Meetings m
            SET
                startTime = start_times[i],
                duration = durations[i],
                day = days[i]
            WHERE 
                m.courseNumber = course_number AND
                m.subjectCode = subject_code AND
                m.sectionNumber = section_number AND
                m.term = term_text AND
                m.startTime = start_time_to_update AND 
                m.day = day_to_update
            ;
        END LOOP;
    END IF;
END;
$$ LANGUAGE plpgsql;
