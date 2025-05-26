SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Proc [dbo].[GTL_SPGetUserAccessRegions]  
(  
 @CompanyID  Int,  
 @LangID   Int,  
 @UserCode  Varchar(25)  
) as  
/**********************************************************************************************************  
Created By : Paul Mathew  
Created On : 12.12.2023  
Purpose  : Top fetch User acess Regions   
Project  : SPARCIM  
Test  : Exec GTL_SPGetUserAccessRegions @LangID=1,@CompanyID=1,@UserCode='natarajan'  
**********************************************************************************************************/  
Begin  
 Set NoCount On  
  
 Declare @UserLevel Varchar(10),@SQL Varchar(Max),@AccessRegions Varchar(Max)='',@LocationID Int,  
 @Location Varchar(50)  
   
 Create Table #TempV5_UserRegions  
 (  
  Checked   Varchar(1),  
  Description  Varchar(200),  
  Region   Varchar(20),  
  RegionID  Int  
 )  
  
 Select @UserLevel=Case When (IsNull(U.CorpUser,'')='Y' or U.UserType='SB-SB') Then 'C' Else 'B' End   
 From GTL_Users U(Nolock) Where U.UserCode=@UserCode  
  
 If @UserLevel='B'  
 Begin   
  
  Select @LocationID=U.LocationID From GTL_Users U(Nolock) Where U.UserCode=@UserCode  
  Select @Location=L.Location From GTL_Location L(Nolock) Where L.LocationID=@LocationID  
  
  Insert Into #TempV5_UserRegions  
  (  
   Region,Description,Checked,RegionID  
  )  
  Select R.Region,R.Description,'N' as Checked,R.RegionID From SPARC_SBregion R(Nolock)   
  Where R.SubBrokerCode=@Location  
  
  Select  @AccessRegions=@AccessRegions+','+Ltrim(L.RegionID) From GTL_wUserlocationsNew L(Nolock)    
  Where L.CompanyID=@CompanyID And L.UserCode=@UserCode   
    
  IF @AccessRegions<>''  
  Begin  
   Set @SQL='Update T set T.Checked=''Y'' From #TempV5_UserRegions T   
   Inner Join SPARC_SBregion (Nolock) R   
   On(R.RegionID In ('+Ltrim(Substring(@AccessRegions,2,len(@AccessRegions)))+') And R.Region=T.Region)'  
   Exec(@SQL)  
  End   
 End  
 Else  
 Begin   
  Insert Into #TempV5_UserRegions  
  (  
   Region,Description,Checked,RegionID  
  )  
  Select R.Region,R.Description,'N' as Checked,R.RegionID From GTL_Region R(Nolock)   
  Where R.CompanyID=@CompanyID And R.LangID=@LangID  
  
  Select  @AccessRegions=@AccessRegions+','+Ltrim(L.RegionID) From GTL_wUserlocationsNew L (Nolock)   
  Where L.CompanyID=@CompanyID And L.UserCode=@UserCode   
    
  If @AccessRegions<>''  
  Begin  
   Set @SQL='Update T set T.Checked=''Y'' From #TempV5_UserRegions T Inner Join GTL_region (Nolock) R    
   On(R.CompanyID= ' + ltrim(@CompanyID) + ' and R.RegionID In ('+Ltrim(Substring(@AccessRegions,2,len(@AccessRegions)))+')   
   and R.Region=T.Region)'  
   Exec(@SQL)  
  End    
 End  
  
 Select Row_Number() Over(Order By T.Description) as SlNo,T.Checked,T.Region,  
 T.Description as [Region Name],T.RegionID From #TempV5_UserRegions T   
  
 Set NoCount Off  
End
GO
