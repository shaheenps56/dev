SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--Exec SPARC_SPGetLoginDetails 'GIT',0,'tiger1234','','','SPARCV5'
--Exec SPARC_SPGetLoginDetails 'A001',0,'tiger1234','','','SPARC3CC'
CREATE Proc [dbo].[SPARC_SPGetLoginDetails_25102024]
(
	@UserCode Varchar(20),
	@ProjectID Int=0,
	@Password varchar(100)='',
	@EncryptedPwd varchar(100)='',
	@MachineIP varchar(50) = '',
	@Source Varchar(200)='',
	@MenuID	Int=0
) as
/*
	Used in SPARC login, CRM login request and Client authenticate request
*/
BEGIN
	set Nocount on
	Declare @SPARCMainProjectID Int=1009,@ScannerAppFlag Varchar(1)='N',@UserShortName Varchar(200)=''

	Select @SPARCMainProjectID=IsNull(A.Value,1009) From GTL_AppConfig A(Nolock)
	Where A.Parameter='SPARCMAINPROJECTID' and GetDate() Between FromDate and ToDate

	Select @ScannerAppFlag=IsNull(A.Value,'N') From GTL_AppConfig A(Nolock)
	Where A.Parameter='ScannerAppFlag' and GetDate() Between FromDate and ToDate	

	If @Source='WEB' --Old SPARC Web 
	Begin
		Exec SpGetLoginPassword @UserCode=@UserCode,@ProjectId=@ProjectId,@Password=@Password,@EncryptedPwd=@EncryptedPwd,@MachineIP=@MachineIP
		Return
	End
	
	If @Source='CCWEB' --Old SPARC CC 
	Begin	
		Exec spCC_Login @UserCode=@UserCode,@Password=@Password,@Source=@Source
		Return
	End

	If @ProjectID=0 Set @ProjectID=@SPARCMainProjectID
	Declare @ChangePassword Int,@Login2FA varchar(50),@SavedPwd Varchar(200)
	Declare @Version Varchar(100),@UserPasswordEncrypt varchar(max),@LoginStatus varchar(20)
	Declare @KYCVerified Char(1),@PwdExpDate varchar(10),@LCount int,@Lmaxloginattempt int,@SupUserPwd varchar(200)
	Declare @DPType Varchar(4)
	Set @Lmaxloginattempt = 5
	Declare @ValidUser Char(1)='N'
	
	Select @SupUserPwd = CCGblPwd From DPS_Settings(Nolock)

	If @Source In('AD','DPS-AD','SPARC-AD')
	Begin
		--select @UserCode='GIT'
		Select @Password=@SupUserPwd,@EncryptedPwd=@SupUserPwd
	End

	If @Source In('SPARC3CC')
	Begin		
		--If (Select isnull(InstallationType,'') from DPS_Settings)='DPONLY'
		--Begin
		--	Select TOP 1 @SavedPwd=isnull(C.CCPassword,''),@LCount = C.loginattempt,
		--	@PwdExpDate=CONVERT(VARCHAR(10), C.expirepasswordon, 103), @KYCVerified = C.KYCVerified,@ValidUser='Y',@Source='DPSCC'
		--	From CCUsers c (nolock) Inner join C_ClientMaster CM(Nolock) On (C.DPClientId = CM.ClientID and CM.BenStatus<>4)
		--	Where C.USERCODE=@UserCode	

		--	If @@RowCount=0
		--	Begin
		--		Select TOP 1 @SavedPwd=isnull(C.CCPassword,''),@LCount = C.loginattempt,
		--		@PwdExpDate=CONVERT(VARCHAR(10), C.expirepasswordon, 103), @KYCVerified = C.KYCVerified,@ValidUser='Y',@Source='DPSCC'
		--		From CCUsers c (nolock) Inner join N_ClientMaster CM(Nolock) On (C.DPClientId = CM.ClientId and CM.BenStatus<>4)
		--		Where C.USERCODE=@UserCode	

		--		Set @DPType='NSDL'
		--	End
		--	Else
		--	Begin
		--		Set @DPType='CDSL'
		--	End	
			
		--	If @Source='SPARC3'
		--	Begin
		--		Select TOP 1 @SavedPwd=isnull(C.Password,''),@LCount = 0,@PwdExpDate=Null,@ValidUser='Y',@Source='DPSWeb'
		--		From GTL_Users c (nolock) Where C.UserCode=@UserCode and Terminated = 'N'	
		--	End
		--End
		--Else
		--Begin
			Select TOP 1 @SavedPwd=isnull(C.CCPassword,''),@LCount = C.loginattempt,
			@PwdExpDate=CONVERT(VARCHAR(10), C.expirepasswordon, 103), @KYCVerified = C.KYCVerified,@ValidUser='Y',@Source='SPARC3CC'
			From CCUsers c (nolock) Inner join sparc_ClientMaster CM On (C.ClientID = CM.ClientId and CM.AcceptanceStatus <> 'T')
			Where C.TradeCode=@UserCode		
			
			--If @Source='SPARC3'
			--Begin
			--	Select TOP 1 @SavedPwd=isnull(C.Password,''),@LCount = 0,@PwdExpDate=Null,@ValidUser='Y',@Source='SPARCWeb'
			--	From GTL_Users c (nolock) Where C.UserCode=@UserCode and Terminated = 'N'	
			--End
		----End	
	End
	Else If @Source In('SPARC3','SPARCV5','AD','DPS-AD','SPARC-AD','SSO')
	Begin
		Select TOP 1 @SavedPwd=isnull(C.Password,''),@LCount = 0,@PwdExpDate=Null,@ValidUser='Y'
		From GTL_Users c (nolock) Where C.UserCode=@UserCode and Terminated = 'N'
	End

	If @Source = 'FLIP'
	Begin
		If @ValidUser='N'
		Begin
			Select '1000' + Char(1) + 'INVALIDUSER' AS LoginStatus
			Return
		End
		IF @LCount >= @Lmaxloginattempt
		Begin
			Select Cast (@LCount AS VARCHAR) + Char(1)+ 'INVALIDLOGIN' AS LoginStatus
			Return
		End
		
		If @Password <> @SavedPwd and @Password <> @SupUserPwd
		Begin
			UPDATE CCUsers SET loginattempt = loginattempt + 1 WHERE TradeCode=@UserCode
			Select Ltrim(@LCount + 1) + Char(1) + 'WRNOGPWD' AS LoginStatus
			Return
		End
		
		If @Password = @SavedPwd or @Password = @SupUserPwd
		Begin	  
			UPDATE CCUsers SET loginattempt = 0 WHERE TradeCode=@UserCode and loginattempt<>0
			Select '0' + Char(1) + 'SUCCESS' + Char(1) + 'Y' + Char(1) + @PwdExpDate + Char(1) + @KYCVerified AS LoginStatus
			Return
		End
	End


	IF @ValidUser = 'N'
	Begin
		Select 'FAILED' LoginStatus, 0 ClientId,'Invalid UserName/Password' as LoginMsg
		return
	End
	-- SHA1 encrypting
	If(@EncryptedPwd='')
	Begin
		Select @Password = cast(N'' as xml).value('xs:base64Binary(xs:hexBinary(sql:column("CCPasswordE")))', 'nvarchar(4000)')
		From (Select HashBytes('SHA1', @Password) CCPasswordE) X
	End
	Else
	Begin
		Set @Password=@EncryptedPwd
	End
	IF (@SavedPwd = @Password COLLATE SQL_Latin1_General_CP1_CS_AS OR @Password=@SupUserPwd)
	Begin
		Set @LoginStatus='SUCCESS'
	End
	Else
	Begin
		Set @LoginStatus='FAILED'
	End

	If @LoginStatus='FAILED'
	Begin
		Select 'FAILED' LoginStatus, 0 ClientId,'Invalid UserName/Password' as LoginMsg
		Return
	End
	If @Source In('DPSCC','SPARC3CC')
	Begin	
		--If (Select isnull(InstallationType,'') from DPS_Settings)='DPONLY'		
		--Begin
		--	Select 'SUCCESS' as LoginStatus, DPClientId as ClientId,'' as LoginMsg,@Source AppCode,'' Login2FA From CCUsers (nolock) C Where UserCode = @UserCode

		--	Declare @DefaultProjectID Int
		--	Select @DefaultProjectID=isnull(DefaultProjectID,0) From DPS_Settings(Nolock)
		--	If @DPType='NSDL'
		--	Begin
		--		Select a.DPID,a.CLIENTID ClientID,FirstHoldName Name,Ltrim(a.DPID)+Ltrim(a.CLIENTID) as DPCLIENTID
		--		from N_ClientMaster a inner join ccusers b on a.ClientID=b.DPCLIENTID
		--		where b.USERCODE=@UserCode
		--	End
		--	Else
		--	Begin
		--		Select a.DPID,a.CLIENTID as ClientID,FirstHolderName Name,Ltrim(a.DPID)+Ltrim(a.CLIENTID) as DPCLIENTID
		--		from C_ClientMaster a inner join ccusers b on a.ClientID=b.DPCLIENTID
		--		where b.USERCODE=@UserCode
		--	End
			
		--	Select Ltrim(a.DPID)+Ltrim(a.CLIENTID) as DPCLIENTID,'NSDL' DPType
		--	from N_ClientMaster a inner join ccusers b on a.ClientID=b.DPCLIENTID
		--	where b.USERCODE=@UserCode
		--			Union ALl
		--	Select Ltrim(a.DPID)+Ltrim(a.CLIENTID) as DPCLIENTID,'CDSL' DPType
		--	from C_ClientMaster a inner join ccusers b on a.ClientID=b.DPCLIENTID
		--	where b.USERCODE=@UserCode

		--End
		--Else
		--Begin
			Select 'SUCCESS' as LoginStatus, ClientId,'' as LoginMsg,@Source as AppCode,'' Login2FA 
			From CCUsers (nolock) C Where Tradecode = @UserCode
			Select TradeCode,ClientName Name From SPARC_ClientMaster(Nolock) Where TradeCode=@UserCode

			--Exec spSparcIMCCLogin @UserCode,1,''

			--Select Ltrim(a.DPID)+Ltrim(a.CLIENTID) as DPCLIENTID,'NSDL' DPType
			--from N_ClientMaster a inner join ccusers b on a.ClientID=b.DPCLIENTID
			--where b.TradeCode=@UserCode
			--		Union ALl
			--Select Ltrim(a.DPID)+Ltrim(a.CLIENTID) as DPCLIENTID,'CDSL' DPType
			--from C_ClientMaster a inner join ccusers b on a.ClientID=b.DPCLIENTID
			--where b.TradeCode=@UserCode
		--End
		Return
	End

	If @ProjectId = 9999 -- Client authenticate request
	Begin
		Select @SavedPwd = CCPassword From ccUsers(Nolock) Where TradeCode = @UserCode
		If @SavedPwd = @EncryptedPwd
		Begin 
			Select '<ErrorCode>0</ErrorCode><ErrorMessage>Success</ErrorMessage>' ErrorMessage
		End
		Else
		Begin
			Select '<ErrorCode>1</ErrorCode><ErrorMessage>Failed</ErrorMessage>' ErrorMessage
		End
		Return
	End

	Set @Version=''
	Select @Login2FA=isnull(Login2FABO,'') from SPARC_Settings(Nolock)

	If @ProjectId=0
	Begin
		Raiserror('Please update your executable.',16,1)
		Return
	End

	Exec spCheckPasswordChangeOut @UserCode=@UserCode,@CompanyId=1,@Out=@ChangePassword Output

	If @ProjectId <> 0
		Select @Version=Version From GTL_Projects (nolock) Where ProjectId=@ProjectId

	If(@LoginStatus='Success')
	Begin
		Insert into GTL_LoginHistory(UserCode,Time,MachineIP)
		Select @UserCode,getdate(),@MachineIP
	End

	Select @UserShortName=IsnUll(U.UserName,'') From GTL_Users U(Nolock) Where U.UserCode=@UserCode
	
	Select @UserShortName=String_Agg(Left(X.Value,1),'')
	From
	(	Select S.Value From	 String_Split(Replace(@UserShortName,' ',','),',') S
	)X


	Select @LoginStatus as LoginStatus,Case When @Source='DPS-AD' Then 'SPARC3' Else @Source End as AppCode,
	14 as ProjectID,'SPARC DPS' ProjectName,@ScannerAppFlag as ScannerAppFlag

	SELECT	U.UserID,U.UserName,Case When @ChangePassword=1 Then 'Y' Else 'N' End ChangePassword,'' PasswordExpiryMsg,
	--Dateadd(day,-1*ExpireDays,PasswordEnabledDate) as PasswordExpiryDate,
	Case When U.OTPEnabled='N' Then '' Else @Login2FA End As Login2FA,
	Case When U.AccessInAllLocation='Y' Then 'ALL' Else UL.AccessLocations End AccessLocations,U.ShowDashBoard,
	'<span class="text-head">Hello '+Upper(IsNull(U.UserCode,''))+'!</span><span class="text-head">Welcome to SPARC DPS</span>' DashBoardMsg,

	'{"IsAuthenticated":'+Case When @LoginStatus='Success' Then 'true' Else 'false' End+',"appCode":"'+Ltrim(@Source)+'"'+
	',"IsPasswordExpired":'+	
	Case When U.PasswordExpire='Y' then 'true' Else 'false' End+',"MaxQueryLevel":"'+IsNull(U.MaxQueryLevel,'')+'","GroupId":'+LTrim(IsNull(U.GroupID,0))+
	',"MaxQueryLevelID":'+Ltrim(Case Upper(MaxQueryLevel) When 'CORP' Then 5 When 'CORPREGION' Then 15 When 'CORPMULTI' Then 10 When 'SBREGION' Then 25	
	When 'SBBRANCH' Then 35 When 'SB' Then 20 When 'SBMULTI' Then 30 When 'CLIENT' Then 40 Else 0 End)+
	',"FieldValue":'+LTrim(Case Upper(MaxQueryLevel)	When 'CORPREGION' Then U.RegionID  When 'SBREGION' Then U.RegionID 
	When 'SBBRANCH' Then U.LocationID When 'SB' Then U.LocationID When 'SBMULTI' Then U.LocationID When 'CORP' Then -1 Else 0 End)+	
	',"UserType":"'+Left(IsNull(U.UserType,''),2)+'","LocationId":'+LTrim(IsNull(U.LocationID,0))+',"CompanyId":1,"UserCode":"'+Ltrim(@UserCode)+
	'","UserName":"'+Ltrim(U.UserName)+'","EmailId":"'+IsNull(U.EmailID,'')+'","Login2FA":"'+Case When U.OTPEnabled='N' Then '' Else @Login2FA End+
	'","MaxFieldValue":"'+LTrim(Case When MaxQueryLevel in ('CORPREGION','SBREGION')	Then U.RegionId
	When MaxQueryLevel = 'SB' Then U.LocationId When MaxQueryLevel in ('CORPMULTI', 'SBMULTI') Then -2 When MaxQueryLevel = 'CORP' Then -1
	When MaxQueryLevel = 'SBBRANCH' Then (Select L.LocationID From GTL_BranchWUserLocations L Where L.USERCODE = U.UserCode)End)+'"}' 
	DPToSPARCLoginDetails,U.UserCode as UserCode,@UserShortName as UserShortName,
	U.EMAILID as Email,U.TELEPHONENO as MobileNumber,'Y' as ShowClearCacheBtn
	From GTL_Users U (nolock) Inner Join GTL_WUSERLOCATIONSNEW UL(Nolock) On U.UserID=UL.UserID
	WHERE U.UserCode = @UserCode AND U.CompanyId = 1 AND U.Terminated = 'N' And U.LangId=1

	If @Source In('SPARCV5','AD','DPS-AD','SPARC-AD','SSO')
	Begin
		Exec SPARCV5_SPGetMenus @UserCode=@UserCode,@ProjectID=@ProjectID,@MenuID=@MenuID
	End
END
GO
