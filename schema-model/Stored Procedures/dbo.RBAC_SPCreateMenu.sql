SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [dbo].[RBAC_SPCreateMenu]
(
	@MenuName			varchar(128),
	@Url				Varchar(2000),
	@ExternalUrl		Varchar(2000),
	@ParentMenuName		Varchar(200),
	@ModuleType			Varchar(20)='Definition',
	@HasSubMenu			Char(1)='N',
	@Visible			Char(1)='N',
	@SortOrder			Int=1,
	@DeniedUserLevels	Varchar(100)='',
	@HelpUrl			Varchar(100)='',
	@MainProject		Varchar(100)='ISPARC',
	@SubProject			Varchar(50)='',
	@PageID				Int=0,
	@DuplicatePageID	Varchar(1)='N',
	@UserCode			Varchar(25)='GIT',
	@ModuleAccessLevel	Varchar(10)='HO' --HO,Branch
)as
/*************************************************************************************************************************
Created By	:Paul Mathew
Created On	:30.12.2023
Project		:SPARC
Purpose		:To create Project Menus
Test		:Exec RBAC_SPCreateMenu @MenuName='General Report',
			@Url='',
			@ExternalUrl='ExtProject?extProj|generalreport|https://sparcgfsl.fliplabs.net/spicexl/#/spice/generalreport?PageIndex=##PageIdx##',
			@ParentMenuName='',	@ModuleType='Report',@HasSubMenu='N',@Visible='Y',@SortOrder=1,@DeniedUserLevels='',
			@HelpUrl='', @MainProject='SPARCXL',@SubProject='AdminX',@PageID=691,@UserCode='GTL'
*************************************************************************************************************************/
Begin
	Set Nocount On
	Declare @ParentID Int=0,@IconColor Varchar(50)='',@LangID Int=1,@ModuleID Int=0,
	@ProjectID	Int=0,@SubProjectID Int=0,@AccessLevelID Int=1,@MenuID Int=0
	
	Select @ProjectID=P.ProjectID From GTL_Projects P(Nolock) Where P.Code=@MainProject
	Select @AccessLevelID=Case When @ModuleAccessLevel='Branch' Then 2 Else 1 End 

	Select @SubProjectID=P.ProjectID From SPARCV5_Project P(Nolock) 
	Where P.Project=@SubProject and ProjectID<>IsNull(ParentProjectID,0)

	If @ProjectID=1111--for geojit
	Begin
		Select @ProjectID=@SubProjectID
	End
	if @ModuleType not in ('Definition','Report','Special Rights')
	Begin
		Raiserror('Invalid @ModuleType not in Definition,Report,Special Rights.',16,1)
		Return
	End

	If IsNull(@ProjectID,0)=0
	Begin
		Raiserror('Main Project does not exists.',16,1)
		Return
	End
	If IsNull(@SubProjectID,0)=0
	Begin
		Raiserror('Sub Project does not exists.',16,1)
		Return
	End
	Else If IsNull(@MenuName,'')=''
	Begin
		Raiserror('Menu name cannot be blank.',16,1)
		Return
	End
	Else If LTrim(IsNull(@ParentMenuName,''))<>''
	Begin
		Select @ParentID=M.MenuID From SPARCV5_Menu M(Nolock) Where M.Caption=@ParentMenuName
		If IsNull(@ParentID,0)=0
		Begin
			Raiserror('Parent menu does not exists.',16,1)
			Return
		End
	End
	
	Select Top 1 @IconColor=IsNull(IconColor,'') From SPARCV5_Menu M(Nolock) 
	Where M.ProjectID=@ProjectID and IsNull(M.IconColor,'')<>''	

	If IsNull(@PageID,0)=0
	Begin
		--Select @PageID=Max(M.PageID)+1 From SPARCV5_Menu M(Nolock) Where M.PageID<10000
		Raiserror('PageID is missing.',16,1)
		Return
	End	
	Else If Not Exists(Select Top 1 Null From SPARCV5_WebPageMaster P(Nolock) Where P.PageID=@PageID)
	Begin
		--Select @PageID=Max(M.PageID)+1 From SPARCV5_Menu M(Nolock) Where M.PageID<10000
		Raiserror('Please insert PageID in SPARCV5_WebPageMaster and then try.',16,1)
		Return
	End
	Else If Exists(Select Top 1 Null From SPARCV5_Menu M(Nolock) Where M.PageID=@PageID) and @DuplicatePageID='N'
	Begin
		Raiserror('If you wish to duplicate PageID, please call the sp with @DuplicatePageID=''Y''.',16,1)
		Return
	End	

	Select @ModuleID=IsNull(Max(M.ModuleID),0)+1 From GTL_ModuleMaster M(Nolock)
	Select @MenuID=IsNull(Max(M.MenuID),0)+1 From SPARCV5_Menu M(Nolock)

	Begin Try
		Begin Tran
		--Inserting menus in GTL_ModuleMaster
		Insert Into GTL_ModuleMaster
		(
			ModuleID,ProjectID,AccessName,ModuleName,MenuName,MainProject,WebProject,
			ModuleType,DepartmentID,AccessLevelID,LangID,Euser,LastUpdatedOn
		)
		Select @ModuleID,@ProjectID,IsNull(@Url,@ExternalUrl),@MenuName,@MenuName,
			@MainProject,@SubProject,@ModuleType,1 as DepartmentID,@AccessLevelID,
			@LangID as LangID,@UserCode,GetDate() as LastUpdatedOn

		--Inserting menus in SPARCV5_Menu
		If @ModuleType in ('Definition', 'Report')
		Begin
			Insert Into SPARCV5_Menu
			(
				ParentID,ProjectID,Caption,Url,ExternalUrl,Visible,Type,SortOrder,
				HasSubMenu,DeniedUserLevels,HelpUrl,ModuleID,IconColor,PageID
			)
			Select @ParentID as ParentID,@SubProjectID as ProjectID,
				@MenuName as Caption,@Url as Url,@ExternalUrl as ExternalUrl,@Visible as Visible,
				@ModuleType as Type,@SortOrder as SortOrder,@HasSubMenu as HasSubMenu,
				@DeniedUserLevels as DeniedUserLevels,@HelpUrl as HelpUrl,@ModuleID as ModuleID,
				@IconColor as IconColor,@PageID as PageID
		End

		--Giving access rights to admin  group
		Insert Into GTL_UserRights
		(
			CompanyID,GroupID,ProjectID,ModuleID,AddRight,ModifyRight,DeleteRight,PreviewRight,MenuName,
			PrintRight,Euser,LastUpdatedOn,ShowMenu
		)
		Select 1 CompanyID,1 GroupID,@ProjectID,@ModuleID,'Y' as AddRight,'Y' as ModifyRight,'Y' as DeleteRight,
		'Y' as PreviewRight,@MenuName,'Y' as PrintRight,@UserCode,GetDate(),@Visible

		Select @PageID as PageID

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
	Set Nocount Off
End
GO
