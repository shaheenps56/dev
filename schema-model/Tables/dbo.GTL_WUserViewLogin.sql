CREATE TABLE [dbo].[GTL_WUserViewLogin]
(
[MODULEID] [int] NULL,
[LOCATIONID] [int] NULL,
[WDATE] [datetime] NULL,
[TIME] [nvarchar] (15) NULL,
[PROJECTID] [int] NULL,
[LOGINYPE] [nvarchar] (20) NULL,
[USERCODE] [nvarchar] (10) NULL,
[COMPANYID] [int] NULL,
[COMPUTERID] [varchar] (64) NULL,
[PKSlNo] [int] NOT NULL IDENTITY(1, 1)
)
GO
ALTER TABLE [dbo].[GTL_WUserViewLogin] ADD CONSTRAINT [GTL_WUserViewLogin_PKSlNo] PRIMARY KEY CLUSTERED ([PKSlNo])
GO
