-- Do not run cs166_db_start
-- Instead run 
-- source startPostgreSQL.sh
-- source createPostgreDB.sh
DROP SEQUENCE IF EXISTS part_number_seq;
CREATE SEQUENCE part_number_seq START WITH 50000;
CREATE OR REPLACE FUNCTION set_part_number()
RETURNS trigger AS
$BODY$
BEGIN
    NEW.part_number := nextval('part_number_seq');
    RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql VOLATILE;

DROP TRIGGER IF EXISTS set_part_number_trigger ON part_nyc;
CREATE TRIGGER set_part_number_trigger
BEFORE INSERT ON part_nyc
FOR EACH ROW
EXECUTE PROCEDURE set_part_number();

-- 4. You can test your code by running test.sh script provided

-- 5. Make sure to stop your database by running the stopPostgreDB.sh script provided