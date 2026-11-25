-- Human products: rank recorded strength/unit groups by the number of distinct
-- associated company names within each ingredient and pharmaceutical form.
-- DENSE_RANK includes all ties. This is not a ranking by prescriptions or sales.
WITH ranked_strengths AS (
    SELECT
        i.ingredient,
        f.pharmaceutical_form,
        i.strength_numeric,
        i.strength_unit,
        COUNT(DISTINCT c.company_name) AS number_of_companies,
        DENSE_RANK() OVER (
            PARTITION BY i.ingredient, f.pharmaceutical_form
            ORDER BY COUNT(DISTINCT c.company_name) DESC
        ) AS company_count_rank
    FROM clean.active_ingredients_numeric_strengths AS i
    JOIN clean.drug_product AS p ON p.drug_code = i.drug_code
    JOIN clean.forms AS f ON f.drug_code = p.drug_code
    JOIN clean.companies AS c ON c.drug_code = p.drug_code
    WHERE p.class = 'Human'
      AND (i.ingredient ILIKE '%alprazolam%'
        OR i.ingredient ILIKE '%clonazepam%'
        OR i.ingredient ILIKE '%diazepam%'
        OR i.ingredient ILIKE '%lorazepam%')
    GROUP BY i.ingredient, f.pharmaceutical_form, i.strength_numeric, i.strength_unit
)
SELECT ingredient, pharmaceutical_form, strength_numeric, strength_unit,
       number_of_companies, company_count_rank
FROM ranked_strengths
WHERE company_count_rank = 1
ORDER BY ingredient, pharmaceutical_form, strength_numeric, strength_unit;
