CREATE TABLE [dbo].[GTL_UserClientMapping]
(
[UserCode] [varchar] (25) NOT NULL,
[CIN] [varchar] (25) NOT NULL,
[UCC] [varchar] (15) NULL,
[Euser] [varchar] (25) NULL,
[LastUpdatedOn] [datetime] NOT NULL CONSTRAINT [DF__GTL_UserC__LastU__4DE98D56] DEFAULT (getdate())
)
GO
ALTER TABLE [dbo].[GTL_UserClientMapping] ADD CONSTRAINT [PK_GTL_UserClientMapping] PRIMARY KEY CLUSTERED ([UserCode], [CIN])
GO
