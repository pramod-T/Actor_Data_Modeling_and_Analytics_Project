# 🎬 Actor Analytics Platform — SQL Data Engineering Project

This project implements a **SQL-based data modeling pipeline** to track actor performance across time using **cumulative history**, **Type 2 Slowly Changing Dimensions (SCD)**, and **incremental data processing**.

It reflects core data engineering patterns and supports powerful analytics — all modeled in **PostgreSQL**.

---

## 🛠 Tech Stack

- PostgreSQL
- SQL (CTEs, window functions, enums, arrays)
- Data Engineering Concepts:
  - Dimensional Modeling
  - Cumulative Table concept
  - Slowly Changing Dimensions (SCD Type 2)
  - Analytical Reporting



## Data Source

The dataset was loaded using a PostgreSQL `.dump` file from a real server (not included here).

---


## 📂 Project Structure

- sql
  - 01_DDL_actors.sql -- Base tables and custom types (films, quality_class)
  - 02_generate_cumulative_actor_table.sql -- Cumulative actor generation (1969–2021)
  - 03_DDL_SCD_table.sql -- Slowly changing dimensions Type-2 table
  - 04_backfill_scd_history.sql -- SCD Type 2 logic to track quality/status changes
  - 05_incremental_scd_update.sql -- logic for Incremental update of SCD.
  - 06_actor_analytics.sql -- SQL queries for actor performance and trends.

---

## Data Model

- **`actors` table** stores actor information by year, including:
  - List of films acted in (with rating, votes, ID)
  - Quality class (`star`, `good`, `average`, `bad`)
  - Active/inactive status
  - year (slowly evolving dimension)

- **Custom Types**:
  - `films`: composite type to store each film's metadata
  - `quality_class`: enum to classify actor performance
---

## Cumulative Table Data Tranformation and Loading Logic

In `02_generate_cumulative_actor_table.sql`, a cumulative data that is generated for each actor:

- Combines data from the current and previous year
- Aggregates all films an actor has done up to that point
- Calculates **average rating** to classify actors:
  - `>8` → `star`
  - `>7` → `good`
  - `>6` → `average`
  - else → `bad`
- Tracks **activity status** (`is_active`) based on presence in the current year
- Merges newly released films with historical records

This process helps simulate a time-traveling data warehouse view of actor careers.

## Slowly Changing Dimension (SCD Type 2)

In `04_backfill_scd_history.sql`, implemented **SCD Type 2 logic**:

- Detects changes in:
  - `is_active` status (active ↔ inactive)
  - `quality_class` (e.g., average → star)
- Assigns each unique streak a `streak_identifier`
- Aggregates start and end years for each state
- Backfills an **`actors_scd_table`** with historical segments for each actor's journey

This allows detailed tracking of actor evolution over time without losing history.

---

## 📊 Analytics Performed

In `actor_analytics.sql`, performed rich analytics using the modeled data:

- **Yearly Active Actor Counts**  
- **Quality Class Distribution Over Time**
- **Actors Who Improved from Average to Star**
- **Longest Continuous Active Streaks**
- **First Year Becoming Star**
- **Comeback Actors (Inactive → Active Again)**
- **Find top 10 actors who sustained star quality the longest across their career.**
- **Identifies actors whose final known career segment was as a star**



These insights help understand:
- Talent evolution
- Industry dynamics
- Career peaks and declines

---

## Use Cases

- Talent analytics for casting agencies
- Career trajectory dashboards
- Data warehouse modeling practice
- Teaching dimensional modeling and SCD concepts

---

## 🧠 Learnings

✅ How to model historical data  
✅ Use of custom types and arrays in SQL  
✅ Implementation of SCD Type 2 manually  
✅ Aggregations with window functions  
✅ Building analytics on top of data models

---
