CREATE TABLE [dbo].[WorkflowRequestData]
(
[RequestDataID] [int] NOT NULL IDENTITY(1, 1),
[RequestID] [int] NOT NULL,
[COMPANYID] [int] NOT NULL CONSTRAINT [DF__WorkflowR__COMPA__731B1205] DEFAULT ((1)),
[FormFieldID] [int] NOT NULL,
[FieldValue] [varchar] (max) NOT NULL,
[CreatedOn] [datetime] NOT NULL CONSTRAINT [DF__WorkflowR__Creat__740F363E] DEFAULT (getdate())
)
GO
ALTER TABLE [dbo].[WorkflowRequestData] ADD CONSTRAINT [PK__Workflow__3867C28A0FF196A8] PRIMARY KEY CLUSTERED ([RequestDataID])
GO
