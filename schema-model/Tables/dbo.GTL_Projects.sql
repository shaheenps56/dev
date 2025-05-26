CREATE TABLE [dbo].[GTL_Projects]
(
[PROJECTID] [int] NOT NULL,
[EUSER] [nvarchar] (20) NULL,
[CODE] [nvarchar] (40) NULL,
[DESCRIPTION] [nvarchar] (64) NULL,
[LANGID] [int] NOT NULL,
[LASTUPDATEDON] [datetime] NOT NULL CONSTRAINT [DF__GTL_PROJE__LASTU__43D61337] DEFAULT (getdate()),
[Version] [varchar] (100) NULL,
[Active] [varchar] (1) NOT NULL CONSTRAINT [DF__GTL_Proje__Activ__4A18FC72] DEFAULT ('Y'),
[ParentProjectID] [int] NULL,
[DefaultProject] [varchar] (1) NULL,
[ExternalProject] [varchar] (1) NULL,
[SortOrder] [int] NULL,
[ShowDropDown] [varchar] (1) NOT NULL CONSTRAINT [DF__GTL_Proje__ShowD__4B0D20AB] DEFAULT ('N'),
[IconUrl] [varchar] (1000) NULL,
[IconClass] [varchar] (100) NULL,
[IconColor] [varchar] (100) NULL,
[SelectedColor] [varchar] (100) NULL,
[HoverColor] [varchar] (100) NULL
)
GO
ALTER TABLE [dbo].[GTL_Projects] ADD CONSTRAINT [PK_GTL_PROJECTS] PRIMARY KEY CLUSTERED ([PROJECTID], [LANGID])
GO
