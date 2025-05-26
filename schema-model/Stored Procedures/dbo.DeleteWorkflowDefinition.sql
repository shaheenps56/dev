SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[DeleteWorkflowDefinition]
    @WorkflowDefinitionID INT
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

        -- Check for dependent WorkflowTypes to prevent orphaning
        IF EXISTS (
            SELECT 1 FROM WorkflowType
            WHERE WorkflowDefinitionID = @WorkflowDefinitionID AND COMPANYID = 1
        )
        BEGIN
            RAISERROR('Cannot delete WorkflowDefinition as it has associated WorkflowTypes.', 16, 1);
            RETURN;
        END

        -- Delete WorkflowDefinition
        DELETE FROM WorkflowDefinition
        WHERE WorkflowDefinitionID = @WorkflowDefinitionID AND COMPANYID = 1;

        SELECT 'WorkflowDefinition deleted successfully.' AS Message;
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
