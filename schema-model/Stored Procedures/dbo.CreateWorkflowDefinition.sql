SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CreateWorkflowDefinition]
    @WorkflowName VARCHAR(100),
    @WorkflowDescription VARCHAR(255) = NULL,
    @FinalApproverGroupID NUMERIC(5,0), -- Changed to NUMERIC(5,0) to match table schema
    @CreatedByUserID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validate FinalApproverGroupID exists in GTL_UserGroups for COMPANYID=1
        IF NOT EXISTS (
            SELECT 1 FROM GTL_UserGroups
            WHERE COMPANYID = 1 AND GROUPID = @FinalApproverGroupID
        )
        BEGIN
            RAISERROR('FinalApproverGroupID does not exist in GTL_UserGroups.', 16, 1);
            RETURN;
        END

        -- Validate CreatedByUserID exists in GTL_Users for COMPANYID=1
        IF NOT EXISTS (
            SELECT 1 FROM GTL_Users
            WHERE COMPANYID = 1 AND USERID = @CreatedByUserID
        )
        BEGIN
            RAISERROR('CreatedByUserID does not exist in GTL_Users.', 16, 1);
            RETURN;
        END

        -- Insert into WorkflowDefinition
        INSERT INTO WorkflowDefinition (
            WorkflowName,
            WorkflowDescription,
            FinalApproverGroupID,
            IsActive,
            CreatedByUserID,
            CreatedOn
        )
        VALUES (
            @WorkflowName,
            @WorkflowDescription,
            @FinalApproverGroupID,
            1, -- IsActive default
            @CreatedByUserID,
            GETDATE()
        );

        SELECT SCOPE_IDENTITY() AS WorkflowDefinitionID;
    END TRY
    BEGIN CATCH
        -- Capture error details
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- Re-raise the error with the same severity and state
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END

GO
