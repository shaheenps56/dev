SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- exec FindProc 'sp'
-- To find SpNames using its Name/Content
CREATE Procedure [dbo].[FindProc](@NameOrContent varchar(50) = '', @NameOrContent2 varchar(50) = '')
as begin
	Declare @Criteria as Char(1)
	set @Criteria = substring(@NameOrContent,1,1)
	if @Criteria = 'C' set @NameOrContent = substring(@NameOrContent,2,len(@NameOrContent))
    
	Declare @Cri as Char(1)
	Declare @Criteria2 as Char(1)
	set @Criteria2 = substring(@NameOrContent2,1,1)
	if @Criteria2 = 'C' set @NameOrContent2 = substring(@NameOrContent2,2,len(@NameOrContent2))

	Select @Criteria NameOrContent, @NameOrContent NameOrContentLike, @Criteria2 NameOrContent2, @NameOrContent2 NameOrContentLike2
	if @Criteria = 'C'
	Begin
		if @NameOrContent2 = ''
		Begin
			select CREATED,LAST_ALTERED,ROUTINE_TYPE,ROUTINE_NAME 
			from sys.sql_modules s
			INNER JOIN INFORMATION_SCHEMA.ROUTINES r ON object_name(S.object_id)=r.ROUTINE_NAME
			Where s.definition like '%'+@NameOrContent+'%'
			order by LAST_ALTERED desc
		End
		else
		Begin
			if @Criteria2 = 'C'
			Begin
				select CREATED,LAST_ALTERED,ROUTINE_TYPE,ROUTINE_NAME 
				from sys.sql_modules s
				INNER JOIN INFORMATION_SCHEMA.ROUTINES r ON object_name(S.object_id)=r.ROUTINE_NAME
				Where s.definition like '%'+@NameOrContent+'%' and s.definition like '%'+@NameOrContent2+'%'
				order by LAST_ALTERED desc
			End
			Else
			Begin
				select CREATED,LAST_ALTERED,ROUTINE_TYPE,ROUTINE_NAME 
				from sys.sql_modules s
				INNER JOIN INFORMATION_SCHEMA.ROUTINES r ON object_name(S.object_id)=r.ROUTINE_NAME
				Where s.definition like '%'+@NameOrContent+'%' and ROUTINE_NAME LIKE '%'+@NameOrContent2+'%'
				order by LAST_ALTERED desc
			End
		End
	End
	Else 
	Begin
		if @NameOrContent2 = ''
		Begin
			SELECT CREATED,LAST_ALTERED,ROUTINE_TYPE,ROUTINE_NAME --, ROUTINE_DEFINITION 
			FROM INFORMATION_SCHEMA.ROUTINES 
			WHERE ROUTINE_NAME LIKE '%'+@NameOrContent+'%'
			AND ROUTINE_TYPE in ('PROCEDURE','FUNCTION')
			order by LAST_ALTERED desc
		End
		Else
		Begin
			if @Criteria2 = 'C'
			Begin
				SELECT CREATED,LAST_ALTERED,ROUTINE_TYPE,ROUTINE_NAME --, ROUTINE_DEFINITION 
				from sys.sql_modules s
				INNER JOIN INFORMATION_SCHEMA.ROUTINES r ON object_name(S.object_id)=r.ROUTINE_NAME
				WHERE r.ROUTINE_NAME LIKE '%'+@NameOrContent+'%' and s.definition like '%'+@NameOrContent2+'%'
				AND ROUTINE_TYPE in ('PROCEDURE','FUNCTION')
				order by LAST_ALTERED desc
			End
			Else
			Begin
				SELECT CREATED,LAST_ALTERED,ROUTINE_TYPE,ROUTINE_NAME --, ROUTINE_DEFINITION 
				FROM INFORMATION_SCHEMA.ROUTINES 
				WHERE ROUTINE_NAME LIKE '%'+@NameOrContent+'%' and ROUTINE_NAME LIKE '%'+@NameOrContent2+'%'
				AND ROUTINE_TYPE in ('PROCEDURE','FUNCTION')
				order by LAST_ALTERED desc
			End
		End
	End
End
GO
