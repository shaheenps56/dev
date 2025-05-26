SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[AssignApproverGroupLevel]
    @WorkflowDefinitionID INT,
    @LevelOrder INT,
    @ApproverGroupID NUMERIC(5,0)
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

        -- Validate ApproverGroupID exists in GTL_UserGroups
        IF NOT EXISTS (
            SELECT 1 FROM GTL_UserGroups
            WHERE COMPANYID = 1 AND GROUPID = @ApproverGroupID
        )
        BEGIN
            RAISERROR('ApproverGroupID does not exist in GTL_UserGroups.', 16, 1);
            RETURN;
        END

        -- Check if LevelOrder already exists for the WorkflowDefinition
        IF EXISTS (
            SELECT 1 FROM WorkflowApproverLevels
            WHERE WorkflowDefinitionID = @WorkflowDefinitionID 
              AND COMPANYID = 1 
              AND LevelOrder = @LevelOrder
        )
        BEGIN
            RAISERROR('LevelOrder already assigned for this WorkflowDefinition.', 16, 1);
            RETURN;
        END

        -- Assign ApproverGroup to Level
        INSERT INTO WorkflowApproverLevels (
            WorkflowDefinitionID,
            COMPANYID,
            LevelOrder,
            ApproverGroupID
        )
        VALUES (
            @WorkflowDefinitionID,
            1,
            @LevelOrder,
            @ApproverGroupID
        );

        SELECT 'ApproverGroup assigned to level successfully.' AS Message;
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
