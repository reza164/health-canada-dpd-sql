-- Product-level check for the leading pair in the local snapshot.
-- DISTINCT avoids repeated product rows caused by repeated ingredient records.
-- Observed result: 383 rows with 383 distinct product codes.
SELECT DISTINCT
    p.drug_code,
    p.brand_name,
    i1.ingredient AS ingredient_1,
    i2.ingredient AS ingredient_2
FROM clean.active_ingredients AS i1
JOIN clean.active_ingredients AS i2 ON i1.drug_code = i2.drug_code
JOIN clean.drug_product AS p ON p.drug_code = i1.drug_code
WHERE p.class = 'Human'
  AND i1.ingredient = 'OCTISALATE'
  AND i2.ingredient = 'AVOBENZONE'
ORDER BY p.drug_code, p.brand_name;
