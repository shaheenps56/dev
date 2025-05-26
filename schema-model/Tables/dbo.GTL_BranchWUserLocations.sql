CREATE TABLE [dbo].[GTL_BranchWUserLocations]
(
[USERID] [int] NOT NULL,
[COMPANYID] [int] NOT NULL,
[USERCODE] [nvarchar] (16) NOT NULL,
[LOCATIONID] [varchar] (500) NOT NULL,
[REGIONID] [varchar] (500) NULL,
[LANGID] [int] NOT NULL,
[ACCESSLOCATIONS] [nvarchar] (2000) NOT NULL,
[USERPROJECTS] [nvarchar] (2000) NULL,
[TOLOCATION] [nvarchar] (50) NULL,
[Euser] [varchar] (30) NULL,
[Lastupdatedon] [datetime] NULL,
[PKSlNo] [int] NOT NULL IDENTITY(1, 1)
)
GO
ALTER TABLE [dbo].[GTL_BranchWUserLocations] ADD CONSTRAINT [GTL_BranchWUserLocations_PKSlNo] PRIMARY KEY CLUSTERED ([PKSlNo])
GO
