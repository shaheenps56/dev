CREATE TABLE [dbo].[SPARCV5_UserQueryLevel]
(
[ID] [int] NOT NULL,
[Code] [varchar] (100) NULL,
[Euser] [varchar] (25) NULL,
[LastUpdatedOn] [datetime] NOT NULL CONSTRAINT [DF__SPARCV5_U__LastU__64CCF2AE] DEFAULT (getdate())
)
GO
ALTER TABLE [dbo].[SPARCV5_UserQueryLevel] ADD CONSTRAINT [PK__SPARCV5___3214EC27EFD14F0C] PRIMARY KEY CLUSTERED ([ID])
GO
