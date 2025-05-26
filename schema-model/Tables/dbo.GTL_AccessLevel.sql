CREATE TABLE [dbo].[GTL_AccessLevel]
(
[LevelID] [int] NOT NULL,
[Description] [varchar] (100) NULL,
[EUser] [varchar] (10) NULL,
[LastUpdatedOn] [datetime] NOT NULL CONSTRAINT [DF__GTL_Acces__LastU__37FA4C37] DEFAULT (getdate())
)
GO
ALTER TABLE [dbo].[GTL_AccessLevel] ADD CONSTRAINT [PK_GTL_AccessLevel] PRIMARY KEY CLUSTERED ([LevelID])
GO
