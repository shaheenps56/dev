CREATE TABLE [dbo].[GTL_ModuleMaster_Log]
(
[MODULEID] [int] NOT NULL,
[PROJECTID] [int] NOT NULL,
[MODULENAME] [nvarchar] (128) NULL,
[MENUNAME] [nvarchar] (128) NULL,
[EUSER] [varchar] (20) NOT NULL,
[LANGID] [int] NOT NULL,
[LASTUPDATEDON] [datetime] NOT NULL,
[ACCESSNAME] [nvarchar] (200) NULL,
[SHOWMODULE] [char] (1) NOT NULL,
[moduleType] [varchar] (20) NULL,
[MainProject] [varchar] (100) NULL,
[webProject] [varchar] (50) NULL,
[DepartmentID] [int] NULL,
[AccessLevelID] [int] NULL,
[Remarks] [varchar] (8000) NULL,
[LogID] [int] NOT NULL IDENTITY(1, 1),
[LogUser] [varchar] (10) NULL,
[LogDateTime] [datetime] NULL
)
GO
ALTER TABLE [dbo].[GTL_ModuleMaster_Log] ADD CONSTRAINT [PK__GTL_Modu__5E5499A895F5F04F] PRIMARY KEY CLUSTERED ([LogID])
GO
