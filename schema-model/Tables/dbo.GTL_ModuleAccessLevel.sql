CREATE TABLE [dbo].[GTL_ModuleAccessLevel]
(
[Code] [int] NULL,
[Description] [varchar] (100) NULL,
[Euser] [varchar] (25) NULL,
[LastUpdatedOn] [datetime] NOT NULL CONSTRAINT [DF__GTL_Modul__LastU__4183B671] DEFAULT (getdate()),
[PKSlNo] [int] NOT NULL IDENTITY(1, 1)
)
GO
ALTER TABLE [dbo].[GTL_ModuleAccessLevel] ADD CONSTRAINT [GTL_ModuleAccessLevel_PKSlNo] PRIMARY KEY CLUSTERED ([PKSlNo])
GO
