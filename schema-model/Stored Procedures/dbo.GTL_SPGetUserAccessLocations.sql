SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Proc [dbo].[GTL_SPGetUserAccessLocations]
(
	@CompanyID		Int,
	@LangID			Int,
	@UserCode		Varchar(25)
)as
/*****************************************************************************************************
Created By	:	Paul Mathew
Created	On	:	12.12.2023
Purpose		:	To fetch User access Locations 
Project		:	SPARCIM
Test		:	Exec GTL_SPGetUserAccessLocations @CompanyID=1,@LangID=1,@UserCode='GIT'
*****************************************************************************************************/
Begin
	Set NoCount On
	
	Declare @UserLevel Varchar(50),@SQL Varchar(Max),@AccessLocations Varchar(Max)='',@LocationID Int
	 
	Create Table #TempV5_Locations
	(
		Checked			Char(1),
		Description		Varchar(200),
		Location		Varchar(20),
		LocationID		Int,
		RegionID		Int
	)
	
	Select @UserLevel=Case When (IsNull(U.CorpUser,'')='Y' Or U.UserType='SB-SB') Then 'C' Else 'B' End
	From GTL_Users U(Nolock) Where U.UserCode=@UserCode

	--Selecting SBBranch as Location for Branch Level users
	If @UserLevel='B'
	Begin		
		Select @LocationID=LocationID From GTL_Users(Nolock) Where UserCode=@UserCode

		Insert Into #TempV5_Locations
		(
			Location,Description,Checked,LocationID,RegionID
		)
		Select B.BranchCode,B.Description,'N' as Checked,B.BranchID,0 From SPARC_SBBranch B(Nolock)
		Where B.LocationID=@LocationID and B.CompanyID=@CompanyID 
		
		Set @AccessLocations=''
		
		Select @AccessLocations=IsNull(L.AccessLocations,'') From GTL_wUserLocationsNew L(Nolock)
		Where L.UserCode=@UserCode and L.CompanyID=@CompanyID 
		
		If @AccessLocations<>''
		Begin
			Set @SQL='Update T set T.Checked=''Y'',T.LocationID=R.BranchID From #TempV5_Locations T  
			Inner Join SPARC_SBBranch (Nolock) R 
			On (R.CompanyID= ' + ltrim(@CompanyID) + ' and R.BranchID In ('+@AccessLocations+') and R.BranchCode=T.Location)'
			Exec (@SQL)
		End
		
		Update T Set T.RegionID=IsNull(L.SBRegionId,0) 
		From #TempV5_Locations T Inner Join SPARC_SBBranch L(Nolock) On(L.BranchID=T.LocationID and L.CompanyID=@CompanyID)		
	End
	Else
	Begin
		Insert Into #TempV5_Locations
		(
			Location,Description,Checked,LocationID,RegionID
		)
		Select L.Location,L.Description,'N' as Checked,L.LocationID,0 as RegionID From GTL_Location L(Nolock) 
		Where L.CompanyID=@CompanyID and L.LangId=@LangID

		Set @AccessLocations=''

		Select @AccessLocations=IsNull(AccessLocations,'') From GTL_wUserlocationsNew Where UserCode=@UserCode and CompanyID=@CompanyID 
		
		If @AccessLocations<>''
		Begin
			Set @SQL='Update T set T.Checked=''Y'',T.LocationID=R.LocationID From #TempV5_Locations T 
			Inner Join GTL_Location (Nolock) R
			On(R.CompanyID= ' + ltrim(@CompanyID) + ' and R.LocationID In ('+@AccessLocations+') and R.Location=T.Location)'
			Exec (@SQL)
		End

		Update T Set T.RegionID=IsNull(L.RegionID,0) From #TempV5_Locations T
		Inner Join GTL_Location (Nolock) L On(L.LocationID=T.LocationID and L.CompanyID=@CompanyID)
	End
	
	Select Row_Number() Over(Order By T.Description) as SlNo,T.Checked,T.Location,
	T.Description as [Location Name],T.LocationID,T.RegionID From #TempV5_Locations T 
	
	Set NoCount Off
End
GO
