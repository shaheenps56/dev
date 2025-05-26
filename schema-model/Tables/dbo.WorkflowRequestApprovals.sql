CREATE TABLE [dbo].[WorkflowRequestApprovals]
(
[ApprovalID] [int] NOT NULL IDENTITY(1, 1),
[RequestID] [int] NOT NULL,
[COMPANYID] [int] NOT NULL CONSTRAINT [DF__WorkflowR__COMPA__7132C993] DEFAULT ((1)),
[ApproverLevelID] [int] NOT NULL,
[ApproverUserID] [int] NOT NULL,
[Action] [varchar] (50) NOT NULL,
[Comments] [varchar] (max) NULL,
[ActionDate] [datetime] NOT NULL CONSTRAINT [DF__WorkflowR__Actio__7226EDCC] DEFAULT (getdate())
)
GO
ALTER TABLE [dbo].[WorkflowRequestApprovals] ADD CONSTRAINT [PK__Workflow__328477D42DE3E564] PRIMARY KEY CLUSTERED ([ApprovalID])
GO
