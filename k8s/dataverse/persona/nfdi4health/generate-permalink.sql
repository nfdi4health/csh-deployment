-- Adapted from: https://github.com/IQSS/dataverse/blob/a36db2d7df0d9976c00179b82f11cfb338a6cfc8/doc/sphinx-guides/source/_static/util/createsequence.sql

DO $$
DECLARE
last_val bigint;
BEGIN
    -- Get the last value of the existing sequence
    SELECT last_value INTO last_val FROM dvobject_id_seq;

    -- Create the new sequence with the desired start and min values
    EXECUTE format('
            CREATE SEQUENCE datasetidentifier_seq
            INCREMENT BY 1
            MINVALUE %s
            MAXVALUE 9223372036854775807
            CACHE 1
        ', last_val + 1);
END $$;

ALTER TABLE datasetidentifier_seq OWNER TO "dataverse";

-- And now create a PostgreSQL FUNCTION, for JPA to
-- access as a NamedStoredProcedure:

CREATE OR REPLACE FUNCTION generateIdentifierFromStoredProcedure()
RETURNS varchar AS $$
DECLARE
identifier varchar;
BEGIN
    identifier := nextval('datasetidentifier_seq')::varchar;
RETURN identifier;
END;
$$ LANGUAGE plpgsql IMMUTABLE;