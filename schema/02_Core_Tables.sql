/*
==============================================================================
Description: DDL for the Standardized Core Encounter Fact Table.
Architecture: Hub-and-Spoke Model - Core Hub
Author: Troy M. Melander
Note: This is mock script to protect UCSD Health related code and provide a highlevel informational perspective.
==============================================================================
*/

-- Create the schema if it does not exist
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Core')
BEGIN
    EXEC('CREATE SCHEMA [Core]');
END
GO

-- Drop table if exists to ensure clean deployment in this mock environment
IF OBJECT_ID('Core.FactEncounter', 'U') IS NOT NULL
    DROP TABLE Core.FactEncounter;
GO

CREATE TABLE Core.FactEncounter (
    EncounterKey        BIGINT IDENTITY(1,1) NOT NULL, -- Surrogate Key
    PatientKey          BIGINT NOT NULL,               -- FK to Core.DimPatient
    SourceEncounterID   VARCHAR(50) NOT NULL,          -- Natural Key from EMR
    EncounterDate       DATE NOT NULL,
    DepartmentKey       INT NOT NULL,                  -- FK to Core.DimDepartment
    EncounterType       VARCHAR(100) NULL,
    ClinicalStatus      VARCHAR(50) NULL,
    IsInpatient         BIT DEFAULT 0 NOT NULL,
    RowInsertDTS        DATETIME2 DEFAULT SYSDATETIME() NOT NULL,
    RowUpdateDTS        DATETIME2 DEFAULT SYSDATETIME() NOT NULL,

    CONSTRAINT PK_FactEncounter PRIMARY KEY CLUSTERED (EncounterKey)
);
GO

-- Create a Non-Clustered Index to optimize ETL lookups on the Natural Key
CREATE NONCLUSTERED INDEX IX_FactEncounter_SourceEncounterID 
ON Core.FactEncounter (SourceEncounterID)
INCLUDE (PatientKey, EncounterDate);
GO
