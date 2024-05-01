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
    message := 'The following items changed for a meeting of ';
    message := message || NEW.subjectCode || ' ' || NEW.courseNumber || ' ' || NEW.sectionNumber;
    message := message || ' in your enrolled: ';
    do_message := false;

    IF OLD.startTime != NEW.startTime THEN
        do_message := true;
        message := message || 'start-time ';
    END IF;

    IF OLD.day != NEW.day THEN
        do_message := true;
        message := message || 'day ';
    END IF;

    IF OLD.duration != NEW.duration THEN
        do_message := true;
        message := message || 'duration ';
    END IF;

    IF do_message THEN
        RAISE NOTICE '%, %, %', NEW.courseNumber, NEW.subjectCode, NEW.sectionNumber;
        SELECT ARRAY_AGG(p.studentID) 
        INTO students
        FROM PreferredEnrollments p 
        WHERE
            p.courseNumber = NEW.courseNumber AND
            p.subjectCode = NEW.subjectCode AND
            p.sectionNumber = NEW.sectionNumber AND
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

CREATE TRIGGER meeting_update 
AFTER UPDATE ON Meetings
FOR EACH ROW
EXECUTE FUNCTION meeting_update();

