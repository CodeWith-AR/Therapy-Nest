# Therapy Nest — Database Schemas & Migrations

This folder contains the Supabase PostgreSQL database schemas, indexes, and Row-Level Security (RLS) policies for **Therapy Nest**.

## 📁 Migration Sequence

Execute these SQL scripts in the Supabase SQL Editor in the following order:

1. **`supabase_profile_setup.sql`**
   - Establishes `user_profiles` and `patient_profiles` tables.
   - Configures automatic trigger to populate `user_profiles` upon user sign-up in Supabase Auth.
   - Configures user role enumeration (`patient`, `clinician`, `admin`).

2. **`therapy_nest_m3_migration.sql`**
   - Sets up cognitive exercises, domain categories, and task stimuli metadata.
   - Defines initial 2PL Item Response Theory psychometric parameters ($a$ discrimination, $b$ difficulty).
   - Initializes diagnostic baseline assessment question banks.

3. **`therapy_nest_m7_sync_migration.sql`**
   - Configures session telemetry logging, attempt tracking, and patient streak history.
   - Adds indexes for sub-millisecond asynchronous sync performance from Flutter Drift SQLite.
