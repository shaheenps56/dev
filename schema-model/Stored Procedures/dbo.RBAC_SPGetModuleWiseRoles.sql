SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 

Create Proc [dbo].[RBAC_SPGetModuleWiseRoles]
(  
	@XMLFilters				Varchar(Max),
	@Channel				Int,
	@Version				Varchar(100),
	@UserCode				Varchar(20)
)As
/**********************************************************************************************************************************************************
	Created By	:	Shammas TP
	Created on	:	06.08.2024
	Purpose		:	To get module wise roles.
	Project		:	SPARCIM
	Test        :	Exec RBAC_SPGetModuleWiseRoles @XMLFilters='',@Channel=5,@Version='0.00225',@UserCode='00010'
**********************************************************************************************************************************************************/
Begin
	Set Nocount ON
	Set Transaction Isolation Level Read UnCommitted

	Declare @ModuleID Int=0

	Create Table #ModuleWiseRoles
	(
		ModuleID			Int,
		ModuleName			Varchar(256),
		ProjectID			Int,
		ProjectDesc			Varchar(128),
		DepartmentID		Int,
		DepartmentCode		Varchar(50),
		DepartmentDesc		Varchar(150),
		RoleID				Int,
		RolesDesc			Varchar(256)
	)

	Insert Into #ModuleWiseRoles
	(
	ModuleID,ModuleName,ProjectID,DepartmentID,RoleID
	)
	Select IsNull(M.MODULEID,0),IsNull(M.MODULENAME,''),IsNull(M.PROJECTID,0),IsNull(M.DepartmentID,0),
	IsNull(R.GROUPID,0)
	From GTL_MODULEMASTER (Nolock) M Inner Join GTL_USERRIGHTS (Nolock) R 
	On(M.MODULEID=R.MODULEID)
	Where M.MODULEID=Case When @ModuleID=0 Then M.MODULEID Else @ModuleID End

	Update M Set
		M.DepartmentCode=IsNull(D.DepartmentCode,''),
		M.DepartmentDesc=IsNull(D.DepartmentDesc,'')
	From #ModuleWiseRoles M Inner Join GTL_Department (Nolock) D
	On(M.DepartmentID=D.DepartmentID)

	Update M Set
		M.ProjectDesc=IsNull(P.DESCRIPTION,'')
	From #ModuleWiseRoles M Inner Join GTL_PROJECTS (Nolock) P
	On(M.ProjectID=P.PROJECTID)

	Update M Set
		M.RolesDesc=IsNull(G.DESCRIPTION,'')
	From #ModuleWiseRoles M Inner Join GTL_USERGROUPS (Nolock) G
	On(M.RoleID=G.GROUPID)

	Select IsNull(M.ModuleID,0) [ModuleID],IsNull(M.ModuleName,'') [Module Name],IsNull(M.ProjectDesc,'') [Project],
	IsNull(M.DepartmentCode,'') [Department Code],IsNull(M.DepartmentDesc,'') [Department Description],
	IsNull(M.RolesDesc,'') [Role]
	From #ModuleWiseRoles M

	Select '' as [ModuleID],'' as [ModuleName],'' as [Project],'' as [Department],'' as [Roles]

	Select 'ModuleID' as HiddenCols,'' as RightAlignCols,'N' as HTMLOutput

	Select'<html><header><img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTh5dX8hbusCfKkLhQFasGj5Ro1P2gVV-FGcQ&s"'+
	+'>Geojit Financial Services Limited (GFSL)</header></html>' as HTMLHeader,'ModuleWiseRoles.xlsx' as FileName,'1|ModuleWiseRoles'
	
	Set Nocount OFF
	Set Transaction Isolation Level Read UnCommitted
End
GO
