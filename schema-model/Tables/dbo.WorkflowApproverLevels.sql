CREATE TABLE [dbo].[WorkflowApproverLevels]
(
[ApproverLevelID] [int] NOT NULL IDENTITY(1, 1),
[WorkflowDefinitionID] [int] NOT NULL,
[COMPANYID] [int] NOT NULL CONSTRAINT [DF__WorkflowA__COMPA__6991A7CB] DEFAULT ((1)),
[LevelOrder] [int] NOT NULL,
[ApproverGroupID] [numeric] (5, 5) NOT NULL
)
GO
ALTER TABLE [dbo].[WorkflowApproverLevels] ADD CONSTRAINT [PK__Workflow__557FB0BAF95B371C] PRIMARY KEY CLUSTERED ([ApproverLevelID])
GO
