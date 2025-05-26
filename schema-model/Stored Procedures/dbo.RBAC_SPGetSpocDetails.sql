SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Proc [dbo].[RBAC_SPGetSpocDetails]
(
	@XMLFilters		Varchar(Max),
	@Channel		Int,
	@Version		Varchar(100),
	@UserCode		Varchar(25)	
)
As
/**********************************************************************************************************************************************************
	Created By	:	Shammas TP
	Created On	:	07.08.2024
	Purpose		:	Fetch Spoc Details For Rbac Report.
	Project		:	SPARCIM
	Test		:	Exec RBAC_SPGetSpocDetails @XMLFilters='',@Channel=5,@Version='0/0265',@UserCode='Git'
**********************************************************************************************************************************************************/
Begin
	
	Set NoCount On
	Set Transaction Isolation Level Read UnCommitted

	Declare @DepartmentID Int=0

	Select @DepartmentID=Case When ColName='DepartmentID' Then ColValue Else IsNull(@DepartmentID,0) End 
	From SPARCV5_FnGetRptFilters(@XMLFilters)


	Create Table #SpocDetails
	(
		DepartmentCode		Varchar(50),
		DepartmentDesc		Varchar(150),
		Spoc				Varchar(Max)
	)

	Insert Into #SpocDetails
	(
	DepartmentCode,DepartmentDesc,Spoc
	)
	Select Distinct D.DepartmentCode,D.DepartmentDesc,Cast(U.USERCODE as Varchar(Max)) Spoc
	From GTL_Department (Nolock) D Cross Apply String_Split(D.SPOC,',') As Split
	Inner Join GTL_USERS (Nolock) U
	On(Cast(Split.value as Varchar(Max))=Cast(U.USERCODE as Varchar(Max)))
	Where IsNull(D.DepartmentID,0)=Case When IsNull(@DepartmentID,0)=0 Then D.DepartmentID Else IsNull(@DepartmentID,0) End
	and D.Active='Y'

	Select DepartmentCode [Department Code],DepartmentDesc [Department Description],Spoc
	From #SpocDetails

	Select '' [Department Code],'' [Department Description],'' Spoc

	Select '' as HiddenCols,'' as RightAlignCols,'N' as HTMLOutput

	SELECT'<html><header><img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTh5dX8hbusCfKkLhQFasGj5Ro1P2gVV-FGcQ&s"'+
	+'>Geojit Financial Services Limited (GFSL)</header></html>' as HTMLHeader,

	'DepartmentWiseSpocDetails.xlsx' as FileName,'1|DepartmentWiseSpocDetails'

	Set Transaction Isolation Level Read Committed 
	Set NoCount Off
End
GO
