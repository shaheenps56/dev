CREATE TABLE [dbo].[WorkflowFormFields]
(
[FormFieldID] [int] NOT NULL IDENTITY(1, 1),
[WorkflowTypeID] [int] NOT NULL,
[COMPANYID] [int] NOT NULL CONSTRAINT [DF__WorkflowF__COMPA__6E565CE8] DEFAULT ((1)),
[FieldName] [varchar] (100) NOT NULL,
[FieldLabel] [varchar] (100) NOT NULL,
[FieldType] [varchar] (50) NOT NULL,
[IsRequired] [bit] NOT NULL CONSTRAINT [DF__WorkflowF__IsReq__6F4A8121] DEFAULT ((0)),
[FieldOrder] [int] NOT NULL,
[FieldOptions] [varchar] (max) NULL,
[ValidationRules] [varchar] (max) NULL,
[DataSourceType] [varchar] (50) NULL,
[DataSourceDetails] [varchar] (max) NULL,
[DependsOn] [varchar] (100) NULL,
[CreatedByUserID] [int] NOT NULL,
[CreatedOn] [datetime] NOT NULL CONSTRAINT [DF__WorkflowF__Creat__703EA55A] DEFAULT (getdate()),
[LastUpdatedByUserID] [int] NULL,
[LastUpdatedOn] [datetime] NULL
)
GO
ALTER TABLE [dbo].[WorkflowFormFields] ADD CONSTRAINT [PK__Workflow__531C0C13AA57454E] PRIMARY KEY CLUSTERED ([FormFieldID])
GO
