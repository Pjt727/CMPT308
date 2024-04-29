-- 1. function PreReqsFor(courseNum) - Returns the immediate prerequisites for the 
-- passed-in course number.
CREATE OR REPLACE FUNCTION PreReqsFor(courseNumInput integer) RETURNS TABLE (
    preReqNum integer,
    preReqName text,
    preReqCredits integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.num, c.name, credits
    FROM Prerequisites p
    INNER JOIN Courses c ON p.preReqNum = c.num
    WHERE p.courseNum = courseNumInput;
END;
$$ LANGUAGE plpgsql;

-- Easier return type to work with for recursion
CREATE OR REPLACE FUNCTION PreReqsForValue(courseNumInput integer) RETURNS int[]
AS $$
DECLARE
    courses int[];
BEGIN
    SELECT ARRAY_AGG(c.num)
    INTO courses
    FROM Prerequisites p
    INNER JOIN Courses c ON p.preReqNum = c.num
    WHERE p.courseNum = courseNumInput;
    RETURN courses;
END;
$$ LANGUAGE plpgsql;


-- 2. function IsPreReqFor(courseNum) - Returns the courses for which the passed-in course 
-- number is an immediate pre-requisite.
CREATE OR REPLACE FUNCTION IsPreReqFor(courseNumInput integer) RETURNS TABLE (
    courseNum integer,
    courseName text,
    courseCredits integer
) AS 
$$
BEGIN
    RETURN QUERY
    SELECT c.num, c.name, c.credits
    FROM Prerequisites p
    INNER JOIN Courses c ON p.courseNum = c.num
    WHERE p.preReqNum = courseNumInput;
END;
$$ LANGUAGE plpgsql
;

-- Demonstrate Jedi-level skills and write a third, recursive, function that takes a passed-in 
-- course number and generates all of its prerequisites. Uses the first two functions you 
-- wrote and recursion.
-- I did not see a need to use the other function :(
CREATE OR REPLACE FUNCTION AllPreReqsFor(courseNumInput integer) RETURNS int[] AS $$
DECLARE
    courses int[];
    courseCode int;
BEGIN
    courses := PreReqsForValue(courseNumInput);
    -- for each for some reason throws an error if array is empty
    IF array_length(courses, 1) IS NOT NULL THEN
        FOREACH courseCode IN ARRAY courses 
        LOOP
            -- add courses from recursive call to running courses
            courses := courses || AllPreReqsFor(coursecode);
        END LOOP;
    END IF;
    RETURN courses;
END;
$$ LANGUAGE plpgsql;


-- example prereq call
SELECT * FROM PreReqsFor(499);
-- example is prereq call
SELECT * FROM IsPreReqFor(221);

-- example use of ALlPreReqsFor 
-- (could not figure out how to get recursion to work with table types)
SELECT c.num, c.name, c.credits
FROM Courses c
WHERE c.num = ANY(AllPreReqsFor(499));
