CREATE TABLE [dbo].[WorkflowDefinition]
(
[WorkflowDefinitionID] [int] NOT NULL IDENTITY(1, 1),
[COMPANYID] [int] NOT NULL CONSTRAINT [DF__WorkflowD__COMPA__6A85CC04] DEFAULT ((1)),
[WorkflowName] [varchar] (100) NOT NULL,
[WorkflowDescription] [varchar] (255) NULL,
[FinalApproverGroupID] [numeric] (5, 0) NOT NULL,
[IsActive] [bit] NOT NULL CONSTRAINT [DF__WorkflowD__IsAct__6B79F03D] DEFAULT ((1)),
[CreatedByUserID] [int] NOT NULL,
[CreatedOn] [datetime] NOT NULL CONSTRAINT [DF__WorkflowD__Creat__6C6E1476] DEFAULT (getdate()),
[LastUpdatedByUserID] [int] NULL,
[LastUpdatedOn] [datetime] NULL
)
GO
ALTER TABLE [dbo].[WorkflowDefinition] ADD CONSTRAINT [PK__Workflow__30FF7BD6587FA040] PRIMARY KEY CLUSTERED ([WorkflowDefinitionID])
GO
