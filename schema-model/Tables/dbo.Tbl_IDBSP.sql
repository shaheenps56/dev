CREATE TABLE [dbo].[Tbl_IDBSP]
(
[SPCode] [varchar] (100) NOT NULL,
[SPID] [int] NOT NULL,
[SPName] [varchar] (200) NOT NULL,
[EUser] [varchar] (25) NULL,
[LastUpdatedOn] [datetime] NOT NULL CONSTRAINT [DF__Tbl_IDBSP__LastU__66B53B20] DEFAULT (getdate())
)
GO
ALTER TABLE [dbo].[Tbl_IDBSP] ADD CONSTRAINT [PK_Tbl_IDBSP] PRIMARY KEY CLUSTERED ([SPCode])
GO
