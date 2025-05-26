CREATE TABLE [dbo].[GTL_BranchUserGroups]
(
[COMPANYID] [int] NOT NULL,
[GROUPID] [int] NOT NULL,
[ISWEBUSER] [nvarchar] (1) NOT NULL,
[DESCRIPTION] [nvarchar] (128) NULL,
[LANGID] [int] NOT NULL,
[EUSER] [nvarchar] (20) NULL,
[LASTUPDATEDON] [datetime] NULL CONSTRAINT [DF__GTL_Branc__LASTU__37FB178E] DEFAULT (getdate()),
[ACCESSPROJECTID] [varchar] (1000) NULL,
[MainUserCode] [varchar] (10) NULL
)
GO
ALTER TABLE [dbo].[GTL_BranchUserGroups] ADD CONSTRAINT [pk_GTL_BranchUserGroups] PRIMARY KEY CLUSTERED ([COMPANYID], [GROUPID])
GO
