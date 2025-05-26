CREATE TABLE [dbo].[TBL_SP]
(
[SPID] [int] NOT NULL,
[SPName] [varchar] (200) NOT NULL,
[LastUpdatedOn] [datetime] NOT NULL,
[Euser] [nvarchar] (20) NULL,
[TransactionRequired] [char] (1) NOT NULL CONSTRAINT [DF_TBL_SP_TransactionRequired] DEFAULT ('Y'),
[Readonly_Connection] [varchar] (2) NOT NULL CONSTRAINT [DF_TBL_SP_Readonly_Connection] DEFAULT ('N'),
[TTL] [int] NULL,
[CacheMechanism] [varchar] (15) NULL
)
GO
ALTER TABLE [dbo].[TBL_SP] ADD CONSTRAINT [PK_SPID] PRIMARY KEY CLUSTERED ([SPID])
GO
