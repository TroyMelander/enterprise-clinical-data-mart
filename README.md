# Enterprise Clinical Data Mart (Hub-and-Spoke Architecture)

## Overview
This repository contains a sanitized, structural representation of an enterprise-scale clinical data mart. It demonstrates the architecture required to extract raw Electronic Medical Record (EMR) data, standardize it through tiered ETL pipelines, and deliver semantic data models to end-users. 

## The Business Problem
Healthcare analysts frequently encounter bottlenecks when querying raw EMR databases (like Epic Clarity) due to highly normalized, complex, and proprietary data dictionaries. This leads to redundant code, inconsistent KPIs, and slow report turnaround times.

## The Architectural Solution
This system implements a hub-and-spoke data architecture on Microsoft SQL Server:
1. **Staging (The Extraction):** High-throughput landing zones for raw EMR data.
2. **Core (The Hub):** Standardized, conformed dimensions and fact tables using surrogate keys.
3. **Data Marts (The Spokes):** Domain-specific semantic views (e.g., Encounters, Medications, Cohorts) that shield analysts from underlying schema changes and abstract complex business logic.

## Technical Stack Demonstrated
* **T-SQL / Microsoft SQL Server**
* **ETL Pipeline Design (Upsert / MERGE logic)**
* **Robust Error Handling (TRY...CATCH)**
* **Dimensional Modeling**
