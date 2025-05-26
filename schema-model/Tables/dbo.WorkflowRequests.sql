CREATE TABLE [dbo].[WorkflowRequests]
(
[RequestID] [int] NOT NULL IDENTITY(1, 1),
[WorkflowTypeID] [int] NOT NULL,
[COMPANYID] [int] NOT NULL CONSTRAINT [DF__WorkflowR__COMPA__75035A77] DEFAULT ((1)),
[RequesterUserID] [int] NOT NULL,
[CurrentApprovalLevel] [int] NULL,
[Status] [varchar] (50) NOT NULL CONSTRAINT [DF__WorkflowR__Statu__75F77EB0] DEFAULT ('Pending'),
[SubmittedOn] [datetime] NOT NULL CONSTRAINT [DF__WorkflowR__Submi__76EBA2E9] DEFAULT (getdate()),
[LastActionOn] [datetime] NOT NULL CONSTRAINT [DF__WorkflowR__LastA__77DFC722] DEFAULT (getdate()),
[IsActive] [bit] NOT NULL CONSTRAINT [DF__WorkflowR__IsAct__78D3EB5B] DEFAULT ((1))
)
GO
ALTER TABLE [dbo].[WorkflowRequests] ADD CONSTRAINT [PK__Workflow__33A8519AF57DE690] PRIMARY KEY CLUSTERED ([RequestID])
GO
