CREATE TABLE [dbo].[GTL_FunctionalDesignation]
(
[DepartmentID] [int] NULL,
[FunctionalDesignation] [varchar] (100) NULL,
[RoleIDs] [varchar] (max) NULL,
[Euser] [varchar] (25) NULL,
[LastUpdatedOn] [datetime] NOT NULL CONSTRAINT [DF__GTL_Funct__LastU__3F9B6DFF] DEFAULT (getdate()),
[PKSlNo] [int] NOT NULL IDENTITY(1, 1)
)
GO
ALTER TABLE [dbo].[GTL_FunctionalDesignation] ADD CONSTRAINT [GTL_FunctionalDesignation_PKSlNo] PRIMARY KEY CLUSTERED ([PKSlNo])
GO
