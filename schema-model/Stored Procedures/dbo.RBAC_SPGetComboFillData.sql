SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE   Proc [dbo].[RBAC_SPGetComboFillData]  
(  
 @UserCode  Varchar(25),  
 @Code   Int,  
 @WhereClause Varchar(500)='',    
 @ShowAll  Char(1)='N',    
 @TableName  Varchar(100)='',  
 @Version  Varchar(100)='',  
 @XMLFilters     Varchar(max)=''  
)as  
/************************************************************************************************  
Created By : Paul Mathew  
Created On : 23-09-2022  
Purpose  : Get Combo FillData  
--Test  : Exec RBAC_SPGetComboFillData 'GIT',10223,'','N','',''  
*************************************************************************************************/  
Begin  
	Set Nocount On  
  
	Declare @Channel Int,@LicenseCompanyName Varchar(500)='', @FullAccessUsers Varchar(Max)=''

	Select @FullAccessUsers=IsNull(Value,'') From GTL_AppConfig A(Nolock)
	Where A.Parameter='FULLACCESSUSERS' and GetDate() Between FromDate and ToDate
   
	Select @LicenseCompanyName=LicenseCompanyName From Sparc_Settings(Nolock)  
	If @Code=10045 --Exchange Reports      
	Begin      
		Select 0 as Code,'All' As Description      
      
		Set @WhereClause=Replace(@WhereClause,'Where','')      
		Select Code as RptTypeID,Description as RptType,IsNull(ShowtoDate,'N') as ShowToDate,      
		IsNull(FromDateCaption,'') FromDateCaption,IsNull(ToDateCaption,'') ToDateCaption,      
		LTrim(IsNull(GroupCode,'')) As RptCategory,'N' as ShowVenue,'Y' as ShowRptType      
		From SPARCIM..SPARC_CommonReportTypeConfig(Nolock)       
		Where Active='Y' and      
		LTrim(IsNull(GroupCode,''))=Case When Ltrim(@WhereClause) Not In('')       
		Then Ltrim(@WhereClause) Else LTrim(RTrim(IsNull(GroupCode,''))) End      
		Order by SortOrder  
      
		Select *  From SPARCV5_FnGetRptType(@UserCode,@Channel)      
	End    
	Else If @Code=10201 -- Rbac -> User department  
	Begin    
		Exec GTL_SPSaveDepartment @Purpose='L',@XMLFilters='',@XMLString='',  
		@Channel=@Channel,@Version=@Version,@UserCode=@UserCode  
	End  
	Else If @Code=10203 -- For Rbac->Module Edit  
	Begin  
		Exec SPARCV5_SPModuleEdit @XMLFilters='',@XMLString='',@Purpose='L',@Version=@Version,   
		@Channel=@Channel,@UserCode=@UserCode  
	End

	Else If @Code=10184  
	Begin  
		Select 'Profile' As Tab1Caption, 'Allocated Regions' As Tab2Caption,    
		'Allocated Locations' As Tab3Caption,'Security' As Tab4Caption,    
		'Password Policy' As Tab5Caption, 'Allocated Roles' As Tab6Caption,'Additional Client Mapping' As Tab7Caption  
      
		Select 'UserID' Code,'UserName' Description,126 SearchKey,'UserID' SearchOPID,  
		'UserCode' SearchOPCode, 'UserName' SearchOPDesc,'User Search' as SearchPageHeader  
      
		Select * From SPARCV5_FnGetCommonComboList('Location')    
     
		Select 193 SearchKey,'GroupID' SearchOPID,  
		'GroupID' SearchOPCode, 'Description' SearchOPDesc,'Role Search' as SearchPageHeader  
      
		Select A.Code,A.Description,Case When Code='S' Then 'Y' Else 'N' End as ShowMappingTab,  
		Case When Code='Y' Then 'N' Else 'Y' End as DisableAllLocAccess,  
		Case When Code<>'Y' Then 'Y' Else 'N' End as ValidateLocation  ,
		Case When Code='S' Then 'N' When Code='N' Then 'Y' When Code='S' Then 'N' End as EnableLocation
		From GTL_UserAccessLevel A(Nolock)  
   
		Select Row_Number() Over(Order By RegionID Desc)SlNo,'N' Checked,RegionID,Region,    
		Description [Region Name] From GTL_Region (Nolock)    
    
		Select Row_Number() Over(Order By LocationID Desc)SlNo,'N' Checked,LocationID,Location,    
		Description [Location Name],RegionID,Case When BRANCH='N' Then 'Franchisee' Else 'Branch' End  
		[Branch Or Franchisee] From GTL_LOCATION (Nolock)     
    
		Select 'N' Checked,'LowerCase' Code,'Lower Case  Alphabetic Letters' As Description Union All    
		Select 'N' Checked,'UpperCase' Code,'Upper Case  Alphabetic Letters' As Description Union All    
		Select 'N' Checked,'Numeric' Code,'Numeric Characters' As Description Union All    
		Select 'N' Checked,'NonAlphaNumeric' Code,'Non AlphaNumeric Letters' As Description    
          
		--XML cols for Region table  
		Select '' RegionID    
  
		--XML cols for Location table  
		Select '' LocationID    
    
		--Style cols for Region& Location  
		Select ''RightAlignCols,''LinkCols,'N' HTMLOutput, 'SlNo,RegionID,LocationID' HiddenCols,  
		'#e9ecef' SelectedRowColor   
    
		Select Case When @UserCode In(Select Value From String_Split(@FullAccessUsers,',')) 
		Then 'N' Else 'Y' End as DisableUser,'N' as DisableAccessLevel  
  
		Select 0 as Code,'' as Description Union All  
		Select D.DepartmentID as Code,D.DepartmentDesc as Description From GTL_Department D(Nolock)  
  
		--Table details for Roles  
		Select '' [Role],'' as [Primary],'' [Description],'' as Button,'' GroupID
  
		Select '' [Role],'' as [Primary],'' [Description],'' as Button,'' GroupID

		--Style cols for Roles  
		Select ''RightAlignCols,''LinkCols,'N' HTMLOutput, 'GroupID' HiddenCols,  
		'#e9ecef' SelectedRowColor   
  
	End  
	Else If @Code=10185  
	Begin  
		Exec GTL_SPUserRights @GroupID=0,@ProjectID=0,@AccessProjects='',@XMLFilters='',  
		@UserAuthorization='',@Version='',@Channel=5,@Purpose='L',@UserCode=@UserCode    
	End   
	Set Nocount Off   
End
GO
