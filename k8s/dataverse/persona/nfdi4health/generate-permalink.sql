CREATE OR REPLACE FUNCTION generateIdentifierFromStoredProcedure()
RETURNS varchar AS $$
DECLARE
identifier varchar;
BEGIN
    identifier := ((select last_value from dvobject_id_seq) + 1)::varchar;
RETURN identifier;
END;
$$ LANGUAGE plpgsql IMMUTABLE;