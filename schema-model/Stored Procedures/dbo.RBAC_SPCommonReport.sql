SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [dbo].[RBAC_SPCommonReport]
(  
	@RptType		Int,
	@FromDate		DateTime,
	@ToDate			DateTime,
	@VenueID		Int,
	@RptFileType	Int,	
	@Channel		Int,  
	@Version		Varchar(100),
	@XMLFilters		Varchar(Max)='',
	@UserCode		Varchar(25),
	@Debug			Varchar(1) ='N'	
)  
As  
/*************************************************************************************************************************************** 
Created By	  : Vidhya Rajesh & Paul Mathew
Created on    : 16.09.2021 
Project       : SPARC 
Purpose       : For Common Report Module 
Test		  : exec RBAC_SPCommonReport @fromDate='20240801',@toDate='20240801',
				@VenueID=0,@RptType=14,@VorE='E',@UserCode='git',
				@RptFileType=3,@Channel=5

18.07.2023	:	MOD:001	By 16593	-	Result set change for Custody -> Settlement Master (OLD SAPRC)
18.03.2025  :	MOD:002 By 19761	- Add login history userwise
***************************************************************************************************************************************/  
Begin  
	Set NoCount On 

	Declare @HtmlOutput Varchar(1) ='N',@HiddenCols Varchar(max) ='',@RightAlignCols Varchar(max) ='',@SBBranch Varchar(100)='',
	@ReportCaption Varchar(Max)='',@Region Varchar(100)='',@Location Varchar(100)=''

	If @RptType In(14)--Login History Details
	Begin
		If @RptFileType Not In(2,3) And @Channel=5
		Begin
			Select @ReportCaption='Login History for the period '+Convert(Varchar(10),@FromDate,105)+ ' to '+Convert(Varchar(10),@ToDate,105)
			Exec RBAC_SPGetReportHeader @ReportCaption=@ReportCaption,@UserCode=@UserCode,@Region=@Region,@Location=@Location, 
			@SBBranch=@SBBranch,@Exchange='',@ShowCompanyAddress='',@ShowSubBrokerAddress='N' 
		End
		Exec RBAC_SPGetLoginHistory @FromDate=@FromDate,@ToDate=@ToDate,@Users='',@UserCode=@UserCode,@Purpose='D'		
		Return
	End	
	Else If @RptType In(22)--Login History Details userwise --MOD 002
	Begin
		If @RptFileType Not In(2,3) And @Channel=5
		Begin
			Select @ReportCaption='Login History for the period '+Convert(Varchar(10),@FromDate,105)+ ' to '+Convert(Varchar(10),@ToDate,105)
			Exec RBAC_SPGetReportHeader @ReportCaption=@ReportCaption,@UserCode=@UserCode,@Region=@Region,@Location=@Location, 
			@SBBranch=@SBBranch,@Exchange='',@ShowCompanyAddress='',@ShowSubBrokerAddress='N' 
		End
		Exec RBAC_SPGetLoginHistory @FromDate=@FromDate,@ToDate=@ToDate,@Users='',@UserCode=@UserCode,@Purpose='S'		
		Return
	End	
	Else If @RptType In(15)--Audit Trial Details
	Begin
		If @RptFileType=3
		Begin
			Select @ReportCaption='Audit Trial for the period '+Convert(Varchar(10),@FromDate,105)+ ' to '+Convert(Varchar(10),@ToDate,105)

			Exec RBAC_SPUserRightLogs @FromDate=@FromDate,@ToDate=@ToDate,@UserCode=@UserCode	
			Return
		End
		Else
		Begin
			Raiserror('Please use download option(Excel).',16,1)
			Return
		End
	End	
	Else If @RptType In(16)--Rbac-Module Wise Users List
	Begin
		If @RptFileType=3
		Begin
			Select @ReportCaption='Module Wise Users List'	

			Exec RBAC_SPGetModuleWiseUsers @XMLFilters='',@Channel=5,@Version='',@UserCode=@UserCode
			Return
		End
		Else
		Begin
			Raiserror('Please use download option(Excel).',16,1)
			Return
		End
	End	
	Else If @RptType In(17)--Rbac-Module Wise Roles List
	Begin
		If @RptFileType=3
		Begin
			Select @ReportCaption='Module Wise Roles List'	

			Exec RBAC_SPGetModuleWiseRoles @XMLFilters='',@Channel=5,@Version='',@UserCode=@UserCode	
			Return
		End
		Else
		Begin
			Raiserror('Please use download option(Excel).',16,1)
			Return
		End
	End	
	Else If @RptType In(18)--Rbac-Role Wise Users List
	Begin
		If @RptFileType=3
		Begin
			Select @ReportCaption='Role Wise Users List'	

			Exec RBAC_SPGetRoleWiseUserReport @XMLFilters='',@Channel=@Channel,@Version='',@UserCode=@UserCode	
			Return
		End
		Else
		Begin
			Raiserror('Please use download option(Excel).',16,1)
			Return
		End
	End	
	Else If @RptType In(19)--Rbac-User Wise All Modules
	Begin
		If @RptFileType=3
		Begin
			Select @ReportCaption='User Wise All Modules'	

			Exec RBAC_UserWiseModuleReport @XMLFilters='',@Channel=@Channel,@Version='',@UserCode=@UserCode
			Return
		End
		Else
		Begin
			Raiserror('Please use download option(Excel).',16,1)
			Return
		End
	End	
	Else If @RptType In(20)--Rbac-Department Wise Spoc Details
	Begin
		If @RptFileType=3
		Begin
			Select @ReportCaption='Department Wise Spoc Details'	

			Exec RBAC_SPGetSpocDetails @XMLFilters='',@Channel=@Channel,@Version='',@UserCode=@UserCode	
			Return
		End
		Else
		Begin
			Raiserror('Please use download option(Excel).',16,1)
			Return
		End
	End	
	Else If @RptType In(21)--Rbac-Modules Details
	Begin
		If @RptFileType=3
		Begin
			Select @ReportCaption='Modules Details'	

			Exec RBAC_SPGetDepartmentModules @XMLFilters='',@Channel=@Channel,@Version='',@UserCode=@UserCode	
			Return
		End
		Else
		Begin
			Raiserror('Please use download option(Excel).',16,1)
			Return
		End
	End	

	Select @HiddenCols as HiddenCols,@RightAlignCols as RightAlignCols 
	Select @HtmlOutput as HTMLOutput
	
	SELECT'<html><header><img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTh5dX8hbusCfKkLhQFasGj5Ro1P2gVV-FGcQ&s">'+
	+'Geojit Financial Services Limited (GFSL)</header></html>',

	'Report1.xlsx','1|UsersDtl' 
	

	Set NoCount Off
End
GO
