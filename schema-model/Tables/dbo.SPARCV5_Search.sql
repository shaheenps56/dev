CREATE TABLE [dbo].[SPARCV5_Search]
(
[Search_Key] [int] NOT NULL,
[Search_Query] [text] NULL,
[OrderBy] [varchar] (500) NOT NULL,
[GroupBy] [varchar] (500) NOT NULL,
[HiddenCols] [varchar] (1000) NULL,
[HeaderText] [varchar] (4000) NULL,
[ColName] [varchar] (8000) NULL,
[SearchFields] [varchar] (max) NULL,
[SearchCode] [varchar] (100) NULL
)
GO
ALTER TABLE [dbo].[SPARCV5_Search] ADD CONSTRAINT [PK_sparcv5_search] PRIMARY KEY CLUSTERED ([Search_Key])
GO
