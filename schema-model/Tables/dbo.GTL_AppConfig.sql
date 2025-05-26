CREATE TABLE [dbo].[GTL_AppConfig]
(
[FromDate] [datetime] NOT NULL,
[ToDate] [datetime] NOT NULL,
[Parameter] [varchar] (100) NOT NULL,
[Value] [varchar] (max) NULL,
[Project] [varchar] (50) NULL,
[Remarks] [varchar] (1000) NULL,
[EUser] [varchar] (25) NULL,
[LastUpdatedOn] [datetime] NOT NULL CONSTRAINT [DF__GTL_AppCo__LastU__38EE7070] DEFAULT (getdate()),
[PKSlno] [int] NOT NULL IDENTITY(1, 1)
)
GO
ALTER TABLE [dbo].[GTL_AppConfig] ADD CONSTRAINT [PK_AppConfig] PRIMARY KEY CLUSTERED ([FromDate], [Parameter])
GO
