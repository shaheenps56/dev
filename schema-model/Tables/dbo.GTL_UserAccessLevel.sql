CREATE TABLE [dbo].[GTL_UserAccessLevel]
(
[Code] [varchar] (20) NULL,
[Description] [varchar] (100) NULL,
[Euser] [varchar] (25) NULL,
[LastUpdatedOn] [datetime] NOT NULL CONSTRAINT [DF__GTL_UserA__LastU__4CF5691D] DEFAULT (getdate()),
[PKSlNo] [int] NOT NULL IDENTITY(1, 1)
)
GO
ALTER TABLE [dbo].[GTL_UserAccessLevel] ADD CONSTRAINT [GTL_UserAccessLevel_PKSlNo] PRIMARY KEY CLUSTERED ([PKSlNo])
GO
