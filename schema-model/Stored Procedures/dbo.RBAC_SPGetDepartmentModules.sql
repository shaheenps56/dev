SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 

Create Proc [dbo].[RBAC_SPGetDepartmentModules]
(
	@XMLFilters			Varchar(Max)='',
	@Channel			Int,
	@Version			Varchar(100),			
	@UserCode			Varchar(25)=''
)
As
/**********************************************************************************************************************************************************
	Created By	:	Shammas TP
	Created On	:	06.08.2024
	Purpose		:	Department Wise Module List.
	Project		:	SPARCIM
	Test		:	Exec RBAC_SPGetDepartmentModules 
					@XMLFilters='<XMLDetails><XMLData><DepartmentID></DepartmentID></XMLData></XMLDetails>',
					@UserCode='00155'
**********************************************************************************************************************************************************/
Begin
	Set NoCount On
	Set Transaction Isolation Level Read UnCommitted

	Declare @DepartmentID Int=0

	Select @DepartmentID=Case When ColName='DepartmentID' Then ColValue Else IsNull(@DepartmentID,0) End 
	From SPARCV5_FnGetRptFilters(@XMLFilters)
	
	Create Table #DepartmentModules
	(
		ModuleID			Int,
		ModuleName			Varchar(256),

		DepartmentDesc		Varchar(150),
		AccessLevelID		Int,
		AccessLevel			Varchar(100),
		Spoc				Varchar(Max)
	)

	Insert Into #DepartmentModules
	(
	ModuleID,ModuleName,DepartmentDesc,AccessLevelID,Spoc			
	)
	Select IsNull(M.ModuleID,0),IsNull(M.ModuleName,''),IsNull(D.DepartmentDesc,''),IsNull(M.AccessLevelID,0),IsNull(D.Spoc,'') 

	From GTL_MODULEMASTER (Nolock) M Inner Join GTL_Department (Nolock) D 
	On(M.DepartmentID=D.DepartmentID)
	Where IsNull(M.DepartmentID,'')=Case When IsNull(@DepartmentID,0)=0 Then IsNull(M.DepartmentID,'') Else @DepartmentID End

	Update D Set
		D.AccessLevel=IsNull(A.Description,'')

	From #DepartmentModules D Inner Join GTL_AccessLevel (Nolock) A
	On(D.AccessLevelID=A.LevelID)

	Select D.ModuleID ModuleID,D.ModuleName [Module Name],D.DepartmentDesc [Department Description],
	D.AccessLevel [Access Level],D.Spoc [Spoc]
	From #DepartmentModules D


	Select '' ModuleID,'' [Module Name],'' [Department Description],'' [Access Level],'' [Spoc]

	Select ''RightAlignCols,''LinkCols,'N' HTMLOutput,'ModuleID' HiddenCols,'' SelectedRowColor 

	Select '<html><header><img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTh5dX8hbusCfKkLhQFasGj5Ro1P2gVV-FGcQ&s"'+

	+'>Geojit Financial Services Limited (GFSL)</header></html>' 
	as HTMLHeader,'ModulesDetails.xlsx' as FileName,'1|ModulesDetails' 

	Set Transaction Isolation Level Read Committed 
	Set NoCount Off

End
GO
