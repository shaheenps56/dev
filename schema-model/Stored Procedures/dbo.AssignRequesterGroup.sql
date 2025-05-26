SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[AssignRequesterGroup]
    @WorkflowDefinitionID INT,
    @RequesterGroupID NUMERIC(5,0)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validate WorkflowDefinition exists
        IF NOT EXISTS (
            SELECT 1 FROM WorkflowDefinition
            WHERE WorkflowDefinitionID = @WorkflowDefinitionID AND COMPANYID = 1
        )
        BEGIN
            RAISERROR('WorkflowDefinitionID does not exist.', 16, 1);
            RETURN;
        END

        -- Validate RequesterGroupID exists in GTL_UserGroups
        IF NOT EXISTS (
            SELECT 1 FROM GTL_UserGroups
            WHERE COMPANYID = 1 AND GROUPID = @RequesterGroupID
        )
        BEGIN
            RAISERROR('RequesterGroupID does not exist in GTL_UserGroups.', 16, 1);
            RETURN;
        END

        -- Check if assignment already exists
        IF EXISTS (
            SELECT 1 FROM WorkflowDefinitionRequesters
            WHERE WorkflowDefinitionID = @WorkflowDefinitionID 
              AND COMPANYID = 1 
              AND RequesterGroupID = @RequesterGroupID
        )
        BEGIN
            RAISERROR('RequesterGroupID is already assigned to this WorkflowDefinition.', 16, 1);
            RETURN;
        END

        -- Assign RequesterGroup
        INSERT INTO WorkflowDefinitionRequesters (
            WorkflowDefinitionID,
            COMPANYID,
            RequesterGroupID
        )
        VALUES (
            @WorkflowDefinitionID,
            1,
            @RequesterGroupID
        );

        SELECT 'RequesterGroup assigned successfully.' AS Message;
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
