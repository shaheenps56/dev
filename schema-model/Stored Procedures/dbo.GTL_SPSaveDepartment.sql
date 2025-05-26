SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Proc [dbo].[GTL_SPSaveDepartment]
(
	@Purpose			Varchar(1),
	@XMLFilters			Varchar(Max),
	@XMLString			Varchar(Max),
	@Channel			Int,
	@Version			Varchar(100),
	@UserCode			Varchar(25)
)as
/*********************************************************************************************
Created By	:Paul Mathew
Created On	:14-08-2024 
Purpose		:Department save/modification
Test		:Exec GTL_SPSaveDepartment @Purpose='V',
			 @XMLFilters='<XMLDetails><XMLData><DepartmentID>7</DepartmentID></XMLData></XMLDetails>',
			 @XMLString= '<XMLDetails><XMLData><DepartmentID>9</DepartmentID><DepartmentDesc>
			 DepartmentDesc</DepartmentDesc><DepartmentCode>DepartmentCode</DepartmentCode>
			 <SPOC>SPOC1,SPOC2</SPOC>
			 </XMLData></XMLDetails>',@Channel=5,@Version= '5.0.3',@UserCode= 'GIT'
**********************************************************************************************/
Begin
	Set NoCount On
   
	Declare @DepartmentID Int=0,@DepartmentEditAccess Char(1)='Y',@XMLDetails as XML

	Select @DepartmentID=Case When ColName='DepartmentID' Then IsNull(ColValue,0) Else @DepartmentID End
	From SPARCV5_FnGetRptFilters(@XMLFilters)

	Select @XMLDetails=@XMLString

	Create Table #Temp_Department
	(
		DepartmentID			Int,
		DepartmentCode			Varchar(100),
		DepartmentDesc			Varchar(200),
		SPOC					Varchar(Max)
	)
	If @Purpose='L'
	Begin
		Select 'UserID' as Code,'UserName' as Description,126 as SearchKey,'UserID' as SearchOPID,
		'UserCode' as SearchOPCode,'UserName' as SearchOPDesc,'SPOC Search' as SearchPageHeader
 
		Select 'DepartmentCode' as Code,'DepartmentDescription' as Description,213 as SearchKey,
		'DepartmentID' as SearchOPID,'DepartmentCode' as SearchOPCode,'DepartmentDescription' as SearchOPDesc,
		'Department Search' as SearchPageHeader,'Y' as DisableDepartment
	End
	Else If @Purpose='V'
	Begin		
		If IsNull(@DepartmentID,0)= 0
		Begin
			Raiserror('Please select Department.',16,1)
			Return
		End	
		Insert Into #Temp_Department
		(
			DepartmentID,DepartmentCode,DepartmentDesc,SPOC
		)
		Select D.DepartmentID,D.DepartmentCode,D.DepartmentDesc,D.SPOC
		From GTL_Department D (NoLock) Where D.DepartmentID=@DepartmentID

		Select 'Y' as Checked,Row_Number() Over(Order By S.Value) as SlNo,S.Value as UserCode,U.UserName
		From #Temp_Department D (NoLock) Cross Apply String_Split(D.SPOC,',') as S
		Inner Join GTL_USERS U (NoLock) On(S.Value=U.UserCode)

        Select '' as RightAlignCols,'' as LinkCols,'N' as HTMLOutput,'Checked' as HiddenCols,'' as SelectedRowColor
    End
    Else If @Purpose='S'
    Begin
		Insert Into #Temp_Department
		(
			DepartmentID,DepartmentCode,DepartmentDesc,SPOC
		)
		Select DepartmentID,DepartmentCode,DepartmentDesc,SPOC
		From
		(
			Select Cast(colx.query('data(DepartmentID)') as Varchar(20)) as DepartmentID,
			Cast(colx.query('data(DepartmentCode)') as Varchar(100)) as DepartmentCode,
			Cast(colx.query('data(DepartmentDesc)') as Varchar(200)) as DepartmentDesc,
			Cast(colx.query('data(SPOC)') as Varchar(Max)) as SPOC
			From @XMLDetails.nodes('XMLDetails/XMLData') as Tabx(colx)
		)T

		If Exists(Select Top 1 Null From #Temp_Department T Where IsNull(T.DepartmentCode,'')='')
		Begin
			Raiserror('Please enter Department Code.',16,1)
			Return
		End
		Else If Exists(Select Top 1 Null From #Temp_Department T Where IsNull(T.DepartmentDesc,'')='')
		Begin
			Raiserror('Please enter Department Description.',16,1)
			Return
		End
		Else If Exists
		(
			Select Top 1 Null From GTL_Department D(Nolock) 
			Inner Join #Temp_Department T On(D.DepartmentCode=T.DepartmentCode and D.DepartmentID<>T.DepartmentID)
		)
		Begin
			Raiserror('Department Code already exists.',16,1)
			Return
		End
		If Exists
		(
			Select Top 1 Null From GTL_Department D(Nolock) 
			Inner Join #Temp_Department T On(D.DepartmentDesc=T.DepartmentDesc and D.DepartmentID<>T.DepartmentID)
		)
		Begin
			Raiserror('Department Description already exists.',16,1)
			Return
		End

		Begin Try
		Begin Tran
			If Exists
			(
				Select Top 1 Null From GTL_Department D(NoLock) 
				Inner Join #Temp_Department T On(D.DepartmentID=T.DepartmentID)
			)
			Begin
				Insert Into GTL_DepartmentLog
				(
					LogUpdatedTime,LogUser,DepartmentID,DepartmentCode,DepartmentDesc,
					Active,EUser,LastUpdatedOn
				)
				Select GetDate() as LogUpdatedTime,@UserCode as LogUser,D.DepartmentID,D.DepartmentCode,
				D.DepartmentDesc,D.Active,D.EUser,D.LastUpdatedOn
				From GTL_Department D(Nolock) Inner Join #Temp_Department T On(D.DepartmentID=T.DepartmentID)

				Update D Set 
				D.SPOC=IsNull(Upper(T.SPOC),''),
				D.DepartmentCode=Case When @DepartmentEditAccess='Y' Then T.DepartmentCode Else D.DepartmentCode End,
				D.DepartmentDesc=Case When @DepartmentEditAccess='Y' Then T.DepartmentDesc Else D.DepartmentDesc End,
				D.LastUpdatedOn=GetDate(),D.EUser=@UserCode
				From GTL_Department D Inner Join #Temp_Department T On(D.DepartmentID=T.DepartmentID)
			End
			Else
			Begin			
				If IsNull(@DepartmentEditAccess,'')='Y'
				Begin
					Exec spGenerateKeyForOutput 'DepartmentID',1,@UserCode,@DepartmentID OutPut

					Insert Into GTL_Department 
					(
						DepartmentID,DepartmentCode,DepartmentDesc,Active,SPOC,EUser,LastUpdatedOn
					)
					Select @DepartmentID as DepartmentID,T.DepartmentCode,T.DepartmentDesc,'Y' as Active,
					T.SPOC,@UserCode as EUser,GetDate() as LastUpdatedOn From #Temp_Department T
				End
				Else
				Begin
					Raiserror('Access denied.',16,1)
					Rollback Tran
					Return
				End
			End
		
			Select 'Data saved successfully.' as ResponseMsg From #Temp_Department T

			Commit Tran
		End Try
		Begin Catch
			Declare @Msg Varchar(Max)=''
			If @@TranCount<>0
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
