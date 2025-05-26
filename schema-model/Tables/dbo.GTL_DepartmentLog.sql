CREATE TABLE [dbo].[GTL_DepartmentLog]
(
[LogID] [int] NOT NULL IDENTITY(1, 1),
[LogUpdatedTime] [datetime] NOT NULL CONSTRAINT [DF__GTL_Depar__LogUp__3DB3258D] DEFAULT (getdate()),
[LogUser] [varchar] (25) NULL,
[DepartmentID] [int] NULL,
[DepartmentCode] [varchar] (50) NOT NULL,
[DepartmentDesc] [varchar] (150) NOT NULL,
[Active] [char] (1) NOT NULL CONSTRAINT [DF__GTL_Depar__Activ__3EA749C6] DEFAULT ('Y'),
[EUser] [varchar] (25) NOT NULL,
[LastUpdatedOn] [datetime] NULL
)
GO
ALTER TABLE [dbo].[GTL_DepartmentLog] ADD CONSTRAINT [PK__GTL_Depa__5E5499A8F852274D] PRIMARY KEY CLUSTERED ([LogID])
GO
