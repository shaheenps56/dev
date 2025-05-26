SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[UpdateWorkflowDefinition]
    @WorkflowDefinitionID INT,
    @WorkflowName VARCHAR(100) = NULL,
    @WorkflowDescription VARCHAR(255) = NULL,
    @FinalApproverGroupID NUMERIC(5,0) = NULL,
    @IsActive BIT = NULL,
    @LastUpdatedByUserID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Check if WorkflowDefinition exists
        IF NOT EXISTS (
            SELECT 1 FROM WorkflowDefinition
            WHERE WorkflowDefinitionID = @WorkflowDefinitionID AND COMPANYID = 1
        )
        BEGIN
            RAISERROR('WorkflowDefinitionID does not exist.', 16, 1);
            RETURN;
        END

        -- If FinalApproverGroupID is provided, validate it
        IF @FinalApproverGroupID IS NOT NULL
        BEGIN
            IF NOT EXISTS (
                SELECT 1 FROM GTL_UserGroups
                WHERE COMPANYID = 1 AND GROUPID = @FinalApproverGroupID
            )
            BEGIN
                RAISERROR('FinalApproverGroupID does not exist in GTL_UserGroups.', 16, 1);
                RETURN;
            END
        END

        -- If LastUpdatedByUserID is provided, validate it
        IF @LastUpdatedByUserID IS NOT NULL
        BEGIN
            IF NOT EXISTS (
                SELECT 1 FROM GTL_Users
                WHERE COMPANYID = 1 AND USERID = @LastUpdatedByUserID
            )
            BEGIN
                RAISERROR('LastUpdatedByUserID does not exist in GTL_Users.', 16, 1);
                RETURN;
            END
        END

        -- Update WorkflowDefinition
        UPDATE WorkflowDefinition
        SET
            WorkflowName = COALESCE(@WorkflowName, WorkflowName),
            WorkflowDescription = COALESCE(@WorkflowDescription, WorkflowDescription),
            FinalApproverGroupID = COALESCE(@FinalApproverGroupID, FinalApproverGroupID),
            IsActive = COALESCE(@IsActive, IsActive),
            LastUpdatedByUserID = COALESCE(@LastUpdatedByUserID, LastUpdatedByUserID),
            LastUpdatedOn = CASE WHEN @LastUpdatedByUserID IS NOT NULL THEN GETDATE() ELSE LastUpdatedOn END
        WHERE
            WorkflowDefinitionID = @WorkflowDefinitionID AND COMPANYID = 1;

        SELECT 'WorkflowDefinition updated successfully.' AS Message;
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
