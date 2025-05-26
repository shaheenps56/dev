SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
Create Proc [dbo].[RBAC_UserWiseModuleReport]
(
	@XMLFilters			Varchar(Max),
	@Channel			Int,
	@Version			Varchar(100),
	@UserCode			Varchar(25)
)
As
/********************************************************************************************************************************************************

	Created By	:	Joseph Thomas
	Created On	:	03-08-2024
	Purpose		:	For fetching userwise module permission report
	Project		:	SPARCIM-Rbac
	Test		:	Exec RBAC_UserWiseModuleReport @XMLFilters='',@Channel=5,@Version='0.226',@UserCode='00030'	
					
********************************************************************************************************************************************************/
Begin
	Set NoCount On
	Set Transaction Isolation Level Read UnCommitted
    
	Declare @UserID Int=0

	Select @UserID=Case When ColName='UserID' Then ColValue Else IsNull(@UserID,0) End 
	From SPARCV5_FnGetRptFilters(@XMLFilters)
	

	Create Table #UserWiseModuleReport
	(
		UserCode		Varchar(100),
		UserName		Varchar(256),
		ModuleID		Int,
		ModuleName		Varchar(256),
		RoleDesc		Varchar(256),
		Creates			Char(1),
		Updates			Char(1),
		Deletes			Char(1),
		Reads			Char(1),
		MenuName		Varchar(50),
		Prints			Char(1),
		Show			Char(1),
		Export			Char(1),
		Special			Char(1)
	)

	Insert Into #UserWiseModuleReport
	(
	UserCode,UserName,ModuleID,RoleDesc,Creates,Updates,Deletes,Reads,MenuName,Prints,Show,Export,Special		
	)
	Select IsNull(U.USERCODE,''),IsNull(U.USERNAME,''),IsNull(R.MODULEID,0),IsNull(G.DESCRIPTION,''),IsNull(R.ADDRIGHT,'N'),
	IsNull(R.MODIFYRIGHT,'N'),IsNull(R.DELETERIGHT,'N'),IsNull(R.PREVIEWRIGHT,'N'),IsNull(R.MENUNAME,'N'),IsNull(R.PRINTRIGHT,'N'),
	IsNull(R.SHOWMENU,'N'),IsNull(R.EXPORTRIGHT,'N'),IsNull(R.SPECIALRIGHT,'N') 
	From GTL_USERS (Nolock) U Inner Join GTL_USERRIGHTS (Nolock) R
	On(U.GROUPID = R.GROUPID)
	Inner Join GTL_USERGROUPS G (Nolock)
	On(U.GROUPID = G.GROUPID)
	Where U.USERID=Case When @UserID=0 Then U.USERID Else @UserID End
	
	Update U Set
		U.ModuleName=IsNull(M.MODULENAME,'')
	From #UserWiseModuleReport U Inner Join GTL_MODULEMASTER (Nolock) M
	On(U.ModuleID=M.MODULEID)

	Select U.UserCode [User Code],U.UserName [User Name],U.ModuleID [ModuleID],U.ModuleName [Module Name],
	U.MenuName [Menu Name],U.RoleDesc [Roles],U.Creates [Create],U.Updates [Update],U.Deletes [Delete],
	U.Reads [Read],U.Prints [Print],U.Show,U.Export,U.Special
	From #UserWiseModuleReport U

	Select  '' [User Code],'' [User Name],'' [ModuleID],'' [Module Name],'' [Menu Name],''  [Roles],'' [Create],'' [Update],'' [Delete],
	'' [Read],'' [Print],'' [Show],'' [Export],'' [Special] 

	Select 'ModuleID' as HiddenCols,'' as RightAlignCols,'N' as HTMLOutput

	SELECT'<html><header><img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTh5dX8hbusCfKkLhQFasGj5Ro1P2gVV-FGcQ&s"'+

	+'>Geojit Financial Services Limited (GFSL)</header></html>' as HTMLHeader,'UserWiseModulePermission.xlsx' as FileName,'1|UserWiseModulePermission' 

	Set Transaction Isolation Level Read Committed 
	Set NoCount Off
End
GO
