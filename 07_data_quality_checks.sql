-- Run each statement individually. Counts are observations, not proof of
-- source completeness; reconcile the original files separately.

-- Raw rows and exact full-row distinct counts.
SELECT COUNT(*) AS raw_rows, COUNT(DISTINCT p) AS distinct_full_rows,
       COUNT(DISTINCT p.drug_code) AS distinct_product_codes
FROM raw.drug_product AS p;
SELECT COUNT(*) AS raw_rows, COUNT(DISTINCT i) AS distinct_full_rows,
       COUNT(DISTINCT i.drug_code) AS distinct_product_codes
FROM raw.active_ingredients AS i;
SELECT COUNT(*) AS raw_rows, COUNT(DISTINCT t) AS distinct_full_rows,
       COUNT(DISTINCT t.drug_code) AS distinct_product_codes
FROM raw.therapeutic_import AS t;

-- Product-code completeness and uniqueness in the clean product view.
SELECT COUNT(*) AS missing_or_blank_product_code_rows
FROM clean.drug_product
WHERE drug_code IS NULL OR BTRIM(drug_code) = '';
SELECT drug_code, COUNT(*) AS product_rows
FROM clean.drug_product
WHERE drug_code IS NOT NULL AND BTRIM(drug_code) <> ''
GROUP BY drug_code HAVING COUNT(*) > 1
ORDER BY product_rows DESC, drug_code;

-- Products missing related records, without join multiplication.
SELECT COUNT(*) AS products_without_ingredients
FROM clean.drug_product AS p
WHERE NOT EXISTS (SELECT 1 FROM clean.active_ingredients AS i WHERE i.drug_code = p.drug_code);
SELECT COUNT(*) AS products_without_forms
FROM clean.drug_product AS p
WHERE NOT EXISTS (SELECT 1 FROM clean.forms AS f WHERE f.drug_code = p.drug_code);
SELECT COUNT(*) AS products_without_companies
FROM clean.drug_product AS p
WHERE NOT EXISTS (SELECT 1 FROM clean.companies AS c WHERE c.drug_code = p.drug_code);

-- Inspect blank strength values before casting. TRIM here handles spaces.
WITH classified AS (
    SELECT CASE WHEN strength IS NULL THEN 'null'
                WHEN strength = '' THEN 'empty_string'
                WHEN BTRIM(strength) = '' THEN 'spaces_only'
                ELSE 'nonblank' END AS category
    FROM clean.active_ingredients
)
SELECT category, COUNT(*) AS ingredient_rows
FROM classified GROUP BY category ORDER BY category;

-- Forces conversion of all current strengths. This fails on nonnumeric text;
-- success does not prove the values or their units are clinically meaningful.
SELECT COUNT(CAST(strength AS numeric)) AS numeric_nonnull_strengths
FROM clean.active_ingredients;
