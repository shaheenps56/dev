SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [dbo].[GTL_SPUserRights]
(
	@GroupID				Int,
	@ProjectID				Int,
	@AccessProjects			Varchar(8000),
	@XMLFilters				Varchar(Max),
	@UserAuthorization		Varchar(Max),
	@Version				Varchar(100),
	@Channel				Int,
	@Purpose				Varchar(2),
	@UserCode				Varchar(25),
	@Debug					Char(1)='N'
)
As
/********************************************************************************************************************
Created By	:	Paul Mathew
Created On	:	16.12.2023
Purpose		:	To set/get user rights 
Project		:	SPARCIM
Test		:	Exec GTL_SPUserRights @GroupID=1,@ProjectID=1009,@AccessProjects='',
				@XMLFilters='',@Version='',@Channel=5,@Purpose='L',@UserCode='GIT'
				
				Exec GTL_SPUserRights @AccessProjects= '',@Channel= 5,@GroupID=5,@ProjectID= 1111,@Purpose= 'V',
				@UserAuthorization= '',@UserCode= 'GIT',@Version= 'SPARC5',@XMLFilters= ''
*********************************************************************************************************************/
Begin
	Set NoCount On

	Declare @XMLDetails XML,@CompanyID Int=1,@LangID Int=1,@AccessProjectIDs Varchar(8000),
	@CopyFromGroupID Int=0
	
	Select @CopyFromGroupID=Case When ColName='GroupID' Then ColValue Else IsNull(@CopyFromGroupID,0) End
	From SPARCV5_FnGetRptFilters(@XMLFilters)

	Create Table #TempV5_AccessRights    
	(    
		ModuleID		Int,    
		ModuleName		Varchar(256),    
		MenuName		Varchar(256), 
		AccessLevelID	Int,
		AccessLevel		Varchar(100),
		AddRight		Char(1),    
		ModifyRight		Char(1),    
		DeleteRight		Char(1),    
		PreviewRight	Char(1),    
		PrintRight		Char(1),      
		ShowMenu		Char(1),
		Export			Char(1),
		Enable			Char(1),
		Project			Varchar(100),
		ProjectID		Int,
		ModuleType		Varchar(20),
		ModuleTypeID	Int,
		ModuleDetails	Varchar(150),
		DepartmentID	Int
	) 

	Create Index IDX_#TempV5_AccessRights_1 On #TempV5_AccessRights(ProjectID)

	Create Table #TempV5_AccessibleProjects
	(
		Checked			Char(1),
		Project			Varchar(100),
		Code			Varchar(25),
		ProjectID		Int,
		ParentProjectID Int
	)

	Create Table #TempV5_UserAuthorization
	(
		GroupID		Int,
		UserID		Int
	)
	
	If IsNull(@GroupID,0)=0 and @Purpose<>'L'
	Begin
		Raiserror('Please select the Role.',16,1)
		Return
	End
	If IsNull(@ProjectID,0)=0 and @Purpose<>'L'
	Begin
		Raiserror('Please select the Project.',16,1)
		Return
	End

	If @Purpose In('V','L','CV')
	Begin
		If @Purpose='L' --Page Load
		Begin

			Select 'Accessible Projects' As Tab1Caption,'Rights' As Tab2Caption,'Allocated Rights' As Tab3Caption,
			'Authorised Users' As Tab4Caption,'Users' As Tab5Caption,'N' as HideTab1,'N' as HideTab2,'N' as HideTab3,
			'Y' as HideTab4,'N' as HideTab5, 'Y' as ProjectEnable
    
			Select G.GroupID as Code,G.Description From GTL_UserGroups G(Nolock) Where G.LangID=1 

			Select Distinct PROJECTID as Code,P.Description Description From GTL_Projects P(Nolock) 
			Where P.ParentProjectID=0 and P.LangID=1
    
			Select '' ModuleID,'' ModuleName,'' MenuName,'' [ADD],'' [MODIFY],'' [DELETE],'' [PREVIEW], '' [PRINT],'' [SHOW] ,'' [ALL]  
    
			Select ''RightAlignCols,''LinkCols,'N' HTMLOutput,'ModuleID,MenuName' HiddenCols,'#e9ecef' SelectedRowColor  
  
			Select 'GROUPID' As Code,'Group' As Description,'193' As SearchKey,'GroupID' As SearchOPID,  
			'Description' As SearchOPCode, 'Description' As SearchOPDesc,'Role Search' As SearchPageHeader
			
			Select 'DepartmentCode' as Code,'DepartmentDescription' as Description,213 as SearchKey,
			'DepartmentID' as SearchOPID,'DepartmentCode' as SearchOPCode,'DepartmentDescription' as SearchOPDesc,
			'Department Search' as SearchPageHeader,'Y' as DisableDepartment
			Return
		
		End

		Insert Into #TempV5_AccessRights
		(
		ModuleID,ModuleName,MenuName,AccessLevelID,AddRight,ModifyRight,DeleteRight,PreviewRight,PrintRight,
		ShowMenu,Export,Enable,ProjectID,ModuleType,ModuleTypeID,DepartmentID,Project
		)
		Select Distinct M.ModuleID,M.ModuleName,LTrim(RTrim(R.MenuName)),M.AccessLevelID,R.AddRight,R.ModifyRight,
		R.DeleteRight,R.PreviewRight, R.PrintRight,R.ShowMenu,IsNull(R.EXPORTRIGHT,'N'),IsNull(R.SPECIALRIGHT,'N'),
		R.PROJECTID as ProjectID,Case When M.moduleType In('Definition') Then 'Activity' When M.moduleType In('Report')
		Then 'Reports' Else M.moduleType End,Case When M.moduleType In('Activity','Definition') Then 1 
		When M.moduleType In('Report') Then 2  When M.moduleType='Special Rights' Then 3 Else 0 End,
		M.DepartmentID,P.CODE
		From GTL_UserRights R (Nolock) Inner Join GTL_ModuleMaster M (Nolock) 
		On(M.ModuleID=R.ModuleID)
		Left Join GTL_PROJECTS (Nolock) P On(R.PROJECTID=P.PROJECTID)
		Where M.ShowModule='Y' and R.GroupID=Case When IsNull(@CopyFromGroupID,0)<>0 Then @CopyFromGroupID Else ltrim(@GroupID) End   
		and P.ParentProjectID=Case When @ProjectID=0 Then P.ParentProjectID Else @ProjectID End 
		and P.Active='Y'
		and R.CompanyID=@CompanyID and M.LangID=@LangID
		
		Insert Into #TempV5_AccessRights
		(
		ModuleID,ModuleName,MenuName,AddRight,ModifyRight,DeleteRight,PreviewRight,PrintRight,ShowMenu,
		Export,Enable,ModuleType,ModuleTypeID,ProjectID,Project,DepartmentID
		)
		Select Distinct M.ModuleID,M.ModuleName,LTrim(Rtrim(M.MenuName)),'N' as AddRight,'N' as ModifyRight,'N' as DeleteRight,
		'N' as PreviewRight,'N' as PrintRight,'N' as ShowMenu,'N' as [Export],'' as [Enable],
		Case When M.moduleType In('Definition') Then 'Activity' When M.moduleType In('Report')
		Then 'Reports' Else M.moduleType End,Case When M.moduleType In('Definition') Then 1 
		When M.moduleType In('Report') Then 2  When M.moduleType='Special Rights' Then 3
		Else 0 End as ModuleType,M.ProjectID,P.CODE,M.DepartmentID
		From GTL_ModuleMaster (Nolock) M  Left Join GTL_PROJECTS (Nolock) P
		On(M.PROJECTID=P.PROJECTID)
		Where M.ShowModule='Y' and  P.ParentProjectID=Case When @ProjectID=0 Then P.ParentProjectID Else @ProjectID End 
		and P.Active='Y'
		and Not Exists(Select Top 1 Null from #TempV5_AccessRights R Where R.ModuleID=M.ModuleID)  
		and M.LangID=@LangID 

		Update T Set
			T.ModuleDetails=Concat(IsNull(D.DepartmentDesc,''),'->',IsNull(T.Project,''),'->',
			Case When T.ModuleType In('Definition') Then 'Activity'
		When T.ModuleType In('Report') Then 'Reports' Else IsNull(T.ModuleType,'') End,'->',IsNull(T.ModuleName,''))
		From #TempV5_AccessRights T Left Join GTL_Department (Nolock) D
		On(T.DepartmentID=D.DepartmentID)

		Update T Set
			T.AccessLevel=L.Description
		From #TempV5_AccessRights T Inner Join GTL_AccessLevel (Nolock) L
		On(T.AccessLevelID=L.LevelID)

		Select R.ModuleID,R.ModuleDetails,Case When IsNull(R.Project,'')<>'' Then 
		Case When R.ModuleTypeID=3 Then '' Else R.Project+' -> ' End+R.ModuleName+' ('+Cast(R.ModuleID as Varchar(20))+')'
		Else R.ModuleName+' ('+Cast(R.ModuleID as Varchar(20))+')' End as ModuleName,R.MenuName,AccessLevel,
		R.ShowMenu [Active],R.AddRight [Save],
		R.ModifyRight [Modify],R.DeleteRight [Delete],R.PreviewRight [View],R.PrintRight [Print],
		R.Export [Export],R.Enable [Enable],'' as [All],R.ProjectID,R.ModuleType,R.ModuleTypeID,R.Enable as [Special Rights]
		From #TempV5_AccessRights R  
		Order By R.ModuleName   
		
		Select '' ModuleID,'' [ModuleDetails],''ModuleName,'' MenuName,'' AccessLevel,'' [Active],'' [Save],
		'' [Modify],'' [Delete],'' [View],'' [Print],'' [Export],'' [Enable],'' [All],'' ProjectID,'' ModuleType,
		'' [ModuleTypeID]

		Select '' RightAlignCols,''LinkCols,'N' HTMLOutput, 
		'ModuleID,MenuName,ProjectID,ModuleType,ModuleTypeID,ModuleDetails' HiddenCols,'#e9ecef' SelectedRowColor

		If @Purpose='CV' --Copy Value
		Begin

			Insert Into #TempV5_AccessibleProjects
			(
			Checked,Project,Code,ProjectID,ParentProjectID
			)
			Exec spUserProjects @GroupID=@CopyFromGroupID,@CompanyID=@CompanyID,@LangID=@LangID,@Channel=@Channel 

		End
		Else
		Begin
			Insert Into #TempV5_AccessibleProjects
			(
				Checked,Project,Code,ProjectID,ParentProjectID
			)
			Exec spUserProjects @GroupID=@GroupID,@CompanyID=@CompanyID,@LangID=@LangID,@Channel=@Channel  
		End
		
		Select Row_Number() Over(Order By P.Project) as SlNo,IsNull(P.Checked,'N') as Checked,
		P.Code as Project,P.Project as Code,P.Project as Description,P.ProjectID From #TempV5_AccessibleProjects P
			
		Select '' ProjectID
		
		Select '' RightAlignCols,''LinkCols,'N' HTMLOutput, 'SlNo,Checked,ProjectID,Code' HiddenCols,
		'#e9ecef' SelectedRowColor

		--below query not using right now-- start---
		Select Top 0 Row_Number() Over(Order By Description asc) as SlNo,U.GroupID,U.UserID,U.UserCode,U.UserName,
		G.Description as UserGroup,Case When IsNull(A.UserID,0)<>0 Then 'Y' Else 'N' End Checked    
		From  GTL_Users U(Nolock) Inner Join GTL_UserGroups G(Nolock)
		On (G.GroupID=U.GroupID and U.CompanyID=G.CompanyID and U.LangID=G.LangID)   
		Left Outer Join GTL_UserAuthorisation A(Nolock) On (A.UserID=U.UserID and A.CompanyID=U.CompanyID) 
		Where U.GroupID=Case When IsNull(@CopyFromGroupID,0)<>0 Then @CopyFromGroupID Else @GroupID End 
		and U.CompanyID=@CompanyID and U.LangID=@LangID
			
		Select '' GroupID,'' UserID

		Select '' RightAlignCols,''LinkCols,'N' HTMLOutput, 'SlNo,GroupID,UserID,Checked' HiddenCols,
		'#e9ecef' SelectedRowColor
		-------stop------------------------------------------
		
		Select  Cast(U.GROUPID As Varchar(Max)) Roles,U.UserCode,U.UserName,Cast('Primary' as varchar(30)) RoleType,
		1 SortOrder Into #RoleWiseUsers
		From GTL_Users U(Nolock) Where U.GroupID=@GroupID
		Order By U.UserCode

		Insert Into #RoleWiseUsers
		(
		Roles,UserCode,UserName,RoleType,SortOrder
		)
		Select Cast(value As Varchar(Max)) as Roles,USERCODE,USERNAME,'Secondary',2
		From GTL_USERS (Nolock) U Cross Apply String_Split(U.RoleIDS, ',') As Split
		Where Not Exists(Select Top 1 1 From #RoleWiseUsers R Where U.USERCODE=R.USERCODE)

		Select R.UserCode,R.UserName,G.DESCRIPTION as [Member Of],R.RoleType[Role Type]
		From #RoleWiseUsers R Inner Join GTL_UserGroups (Nolock) G
		On(Cast(Roles as Int)=G.GROUPID) Where G.GROUPID=@GroupID
		Order By SortOrder,UserCode Asc

		Select '' UserCode,'' UserName,'' [Member Of],'' [Role Type]
		
		Select '' RightAlignCols,'' LinkCols,'N' HTMLOutput,'' HiddenCols,'#e9ecef' SelectedRowColor
		

		Select X.ProjectID,X.ModuleTypeID,X.ModuleType,X.HiddenCols,
		Case When SlNo=1 Then 'Y' Else 'N' End as DefaultProject
		From
		(
			Select Distinct ProjectID,ModuleTypeID,ModuleType,
			Case When ModuleTypeID=1 Then 'ModuleID,MenuName,Enable,ProjectID,ModuleType,ModuleTypeID,ModuleDetails'
			When ModuleTypeID=2 Then 'ModuleID,MenuName,Add,Modify,Delete,Save,Modify,Delete,Enable,ProjectID,ModuleType,ModuleTypeID,ModuleDetails'
			When ModuleTypeID=3 Then 'ModuleID,MenuName,View,All,Save,Modify,Delete,Print,Active,Export,ProjectID,ModuleType,ModuleTypeID,ModuleDetails'
			Else 'ModuleID,MenuName,ProjectID,ModuleType,ModuleTypeID,ModuleDetails' End+',Special Rights'
			HiddenCols,Row_Number() Over(Order By Project,ModuleTypeID) as SlNo
			From #TempV5_AccessRights R  Where IsNull(ModuleType,'')Not In('','None')
		)X Order By SlNo

		Select '' RightAlignCols,'' LinkCols,'N' HTMLOutput,
		'ModuleID,ModuleName,MenuName,All,ProjectID,ModuleType,ModuleTypeID,Enable,AccessLevel' HiddenCols,'#e9ecef' SelectedRowColor
		
		Return	
	End

	If @Purpose='S'
	Begin

		Select @XMLDetails=Cast(@XMLFilters As XML)  

		Insert Into #TempV5_AccessRights
		(
		ModuleID,ModuleName,AddRight,ModifyRight,DeleteRight,PreviewRight,PrintRight,
		ShowMenu,Export,Enable,ProjectID
		)
		Select ModuleID,ModuleName,AddRight,ModifyRight,DeleteRight,PreviewRight,PrintRight,
		ShowMenu,Export,Enable,ProjectID
		From
		(  
			Select Cast(colx.query('data(ModuleID)') as Varchar(100)) as ModuleID,  
			Cast(colx.query('data(ModuleName)') as Varchar(256)) as ModuleName, 	  
			Cast(colx.query('data(Save)') as Varchar(100)) as AddRight,      
			Cast(colx.query('data(Modify)') as Varchar(100)) as ModifyRight,      
			Cast(colx.query('data(Delete)') as Varchar(100)) as DeleteRight,      
			Cast(colx.query('data(View)') as Varchar(100)) as PreviewRight,      
			Cast(colx.query('data(Print)') as Varchar(100)) as PrintRight,      
			Cast(colx.query('data(Active)') as Varchar(100)) as ShowMenu,
			Cast(colx.query('data(Export)') as Varchar(100)) as Export,
			Cast(colx.query('data(Enable)') as Varchar(100)) as Enable,
			Cast(colx.query('data(ProjectID)') as Varchar(100)) as ProjectID
			From @XMLDetails.nodes('XMLDetails/XMLData') as Tabx(colx)  
		)T  

		Update T Set 
			T.MenuName=LTrim(RTrim(M.MENUNAME))
		From #TempV5_AccessRights T Inner Join GTL_MODULEMASTER (Nolock) M
		On(T.ModuleID=M.MODULEID)

		Select @XMLDetails=Cast(@AccessProjects As XML)  

		Insert Into #TempV5_AccessibleProjects(ProjectID)
		Select ProjectID
		From
		(  
			Select Cast(colx.query('data(ProjectID)') as Varchar(100)) as ProjectID	
			From @XMLDetails.nodes('XMLDetails/XMLData') as Tabx(colx)  
		)T  
			
		Insert Into #TempV5_AccessibleProjects(ProjectID)
		Select P.ParentProjectID From  
		#TempV5_AccessibleProjects T Inner Join GTL_Projects P(Nolock) On(P.ProjectID=T.ProjectID)
		Where Not Exists
		(
			Select Top 1 Null From #TempV5_AccessibleProjects X(Nolock) Where X.ProjectID=P.ParentProjectID
		) 
		Group By P.ParentProjectID

		Begin Try
		Begin Tran

			Delete R From GTL_UserRights R Inner Join #TempV5_AccessRights T
			On (R.ModuleID=T.ModuleID and R.PROJECTID=T.ProjectID)
			Where R.CompanyID=@CompanyID and R.GroupID=@GroupID

			Insert Into GTL_UserRights
			(
			ModuleID,AddRight,ModifyRight,DeleteRight,PreviewRight,PrintRight,EUser,CompanyID,
			GroupID,MenuName,ProjectID,ShowMenu,EXPORTRIGHT,SPECIALRIGHT,LASTUPDATEDON
			)
			Select ModuleID,AddRight,ModifyRight,DeleteRight,PreviewRight,PrintRight,@UserCode,
			@CompanyID,@GroupID,LTrim(RTrim(MenuName)),ProjectID,ShowMenu,Export,Enable,GETDATE()
			From #TempV5_AccessRights

			Update G Set G.IsWebUser='Y' From GTL_UserGroups G Where G.CompanyID=@CompanyID and G.GroupID=@GroupID 


			Set @AccessProjectIDs=''

			Select @AccessProjectIDs=String_Agg(T.ProjectID,',') From #TempV5_AccessibleProjects T

			Update G Set G.AccessProjectID=@AccessProjectIDs From GTL_UserGroups G
			Where G.CompanyID=@CompanyID and G.GroupID=@GroupID

			Update G Set G.LoginProjectId=@AccessProjectIDs From GTL_Users G
			Where G.GroupID=@GroupID and G.CompanyID=@CompanyID
	

			If IsNull(@UserAuthorization,'')<>''
			Begin
				Select @XMLDetails=Cast(@UserAuthorization As XML)

				Insert Into #TempV5_UserAuthorization
				(
					GroupID,UserID
				)
				Select GroupID,UserID From 
				(
					Select Cast(colx.query('data(GroupID)') as Varchar(100)) as GroupID,
					Cast(colx.query('data(UserID)') as Varchar(100)) as UserID					
					From @XMLDetails.nodes('XMLDetails/XMLData') as Tabx(colx)
				)T	
				
				Delete A From GTL_UserAuthorisation A Inner Join #TempV5_UserAuthorization U On (A.GroupID=U.GroupID)
				Where A.CompanyID=@CompanyID

				Insert Into	GTL_UserAuthorisation
				(
				CompanyID,GroupID,UserID,Euser,Lastupdatedon
				)
				Select @CompanyID,GroupID,UserID,@UserCode,GetDate() From #TempV5_UserAuthorization

			End

			Select 'Data saved successfully.' As ResponseMsg
			Commit Tran

		End Try
		Begin Catch

			Declare @Msg Varchar(8000)=''
			If @@Trancount <> 0
			Begin
				Rollback Tran
			End
			Select @Msg=Error_Message()
			Raiserror(@Msg,16,1)
			Return

		End Catch
	End
	
	Set NoCount Off
End
GO
