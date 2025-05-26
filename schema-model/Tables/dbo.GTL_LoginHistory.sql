CREATE TABLE [dbo].[GTL_LoginHistory]
(
[UserCode] [varchar] (20) NULL,
[Time] [datetime] NULL,
[Remarks] [varchar] (max) NULL,
[MachineIP] [varchar] (50) NULL,
[PKSlNo] [int] NOT NULL IDENTITY(1, 1)
)
GO
ALTER TABLE [dbo].[GTL_LoginHistory] ADD CONSTRAINT [GTL_LoginHistory_PKSlNo] PRIMARY KEY CLUSTERED ([PKSlNo])
GO
