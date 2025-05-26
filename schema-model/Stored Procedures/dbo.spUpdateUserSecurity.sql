SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Proc [dbo].[spUpdateUserSecurity]
(
	@PasswordExpire char(1),
	@ExpireDays Int, 
	@MachineWiseLogin Char(1),
	@MachineName nvarchar(100),
	@EnablePasswordCount Char(1), 
	@PasswordCount Int,
	@UserId Int=0,
	@CompanyId Int,
	@ChangePassword Char(1)='N',
	@EUser Varchar(10),
	@Channel Int=1
)AS 
BEGIN
	Declare @SQL nVarchar(MAX)
	Declare @GroupId Int

	If @Channel<>5
	Begin
		Select GroupId From GTL_Users Where UserCode=@EUser And CompanyId=@CompanyId
	End

	Set @SQL='Update GTL_Users Set PasswordExpire='''+@PasswordExpire+''', ExpireDays='+LTrim(@ExpireDays) +',
		MachineWiseLogin='''+@MachineWiseLogin + ''', MachineName='''+@MachineName+''',
		EnablePasswordCount='''+ @EnablePasswordCount + ''',PasswordCount='+LTrim(@PasswordCount)+ ', 
		ChangePassword='''+ @ChangePassword + ''' Where CompanyId='+Ltrim(@CompanyId )
	If @UserId<>0 
		Set @SQL=@SQL+' And UserId= '+LTrim(@UserId)

	Else If @UserId=0 And @GroupId<>1-- Administrator
	Begin
		Set @SQL=@SQL+' And UserId In(Select UserId From GTL_Users U, GTL_BranchUserGroups G 
									Where MainUserCode='''+@EUser +''' And G.GroupId=U.BranchGroupId 
									And U.COmpanyId=G.CompanyId And G.CompanyId='+ Ltrim(@CompanyId) +')'
	End
	Exec (@SQL)
	Create Table #User (SlNo Int Identity(1,1),Usercode nvarchar(10))
	Set @SQL ='Insert Into #User(UserCode) Select Usercode From GTL_Users Where LangId=1 And companyId=' +LTrim(@CompanyId)
	If @UserId<>0
		Set @SQL=@SQL+ ' And UserId='+Ltrim(@UserId)
	Else If @UserId=0 And @GroupId<>1
	Begin
		Set @SQL=@SQL+' And UserId In(Select UserId From GTL_Users U, GTL_BranchUserGroups G 
									Where MainUserCode='''+@EUser +''' And G.GroupId=U.BranchGroupId 
									And U.COmpanyId=G.CompanyId And G.CompanyId='+ Ltrim(@CompanyId) +')'
	End
	Exec (@SQL)
	-- Clearing Existing password with password count
	-- IF First time Password count was 10 and then reset to 3. In this case old 7 paswords have to be cleared
	Declare @SlNo Int, @Total int, @UserCode nvarchar(10)
	Select @SlNo=1,@Total=Count (*) From #User
	While @SlNo<=@Total Begin
		Select @UserCode=Usercode From #User Where SlNo=@SlNo
		If @EnablePasswordCount ='Y' 
		Begin
			Set @SQL='Delete From GTL_UserPassword Where UserCode='''+@UserCode +''' And CompanyId='+Ltrim(@CompanyId) +
					 ' And PasswordId Not IN(Select Top ' +  Ltrim(@PasswordCount) + ' Passwordid From
					  GTL_UserPassword Where UserCode='''+@UserCode +''' And CompanyId='+Ltrim(@CompanyId)+
					 ' Order By PasswordId Desc)'
			Exec(@SQL)
		End
		Else
		Begin
			Delete From GTL_UserPassword Where UserCode=@UserCode And CompanyId=@CompanyId
		End
		Set @SlNo=@SlNo+1
	End
END
GO
