SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Function [dbo].[Fn_GetUserQueryLevel]
(
	@UserCode Varchar(25),@XMLFilters Varchar(Max)
)Returns @AccessLevel Table
(
	UserType Varchar(100),
	QueryLevel Varchar(100),
	MaxQueryLevel Varchar(100),
	MaxFieldValue Varchar(100),
	FieldValue Int,
	QueryLevelID Int,
	MaxQueryLevelID Int,
	RegionID Int,
	LocationID Int,
	SBBranchID Int,
	Region Varchar(500),
	Location Varchar(500),
	SBBranch Varchar(500)
) 
As
/********************************************************************************
Created By	: Paul Mathew
Created on	: 23-09-2022
Project		: SPARCV5
Purpose		: For getting user query access level
Test		: Select * From dbo.Fn_GetUserQueryLevel('GIT',
			 '<XMLDetails>
			 <XMLData><RegionID>0</RegionID></XMLData>
			 <XMLData><LocationID>0</LocationID></XMLData>
			 <XMLData><SBBranchID>0</SBBranchID></XMLData></XMLDetails>')
**********************************************************************************/
Begin
	Declare @RegionID Int,@LocationID Int,@SBBranchID Int

	Select @RegionID=Case When ColName='RegionID' Then ColValue Else IsNull(@RegionID,0) End,
	@LocationID=Case When ColName='LocationID' Then ColValue Else IsNull(@LocationID,0) End,
	@SBBranchID=Case When ColName='SBBranchID' Then ColValue Else IsNull(@SBBranchID,0) End
	From SPARCV5_FnGetRptFilters(@XMLFilters)

	Insert Into @AccessLevel
	(
		UserType,QueryLevel,MaxQueryLevel,MaxFieldValue,FieldValue,QueryLevelID,MaxQueryLevelID,RegionID,LocationID,SBBranchID
	)
	Select Left(UserType,2) UserType,MaxQueryLevel,MaxQueryLevel,Case When MaxQueryLevel in ('CORPREGION','SBREGION') Then RegionId
	When MaxQueryLevel = 'SB' Then LocationID When MaxQueryLevel in ('CORPMULTI', 'SBMULTI') Then -2
	When MaxQueryLevel = 'CORP'	Then -1 When MaxQueryLevel = 'SBBRANCH'
	Then (Select L.LocationID From GTL_BranchWUserLocations L(Nolock) Where L.UserCode = U.UserCode)
	End as MaxFieldValue,
	Case Upper(MaxQueryLevel) When 'CORPREGION' Then RegionID When 'SBREGION' Then RegionID 
	When 'SBBRANCH' Then LocationID	When 'SB' Then LocationID When 'SBMULTI' Then LocationID 
	When 'CORP'	Then -1 Else 0 End As FieldValue,IsNull(L.ID,0) as QueryLevelID,IsNull(L.ID,0) as MaxQueryLevelID,
	@RegionID,@LocationID,@SBBranchID
	From GTL_Users U (Nolock) Inner Join SPARCV5_UserQueryLevel L(Nolock) On(L.Code=U.MaxQueryLevel)
	Where U.UserCode=@UserCode

	Update T Set T.FieldValue=
	Case When T.UserType='CO' Then 
		Case When @SBBranchID<>0 Then @SBBranchID When @LocationID<>0 Then @LocationID When @RegionID<>0 Then @RegionID Else -1 End
	When T.UserType='SB' Then --RegionID will be SBRegionID in this case
		Case When @SBBranchID<>0 Then @SBBranchID When @RegionID<>0 Then @RegionID When @LocationID<>0 Then @LocationID Else T.FieldValue End
	Else T.FieldValue End,
	T.QueryLevel=
	Case When T.UserType='CO' Then 
		Case When @SBBranchID<>0 Then 'SBBRANCH' When @LocationID<>0 Then 'SB' When @RegionID<>0 Then 'CORPREGION' Else 'CORP' End
	When T.UserType='SB' Then --RegionID will be SBRegionID in this case
		Case When @SBBranchID<>0 Then 'SBBRANCH' When @RegionID<>0 Then 'SBREGION' When @LocationID<>0 Then 'SB' Else 'SB' End
	Else T.QueryLevel End
	From @AccessLevel T
	
	Update T Set T.QueryLevelID=L.ID From @AccessLevel T Inner Join SPARCV5_UserQueryLevel L On(T.QueryLevel=L.Code)
	Update T Set T.QueryLevelID=T.MaxQueryLevelID From  @AccessLevel T Where T.QueryLevelID<T.MaxQueryLevelID

	Update T Set T.Region=R.Region From @AccessLevel T Inner Join GTL_Region R On(T.RegionID=R.RegionID)
	Update T Set T.Location=L.Location From @AccessLevel T Inner Join GTL_Location L On(T.LocationID=L.LocationID)
	Update T Set T.SBBranch=SB.BranchCode From @AccessLevel T Inner Join SPARC_SBBranch SB On(T.SBBranchID=SB.BranchID)
	Return
End
GO
