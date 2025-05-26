SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 

Create Proc [dbo].[RBAC_SPGetRoleWiseUserReport]
(
	@XMLFilters			Varchar(Max),
	@Channel			Int,
	@Version			Varchar(100),
	@UserCode			Varchar(25)

)
As
/********************************************************************************************************************************************************
	Created By	:	Shammas TP
	Created On	:	03-08-2024
	Purpose		:	For fetching Rolewise user report
	Project		:	SPARCIM-Rbac.
	Test		:	Exec [RBAC_SPGetRoleWiseUserReport] 
					@XMLFilters='',@Channel=5,@Version='0.226',@UserCode='00030'		
********************************************************************************************************************************************************/
Begin
	Set NoCount On
	Set Transaction Isolation Level Read UnCommitted
    
	Declare @GroupID Int=0

	Select @GroupID=Case When ColName='GroupID' Then ColValue Else IsNull(@GroupID,0) End 
	From SPARCV5_FnGetRptFilters(@XMLFilters)

	Create Table #RoleWiseUsers
	(
		RoleID				Int,
		RoleDescription		Varchar(256),
		UserCode			Varchar(100),
		UserName			Varchar(256),
	)

	Insert Into #RoleWiseUsers
	(
	RoleID,RoleDescription,UserCode,UserName
	)
	Select Distinct IsNull(G.GROUPID,0),IsNull(G.DESCRIPTION,''),IsNull(U.USERCODE,''),IsNull(U.USERNAME,'')

	From GTL_USERGROUPS (Nolock) G Inner Join GTL_USERS U (Nolock)
	On(U.GROUPID=G.GROUPID)
	Where G.GROUPID=Case When @GroupID=0 Then G.GROUPID Else IsNull(@GroupID,0) End

	Select R.RoleID,R.RoleDescription [Roles],R.UserCode [User Code],R.UserName [User Name] From #RoleWiseUsers R
	
	Select  '' RoleID,'' [Roles],'' as [User Code],'' as [UserName]

	Select 'RoleID' as HiddenCols,'' as RightAlignCols,'N' as HTMLOutput

	SELECT'<html><header><img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTh5dX8hbusCfKkLhQFasGj5Ro1P2gVV-FGcQ&s"'+

	+'>Geojit Financial Services Limited (GFSL)</header></html>' as HTMLHeader,'RoleWiseUserReport.xlsx' as FileName,'1|RoleWiseUserReport' 

	Set Transaction Isolation Level Read Committed 
	Set NoCount Off
End
GO
