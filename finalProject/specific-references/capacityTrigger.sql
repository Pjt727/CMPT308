-- Trigger to give a message for a section getting being close to filling up OR
--    becoming open 
CREATE OR REPLACE FUNCTION capacity_notice()
RETURNS TRIGGER AS $$
DECLARE
    students int[];
    student int;
    message text;
    do_message boolean;
BEGIN
    -- do nothing if the enorllments are the same
    IF OLD.enrollment = NEW.enrollment THEN
        RETURN NEW;
    END IF;
    do_message := false;
    -- if the enrollment is within 25% of the capicity then give a message to every student
    --   that has this in there enrollment
    IF NEW.enrollment >= NEW.maximumEnrollment * .75 THEN
        do_message := true;
        message := NEW.subjectCode || ' ' || NEW.courseNumber || ' ' 
            || NEW.number || ' only has ' || (NEW.maximumEnrollment - NEW.enrollment) || ' seats left!';
    ELSIF OLD.enrollment > NEW.enrollment THEN
        do_message := true;
        message := NEW.subjectCode || ' ' || NEW.courseNumber || ' ' 
            || NEW.number || ' has ' || (OLD.enrollment - NEW.enrollment) || ' new seats and ' ||
            (NEW.maximumEnrollment - NEW.enrollment) || ' seats left!!';
    END IF;


    IF do_message THEN
        SELECT ARRAY_AGG(p.studentID) 
        INTO students
        FROM PreferredEnrollments p 
        WHERE
            p.courseNumber = NEW.courseNumber AND
            p.subjectCode = NEW.subjectCode AND
            p.sectionNumber = NEW.number AND
            p.term = NEW.term;

        IF array_length(students, 1) >= 1 THEN
            FOREACH student in ARRAY students LOOP
                INSERT INTO Messages (studentId, message)
                VALUES(student, message);
            END LOOP;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER capacity_notice 
AFTER UPDATE ON SECTIONS
FOR EACH ROW
EXECUTE FUNCTION capacity_notice();

