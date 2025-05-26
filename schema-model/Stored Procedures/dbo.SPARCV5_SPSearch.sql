SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Proc [dbo].[SPARCV5_SPSearch]
(
	 @SearchKey		Int,
	 @WhereClause	Varchar(Max)='',
	 @SearchValue	Varchar(Max),
	 @UserCode		Varchar(25)='',
	 @Version		Varchar(100),
	 @SearchMode	Varchar(100)='OnSearch',--OnSearch/OnLeave
	 @InitialSearch	Varchar(1)='Y'
)as
/**************************************************************************************************************
Created By	:	Paul Mathew
Created On	:	21-11-2021
Purpose		:	Common Search
Test		:	Exec SPARCV5_SPSearch @SearchKey=44,@WhereClause='B.Description Like ''h%'' And 1=1',
				@SearchValue='',@UserCode='GIT',@Version=''
***************************************************************************************************************/

Begin
	Set Nocount On
	Declare @QueryLevel Varchar(100),@QueryLevelID Int,@FieldValue Int,@SQL Varchar(8000),@GroupBy Varchar(8000),
	@OrderByClause Varchar(Max),@UserType Varchar(16),@SearchFields Varchar(8000),@RowLimit Int=20,
	@SearchCode Varchar(100)='',@LicenseCompanyName Varchar(50)=''
	
	Select  @LicenseCompanyName=LicenseCompanyName From SPARC_Settings(Nolock)
	Select @RowLimit=Case When @InitialSearch='Y' Then IsNull(InitialSearchRows,20) Else 10 End 
	From DPS_Settings(Nolock)

	Select @QueryLevel=QueryLevel,@QueryLevelID=QueryLevelID,@FieldValue=FieldValue From dbo.Fn_GetUserQueryLevel(@UserCode,'')

	Select @UserType=Left(UserType,2) From GTL_Users(Nolock) Where UserCode=@UserCode and CompanyID=1 

	Select @SearchValue=Replace(Replace(Replace(Replace(Replace(@SearchValue,'Delete',''),'Drop',''),'Truncate',''),
						'Update',''),'Insert','')
	Select @WhereClause=Replace(Replace(Replace(Replace(Replace(@WhereClause,'Delete',''),'Drop',''),'Truncate',''),
						'Update',''),'Insert','')

	If @SearchKey In(75,82) and @LicenseCompanyName='GFSL'
	Begin
		If IsNull(@WhereClause,'')<>''
		Begin
			Select @WhereClause=Replace(@WhereClause,'C.PANNumber','dbo.Enc_fnSKDecrypt(@EncType,
								C.PANNumber,C.PANNumber_ENC) ')
			Select @WhereClause=Replace(@WhereClause,'C.MobileNo','dbo.Enc_fnSKDecrypt(@EncType,
						C.MobileNo,C.MobileNo_ENC) ')
			Select @WhereClause=Replace(@WhereClause,'C.Email','dbo.Enc_fnSKDecrypt(@EncType,
			C.Email,C.Email_ENC) ')
		End
	End

	If @SearchKey=5 and @UserType<>'CO' --Region search is changing to  SBRegion search based on user type
	Begin
		Set @SearchKey=78
		Set @WhereClause=@WhereClause+Case When IsNull(@WhereClause,'')<>'' Then ' and ' Else '' End+
		Case When @QueryLevelID>=25 Then ' D.AllLocationID=SB.BranchID ' Else ' D.AllLocationID=SB.LocationID ' End--(>'SBMULTI') 
	End
	Else If @SearchKey=44 
	Begin
		--Location filter missing in below query. need to add later
		Set @WhereClause=@WhereClause++Case When IsNull(@WhereClause,'')<>'' Then ' and ' Else '' End+
		Case When @QueryLevelID>=25 Then ' D.AllLocationID= B.BranchID ' Else ' D.AllLocationID= B.LocationID ' End--(>'SBMULTI') 
	End
	
	Select @SQL=Search_Query,@GroupBy=IsNull(GroupBy,''),@OrderByClause=IsNull(OrderBy,''),
	@SearchFields=IsNull(SearchFields,''),@SearchCode=IsNull(SearchCode,'') 
	From SPARCV5_Search(Nolock) Where Search_Key=@SearchKey    

	If @SearchKey In(75,82) and @LicenseCompanyName='GFSL'
	Begin
		If IsNull(@SearchValue,'')<>''
		Begin
			Select @SearchFields=Replace(@SearchFields,'C.PANNumber','dbo.Enc_fnSKDecrypt(@EncType,
								C.PANNumber,C.PANNumber_ENC) ')
			Select @SearchFields=Replace(@SearchFields,'C.MobileNo','dbo.Enc_fnSKDecrypt(@EncType,
						C.MobileNo,C.MobileNo_ENC) ')
			Select @SearchFields=Replace(@SearchFields,'C.Email','dbo.Enc_fnSKDecrypt(@EncType,
			C.Email,C.Email_ENC) ')
		End

	End


	If CharIndex('@UserType',@SQL)<>0 or CharIndex('@UserCode',@SQL)<>0 
	Begin  
		Set @UserCode=''+@UserCode +''  
		Set @UserType=''+@UserType +''  
		Set @SQL=Replace(Replace(@SQL,'@UserType',@UserType),'@UserCode', @UserCode)  
	End
	
	If @SQL<>''     
	Begin   
		If @WhereClause<>''     
		Begin         
			If CharIndex('Where ',@SQL)>0 
				Set @SQL= @SQL + ' and ' + @WhereClause          
			Else          
				Set @SQL=@SQL + ' Where ' + @WhereClause 
		End     
		
		If IsNull(@SearchValue,'')<>'' and IsNull(@SearchFields,'')<>''    
		Begin   
			If @SearchMode='OnLeave'
			Begin
				If CharIndex('Where ',@SQL)>0 
					Set @SQL= @SQL + ' and ' + @SearchCode+'='''+@SearchValue+''''         
				Else          
					Set @SQL=@SQL + ' Where ' + @SearchCode+'='''+@SearchValue+'''' 
			End
			Else
			Begin
				If CharIndex('Where ',@SQL)>0 
					Set @SQL= @SQL + ' and ' + @SearchFields+' like ''%'+@SearchValue+'%'''         
				Else          
					Set @SQL=@SQL + ' Where ' + @SearchFields+' like ''%'+@SearchValue+'%''' 
			End
		End  

		If @GroupBy<>''     
		Begin          
			Set @SQL= @SQL + ' Group By ' + @GroupBy 
		End          
		If @OrderByClause<>''     
		Begin    
			Set @SQL= @SQL + ' Order By ' + @OrderByClause          
		End          

		If CharIndex('Distinct',@SQL)=0     
		Begin  
			Set @SQL='Select Top '+LTrim(@RowLimit)+' '+Right(LTrim(@SQL),Len(@SQL)-(PatIndex('%Select %',@SQL)+5))
		End 
		If @SearchKey In(75,82) and @LicenseCompanyName='GFSL'
		Begin
			Set @SQL=' Declare @EncType Varchar(100)
			Exec Enc_SPOpenSK @EncType=@EncType Output '+@SQL+' Exec Enc_SPCloseSK @EncType '
		ENd

		Exec(@SQL)  

		Select HiddenCols as HiddenCol,HeaderText as HeaderText,ColName 
		From SPARCV5_Search(Nolock) Where Search_Key=@SearchKey   
	End 
	Set Nocount Off
End
GO
