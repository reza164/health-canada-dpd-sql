# Exploring Canada's Drug Product Database with PostgreSQL

An exploratory data-analysis project using a locally imported snapshot of Health Canada's Drug Product Database (DPD). It examines recorded product strengths, pharmaceutical forms, associated companies, and combinations of active ingredients. The project also investigates duplicate records and incomplete therapeutic-class matches before interpreting the results.

**Tools and techniques:** PostgreSQL · pgAdmin · joins and self-joins · common table expressions (CTEs) · window functions · data-quality checks · text-to-numeric conversion.

## Questions and findings

These are observed results from the author's local snapshot, not current Canadian market statistics. The exact source-file version, successful import settings, and completeness of the ingredient file still need to be confirmed (see [Reproducing the analysis](REPRODUCIBILITY.md)).

### 1. How do listed benzodiazepine strengths compare across companies?

For Human products containing alprazolam, clonazepam, diazepam or lorazepam, which strengths have the largest number of distinct associated company names within each ingredient and pharmaceutical form?

The query groups by ingredient, form, numeric strength and strength unit, then ranks company counts within each ingredient–form group. `DENSE_RANK()` retains ties. In this snapshot, three lorazepam tablet strengths—0.5, 1 and 2 MG—each had **five associated company names**. These counts are based on recorded names, not corporate identity, sales or prescriptions.

[Query](03_benzodiazepine_ranking.sql) · [Observed results](results_benzodiazepine_ranking.csv)

### 2. Which active ingredients most often occur together?

A self-join pairs different ingredient names on the same product code. Alphabetical ordering prevents the same pair appearing in both directions; distinct product counts avoid inflating totals when an ingredient has multiple records for a product.

The leading pair in this snapshot was **octisalate and avobenzone**, recorded together in **383 distinct Human product codes**. A separate product-level query returned 383 rows with 383 distinct product codes for this pair. The top-ten list and the validation query are linked below.

[Query](04_ingredient_pairs.sql) · [Observed top ten](results_top_ingredient_pairs.csv) · [Validation query](05_pair_validation.sql)

### 3. How complete are therapeutic-class matches?

An anti-join found **938 product codes** without a matching record in the deduplicated therapeutic-class table: 927 Veterinary, 8 Human and 3 Radiopharmaceutical. This is a coverage observation, not evidence that the products are defective or misclassified.

The original exploration also attempted a class-level percentage using a direct join to the therapeutic table. That join can multiply product rows when a product has more than one therapeutic record. The revised query uses `EXISTS` so each product contributes once to the denominator. The revised percentage results have **not yet been run on the original database**.

[Coverage and validation queries](06_therapeutic_coverage.sql)

## Source and project scope

- **Source:** [Health Canada DPD data extract](https://www.canada.ca/en/health-canada/services/drugs-health-products/drug-products/drug-product-database/what-data-extract-drug-product-database.html) and [official extract structure](https://www.canada.ca/en/health-canada/services/drugs-health-products/drug-products/drug-product-database/read-file-drug-product-database-data-extract.html).
- **Local database:** PostgreSQL, with `raw` tables and deduplicated `clean` views. The saved practice script identifies the tables and transformations used; the local environment was accessed through pgAdmin.
- **Extract status and download date:** not yet verified. Health Canada distributes marketed, approved, dormant and cancelled extracts separately; the results should not be labelled as currently marketed until the specific files are confirmed.
- **Data not included:** Download the source independently. Data files and the author's original exploratory script are not included in the repository.

## Data quality and interpretation

- The author's raw product table had 26,712 rows and 13,356 distinct full rows; each distinct row appeared twice. The clean product view uses `SELECT DISTINCT`; it does not delete raw data.
- The raw ingredient table had 19,439 rows and 19,438 distinct full rows. Exact duplicates were removed in the clean view. Multiple rows for an ingredient can still be legitimate—for example, different strengths or descriptions.
- An initial ingredient-file import failed at line 19,440 with a CSV quoting error. A later import succeeded and reported 19,439 rows. **Whether any source records were changed, removed, skipped or lost during correction has not been established.** Compare with the original source before treating these analyses as complete.
- Strength was imported as text; a view converts it to PostgreSQL `numeric` without imposing a fixed precision or rounding. A successful conversion does not mean the strength is clinically equivalent across forms, units, ingredients or denominators. Some dosage-value fields were blank.
- Company counts are distinct **names as recorded**, not necessarily distinct manufacturers or corporate groups. Inner joins omit products lacking a match. Ingredient spelling and chemical forms were not standardized, and the selected four-ingredient list is not a complete benzodiazepine classification.
- Product counts do not measure use, prescriptions, market share, safety or clinical effectiveness. `LIMIT 10` may omit ties at the cutoff. A product containing three ingredients contributes to three different ingredient pairs.

## Repository guide

| File | Purpose |
| --- | --- |
| [REPRODUCIBILITY.md](REPRODUCIBILITY.md) | Setup, import and validation steps; known gaps |
| [DATA_DICTIONARY.md](DATA_DICTIONARY.md) | Relationships and important columns |
| `01_create_raw_tables.sql` | Raw table definitions for a new database |
| `02_create_clean_views.sql` | Deduplicated views and numeric strength |
| `03_benzodiazepine_ranking.sql` | Company-count ranking with ties |
| `04_ingredient_pairs.sql` | Most common Human product ingredient pairs |
| `05_pair_validation.sql` | Product-level check for the leading pair |
| `06_therapeutic_coverage.sql` | Matching checks and class-level coverage |
| `07_data_quality_checks.sql` | Duplicates, key checks and missing strengths |
| `08_update_dates.sql` | Last-update date exploration |
| `results_*.csv` | Results copied from the author's original analysis |

**Status:** exploratory portfolio project; source reconciliation and an end-to-end reproduction against the original snapshot remain open. Future work includes connecting to the database from Python, visualizing results, and continuing SQL practice.
