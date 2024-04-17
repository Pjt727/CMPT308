CREATE OR REPLACE FUNCTION add_flat_sections(term text,  )
RETURNS void AS $$
DECLARE
    tuple_row text[];
BEGIN
    FOREACH tuple_row IN ARRAY input_tuples
    LOOP
        RAISE NOTICE 'Tuple: % % %', tuple_row[1], tuple_row[2], tuple_row[3];
    END LOOP;
END;
$$ LANGUAGE plpgsql;
