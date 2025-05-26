CREATE TABLE [dbo].[GTL_CommonReportTypeConfig]
(
[Code] [int] NOT NULL,
[Description] [varchar] (500) NULL,
[GroupCode] [varchar] (50) NULL,
[FromDateCaption] [varchar] (100) NULL,
[ToDateCaption] [varchar] (100) NULL,
[ShowToDate] [varchar] (1) NULL,
[SortOrder] [int] NULL,
[Active] [varchar] (1) NULL,
[EUser] [varchar] (25) NULL,
[LastUpdatedOn] [datetime] NOT NULL CONSTRAINT [DF__GTL_Commo__LastU__3AD6B8E2] DEFAULT (getdate())
)
GO
ALTER TABLE [dbo].[GTL_CommonReportTypeConfig] ADD CONSTRAINT [PK_Code] PRIMARY KEY CLUSTERED ([Code])
GO
