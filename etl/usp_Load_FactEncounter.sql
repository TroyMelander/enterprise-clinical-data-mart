/*
==============================================================================
Description: ETL Stored Procedure to load Core.FactEncounter using MERGE.
Handles Inserts for new encounters and Updates for changed clinical statuses.
Author: Troy M. Melander
==============================================================================
*/

CREATE OR ALTER PROCEDURE etl.usp_Load_FactEncounter
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @ProcessName VARCHAR(100) = 'Load FactEncounter';
    DECLARE @RowsAffected INT = 0;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- MERGE Statement: Upsert logic from Staging to Core
        MERGE Core.FactEncounter AS Target
        USING (
            -- Simulate the extraction logic joining Staging data to Core Dimensions
            SELECT 
                p.PatientKey,
                s.SourceEncounterID,
                s.EncounterDate,
                d.DepartmentKey,
                s.EncounterType,
                s.ClinicalStatus,
                s.IsInpatient
            FROM Staging.RawEncounters s
            INNER JOIN Core.DimPatient p ON s.SourcePatientID = p.SourcePatientID
            INNER JOIN Core.DimDepartment d ON s.SourceDeptID = d.SourceDeptID
        ) AS Source
        ON (Target.SourceEncounterID = Source.SourceEncounterID)

        WHEN MATCHED AND (
            Target.ClinicalStatus <> Source.ClinicalStatus 
            OR Target.EncounterType <> Source.EncounterType
        ) THEN 
            -- Update existing records if clinical attributes change
            UPDATE SET 
                Target.ClinicalStatus = Source.ClinicalStatus,
                Target.EncounterType = Source.EncounterType,
                Target.RowUpdateDTS = SYSDATETIME()

        WHEN NOT MATCHED BY TARGET THEN 
            -- Insert new encounters
            INSERT (PatientKey, SourceEncounterID, EncounterDate, DepartmentKey, EncounterType, ClinicalStatus, IsInpatient)
            VALUES (Source.PatientKey, Source.SourceEncounterID, Source.EncounterDate, Source.DepartmentKey, Source.EncounterType, Source.ClinicalStatus, Source.IsInpatient);

        SET @RowsAffected = @@ROWCOUNT;

        COMMIT TRANSACTION;
        
        -- Optional: Log success to an audit table
        -- EXEC etl.usp_LogProcess @ProcessName, 'Success', @RowsAffected;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Capture and log error details
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- EXEC etl.usp_LogError @ProcessName, @ErrorMessage;
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO
