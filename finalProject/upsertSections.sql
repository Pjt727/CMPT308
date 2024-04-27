-- procedure to update sections utilizing bannerId to match the exact sections
-- if bannerId is not reliable should change but bannerId allows the program to
-- more accurately and easily do the right change to the section (update, create, delete)
-- such that triggers can will be called correctly... if bannerId could not be relied
-- on the database will still be fine but this procedure will produce unexpected behavior

-- Comentary for later parts
-- This set up is NOT built to be performant I am not sql expert,
--    still some of these things cause me worry:
--  - IN checks with large array on large data set due to quadratic time complexity
--      - this is like really slow (hey that article suggests a really easy fix)
--      - https://medium.com/@mukul.chaware13/sql-query-optimization-for-large-in-queries-74f58dc524b6
--  - Checks on every insertion for whether it is there or not AND that prof inner query on each check
-- I imagine the best way to solve both of these would be to load the new sections into a temp table
--    remove on inner join of term / banner_id for sections that were deleted then somehow manually
--    trigger the update for the remaining section using the values of the temp table as the remaining
--    sections are replaced by the temp data (or maybe have the update triggers happen on create of the temp 
--    sections table)

CREATE OR REPLACE FUNCTION upsert_sections_in_term(
    term_text text,
    banner_ids text[],
    course_numbers text[],
    enrollments int[],
    maximum_enrollments int[],
    subject_codes text[],
    numbers text[],
    primary_professor_emails text[]
)
RETURNS void AS $$
DECLARE
    i int;
BEGIN
    -- delete sections
    DELETE FROM Sections as s
    WHERE 
        s.term like term_text AND
        s.BannerId = ANY(banner_ids);
    FOR i IN 1..array_length(banner_ids, 1) LOOP
        INSERT INTO Sections 
            (bannerId, courseNumber, subjectCode, number, enrollment, maximum_enrollment, term, primaryProfessor)
        VALUES (
            banner_ids[i],
            course_numbers[i],
            subject_codes[i],
            numbers[i],
            enrollments[i],
            maximum_enrollments[i],
            term_text,
            primary_professor_emails[i])
        -- Would mean that either ref errors from coures composite key or
        --   the section already exists which in that case should update
        ON CONFLICT (bannerId) DO UPDATE
        SET courseNumber = course_numbers[i],
            subjectCode = subject_codes[i],
            number = numbers[i],
            enrollment = enrollments[i],
            maximum_enrollment = maximum_enrollments[i],
            term = term_text,
            primaryProfessor = primary_professor_emails[i];
        -- Would fail again on ref errors which is wanted
    END LOOP;
END;
$$ LANGUAGE plpgsql;
