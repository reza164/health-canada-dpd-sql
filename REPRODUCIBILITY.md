# Reproducing the analysis

## Before you begin

This project is based on a local PostgreSQL database built through pgAdmin. The analysis queries are provided, but an independent end-to-end reconstruction on the exact original files has **not** been completed. The original extract's download date, product-status category, import settings and complete file contents remain unverified. Newer Health Canada files can produce different results.

Do not run setup scripts against the existing `health_canada_dpd` database: they create tables and views that may already exist. Use a **new, empty database** to reproduce from scratch. No script here drops data or overwrites an existing table.

## 1. Identify and download the source

1. Download a consistent set of product, ingredient, company, form and therapeutic-class files from [Health Canada](https://www.canada.ca/en/health-canada/services/drugs-health-products/drug-products/drug-product-database/what-data-extract-drug-product-database.html). Record the download date, source URLs, filenames, status category and file hashes.
2. The [official readme](https://www.canada.ca/en/health-canada/services/drugs-health-products/drug-products/drug-product-database/read-file-drug-product-database-data-extract.html) describes comma-separated, double-quoted UTF-8 files and the field layouts. Inspect the actual files: formats can change and the local therapeutic file appeared to contain four fields despite the documentation listing seven.
3. Keep the original downloads unchanged. If a file is modified for import, save a separate copy and document every modification.

## 2. Create and import raw tables

1. In a new PostgreSQL database, run `01_create_raw_tables.sql` **once**. All fields are initially `text`, including identifiers and dates, preserving the imported representation. The script reflects the four-field local therapeutic table; check your source layout first.
2. Import the corresponding product, ingredient, company, form and therapeutic files into their matching tables with pgAdmin's Import/Export Data tool. Select CSV, UTF-8, comma delimiter and appropriate quote/escape settings for the actual file. Check whether the file has a header rather than assuming one. Verify column counts and order against both the file and Health Canada's documentation.
3. The ingredient file used for the successful import was checked afterward. It contained 19,439 records, 19,438 distinct full rows and 13,356 distinct drug codes, matching the database counts; every record had 15 fields. Matching counts do not establish that every imported value is identical or whether the file was changed before import. Keep the original source file and reconcile it with the database when possible.
4. Avoid importing the same file twice. Check counts and exact duplicate groups before and after import. The author's product table was imported twice; the clean view removed exact duplicate rows, but preserving an accurate import process is preferable.

## 3. Create views and run checks

1. Run `02_create_clean_views.sql` once after importing raw tables. The clean views use `SELECT DISTINCT *`. The numeric-strength view performs an on-read cast: nonnumeric future data can make it fail. `strength_numeric` is unconstrained numeric, so the script does not round to two decimal places.
2. Run statements in `07_data_quality_checks.sql` individually. Check duplicate counts, product-code uniqueness and unmatched records. `COUNT(DISTINCT drug_code)` ignores nulls; the key checks call out missing product codes separately. Verify that the numeric strength check completes.
3. Run `03_benzodiazepine_ranking.sql` through `06_therapeutic_coverage.sql`. Compare results with the supplied CSV snapshots where applicable. Run `08_update_dates.sql` for the exploratory date analysis.

The clean views are logical views and reflect the current raw tables; they are not frozen copies. The numeric cast does not change the original text column. Only scripts 01 and 02 create database objects; the analysis and validation queries are read-only.

## Original reported counts for comparison

| Check | Reported in author's local snapshot |
| --- | ---: |
| Raw product rows / distinct full product rows | 26,712 / 13,356 |
| Raw ingredient rows / distinct full ingredient rows | 19,439 / 19,438 |
| Raw company rows / distinct product codes | 13,356 / 13,356 |
| Raw form rows / distinct product codes | 13,638 / 13,356 |
| Raw therapeutic rows / distinct full rows | 13,176 / 12,418 |
| Product codes without a therapeutic match | 938 |

These counts are observations, not assertions about a newer download or proof that a source file was complete. Any difference should be investigated against the source files and import settings.
