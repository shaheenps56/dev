SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[SELECTFROMTABLE](@TableName varchar(50))
as begin
declare @sql varchar(8000)
set @sql = 'select * from ' + @TableName 
  exec(@SQL)

end
GO
