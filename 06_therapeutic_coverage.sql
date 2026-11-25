-- Coverage across product codes, verified against the local database.
-- EXISTS prevents several therapeutic rows from multiplying product counts.
WITH product_coverage AS (
    SELECT DISTINCT p.drug_code, p.class,
        EXISTS (
            SELECT 1 FROM clean.therapeutic_import AS t
            WHERE t.drug_code = p.drug_code
        ) AS has_therapeutic_match
    FROM clean.drug_product AS p
    WHERE p.drug_code IS NOT NULL
)
SELECT class,
       COUNT(*) AS total_product_codes,
       COUNT(*) FILTER (WHERE has_therapeutic_match) AS with_match,
       COUNT(*) FILTER (WHERE NOT has_therapeutic_match) AS without_match,
       ROUND(100.0 * COUNT(*) FILTER (WHERE has_therapeutic_match)
             / NULLIF(COUNT(*), 0), 2) AS percentage_with_match
FROM product_coverage
GROUP BY class
ORDER BY total_product_codes DESC, class;

-- Therapeutic codes with no product match. Empty in the author's local check.
SELECT DISTINCT t.drug_code
FROM clean.therapeutic_import AS t
WHERE NOT EXISTS (
    SELECT 1 FROM clean.drug_product AS p WHERE p.drug_code = t.drug_code
)
ORDER BY t.drug_code;
