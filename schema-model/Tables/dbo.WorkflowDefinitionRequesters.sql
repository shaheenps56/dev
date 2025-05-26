CREATE TABLE [dbo].[WorkflowDefinitionRequesters]
(
[WorkflowDefinitionID] [int] NOT NULL,
[COMPANYID] [int] NOT NULL CONSTRAINT [DF__WorkflowD__COMPA__6D6238AF] DEFAULT ((1)),
[RequesterGroupID] [numeric] (5, 5) NOT NULL
)
GO
ALTER TABLE [dbo].[WorkflowDefinitionRequesters] ADD CONSTRAINT [PK__Workflow__9FB5004359B92C09] PRIMARY KEY CLUSTERED ([WorkflowDefinitionID], [COMPANYID], [RequesterGroupID])
GO
