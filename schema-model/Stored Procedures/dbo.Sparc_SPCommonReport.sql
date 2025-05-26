SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Proc [dbo].[Sparc_SPCommonReport]
(  
	@FromDate		DateTime,  
	@ToDate			DateTime,  
	@VenueID		Int,  
	@ReportType		Int,  
	@VorE			Varchar(10),  
	@Euser			Varchar(25) ,
	@RptFileType	Int=0,
	@Channel		Int=1
)  
As  
/*************************************************************************************************************************************** 
Created By	  : Vidhya Rajesh & Paul Mathew
Created on    : 16.09.2021 
Project       : SPARC 
Purpose       : For Common Report Module 
Test		  : exec Sparc_SPCommonReport @fromDate='20240801',@toDate='20240801',
				@VenueID=0,@reportType=14,@VorE='E',@Euser='git',
				@RptFileType=3,@Channel=5

18.07.2023	:	MOD:001	By 16593	-	Result set change for Custody -> Settlement Master (OLD SAPRC)
***************************************************************************************************************************************/  
Begin  
	Set NoCount On 

	Declare @HtmlOutput Varchar(1) ='N',@HiddenCols Varchar(max) ='',@RightAlignCols Varchar(max) ='',@SBBranch Varchar(100)='',
	@ReportCaption Varchar(Max)='',@Region Varchar(100)='',@Location Varchar(100)=''

	If @ReportType In(1)--getting settlement details
	Begin	
		/*MOD:001*/
		If IsNull(@Channel,0)=1
		Begin
			Set @RptFileType = 2
		End

		If @RptFileType Not In(2,3) And @Channel=5
		Begin
			Select @ReportCaption='Settlement Master for the period '+Convert(Varchar(10),@FromDate,105)+ ' to '+Convert(Varchar(10),@ToDate,105)

			Exec SPARCV5_SPGetReportHeader @ReportCaption=@ReportCaption,@UserCode=@Euser,@Region=@Region,@Location=@Location, 
			@SBBranch=@SBBranch,@Exchange=@VenueID,@ShowCompanyAddress='',@ShowSubBrokerAddress='N' 
		End

	
		Select Exchange, SttlNo, SttlType, FromDate, ToDate, PayinDate, PayoutDate, AuctionSttlNo as AuctSttlNo, AuctionSttlType as AuctSttlType, 
		AuctOfferDate, AuctionDate, Category
		From
		(
			Select S.VenueID,V.VenueCode as Exchange,LTrim(S.SttlNo) as SttlNo,S.SttlType,Convert(Varchar(10),S.FromDate,103) as FromDate,
			Convert(Varchar(10),S.ToDate,103) as ToDate,Convert(Varchar(10),S.PayinDate,103) as PayinDate,
			Convert(Varchar(10),S.PayoutDate,103) as PayoutDate,Ltrim(S.AuctionSttlNo) as AuctionSttlNo,		
			Case When (S.VenueID=1 and S.SttlType In('N','M')) Then 'A' 
			When (S.VenueID=1 and S.SttlType In('W','Z')) Then 'X'  When (S.VenueID=2 and S.SttlType='C') Then 'AC' 
			When (S.VenueID=2 and S.SttlType='D') Then 'AD' When (S.VenueID=2 and S.SttlType='U') Then 'AU' 
			When (S.VenueID=2 and S.SttlType='V') Then 'AV'	Else '' End AuctionSttlType,		
			Convert(Varchar(10),S.AuctOfferTrdDate,103) as AuctOfferDate,
			Convert(Varchar(10),S.AuctionDate,103) as AuctionDate,
			Case When (Category='N' and PayinDate<@FromDate) Then 'Auction' 		
			
			When (Category='N' and PayinDate>=@FromDate) Then 'Normal' When Category='OFS' Then 'OFS' When Category='BB' Then 'Buy Back' 
			When Category='PSN' Then 'Physical Settlement' Else Category End As Category
			From SPARC_SettlementMaster S Inner Join SPARC_VenueMaster V(Nolock) On(S.VenueID=V.VenueID) 
			Where S.VenueID=Case When @VenueID<>0 Then @VenueID Else S.VenueID End and
			((FromDate>=@FromDate and FromDate<=@ToDate) Or (AuctOfferTrdDate>=@FromDate and AuctOfferTrdDate<=@ToDate) Or (AuctionDate>=@FromDate 
			and AuctionDate<=@ToDate))
			and 1= Case When (S.SttlType In('A','X','AC','AD','AU','AV') and S.Category='N') Then 0 Else 1 End
			Union All
			Select S.VenueID,V.VenueCode as Exchange,'' As SttlNo,'' as SttlType,Convert(Varchar(10),S.TradeDate,103) as FromDate,
			Convert(Varchar(10),S.TradeDate,103) as ToDate,Convert(Varchar(10),S.PayinDate,103) as PayinDate,
			Convert(Varchar(10),S.PayinDate,103) as PayoutDate,'' as AuctionSttlNo,		
			'' as AuctionSttlType,'' as AuctOfferDate,'' as AuctionDate,
			'Normal' as Category
			From SPARC_FOSettlementMaster S(Nolock) Inner Join SPARC_VenueMaster V(Nolock) On(S.VenueID=V.VenueID) 
			Where S.VenueID=Case When @VenueID<>0 Then @VenueID Else S.VenueID End and
			(TradeDate>=@FromDate and TradeDate<=@ToDate)
			--Order By S.VenueID,S.TradeDate
		)X
		Order By X.VenueID,X.FromDate,X.SttlNo

		Select * From SPARC_Settings

		If Isnull(@Channel,0)=5/*MOD:001*/
		Begin
			Select  '' Exchange, '' SttlNo, '' SttlType,'' FromDate,'' ToDate,'' PayinDate, '' PayoutDate,''  AuctSttlNo, '' AuctSttlType,
			'' AuctOfferDate,'' AuctionDate,'' Category
		End

	End
	Else If @ReportType In(2)--Getting Master config details
	Begin
		If @RptFileType<>2  and @Channel=5
		Begin
			Select '' as HTMLContent
		End

		Select Convert(Varchar(10),FromDate,103) FromDate,Convert(Varchar(10),ToDate,103) ToDate,Parameter,Description,Value,Minimum
		From SPARC_Paramconfig(Nolock) Where Parameter not like 'Brok%' and ToDate>=@FromDate
		Order By ToDate Desc
	End
	Else If @ReportType In(3)--Custody > Exchage Reports > Holding Statemnt 
	Begin

		Create Table #Temp_ExgFullHolding
		(
			SlNo			Int Not Null Identity Primary Key,
			HoldDate		Datetime,
			ClientID		Int,
			TradeCode		Varchar(15),
			ClientName		Varchar(200),
			PAN				Varchar(15),
			DPClientID		Varchar(16),
			DPAccountType	Varchar(100),
			ISIN			Varchar(12),
			SecurityID		Int,
			SecurityCode	Varchar(200),
			SecurityType	Varchar(4),
			PledgedBalance	Numeric(18,3),
			FreeBalance		Numeric(18,3),
			SttlNo			Int,
			SttlType		Char(2),
			SecurityName	Varchar(200),
			HoldingStatus	Varchar(100)
		)

		Insert Into #Temp_ExgFullHolding
		(
		HoldDate,DPClientID,DPAccountType,TradeCode,ClientID,ClientName,PAN,ISIN,SecurityID,SecurityCode,SecurityType,
		PledgedBalance,FreeBalance,HoldingStatus
		)
		Exec SPSparc_GetExgHoldingFileUploadDtls @VenueID=@VenueID,@AsOnDate=@FromDate,@UserCode=@EUser,@VorG='S',@XMLString=''

		Update T Set T.SecurityType = S.ISINCategory From #Temp_ExgFullHolding T Inner join sparc_SecurityMultiISIN S (Nolock) on (S.ISIN = T.ISIN)

		Delete T From #Temp_ExgFullHolding T
		Where isnull(HoldingStatus,'') <> 'UNKNOWN' and Not Exists
		(
		Select Top 1 Null From SPARC_ClientMaster C Inner Join SPARC_ClientVenue CV On(C.ClientID=CV.ClientID)
		Inner Join SPARC_VenueMaster VM(Nolock) On(VM.VenueID=CV.VenueID )
		Where C.TradeCode=T.TradeCode and CV.Membership='Y' and VM.SPotVenueID=@VenueID
		)

		If @RptFileType<>2  and @Channel=5
		Begin
			Select '' as HTMLContent
		End

		Select * from #Temp_ExgFullHolding		
	End
	Else If @ReportType In(4)--Custody > Exchage Reports > Register of Securities(ROS) 
	Begin
		If @RptFileType<>2  and @Channel=5
		Begin
			Select '' as HTMLContent
		End
		Exec SPSparc_GetExgROSFileUploadDtls @VenueID=@VenueID,@FromDate=@FromDate,@ToDate=@ToDate,@UserCode=@Euser,@CallFromSP='Y'
	End
	Else If @ReportType In(5)--Admin > WhatsApp Logs
	Begin
		If @RptFileType<>2  and @Channel=5
		Begin
			Select '' as HTMLContent
		End

		Exec W_SPSummary @FromDate=@FromDate,@ToDate=@ToDate,@RptType=1,@TradeCode=''
		Set @HtmlOutput ='Y'
	End
	Else If @ReportType In(6)-- Audit Report
	Begin
		If @RptFileType<>2  and @Channel=5
		Begin
			Select '' as HTMLContent
		End

		Exec spSparc_Audit_TopMgnClient @FileTypeID=@ReportType,@FromDate = @FromDate,@ToDate=@ToDate,@VenueID=0,
		@TopN=2,@RptType='TOP_MONTHLY_MGN_CLIENTS'
	End
	Else If @ReportType In(7)-- AP Brokerage Sharing
	Begin
		If @RptFileType<>2  and @Channel=5
		Begin
			Select '' as HTMLContent
		End

		Exec SPSparc_APBrokeragesharePaid @Refno='SBBRKTDS',@FromDate=@FromDate,@Todate=@ToDate,@RefcodeBrkshare='99994',@Refcode='',@Euser	=@Euser
	End
	Else If @ReportType In(8)--Introducer Details
	Begin
		Exec SpGetSPARC_IntroducerDetails @IntroducerID='',@CompanyID=1,@Status=''
	End
	Else If @ReportType In(9)
	Begin
		If @RptFileType=0 and @Channel=5
		Begin
			Raiserror('Please use download option(Pdf).',16,1)
			Return
		End

		If @RptFileType<>2  and @Channel=5
		Begin
			Select '' as HTMLContent
		End

		Exec SPSPARC_SPGetSLBMHTMLDtls  @FromDate=@FromDate,@ToDate=@ToDate,@Product=1000,@SelectOutPut='Y',  
		@Type=0,@Debug='N',@Source='COMDCN',@UserCode=@Euser,@FromTradeCode='',@ToTradeCode='',@SingleFile='N',@MarginOnlyClients='B'  
	End
	Else If @ReportType In(11)
	Begin
		If @RptFileType=0 and @Channel=5
		Begin
			Raiserror('Please use download option(Pdf).',16,1)
			Return
		End

		If @RptFileType<>2  and @Channel=5
		Begin
			Select '' as HTMLContent
		End

		Select SlNo,TradeCode,HTMLContent,IsNull(TradeCode,'')+'.html' as FileName From SPARC_EmailReportLog (Nolock) 
		Where FromDate>=@FromDate and  FromDate<=@ToDate and TradeCode='KAM77' and ReportType='WEEKLYSOA'
		Order By TradeCode,FromDate,SlNo 
	End
	Else If @ReportType In(14)--Login History Details
	Begin
		If @RptFileType Not In(2,3) And @Channel=5
		Begin
			Select @ReportCaption='Login History for the period '+Convert(Varchar(10),@FromDate,105)+ ' to '+Convert(Varchar(10),@ToDate,105)
			Exec SPARCV5_SPGetReportHeader @ReportCaption=@ReportCaption,@UserCode=@Euser,@Region=@Region,@Location=@Location, 
			@SBBranch=@SBBranch,@Exchange='',@ShowCompanyAddress='',@ShowSubBrokerAddress='N' 
		End
		Exec SPARCV5_SPGetLoginHistory @FromDate=@FromDate,@ToDate=@ToDate,@Users='',@UserCode=@Euser		
		Return
	End	
	Else If @ReportType In(15)--Audit Trial Details
	Begin
		If @RptFileType=3
		Begin
			Select @ReportCaption='Audit Trial for the period '+Convert(Varchar(10),@FromDate,105)+ ' to '+Convert(Varchar(10),@ToDate,105)

			Exec SPARCV5_SPUserRightLogs @FromDate=@FromDate,@ToDate=@ToDate,@UserCode=@Euser	
			Return
		End
		Else
		Begin
			Raiserror('Please use download option(Excel).',16,1)
			Return
		End
	End	
	Else If @ReportType In(16)--Rbac-Module Wise Users List
	Begin
		If @RptFileType=3
		Begin
			Select @ReportCaption='Module Wise Users List'	

			Exec SPARCV5_SPGetModuleWiseUsers @XMLFilters='',@Channel=5,@Version='',@UserCode=@Euser
			Return
		End
		Else
		Begin
			Raiserror('Please use download option(Excel).',16,1)
			Return
		End
	End	
	Else If @ReportType In(17)--Rbac-Module Wise Roles List
	Begin
		If @RptFileType=3
		Begin
			Select @ReportCaption='Module Wise Roles List'	

			Exec SPARCV5_SPGetModuleWiseRoles @XMLFilters='',@Channel=5,@Version='',@UserCode=@Euser	
			Return
		End
		Else
		Begin
			Raiserror('Please use download option(Excel).',16,1)
			Return
		End
	End	
	Else If @ReportType In(18)--Rbac-Role Wise Users List
	Begin
		If @RptFileType=3
		Begin
			Select @ReportCaption='Role Wise Users List'	

			Exec SPARCV5_SPGetRoleWiseUserReport @XMLFilters='',@Channel=@Channel,@Version='',@UserCode=@Euser	
			Return
		End
		Else
		Begin
			Raiserror('Please use download option(Excel).',16,1)
			Return
		End
	End	
	Else If @ReportType In(19)--Rbac-User Wise All Modules
	Begin
		If @RptFileType=3
		Begin
			Select @ReportCaption='User Wise All Modules'	

			Exec [SPARCV5_UserWiseModuleReport] @XMLFilters='',@Channel=@Channel,@Version='',@UserCode=@Euser
			Return
		End
		Else
		Begin
			Raiserror('Please use download option(Excel).',16,1)
			Return
		End
	End	
	Else If @ReportType In(20)--Rbac-Department Wise Spoc Details
	Begin
		If @RptFileType=3
		Begin
			Select @ReportCaption='Department Wise Spoc Details'	

			Exec SPARCV5_SPGetSpocDetails @XMLFilters='',@Channel=@Channel,@Version='',@UserCode=@Euser	
			Return
		End
		Else
		Begin
			Raiserror('Please use download option(Excel).',16,1)
			Return
		End
	End	
	Else If @ReportType In(21)--Rbac-Modules Details
	Begin
		If @RptFileType=3
		Begin
			Select @ReportCaption='Modules Details'	

			Exec SPARCV5_SPGetDepartmentModules @XMLFilters='',@Channel=@Channel,@Version='',@UserCode=@Euser	
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
	
	Select '<html><header><img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTh5dX8hbusCfKkLhQFasGj5Ro1P2gVV-FGcQ&s">'+
	+'Geojit Financial Services Limited (GFSL)</header></html>','Report1.xlsx','1|UsersDtl' 
	

	Set NoCount Off
End
GO
