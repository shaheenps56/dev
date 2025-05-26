SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE Proc [dbo].[SPARC_SPProcessCommonAPIRequest]
(
	@RequestType		Varchar(100),
	@JSonRequest		Varchar(Max),
	@RequestSource		Varchar(100),
	@RequestIP			Varchar(100),
	@RequestUser		Varchar(100),
	@Token				Varchar(Max)
)as
/**********************************************************************************************************
Created By	:	Paul Mathew
Created On	:	27.05.2023
Project		:	SPARCIM
Purpose		:	For Processing common API request
Test		:	Exec SPARC_SPProcessCommonAPIRequest @RequestType='FOSCRIPAVGRATE',@JSonRequest='
				{
				"TranDate": "20230701",
				"UserCode": "GIT",
				"TradeCode": "J2191",
				"Segment": "FO",
				"SecurityCode": "NIFTY",
				"ExpiryDate": "20230628",
				"StrikePrice": "19000",
				"OptionType": "PE"
				}',@RequestSource='',@RequestIP='',@RequestUser='',@Token=''

				Exec SPARC_SPProcessCommonAPIRequest @RequestType='CMSCRIPAVGRATE',@JSonRequest='
				{
				"TranDate": "20230626",
				"UserCode": "GIT",
				"TradeCode": "PM1686",
				"Segment": "CM",
				"SecurityCode": "RELCAPITAL"
				}',@RequestSource='',@RequestIP='',@RequestUser='',@Token=''

				Exec SPARC_SPProcessCommonAPIRequest @RequestType='DUPLICATEVALIDATION',@JSonRequest='
				{
				"PhoneNo": "",
				"EmailId": "PaulMathew4Ever@gmail.com"
				}',@RequestSource='',@RequestIP='',@RequestUser='',@Token=''

				Exec SPARC_SPProcessCommonAPIRequest @RequestType='CRM_GetClientInfo',@JSonRequest='
				{
				"FromDate": "20240905",
				"ToDate": "20240905",
				"TradeCode": ""
				}',@RequestSource='',@RequestIP='',@RequestUser='',@Token=''
***********************************************************************************************************/
Begin
	Set Nocount On

	Create Table #Temp_JsonRequest(JSonRequest Varchar(Max))

	Insert Into #Temp_JsonRequest(JSonRequest)
	Select @JSonRequest

	If @RequestType In('USERMASTER')
	Begin
		Select Top 10 USERCODE,USERNAME,EmailID,Designation,CompanyState from GTL_USERS
	End

	If @RequestType In('CMSCRIPAVGRATE','FOSCRIPAVGRATE')
	Begin
		Declare @TranDate Datetime,@TradeCode Varchar(15),@SecurityCode Varchar(100),
		@Segment Varchar(50),@ClientID Int,@ExpiryDate Varchar(10),@StrikePrice Numeric(18,6),@OptionType Varchar(50)

		Create Table #TempV5_AvgRate
		(
			TranDate Datetime,
			SaudaType Varchar(100),
			BuyQty Numeric(18,3),
			BuyRate Numeric(18,2),
			BuyValue Numeric(18,2),
			SellQty Numeric(18,3),
			SellRate Numeric(18,2),
			SellValue Numeric(18,2),
		)

		Select @TranDate=RA.TranDate,@TradeCode=RA.TradeCode,@SecurityCode=RA.SecurityCode,@Segment=RA.Segment,
		@ExpiryDate=RA.ExpiryDate,@StrikePrice=RA.StrikePrice,@OptionType=RA.OptionType
		From #Temp_JsonRequest T 
		Cross Apply OpenJSon(JSonRequest) With
		(
   			TranDate       Varchar(Max)   '$.TranDate', 
			TradeCode      Varchar(Max)   '$.TradeCode', 
			SecurityCode   Varchar(Max)   '$.SecurityCode',
			Segment   	   Varchar(Max)   '$.Segment',
			OptionType     Varchar(Max)	  '$.OptionType',
			StrikePrice    Varchar(Max)	  '$.StrikePrice',
			ExpiryDate     Varchar(Max)	  '$.ExpiryDate',
			UserCode   	   Varchar(Max)   '$.UserCode'
		) as RA
		Where isJSon(T.JSonRequest)>0

		Select @ClientID=ClientID From SPARC_ClientMaster C(Nolock) Where C.TradeCode=@TradeCode

		If IsNull(@ClientID,0)=0
		Begin
			Raiserror('Invalid client.',16,1)
			Return
		End

		If IsNull(@SecurityCode,'')=''
		Begin
			Raiserror('Invalid security.',16,1)
			Return
		End
		If @RequestType='CMSCRIPAVGRATE'
		Begin			
			Exec SpSPARC_GetTradingPandL @ClientID=@ClientID,@FromDate=@TranDate,@ToDate=@TranDate,@ReportType='CM',@Source='CC',
			@VenueID=0,@SecCode=@SecurityCode,@ExpDate='',@OptionType='',@StrikePrice=0,@Debug='N',@PandLType='ABS',@Summary='N',
			@ReportSubType='CMAVGRATE-API'

			Select Convert(Varchar(10),TranDate,105) as TranDate,@TradeCode as TradeCode,@SecurityCode as SecurityCode,
			BuyQty,BuyRate,BuyValue,SellQty,SellRate,SellValue From #TempV5_AvgRate
		End
		Else
		Begin
			Exec SpSPARC_GetTradingPandL @ClientId=@ClientID,@FromDate=@TranDate,@ToDate=@TranDate,@ReportType='FO',@Source='CC',
			@VenueID=0,@SecCode=@SecurityCode,@ExpDate=@ExpiryDate,@OptionType=@OptionType,@StrikePrice=@StrikePrice,
			@Debug='N',@PandLType='ABS',@Summary='N',@ReportSubType='FOSCRIPAVGRATE-API'

			Select Convert(Varchar(10),TranDate,105) as TranDate,@TradeCode as TradeCode,@SecurityCode as SecurityCode,
			Convert(Varchar(10),Cast(@ExpiryDate as Datetime),105) as ExpiryDate,@StrikePrice as StrikePrice,@OptionType as OptionType,
			BuyQty,BuyRate,BuyValue,SellQty,SellRate,SellValue From #TempV5_AvgRate
		End
	End
	Else If @RequestType In('CRM_GetClientInfo')
	Begin
		Declare @FromDate Datetime,@ToDate Datetime,@AsOnDate Datetime,@LastTradeDate Datetime

		Select @FromDate=Case When IsNull(J.FromDate,'')<>'' Then J.FromDate Else Null End,
		@ToDate=Case When IsNull(J.ToDate,'')<>'' Then J.ToDate Else Null End,
		@TradeCode=J.TradeCode	From #Temp_JsonRequest T 
		Cross Apply OpenJSon(JSonRequest) With
		(
   			FromDate       Varchar(20)     '$.FromDate',
			ToDate         Varchar(20)     '$.ToDate', 
			TradeCode      Varchar(Max)    '$.TradeCode'
		) as J
		Where isJSon(T.JSonRequest)>0

		If IsNull(@FromDate,'')=''
		Begin
			Raiserror('Invalid FromDate.',16,1)
			Return
		End
		Else If IsNull(@ToDate,'')=''
		Begin
			Raiserror('Invalid ToDate.',16,1)
			Return
		End

		Create Table #Temp_CRMDetails
		(
			TradeCode	Varchar(15),
			TranType	Varchar(10),
			TranDate	Datetime,
			Amount		Numeric(18,2),
			TotalBrk	Numeric(18,2),
			NoOfOrders	Int,
			Ledger		Numeric(18,2)
		)
		Create Table #AccountCode
		(
			ClientID		Int,
			AccountCode		Int,
			Balance			Numeric(18,2) not null default 0,
			PendBalance		Numeric(18,2) not null default 0,
			Venueid			Int,
			Product			Int
		)
		Create Table #Temp_ClientList
		(
			TradeCode		Varchar(15),
			ClientID		Int
		)

		Select @LastTradeDate=Max(TranDate),@AsOnDate=Convert(Varchar(10),GetDate(),111)
		From SPARC_TradeVouchers S(Nolock) Where S.TranDate>=GetDate()-10

		Insert Into #Temp_CRMDetails
		(
			TradeCode,TranType,TranDate,Amount
		)
		Select F.TradeCode,F.TranType,Convert(Varchar(10),F.TranDate,105) as TranDate,F.Amount
		From CRM_ClientInitialTransaction F (Nolock)
		Where TranDate>=@FromDate and TranDate<=@ToDate and 
		F.TradeCode=Case When IsNull(@TradeCode,'')<>'' Then @TradeCode Else F.TradeCode End

		Insert Into #Temp_ClientList(ClientID,TradeCode)
		Select C.ClientID,C.TradeCode 
		From SPARC_ClientMaster C(Nolock) 
		Where Exists(Select Top 1 Null From #Temp_CRMDetails T Where C.TradeCode=T.TradeCode)

		Insert Into #AccountCode(ClientID,AccountCode,VenueID)
		Select C.ClientID,C.ClientID as AccountCode,V.VenueID
		From #Temp_ClientList C(Nolock) Inner Join SPARC_ClientVenue V On(C.ClientID=V.ClientID)

		Exec SpSPARCGetClearedBalance @CompanyID=1,@AsOnDate=@AsOnDate,@Filter='Y',@BalanceType='E',
		@ConvertToSingleCurrency='N',@LocationID=0,@CurrencyID=1,@LangID=1,@IncludePend='N'

		Update T Set T.Ledger=X.Ledger
		From #Temp_CRMDetails T Inner Join  #Temp_ClientList C On(T.TradeCode=C.TradeCode)
		Inner Join(Select A.ClientID,Sum(Balance) as Ledger From #AccountCode A Group By A.ClientID)X
		On(C.ClientID=X.ClientID)

		Update T Set T.TotalBrk=X.TotalBrk,T.NoOfOrders=X.NoOfOrders
		From #Temp_CRMDetails T Inner Join
		(
			Select D.TradeCode,Sum(IsNull(D.TotalBrk,0)) as TotalBrk,Sum(IsNull(D.NoOfOrders,0)) as NoOfOrders  
			From Sparc_FOClientMarginDtl D (Nolock) Inner Join #AccountCode A On(D.ClientID=A.ClientID)
			Where D.TranDate=@LastTradeDate
			Group By D.TradeCode
		)X On(T.TradeCode=X.TradeCode)

		Select T.TradeCode,T.TranType,Convert(Varchar(10),T.TranDate,105) as TranDate,T.Amount,
		IsNull(T.TotalBrk,0) as Brokerage,IsNull(T.NoOfOrders,0) as NoOfOrders,IsNull(T.Ledger,0) as Ledger
		From #Temp_CRMDetails T
	End
	Else If @RequestType In('VALIDATECLIENT')
	Begin
		Declare @Key Varchar(100)='',@Value Varchar(100)='',@Response Varchar(8000)=''

		Create Table #Temp_ClientValidation
		(
			SKey	Varchar(100),
			Value	Varchar(100)
		)

		Select @Key=J.SKey,@Value=J.Value From #Temp_JsonRequest T 
		Cross Apply OpenJSon(JSonRequest) With
		(
   			SKey       Varchar(100)   '$.Key', 
			Value      Varchar(100)   '$.Value'
		) as J
		Where isJSon(T.JSonRequest)>0

		If IsNull(@Key,'') Not In('TradeCode','MobileNo','EmailID','PAN')
		Begin
			Raiserror('Invalid key.',16,1)
			Return
		End
		
		If @Key='TradeCode'
		Begin
			Select @Response='TradeCode '+LTrim(@Value) +' is already exists in back office.'   
			From SPARC_ClientMaster C(Nolock) Where C.AcceptanceStatus<>'T' and  C.TradeCode=LTrim(RTrim(@Value)) and @Key='TradeCode'

			Select @Response='TradeCode '+LTrim(@Value) +' is already exists in back office.'   
			From SPARC_ClientMaster_Pending C(Nolock) Where C.AcceptanceStatus<>'T' and  C.TradeCode=LTrim(RTrim(@Value)) and
			@Key='TradeCode' and IsNull(@Response,'')=''
		End
		Else If @Key='MobileNo'
		Begin
			Select @Response='MobileNo '+LTrim(@Value) +' is already exists in back office for client '+LTrim(C.TradeCode)+'.'   
			From SPARC_ClientMaster C(Nolock) Where C.AcceptanceStatus<>'T' and C.MobileNo=LTrim(RTrim(@Value)) and @Key='MobileNo'

			Select @Response='MobileNo '+LTrim(@Value) +' is already exists in back office for client '+LTrim(C.TradeCode)+'.'   
			From SPARC_ClientMaster_Pending C(Nolock) Where C.AcceptanceStatus<>'T' and C.MobileNo=LTrim(RTrim(@Value)) and 
			@Key='MobileNo' and IsNull(@Response,'')=''
		End
		Else If @Key='EmailID'
		Begin
			Select @Response='EmailID '+LTrim(@Value) +' is already exists in back office for client '+LTrim(C.TradeCode)+'.'   
			From SPARC_ClientMaster C(Nolock) Where C.AcceptanceStatus<>'T' and C.Email=LTrim(RTrim(@Value)) and @Key='EmailID'

			Select @Response='EmailID '+LTrim(@Value) +' is already exists in back office for client '+LTrim(C.TradeCode)+'.'   
			From SPARC_ClientMaster_Pending C(Nolock) Where C.AcceptanceStatus<>'T' and C.Email=LTrim(RTrim(@Value)) and
			@Key='EmailID' and IsNull(@Response,'')=''
		End
		Else If @Key='PAN'
		Begin
			Select @Response='PAN '+LTrim(@Value) +' is already exists in back office for client '+
			LTrim(C.TradeCode)+'.'   
			From SPARC_ClientMaster C(Nolock) 
			Where C.AcceptanceStatus<>'T' and C.PANNumber=LTrim(RTrim(@Value)) and @Key='PAN' and
			C.TradeCode Not Like 'DP%'

			Select @Response='PAN '+LTrim(@Value) +' is already exists in back office for client '+LTrim(C.TradeCode)+'.'   
			From SPARC_ClientMaster_Pending C(Nolock) Where C.AcceptanceStatus<>'T' and C.PANNumber=LTrim(RTrim(@Value)) and
			@Key='PAN' and IsNull(@Response,'')='' and C.TradeCode Not Like 'DP%'
		End

		Select Case When IsNull(@Response,'')='' Then @Key+' is Valid.' Else @Response End as ResponseMsg,
		Case When IsNull(@Response,'')='' Then 'Success' Else 'Failed' End as Status
	End
	Set Nocount Off
End
GO
