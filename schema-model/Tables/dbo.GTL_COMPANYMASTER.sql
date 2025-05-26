CREATE TABLE [dbo].[GTL_COMPANYMASTER]
(
[COMPANYID] [int] NOT NULL,
[LANGID] [int] NOT NULL,
[COMPANYNAME] [nvarchar] (64) NOT NULL,
[COMPANYADD1] [varchar] (250) NULL,
[COMPANYADD2] [nvarchar] (100) NULL,
[COMPANYADD3] [nvarchar] (100) NULL,
[LOGO] [image] NULL,
[PIN] [varchar] (20) NULL,
[PHONE] [varchar] (60) NULL,
[EMAIL] [nvarchar] (250) NULL,
[WEBSITE] [nvarchar] (400) NULL,
[LOCATIONID] [numeric] (5, 0) NULL,
[CITY] [nvarchar] (100) NULL,
[COUNTRY] [nvarchar] (100) NULL,
[STATE] [nvarchar] (200) NULL,
[CompanyCode] [varchar] (20) NULL,
[Fax] [varchar] (50) NULL,
[CorporateOffAddress] [varchar] (200) NULL,
[CorporateOffTelNo] [varchar] (100) NULL,
[CIN] [varchar] (50) NULL,
[CompanyPAN] [varchar] (15) NULL,
[SEBIRegNoWithMemberCode] [varchar] (200) NULL
)
GO
ALTER TABLE [dbo].[GTL_COMPANYMASTER] ADD CONSTRAINT [PK_COMPANY] PRIMARY KEY CLUSTERED ([COMPANYID], [LANGID])
GO
