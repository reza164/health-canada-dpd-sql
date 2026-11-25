-- Last-update dates recorded in the snapshot, not a history of update events.
-- The imported text is expected to follow DD-MON-YYYY; verify before conversion.
SELECT DATE_TRUNC('month', TO_DATE(last_update_date, 'DD-MON-YYYY'))::date AS month,
       COUNT(DISTINCT drug_code) AS human_product_codes
FROM clean.drug_product
WHERE class = 'Human'
  AND TO_DATE(last_update_date, 'DD-MON-YYYY') >= DATE '2025-01-01'
  AND TO_DATE(last_update_date, 'DD-MON-YYYY') < DATE '2026-01-01'
GROUP BY 1
ORDER BY 1;

-- Human records last updated on each observed day in March 2025.
SELECT TO_DATE(last_update_date, 'DD-MON-YYYY') AS last_updated,
       COUNT(DISTINCT drug_code) AS human_product_codes
FROM clean.drug_product
WHERE class = 'Human'
  AND TO_DATE(last_update_date, 'DD-MON-YYYY') >= DATE '2025-03-01'
  AND TO_DATE(last_update_date, 'DD-MON-YYYY') < DATE '2025-04-01'
GROUP BY 1
ORDER BY human_product_codes DESC, last_updated;
