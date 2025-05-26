CREATE TABLE [dbo].[WorkflowType]
(
[WorkflowTypeID] [int] NOT NULL IDENTITY(1, 1),
[WorkflowDefinitionID] [int] NOT NULL,
[COMPANYID] [int] NOT NULL CONSTRAINT [DF__WorkflowT__COMPA__79C80F94] DEFAULT ((1)),
[TypeName] [varchar] (100) NOT NULL,
[TypeDescription] [varchar] (255) NULL,
[IsActive] [bit] NOT NULL CONSTRAINT [DF__WorkflowT__IsAct__7ABC33CD] DEFAULT ((1)),
[CreatedByUserID] [int] NOT NULL,
[CreatedOn] [datetime] NOT NULL CONSTRAINT [DF__WorkflowT__Creat__7BB05806] DEFAULT (getdate()),
[LastUpdatedByUserID] [int] NULL,
[LastUpdatedOn] [datetime] NULL
)
GO
ALTER TABLE [dbo].[WorkflowType] ADD CONSTRAINT [PK__Workflow__077F14C99D95D74C] PRIMARY KEY CLUSTERED ([WorkflowTypeID])
GO
