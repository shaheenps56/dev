SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Exec SPARCV5_SPGetMenus @UserCode='00708',@ProjectID=1125,@MenuID=0,@Channel=25
CREATE Procedure [dbo].[SPARCV5_SPGetMenus]
(
	@UserCode	Varchar(50),
	@ProjectID	Int=0,
	@MenuID		Int=0,
	@Channel	Int=5,
	@Debug		Varchar(1)='N'
)
As
/* ***********************************************************************************************
Created By	:Paul Mathew
Created On	:19.04.2022
Project		:SPARC
Purpose		:Fetching Project & Menus
Test		:Exec SPARCV5_SPGetMenus @UserCode='02108',@ProjectID=1115,@MenuID=0,@Channel=25
			 Exec SPARCV5_SPGetMenus @UserCode='02108',@ProjectID=1115,@MenuID=326,@Channel=25
	MOD:001 : On 07052025 By Dipu - Adding the special rights items along wth the menues if project if is given
************************************************************************************************ */
Begin
	Set NoCount On
	Declare @FavMenuItems Varchar(Max),@GroupID Int,@UserType Varchar(100),@MaxQueryLevel Varchar(100)
	Declare @LicenseCompanyName Varchar(100)='',@SPARCMainProjectID Int=1009,@UserAccessLevel Varchar(1)

	Select  @LicenseCompanyName=LicenseCompanyName From SPARC_Settings(Nolock)
	Select @SPARCMainProjectID=IsNull(A.Value,1009) From GTL_AppConfig A(Nolock)
	Where A.Parameter='SPARCMAINPROJECTID' and GetDate() Between FromDate and ToDate

	Create Table #TempV5_Project
	(
		SlNo				Int Not NUll Identity Primary Key,
		ProjectID			Int,
		ParentProjectID		Int,
		Project				Varchar(100),
		IconUrl				Varchar(1000),
		IconClass			Varchar(100),
		IconColor			Varchar(50),
		SelectedColor		Varchar(50),
		HoverColor			Varchar(50),
		DefaultProject		Varchar(1),
		ExternalProject		Varchar(1),
		Active				Varchar(1),
		SortOrder			Int
	)

	Create Table #TempV5_Menus
	(
		SlNo				Int Not Null Identity Primary Key,
		ProjectID			Int,
		ModuleID			Int,
		MenuID				Int,
		ParentID			Int,
		Caption				Varchar(1000),
		Url					Varchar(2000),
		ExternalUrl			Varchar(2000),
		OutPutUrl			Varchar(2000),
		Type				Varchar(100),
		IconClass			Varchar(100),
		IconColor			Varchar(100),
		HasSubMenu			Varchar(100),
		Favourite			Varchar(100),
		PageID				Int,
		ProjectName			Varchar(100),
		ParentProjectID		Int,
		ParentProjectName	Varchar(100),
		ShowFooter			Varchar(1),--To show/hide page footer in main project
		AddRight			Varchar(1) Not Null Default('Y'),
		ModifyRight			Varchar(1) Not Null Default('Y'),
		DeleteRight			Varchar(1) Not Null Default('Y'),
		PreviewRight		Varchar(1) Not Null Default('Y'),
		PrintRight			Varchar(1) Not Null Default('Y'),
		ShowMenu			Varchar(1) Not Null Default('Y'),
		ExportRight			Varchar(1) Not Null Default('Y'),
		SpecialRight		Varchar(1) Not Null Default('Y'),
		ApplyUILvlRights	Varchar(1) Not Null Default('Y')
	)

	Create Table #Temp_ModuleRights
	(
		GroupID			Int,
		ProjectID		Int,
		ModuleID		Int,
		AddRight		Varchar(1),
		ModifyRight		Varchar(1),
		DeleteRight		Varchar(1),
		PreviewRight	Varchar(1),
		PrintRight		Varchar(1),
		ShowMenu		Varchar(1),
		ExportRight		Varchar(1),
		SpecialRight	Varchar(1),
		ModuleName		Varchar(100)
	)

	Select @GroupID=GroupID,@UserType=IsNull(U.UserType,''),@MaxQueryLevel=IsNull(U.MaxQueryLevel,''),
		@UserAccessLevel=IsNull(U.CorpUser,'N')
	From GTL_Users U(Nolock) Where U.UserCode=@UserCode

	Select @FavMenuItems =F.MenuIds From SPARCV5_Favourites F(Nolock) Where F.UserCode=@UserCode
	Select Item1 Into #Temp_Favourites From dbo.GTL_Split(',',@FavMenuItems,Null,Null,Null,Null)	

	--If menus displayed under different project, we need to set ProjectID(to which the source code resides) 
	If @MenuID<>0
	Begin
		Select @ProjectID=M.ProjectID From SPARCV5_Menu M(Nolock) Where M.MenuID=@MenuID
	End
	If @LicenseCompanyName='GFSL'
	Begin
		Insert Into #Temp_ModuleRights
		(
			GroupID,ProjectID,ModuleID,AddRight,ModifyRight,DeleteRight,PreviewRight,
			PrintRight,ShowMenu,ExportRight,SpecialRight,ModuleName
		)
		Select R.GroupID,R.ProjectID,R.ModuleID,R.AddRight,R.ModifyRight,R.DeleteRight,R.PreviewRight,
			R.PrintRight,R.ShowMenu,R.ExportRight,R.SpecialRight,r.ModuleName
		From dbo.SPARCV5_FnGetUserAccessRights(@UserCode,@UserAccessLevel) R
	End
	Else
	Begin
		Insert Into #Temp_ModuleRights
		(
			GroupID,ProjectID,ModuleID,AddRight,ModifyRight,DeleteRight,PreviewRight,
			PrintRight,ShowMenu,ExportRight,SpecialRight
		)
		Select R.GroupID,R.ProjectID,R.ModuleID,R.AddRight,R.ModifyRight,R.DeleteRight,R.PreviewRight,
		R.PrintRight,R.ShowMenu,R.ExportRight,R.SpecialRight From GTL_UserRights R(Nolock) 
		Where R.GroupID=@GroupID and R.ShowMenu='Y'
	End


	Insert Into #TempV5_Project
	(
		ProjectID,ParentProjectID,Project,IconUrl,IconClass,IconColor,SelectedColor,HoverColor,
		DefaultProject,ExternalProject,Active,SortOrder
	)
	Select P.ProjectID,P.ParentProjectID,P.Project,P.IconUrl,P.IconClass,P.IconColor,
	IsNull(P.SelectedColor,'red') as SelectedColor,Isnull(P.HoverColor,'#008000') as HoverColor,
	IsNull(P.DefaultProject,'N') as DefaultProject,IsNull(P.ExternalProject,'N') as ExternalProject,
	IsNull(P.Active,'N') as Active,P.SortOrder
	From SPARCV5_Project P(Nolock) 
	Where((P.ParentProjectID=@ProjectID Or P.ProjectID=@ProjectID)) and P.Active='Y' and
	--For showing main project while branch user login
	1=Case When (@UserAccessLevel In('N','S') and P.ProjectID=@SPARCMainProjectID) Or P.Active='Y' Then 1 Else 0 End
	Order By P.SortOrder
	   	
	Insert Into #TempV5_Menus
	(
		ProjectID,MenuID,ModuleID,ParentID,Caption,Url,ExternalUrl,Type,IconClass,IconColor,HasSubMenu,
		Favourite,PageID,ParentProjectID
	)
	Select 0 as ProjectID, 0 as MenuID,0 asModuleID,0 as ParentID,'Dashboard' as  Caption,
	'project-dashboard' as Url,'' as ExternalUrl,'' as Type,'' as IconClass,'' as IconColor,
	'N' as HasSubMenu,'N' as Favourite,0 as PageID,0 as ParentProjectID

	--If @UserCode In('GIT','GTL') Or @LicenseCompanyName='GFSL'--For Group testing only . can remove later
	Begin
		Insert Into #TempV5_Menus
		(
			ProjectID,MenuID,ModuleID,ParentID,Caption,Url,ExternalUrl,Type,IconClass,IconColor,HasSubMenu,
			Favourite,PageID,ParentProjectID
		)
		Select M.ProjectID,M.MenuID,M.ModuleID,M.ParentID,M.Caption,M.Url,M.ExternalUrl,M.Type,M.IconClass,
		M.IconColor,M.HasSubMenu,'N' as Favourite,M.PageID,IsNull(M.ParentProjectID,0) as ParentProjectID
		From SPARCV5_Menu M(Nolock) Where M.HasSubmenu='Y' and M.Visible='Y' and 
		M.MenuID=Case When @MenuID<>0 Then @MenuID Else M.MenuID End
		Order By M.SortOrder
	End

	Insert Into #TempV5_Menus
	(
		ProjectID,MenuID,ModuleID,ParentID,Caption,Url,ExternalUrl,Type,IconClass,IconColor,
		HasSubMenu,Favourite,PageID,ParentProjectID
	)
	Select M.ProjectID,M.MenuID,M.ModuleID,
	Case When @LicenseCompanyName In('GFSL','BgSE') Then M.ParentID Else 0 End as ParentID,
	M.Caption,M.Url,M.ExternalUrl,M.Type,M.IconClass,M.IconColor,M.HasSubMenu,
	Case When M.MenuID=F.Item1 Then 'Y' Else 'N' End Favourite,M.PageID,IsNull(M.ParentProjectID,0) as ParentProjectID
	From SPARCV5_Menu M(Nolock)	
	Left Outer Join #Temp_Favourites F On(M.MenuID=F.Item1)  
	Where IsNull(M.Url,'')+IsNull(M.ExternalUrl,'')<>'' and M.SPARCMenu='Y' and
		Exists
		(
			Select R.ModuleID From #Temp_ModuleRights R(Nolock) 
			Where R.ModuleID=M.ModuleID and R.ShowMenu='Y'
		) and
		M.MenuID=Case When @MenuID<>0 Then @MenuID Else M.MenuID End and
		IsNull(Visible,'N')=Case When @UserCode In('GIT','GTL','02108') Then IsNull(Visible,'N') Else 'Y' End
	Order By M.SortOrder
	
	If @ProjectID > 0 and @MenuID = 0
	Begin
		Insert Into #TempV5_Menus
		(
			ProjectID,MenuID,ModuleID,ParentID,Caption,Url,ExternalUrl,Type,IconClass,IconColor,
			HasSubMenu,Favourite,PageID,ParentProjectID
		)
		Select r.ProjectID, -1 MenuId, r.ModuleID, -1 ParentId, r.ModuleName Caption,m.accessname Url,'' ExternalUrl,
			m.moduleType Type,'' IconClass,'' IconColor,
			'N' HasSubMenu,'N' Favourite,-1 PageID,-1 ParentProjectID
		From #Temp_ModuleRights r inner join GTL_ModuleMaster m on (r.ModuleID = m.MODULEID)
		Where r.SpecialRight = 'Y'
	End
	
	--Updating all projectid to Main projectid while branch user login(only for Geojit)
	If @UserAccessLevel In('N','S') and @MenuID=0 and @LicenseCompanyName='GFSL'
	Begin
		Update T Set T.ProjectID=@SPARCMainProjectID,T.ParentProjectID=T.ProjectID
		From #TempV5_Menus T 
		Where Exists
		(
			Select Top 1 Null From #TempV5_Project P 
			Where P.ProjectID=T.ProjectID and IsNull(P.ExternalProject,'N')='N'
		)

		Update T Set T.DefaultProject=Case When T.ProjectID=@SPARCMainProjectID Then 'Y' Else 'N' End,
		T.Project=Case When T.ProjectID=@SPARCMainProjectID Then 'Branch BO' Else T.Project End,
		T.SortOrder=0
		From #TempV5_Project T
		
		Delete T From #TempV5_Project T 
		Where IsNull(T.ExternalProject,'N')='N' and T.ProjectID<>@SPARCMainProjectID			
	End

	Update T Set T.ProjectName=P.Project 
	From #TempV5_Menus T Inner Join #TempV5_Project P(Nolock) On (T.ProjectID=P.ProjectID)

	Update T Set T.ParentProjectName=Case When P.ProjectID In(2,1113) Then 'Equity'
	When P.ProjectID In(1115,1118,1119) and @UserAccessLevel In('Y') Then 'Main' Else P.Project End
	From #TempV5_Menus T Inner Join SPARCV5_Project P(Nolock) On (T.ParentProjectID=P.ProjectID)


	/*Removing menus of inactive projects(This we can remove by linking ProjectID in menu selection query
	after removing all thick application version)*/
	Delete T From #TempV5_Menus T 
	Where Not Exists(Select Top 1 Null From #TempV5_Project P Where P.ProjectID=T.ProjectID and P.Active='Y')
	
	--Deleting menus and projects having no access(currently enabled only in Geojit)
	If @LicenseCompanyName='GFSL'
	Begin
		Delete T From #TempV5_Menus T 
		Where Not Exists
		(
			Select Top 1 Null From #Temp_ModuleRights R(Nolock)
			Inner Join GTL_UserGroups G(Nolock) On(G.GroupID=R.GroupID)
			Cross Apply String_Split(IsNull(G.AccessProjectID,''),',') X
			Where ((X.Value=T.ProjectID) Or 1=
			(Case When @UserAccessLevel='Y' Then 1 
			When @UserAccessLevel In('N','S') and @LicenseCompanyName='GFSL' and X.Value=T.ParentProjectID 
			Then 1 Else 0 End))
		)
		
		Delete T From #TempV5_Project T 
		Where Not Exists
		(
			Select Top 1 Null From #TempV5_Menus M 
			Where (M.ProjectID=T.ProjectID Or M.ParentProjectID=T.ProjectID)
		)
	End

	If @UserCode In('GIT','GTL') Or @LicenseCompanyName='GFSL'
	Begin
		Delete T From #TempV5_Menus T Where T.HasSubMenu = 'Y' and 
		Not Exists (Select Top 1 null From #TempV5_Menus P Where P.ParentID=T.MenuID)
	End
	
	/*
		If call comes from SPARC Main project, then set ExternalUrl as OutPutUrl if exists else url.
		Also external project PageID set to 691 so that the front end can route to external url.
	*/
	If @ProjectID=@SPARCMainProjectID
	Begin
		Update T Set T.OutPutUrl=Case When IsNull(T.ExternalUrl,'')<>'' Then 
		Replace(T.ExternalUrl,'##PageIdx##',LTrim(T.SlNo)) Else IsNull(T.Url,'') End,
		T.PageID=Case When IsNull(T.ExternalUrl,'')<>'' Then 691 Else T.PageID End,
		T.ShowFooter=Case When IsNull(T.ExternalUrl,'')='' And T.Caption='CARE.' Then 'N'
		When IsNull(T.ExternalUrl,'')='' Then 'Y' Else 'N' End
		From #TempV5_Menus T	
	End
	Else
	Begin
		Update T Set T.OutPutUrl=Url From #TempV5_Menus T
	End

	Update T Set T.AddRight=R.AddRight,T.ModifyRight=R.ModifyRight,
	T.DeleteRight=R.DeleteRight,T.PreviewRight=R.PreviewRight,
	T.PrintRight=R.PrintRight,T.ShowMenu=R.ShowMenu,
	T.ExportRight=R.ExportRight,T.SpecialRight=R.SpecialRight
	From #TempV5_Menus T Inner Join 
	(
		Select A.ModuleID,Max(IsNull(A.AddRight,'N')) as AddRight,Max(IsNull(A.ModifyRight,'N')) as ModifyRight,
		Max(IsNull(A.DeleteRight,'N')) as DeleteRight,Max(IsNull(A.PreviewRight,'N')) as PreviewRight,
		Max(IsNull(A.PrintRight,'N')) as PrintRight,Max(IsNull(A.ShowMenu,'N')) as ShowMenu,
		Max(IsNull(A.ExportRight,'N')) as ExportRight,Max(IsNull(A.SpecialRight,'N')) as SpecialRight
		From #Temp_ModuleRights A Group By A.ModuleID 
	)R On(T.ModuleID=R.ModuleID)

	--Setting default Project if not set in project table
	If Not Exists(Select Top 1 Null From #TempV5_Project T Where T.DefaultProject='Y')
	Begin
		Update T Set T.DefaultProject='Y' From #TempV5_Project T 
		Where T.SlNo=(Select Min(P.SlNo) From #TempV5_Project P Where IsNull(ExterNalProject,'N') In('N',''))
	End

	If @Debug='Y'
	Begin
		Select * From #TempV5_Project
		Select * From #TempV5_Menus
		Return
	End
	If @Channel=25 --Call from Mobile
	Begin
		Select T.SlNo,T.SlNo as PageIndex,T.ProjectID as ProjectID,T.MenuID,T.ParentID,T.ModuleID,
		T.Caption,Case When Charindex('?',T.OutPutUrl)>0 
		Then Substring(T.OutPutUrl,1,Charindex('?',T.OutPutUrl)-1) Else T.OutPutUrl End as Url,
		Case When Charindex('?',T.OutPutUrl)>0 
		Then Substring(T.OutPutUrl,Charindex('?',T.OutPutUrl)+1,Len(T.OutPutUrl)) Else '' End as QueryString,
		T.Type,T.IconClass,T.IconColor,T.HasSubMenu,T.Favourite,T.PageID,T.ProjectName,T.ParentProjectID,
		IsNull(T.ParentProjectName,'') as ParentProjectName,T.ShowFooter,
		T.AddRight,T.ModifyRight,T.DeleteRight,T.PreviewRight,T.PrintRight,T.ExportRight,
		T.SpecialRight,T.ApplyUILvlRights
		From #TempV5_Menus T Order By T.SlNo

		Return
	End
	Select ProjectID,Project,IconUrl,IconClass,IconColor,SelectedColor,HoverColor,DefaultProject,ExternalProject 
	From #TempV5_Project P Order By P.SlNo

	Select T.SlNo,T.SlNo as PageIndex,T.ProjectID as ProjectID,T.MenuID,T.ParentID,
		T.Caption,Case When Charindex('?',T.OutPutUrl)>0 
		Then Substring(T.OutPutUrl,1,Charindex('?',T.OutPutUrl)-1) Else T.OutPutUrl End as Url,
		Case When Charindex('?',T.OutPutUrl)>0 
		Then Substring(T.OutPutUrl,Charindex('?',T.OutPutUrl)+1,Len(T.OutPutUrl)) Else '' End as QueryString,
		T.Type,T.IconClass,T.IconColor,T.HasSubMenu,T.Favourite,T.PageID,T.ProjectName,T.ParentProjectID,
		IsNull(T.ParentProjectName,'') as ParentProjectName,T.ShowFooter,
		T.AddRight,T.ModifyRight,T.DeleteRight,T.PreviewRight,T.PrintRight,T.ExportRight,
		T.SpecialRight,T.ApplyUILvlRights
	From #TempV5_Menus T Order By T.SlNo

	--For Dashboard Icon setting
	Select Top 1 P.IconColor,P.SelectedColor,P.HoverColor,'Y' as ShowMenuOnLogoClick,
	'C' as MainMenuOrientation From #TempV5_Project P(Nolock) Order By P.SlNo	

	Set NoCount Off
End

GO
