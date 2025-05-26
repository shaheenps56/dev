CREATE TABLE [dbo].[GTL_State]
(
[CompanyId] [int] NOT NULL,
[StateId] [int] NOT NULL,
[LangId] [int] NOT NULL,
[Code] [varchar] (4) NOT NULL,
[StateName] [varchar] (50) NOT NULL,
[EUser] [varchar] (15) NULL,
[LastUpdatedOn] [datetime] NULL CONSTRAINT [DF_GTL_State_LastUpdatedOn] DEFAULT (getdate()),
[NCDEXId] [varchar] (10) NULL,
[GSTStateCode] [int] NULL,
[CDSL_StateCode] [varchar] (10) NULL,
[CDSL_StateName] [varchar] (200) NULL,
[NSDL_StateCode] [varchar] (20) NULL,
[NSDL_StateName] [varchar] (200) NULL,
[ISO_StateCode] [varchar] (20) NULL
)
GO
ALTER TABLE [dbo].[GTL_State] ADD CONSTRAINT [PK_GTL_State] PRIMARY KEY CLUSTERED ([CompanyId], [StateId], [LangId])
GO
