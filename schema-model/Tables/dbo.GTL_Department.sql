CREATE TABLE [dbo].[GTL_Department]
(
[DepartmentID] [int] NOT NULL,
[DepartmentCode] [varchar] (50) NOT NULL,
[DepartmentDesc] [varchar] (150) NOT NULL,
[Active] [char] (1) NOT NULL CONSTRAINT [DF__GTL_Depar__Activ__3BCADD1B] DEFAULT ('Y'),
[EUser] [varchar] (25) NOT NULL,
[LastUpdatedOn] [datetime] NOT NULL CONSTRAINT [DF__GTL_Depar__LastU__3CBF0154] DEFAULT (getdate()),
[SPOC] [varchar] (max) NULL
)
GO
ALTER TABLE [dbo].[GTL_Department] ADD CONSTRAINT [PK__GTL_Depa__B2079BCD4C9C82CD] PRIMARY KEY CLUSTERED ([DepartmentID])
GO
ALTER TABLE [dbo].[GTL_Department] ADD CONSTRAINT [UQ__GTL_Depa__6EA8896D585B81CB] UNIQUE NONCLUSTERED ([DepartmentCode])
GO
