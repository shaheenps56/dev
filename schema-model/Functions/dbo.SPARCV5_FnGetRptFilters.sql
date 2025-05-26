SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Function [dbo].[SPARCV5_FnGetRptFilters](@XMLFilters Varchar(Max)) Returns @Results Table 
(
	ColName Varchar(Max),
	ColValue Varchar(Max)
)   
As
/*****************************************************************************************************************
Created By	: Paul Mathew
Created on	: 08-11-2022
Project		: SPARC
Purpose		: For Setting report filter values from XML string
Test		: Select * From SPARCV5_FnGetRptFilters('<XMLDetails><XMLData><RegionID>1000</RegionID>
			  <LocationID>0</LocationID><SBBranchID>0</SBBranchID><ClientID>0</ClientID></XMLData></XMLDetails>')
******************************************************************************************************************/
Begin
	Declare @XMLDetails xml
	Select @XMLDetails = Cast(@XMLFilters as XML)

	Insert Into @Results(ColName,ColValue)
	Select Tabx.colx.value('local-name(.)', 'nvarchar(max)') as ColName,
	Tabx.colx.value('text()[1]', 'nvarchar(max)') as ColValue 
	from @XMLDetails.nodes('XMLDetails/XMLData/*') as Tabx(colx)

	


	/*
	@Results Table 
(
	RegionID Int,
	LocationID Int,
	SBBranchID Int,
	ClientID Int,
	TradeCode Varchar(15)
)  

	If LTrim(RTrim(IsNull(@XMLFilters,'')))=''
	Begin
		Insert Into @Results(RegionID,LocationID,SBBranchID,ClientID,TradeCode)
		Select 0 RegionID,0 LocationID,0 SBBranchID,0 ClientID,'' as TradeCode
	End
	Else
	Begin
		Select @XMLDetails = Cast(@XMLFilters as XML)

		Insert Into @Results(RegionID,LocationID,SBBranchID,ClientID,TradeCode)
		Select IsNull(RegionID,0) as RegionID,IsNulL(LocationID,0) as LocationID,
		IsNull(SBBranchID,0) as SBBranchID,IsNull(ClientID,0) as ClientID,IsNull(TradeCode,'') as TradeCode
		From (Select Cast(colx.query('data(RegionID)') as Varchar(100)) as RegionID,
		Cast(colx.query('data(LocationID)') as Varchar(100)) as LocationID,
		Cast(colx.query('data(SBBranchID)') as Varchar(100)) as SBBranchID,
		Cast(colx.query('data(ClientID)') as Varchar(100)) as ClientID,
		Cast(colx.query('data(TradeCode)') as Varchar(100)) as TradeCode
		From @XMLDetails.nodes('XMLDetails/XMLData') as Tabx(colx))T

		Update T Set T.ClientID=C.ClientID From @Results T Inner Join SPARC_ClientMaster C On(T.TradeCode=C.TradeCode)
		Where IsNull(T.TradeCode,'')<>'' and IsNull(T.ClientID,0)=0

		Update T Set T.TradeCode=C.TradeCode From @Results T Inner Join SPARC_ClientMaster C On(T.TradeCode=C.TradeCode)
		Where IsNull(T.ClientID,0)<>0 and IsNull(T.TradeCode,'')=''
	End
	*/
	/*
	Test 
	Declare @XML xml,@ColumnName Varchar(Max),@ColNames Varchar(Max)='',@SQL Varchar(Max)=''
	SET @XML = '<XMLDetails><XMLData><RegionID>1000</RegionID>
			<LocationID>0</LocationID><SBBranchID>0</SBBranchID><ClientID>0</ClientID><XXX>AMMMMMMM</XXX><YY>rrrr</YY></XMLData></XMLDetails>'

	Select Tabx.colx.value('local-name(.)', 'nvarchar(max)') as ColName,
	Tabx.colx.value('text()[1]', 'nvarchar(max)') as ColValue Into #Temp_XMLCols
	from @XML.nodes('XMLDetails/XMLData/*') as Tabx(colx)
	select * from #Temp_XMLCols
	Select @ColNames=@ColNames+','+ ColName +'' From #Temp_XMLCols Group By ColName

	Set @ColNames=SubString(@ColNames,2,Len(Rtrim(@ColNames)))


	Set @SQL='Select '+@ColNames+' From(Select ColName, ColValue From #Temp_XMLCols) D Pivot(Max(ColValue) For ColName In ('+@ColNames+')) as PvtCols;'
	Exec(@SQL)
	
	
	*/*/
	Return
End
GO
