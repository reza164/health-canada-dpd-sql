-- Top ten pairs of distinct ingredient names in Human product records.
-- The greater-than comparison chooses one ordering and excludes self-pairs.
-- DISTINCT product codes avoid overcounting repeated ingredient rows.
SELECT
    i1.ingredient AS ingredient_1,
    i2.ingredient AS ingredient_2,
    COUNT(DISTINCT i1.drug_code) AS number_of_products
FROM clean.active_ingredients AS i1
JOIN clean.active_ingredients AS i2 ON i1.drug_code = i2.drug_code
JOIN clean.drug_product AS p ON p.drug_code = i1.drug_code
WHERE i1.ingredient > i2.ingredient
  AND p.class = 'Human'
GROUP BY i1.ingredient, i2.ingredient
ORDER BY number_of_products DESC, ingredient_1, ingredient_2
LIMIT 10;
