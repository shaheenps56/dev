CREATE TABLE [dbo].[SPARCV5_Menu]
(
[MenuId] [int] NOT NULL IDENTITY(1, 1),
[ParentId] [int] NOT NULL,
[ProjectId] [int] NULL,
[Caption] [varchar] (100) NULL,
[Url] [varchar] (2000) NULL,
[Visible] [char] (1) NULL,
[Type] [varchar] (100) NULL,
[SortOrder] [int] NULL,
[HasSubMenu] [char] (1) NOT NULL,
[DeniedUserLevels] [varchar] (100) NULL,
[HelpUrl] [varchar] (100) NULL,
[ModuleID] [int] NULL,
[IconClass] [varchar] (100) NULL,
[IconContent] [varchar] (100) NULL,
[IconColor] [varchar] (50) NULL,
[PageID] [int] NULL,
[ParentProjectID] [int] NULL,
[SPARCMenu] [varchar] (1) NOT NULL CONSTRAINT [DF__SPARCV5_M__SPARC__62E4AA3C] DEFAULT ('Y'),
[LastUpdatedOn] [datetime] NOT NULL CONSTRAINT [DF__SPARCV5_M__LastU__63D8CE75] DEFAULT (getdate()),
[ExternalUrl] [varchar] (2000) NULL,
[Euser] [varchar] (25) NULL
)
GO
ALTER TABLE [dbo].[SPARCV5_Menu] ADD CONSTRAINT [PK_SPARCV5_Menu_MenuId] PRIMARY KEY CLUSTERED ([MenuId])
GO
