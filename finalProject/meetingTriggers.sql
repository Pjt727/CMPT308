-- Trigger to give a message for a section getting being close to filling up OR
--    becoming open 
CREATE OR REPLACE FUNCTION meeting_update()
RETURNS TRIGGER AS $$
DECLARE
    students int[];
    student int;
    do_message boolean;
    message text;
BEGIN
    -- The only reason to notify is if the day/ time/ duration changed
    message := 'The following items changed for a section in your enrolled: ';
    do_message := false;

    IF OLD.startTime != NEW.startTime THEN
        message := message || 'start time, ';
    END IF;

    IF OLD.day != NEW.day THEN
        message := message || 'day, ';
    END IF;

    IF OLD.duration != NEW.duration THEN
        message := message || 'duration, ';
    END IF;

    IF do_message THEN
        SELECT p.studentID 
        INTO students
        FROM PreferredEnrollments p 
        WHERE
            p.courseNumber = NEW.courseNumber AND
            p.subjectCode = NEW.subjectCode AND
            p.sectionNumber = NEW.sectionNumber AND
            p.term = NEW.term;

        IF students != NULL THEN
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

