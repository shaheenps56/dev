SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[GTL_SPSaveUserGroups]
(
	@Purpose		Char(1),
	@XmlFilters		Varchar(8000),
	@Version		Varchar(100),
	@Channel		Int,
	@Code			Varchar(50),
	@Description	Varchar(150),
	@UserCode		Varchar(30)
)
As
/*****************************************************************************************************************
	Created	By	:	Shammas TP
	Created	On	:	29.11.2023
	Purpose		:	DPS-User group adding sp
	Project		:	SPARC-DPS
	Test		:	Exec SPARCV5_GTLSpInsertUserGroups @Purpose='S',
					@XmlFilters='<XMLDetails><XMLData><DepartmentID>21</DepartmentID></XMLData></XMLDetails>',@Version='1.0.0',	
					@Channel=5,@Code='credits',@Description='credit club',@UserCode='GIT'
*****************************************************************************************************************/
Begin
	Set NoCount On

	Declare @GroupID Int, @CompanyID Int=1,@LangID Int=1,@DepartmentID Int

	Select @DepartmentID=Case When ColName='DepartmentID' Then ColValue Else IsNull(@DepartmentID,0) End  
	From SPARCV5_FnGetRptFilters(@XMLFilters)  

	If @Purpose='S'
	Begin

		If IsNull(@Code,'')=''
		Begin
			RAISERROR('Role is invalid',16,1)
			Return
		End
		If Exists(Select Top 1 Null From GTL_UserGroups (Nolock) Where DESCRIPTION=@Code)
		Begin
			RAISERROR('Role Already Exists',16,1)
			Return
		End
		
		If IsNull(@Description,'')=''
		Begin
			RAISERROR('Role description is invalid',16,1)
			Return
		End
		If Exists(Select Top 1 Null From GTL_UserGroups (Nolock) Where Remarks=@Description)
		Begin
			RAISERROR('Role description Already Exists',16,1)
			Return
		End

		If IsNull(@DepartmentID,0)=0
		Begin
			RAISERROR('Please select department',16,1)
			Return
		End

		If Not Exists(Select Top 1 1 From GTL_Department (Nolock) Where DepartmentID=IsNull(@DepartmentID,0))
		Begin
			RAISERROR('Invalid department',16,1)
			Return
		End
	
		Exec SPARCIM.DBO.spGenerateKeyForOutput 'UserGroupId',@CompanyID,@UserCode,@GroupID OutPut

		Insert Into GTL_UserGroups
			(
			COMPANYID,GROUPID,ISWEBUSER,DESCRIPTION,LANGID,EUSER,LASTUPDATEDON,Remarks,DepartmentID
			) 
		Values
			(
			@CompanyID,@GroupID,'Y',@Code,1,@UserCode,GETDATE(),IsNull(@Description,''),IsNull(@DepartmentID,0)
			)

		Select 'Data saved successfully.' As ResponseMsg

		Select Distinct U.GroupID [Code],U.Description [Description]  From GTL_USERGROUPS (Nolock) U
		Return
		
	End
	Set NoCount Off
End
GO
