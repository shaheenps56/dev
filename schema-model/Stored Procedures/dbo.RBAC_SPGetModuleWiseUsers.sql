SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Proc [dbo].[RBAC_SPGetModuleWiseUsers]
(
	@XMLFilters				Varchar(Max),
	@Channel				Int,
	@Version				Varchar(100),
	@UserCode				Varchar(20)	
)As
/**********************************************************************************************************************************************************
	
	Created By	:	Shammas TP
	Created on	:	06.08.2024
	Purpose		:	To get module wise users
	Project		:	SPARCIM
	Test        :	Exec RBAC_SPGetModuleWiseUsers @XMLFilters='',@Channel=5,@Version='0.0026',@UserCode='00010'

**********************************************************************************************************************************************************/
Begin
	Set Nocount ON
	Set Transaction Isolation Level Read UnCommitted

	Declare @ModuleID Int=0

	Select @ModuleID=0
	
	Create Table #ModuleWiseUsers
	(
		ModuleID			Int,
		ModuleName			Varchar(256),
		ProjectID			Int,
		ProjectDesc			Varchar(128),
		DepartmentID		Int,
		DepartmentCode		Varchar(50),
		DepartmentDesc		Varchar(150),
		RoleID				Int,
		Users				Varchar(100),
		UserName			Varchar(256)
	)

	Insert Into #ModuleWiseUsers
	(
	ModuleID,ModuleName,ProjectID,DepartmentID,RoleID
	)
	Select IsNull(M.MODULEID,0),IsNull(M.MODULENAME,''),IsNull(M.PROJECTID,0),IsNull(M.DepartmentID,0),IsNull(R.GROUPID,0)
	From GTL_MODULEMASTER M (Nolock) Inner Join GTL_USERRIGHTS (Nolock) R 
	On(M.MODULEID=R.MODULEID)
	Where M.MODULEID=Case When @ModuleID=0 Then M.MODULEID Else @ModuleID End

	Update M Set
		M.DepartmentCode=IsNull(D.DepartmentCode,''),
		M.DepartmentDesc=IsNull(D.DepartmentDesc,'')
	From #ModuleWiseUsers M Inner Join GTL_Department (Nolock) D
	On(M.DepartmentID=D.DepartmentID)

	Update M Set
		M.ProjectDesc=IsNull(P.DESCRIPTION,'')
	From #ModuleWiseUsers M Inner Join GTL_PROJECTS (Nolock) P
	On(M.ProjectID=P.PROJECTID)

	Update M Set
		M.Users=IsNull(U.USERCODE,''),
		M.UserName=IsNull(U.USERNAME,'')
	From #ModuleWiseUsers M Inner Join GTL_USERS (Nolock) U
	On(M.RoleID=U.GROUPID)

	Select IsNull(M.ModuleID,'') [ModuleID],IsNull(M.ModuleName,'') [Module Name],IsNull(M.ProjectDesc,'') [Project],
	IsNull(M.DepartmentCode,'') [Department Code],IsNull(M.DepartmentDesc,'') [Department Description],
	IsNull(M.Users,'') [User Code],IsNull(M.UserName,'') [User Name]
	From #ModuleWiseUsers M

	Select '' as [ModuleID],'' as [ModuleName],'' as [Project],'' as [Department],'' as [Users] 

	Select 'ModuleID' as HiddenCols,'' as RightAlignCols,'N' as HTMLOutput

	SELECT'<html><header><img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTh5dX8hbusCfKkLhQFasGj5Ro1P2gVV-FGcQ&s"'+

	+'>Geojit Financial Services Limited (GFSL)</header></html>' as HTMLHeader,'ModuleWiseUsers.xlsx' as FileName,'1|ModuleWiseUsers' 

	Set Nocount OFF
	Set Transaction Isolation Level Read UnCommitted
End
GO
