-- Trigger to give a message for a section getting being close to filling up OR
--    becomeing open
CREATE OR REPLACE FUNCTION capacityNotice()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER audit_trigger
BEFORE UPDATE ON my_table
FOR EACH ROW
EXECUTE FUNCTION audit_function();



