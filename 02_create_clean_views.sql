-- Run once, after importing raw tables, in the NEW project database.
-- DISTINCT removes exact full-row duplicates, not all possible key conflicts.
CREATE SCHEMA clean;
CREATE VIEW clean.drug_product AS SELECT DISTINCT * FROM raw.drug_product;
CREATE VIEW clean.active_ingredients AS SELECT DISTINCT * FROM raw.active_ingredients;
CREATE VIEW clean.companies AS SELECT DISTINCT * FROM raw.companies;
CREATE VIEW clean.forms AS SELECT DISTINCT * FROM raw.forms;
CREATE VIEW clean.therapeutic_import AS SELECT DISTINCT * FROM raw.therapeutic_import;

-- Keeps the source text. An invalid numeric string can make queries fail.
CREATE VIEW clean.active_ingredients_numeric_strengths AS
SELECT *, CAST(strength AS numeric) AS strength_numeric
FROM clean.active_ingredients;
