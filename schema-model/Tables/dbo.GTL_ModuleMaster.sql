CREATE TABLE [dbo].[GTL_ModuleMaster]
(
[MODULEID] [int] NOT NULL,
[PROJECTID] [int] NOT NULL,
[MODULENAME] [nvarchar] (128) NULL,
[MENUNAME] [nvarchar] (128) NULL,
[EUSER] [varchar] (20) NOT NULL,
[LANGID] [int] NOT NULL,
[LASTUPDATEDON] [datetime] NOT NULL CONSTRAINT [DF__GTL_MODUL__LASTU__40058253] DEFAULT (getdate()),
[ACCESSNAME] [nvarchar] (200) NULL,
[SHOWMODULE] [char] (1) NOT NULL CONSTRAINT [DF__GTL_MODUL__SHOWM__40F9A68C] DEFAULT ('Y'),
[moduleType] [varchar] (20) NULL,
[MainProject] [varchar] (100) NULL,
[webProject] [varchar] (50) NULL,
[DepartmentID] [int] NULL,
[AccessLevelID] [int] NULL,
[Remarks] [varchar] (8000) NULL
)
GO
ALTER TABLE [dbo].[GTL_ModuleMaster] ADD CONSTRAINT [PK_GTL_MODULEMASTER] PRIMARY KEY CLUSTERED ([MODULEID], [LANGID])
GO
