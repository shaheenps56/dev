SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE Procedure [dbo].[FindTable]
(
	@TblName varchar(50)=''
)
As
Begin
	-- SELECT Table_Name --, ROUTINE_DEFINITION 
	-- FROM INFORMATION_SCHEMA.Tables
	-- WHERE Table_Name LIKE '%'+@TblName+'%'
	-- Order By Table_Name

	Select t.[Name] as TableName, create_date, t.modify_date, [Type], OBJECTPROPERTY(t.object_id, 'TableHasPrimaryKey') PK
	From sys.tables t 
	Where t.name like '%'+@TblName+'%'
	Order By t.modify_date desc
End
GO
