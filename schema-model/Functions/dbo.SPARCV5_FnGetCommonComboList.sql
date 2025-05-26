SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Function [dbo].[SPARCV5_FnGetCommonComboList]
(
	@Code Varchar(100)
) Returns @Results Table 
(
	SlNo Int Not Null Identity Primary Key,
	Code Varchar(100),
	Description Varchar(Max),
	SearchKey Int,
	SearchOPID Varchar(100),
	SearchOPCode Varchar(100),
	SearchOPDesc varchar(Max),
	SearchPageHeader varchar(Max)
)   
As
/*****************************************************************************************************************
Created By	: Paul Mathew
Created on	: 08-11-2022
Project		: SPARC
Purpose		: For getting combo values for common search control
Test		: Select * From SPARCV5_FnGetCommonComboList('')
******************************************************************************************************************/
Begin
	/*
		@Code=1	Region,Location,SBBranch,Client	
		@Code=2	Region,Location,SBBranch 
		@Code=3	Region,Location,SBBranch,Client,Introducer
		@Code=4	Region,Location,SBBranch,Client,Introducer,Referal Client
		@Code=5	Region,Location,SBBranch,Client,Introducer,Referal Client
		@Code=6	Client,Introducer
		@Code=7	Client,Vendor
		@Code=8	Region,Location,SBBranch,CDSLClient
		@Code=9	Region,Location,SBBranch,NSDLClient	
	*/
	Select @Code='1' Where IsNull(@Code,'')=''--By default Region,Location,SBBranch,Client

	Insert Into @Results(Code,Description,SearchKey,SearchOPID,SearchOPCode,SearchOPDesc,SearchPageHeader)
	Select 'TradeCode' Code,'Client' Description,'75' SearchKey, 'ClientID' SearchOPID,
	'TradeCode' SearchOPCode, 'ClientName' SearchOPDes,'Client Search' as SearchPageHeader
	Where 1=Case When @Code In('TradeCode','1','3','4','5','6','7') Then 1 Else 2 End
	Union All
	Select 'ClientID' Code,'Client' Description,'199' SearchKey,'ClientID' SearchOPID,
	'ClientID' SearchOPCode, 'ClientName' SearchOPDesc,'Client Search' as SearchPageHeader
	Where 1=Case When @Code In('CDSLClient','8') Then 1 Else 2 End
	Union All
	Select 'ClientID' Code,'Client' Description,'200' SearchKey,'ClientID' SearchOPID,
	'ClientID' SearchOPCode, 'ClientName' SearchOPDesc,'Client Search' as SearchPageHeader
	Where 1=Case When @Code In('NSDLClient','9') Then 1 Else 2 End
	Union All
	Select  'Region' Code,'Region' Description,'5' SearchKey, 'RegionID' SearchOPID,
	'Region' SearchOPCode, 'Description' SearchOPDes,'Region Search' as SearchPageHeader
	Where 1=Case When @Code In('Region','1','2','3','4','5','8','9') Then 1 Else 2 End
	Union All	
	Select 'Location' Code,'Location' Description,'1' SearchKey,'LocationID' SearchOPID,
	'Location' SearchOPCode, 'Description' SearchOPDesc,'Location Search' as SearchPageHeader
	Where 1=Case When @Code In('Location','1','2','3','4','5','8','9') Then 1 Else 2 End
	Union All
	--In case of GFSL, no need to show SBBranch in report common search dropdown
	Select 'SBBranch' Code,'SBBranch' Description,'44' SearchKey,'SBBranchID' SearchOPID,
	Case When S.LicenseCompanyName='GFSL' Then 'Location' Else 'SBBranch' End as SearchOPCode,
	'Description' SearchOPDesc,
	Case When S.LicenseCompanyName='GFSL' Then 'Location Search' Else 'Sub Branch Search' End as SearchPageHeader
	From SPARC_Settings S(Nolock) 
	Where 1=Case When @Code In('SBBranch','1','2','3','4','5','8','9') Then
	Case When S.LicenseCompanyName='GFSL' and @Code In('1','2','3','4','5','8','9') Then 0 Else 1 End Else 2 End
	Union All
	Select 'Introducer' Code,'Introducer' Description,'115' SearchKey,'IntroducerID' SearchOPID,
	'IntroducerCode' SearchOPCode, 'Name' SearchOPDesc,'Introducer Search' as SearchPageHeader
	Where 1=Case When @Code In('Introducer','3','4','5','6') Then 1 Else 2 End
	Union All
	Select 'Security' Code,'Security' Description,'53' SearchKey,'SecurityID' SearchOPID,
	'SecurityCode' SearchOPCode, 'SecurityName' SearchOPDesc,'Security Search' as SearchPageHeader
	Where 1=Case When @Code In('Security') Then 1 Else 2 End
	Union All 
	Select 'Dealer' Code,'Dealer' Description,'55' SearchKey,'DealerID' SearchOPID,
	'DealerCode' SearchOPCode, 'DealerName' SearchOPDesc,'Dealer Search' as SearchPageHeader
	Where 1=Case When @Code In('Dealer','5') Then 1 Else 2 End
	Union All 
	Select 'Vendor' Code,'Vendor' Description,'136' SearchKey,'VendorID' SearchOPID,
	'VendorCode' SearchOPCode, 'VendorName' SearchOPDesc,'Vendor Search' as SearchPageHeader
	Where 1=Case When @Code In('Vendor','7') Then 1 Else 2 End
	Union All 
	Select 'Symbol' Code,'Symbol' Description,'100' SearchKey,'SecurityCode' SearchOPID,
	'SecurityCode' SearchOPCode, 'SecurityName' SearchOPDesc,'Symbol Search' as SearchPageHeader
	Where 1=Case When @Code In('FOSecurity') Then 1 Else 2 End
	Union All
	Select 'sttlno' Code,'sttlno' Description,'190' SearchKey,'sttlno' SearchOPID,
	'sttlno' SearchOPCode, 'sttlno' SearchOPDesc,'Settlement Search' as SearchPageHeader
	Where 1=Case When @Code In('sttlno') Then 1 Else 2 End

	/**************************************DP Code Begins************************/
	Union All
	Select 'ISIN' Code,'ISIN' Description,'197' SearchKey,'ISIN' SearchOPID,
	'ISIN' SearchOPCode, 'SecurityName' SearchOPDesc,'ISIN Search' as SearchPageHeader
	Where 1=Case When @Code In('CDSLSecurity') Then 1 Else 2 End
	Union All
	Select 'ISIN' Code,'ISIN' Description,'198' SearchKey,'ISIN' SearchOPID,
	'ISIN' SearchOPCode, 'SecurityName' SearchOPDesc,'ISIN Search' as SearchPageHeader
	Where 1=Case When @Code In('NSDLSecurity') Then 1 Else 2 End
	Union All
	Select 'DPID' Code,'DPID' Description,'206' SearchKey,'DPID' SearchOPID,
	'DPID' SearchOPCode, 'DPName' SearchOPDesc,'DP Search' as SearchPageHeader
	Where 1=Case When @Code In('NSDLDPID') Then 1 Else 2 End
	Union All
	Select 'DPID' Code,'DPID' Description,'207' SearchKey,'DPID' SearchOPID,
	'DPID' SearchOPCode, 'DPName' SearchOPDesc,'DP Search' as SearchPageHeader
	Where 1=Case When @Code In('CDSLDPID') Then 1 Else 2 End
	/*************************************DP Code Ends***************************/

	Return
End
GO
