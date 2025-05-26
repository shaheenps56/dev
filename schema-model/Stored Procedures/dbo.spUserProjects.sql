SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Proc [dbo].[spUserProjects]
(
	@GroupId		Int,
	@Companyid		Int ,
	@LangId			Int,
	@Channel		Int=1
) As
Begin
	Set NoCount On
	Declare @str nvarchar(4000), @str2 nvarchar(3000)
	Create Table #TempGroup
	(
		UserProject nChar(1),
		Description nVarchar(64),
		Code nVarchar(25),
		projectId Int,
		ParentProjectID Int
	)
	
	Insert Into #Tempgroup(Code, Description, UserProject, ProjectId,ParentProjectID)
	Select Code,Description,'N',ProjectId,ParentProjectID 
	From GTL_Projects (Nolock) Where Active='Y' and 
	1=Case When @Channel=5 and IsNull(ParentProjectID,0)=0 Then 2 Else 1 End

	and LangId=@LangId
	Set @Str2=''
	Select  @str2 = @str2+','+Ltrim(Isnull(AccessProjectId,'')) 
	From	GTL_UserGroups U
	Where	groupId=@GroupId And U.CompanyId =@CompanyId 
			And Isnull(AccessProjectId,'')<>''
	IF @Str2<>''
	Begin
		
		set @str='Update T set T.UserProject=''Y''  from GTL_Projects R, #TempGroup T 
		where R.ProjectId in ('+Ltrim(Substring(@str2,2,len(@Str2)))+') And R.ProjectId=T.ProjectId'
--print @str
		exec (@str)
	End
	select * from #Tempgroup
End
GO
