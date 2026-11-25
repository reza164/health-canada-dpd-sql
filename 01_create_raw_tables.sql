-- One-time setup in a NEW, empty database. Do not run in the original database.
-- File columns follow the author's local layout; verify your extract before import.
CREATE SCHEMA raw;

CREATE TABLE raw.drug_product (
    drug_code text, product_categorization text, class text,
    drug_identification_number text, brand_name text, descriptor text,
    pediatric_flag text, accession_number text, number_of_ais text,
    last_update_date text, ai_group_no text, class_f text, brand_name_f text,
    descriptor_f text
);

CREATE TABLE raw.active_ingredients (
    drug_code text, active_ingredient_code text, ingredient text,
    ingredient_supplied_ind text, strength text, strength_unit text,
    strength_type text, dosage_value text, base text, dosage_unit text,
    notes text, ingredient_f text, strength_unit_f text, strength_type_f text,
    dosage_unit_f text
);

CREATE TABLE raw.companies (
    drug_code text, mfr_code text, company_code text, company_name text,
    company_type text, address_mailing_flag text, address_billing_flag text,
    address_notification_flag text, address_other text, suite_number text,
    street_name text, city_name text, province text, country text,
    postal_code text, post_office_box text, province_f text, country_f text
);

CREATE TABLE raw.forms (
    drug_code text, pharm_form_code text, pharmaceutical_form text,
    pharmaceutical_form_f text
);

-- Local file was observed to have four columns. The current Health Canada
-- documentation lists seven; inspect the specific file before importing it.
CREATE TABLE raw.therapeutic_import (
    drug_code text, tc_atc_number text, tc_atc text, fourth_field text
);
