SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Proc [dbo].[SPARCV5_SPModuleEdit]
(
	@XMLFilters			Varchar(Max),
	@XMLString			Varchar(Max),
	@Purpose			Varchar(2),
	@Version			Varchar(50),	
	@Channel			Int,
	@UserCode			Varchar(25)
)
As
/*****************************************************************************************************
Created By	:Paul Mathew
Created On	:08-08-2024
Purpose		:For Fetching/Updating Module Master details
Test		:Exec SPARCV5_SPModuleEdit 
			 @XMLFilters='<XMLDetails><XMLData><DepartmentID></DepartmentID></XMLData></XMLDetails>',
			 @XMLString='',@Version='',@Channel='',@Purpose='V',@UserCode='GIT'			
******************************************************************************************************/
Begin
	Set NoCount On

	Declare @DepartmentID Int,@ModuleName Varchar(100),@XMLDetails XML,@Msg Varchar(Max)

	Select @XMLDetails=Cast(@XMLString as XML)

	Create Table #Temp_ModuleMaster
	(
		ProjectID			Int,
		Project				Varchar(100),
		ModuleID		    Varchar(5),
		ModuleName			Varchar(200),
		ShowModule			Varchar(1),
		AccessLevelID       Int, 
		Remarks				Varchar(8000),
		DepartmentID        Int,
		Department			Varchar(200)
	)

	Select @DepartmentID=Case When ColName='DepartmentID' Then ColValue Else IsNull(@DepartmentID,0) End,
	@ModuleName=Case When ColName='ModuleName' Then ColValue Else IsNull(@ModuleName,'') End 
	From SPARCV5_FnGetRptFilters(@XMLFilters)

	If @Purpose='L'--Page Load
	Begin
		Select 'DepartmentCode' as Code,'DepartmentDescription' as Description,214 as SearchKey,
		'DepartmentID' as SearchOPID,'DepartmentCode' as SearchOPCode,
		'DepartmentDescription' as SearchOPDesc,'Department Search' as SearchPageHeader
				
		Select 0 as Code,'All' as Description
		Union All
		Select A.Code,A.Description From GTL_ModuleAccessLevel A(Nolock)
	End
	Else If @Purpose='V'--View Click
	Begin
		Insert Into #Temp_ModuleMaster
		(
		ModuleID,ProjectID,Project,ModuleName,ShowModule,Remarks,DepartmentID,AccessLevelID
		)
		Select M.ModuleID,M.ProjectID,P.Code as Project,M.ModuleName,M.ShowModule,
		M.Remarks,M.DepartmentID,M.AccessLevelID
		From GTL_ModuleMaster M(Nolock) Inner Join GTL_Projects P(Nolock) On(M.ProjectID=P.ProjectID)
		Where (M.ModuleName Like '%' + @ModuleName + '%' Or IsNull(@ModuleName,'')='') and
		M.DepartmentID=Case When IsNull(@DepartmentID,0)<>0 Then @DepartmentID Else M.DepartmentID End

		Update T Set T.Department=D.DepartmentDesc 
		From #Temp_ModuleMaster T Inner Join GTL_Department D(Nolock) On(D.DepartmentID=T.DepartmentID)

		--Selecting O/P
		Select '' as Checked,'' as SlNo,'' ModuleID,'' Project,'' ModuleName,'' Department,'' DepartmentID,
		'' as Active,'' as AccessLevel,'' as Remarks Union All
		Select 'N' as Checked,Cast(Row_Number() Over(Order By T.ModuleName) as Varchar(10)) as SlNo,
		Cast(T.ModuleID as Varchar(10)) ModuleID,T.Project,T.ModuleName,T.Department,
		Cast(T.DepartmentID as Varchar(10)) DepartmentID,IsNull(T.ShowModule,'N') as Active,
		Cast(T.AccessLevelID as Varchar(10)) as AccessLevel,IsNull(T.Remarks,'') as Remarks From #Temp_ModuleMaster T

		--Selecting table styles
		Select '' as RightAlignCols,'' as LinkCols,'N' as HTMLOutput,
		'DepartmentID' as HiddenCols,dbo.SPARCV5_FnGetAppControlsColor('SELECTEDROW') as SelectedRowColor

		--Selecting XML header
		Select '' as ModuleID,'' as Project,'' as ModuleName,'' as Active,'' as AccessLevel,
		'' as Remarks,'' as DepartmentID
	End
	Else If @Purpose='S'--Save Click	
	Begin
		Insert Into #Temp_ModuleMaster
		(
		ModuleID,ShowModule,AccessLevelID,Remarks,DepartmentID
		)
		Select T.ModuleID,T.ShowModule,T.AccessLevelID,T.Remarks,T.DepartmentID
		From (Select Cast(colx.query('data(ModuleID)') as Varchar(100)) as ModuleID,
		Cast(colx.query('data(Active)') as Varchar(100)) as ShowModule,
		CAST(colx.query('data(AccessLevel)') as Varchar(100)) as AccessLevelID,
		Cast(colx.query('data(Remarks)') as Varchar(8000)) as Remarks,
		CAST(colx.query('data(DepartmentID)') as Varchar(100)) as DepartmentID
		From @XMLDetails.nodes('XMLDetails/XMLData') as Tabx(colx))T
		
		If Exists(Select Top 1 Null From #Temp_ModuleMaster T Where IsNull(T.DepartmentID,0)=0)
		Begin
			Select @Msg='Please select Department.'
			Raiserror(@Msg,16,1)
			Return
		End

		Begin Try
		Begin Tran
			
			--Keeping Log of existing data
			Insert Into GTL_ModuleMaster_Log
			(
				ModuleID,ProjectID,ModuleName,MenuName,EUser,LangID,LastUpdatedOn,
				AccessName,ShowModule,ModuleType,MainProject,
				WebProject,DepartmentID,AccessLevelID,Remarks,LogUser,LogDateTime
			)
			Select M.ModuleID,M.ProjectID,M.ModuleName,M.MenuName,@UserCode,M.LangID,
			M.LastUpdatedOn,M.AccessName,M.ShowModule,M.ModuleType,M.MainProject,
			M.WebProject,M.DepartmentID,M.AccessLevelID,M.Remarks,
			@UserCode as LogUser,GetDate() as LogDateTime
			From GTL_ModuleMaster M (Nolock) Inner Join #Temp_ModuleMaster T On(M.ModuleID=T.ModuleID)

			--Updating Module master details
			Update M 
			Set M.ShowModule=IsNull(T.ShowModule,'N'),M.AccessLevelID=T.AccessLevelID,
			M.Remarks=T.Remarks,M.DepartmentID=T.DepartmentID,
			M.Euser=@UserCode,M.LastUpdatedOn=GetDate()
			From GTL_ModuleMaster M Inner Join #Temp_ModuleMaster T On(M.ModuleID=T.ModuleID)

			Select 'Data saved successfully.' as ResponseMsg
			Drop Table #Temp_ModuleMaster

			Commit Tran
		End Try
		Begin Catch
			If @@Trancount<>0
			Begin
				Rollback Tran
			End
			Select @Msg=Error_Message()
			Raiserror(@Msg,16,1)
			Return
		End Catch
	End
	Else
	Begin
		Raiserror('Invalid operation.',16,1)
	End

	Set NoCount Off
End
GO
