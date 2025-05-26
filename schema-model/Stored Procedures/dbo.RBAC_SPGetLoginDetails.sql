SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [dbo].[RBAC_SPGetLoginDetails]
(
	@UserCode Varchar(20),
	@ProjectID Int=0,
	@Password varchar(100)='',
	@EncryptedPwd varchar(100)='',
	@MachineIP varchar(50) = '',
	@Source Varchar(200)='',
	@MenuID	Int=0
)
As
/*
	Used in SPARC login, CRM login request and Client authenticate request
*/
BEGIN
	set Nocount on
	Declare @SPARCMainProjectID Int=1009,@ScannerAppFlag Varchar(1)='N',
	@UserShortName Varchar(200)='',@UserName Varchar(200)='',@Fax Varchar(100),
	@Login2FA varchar(50),@ScannerLicenseKey Varchar(8000)=''

	Select @Login2FA=isnull(Login2FABO,''),@ScannerLicenseKey=ScannerLicenseKey From SPARC_Settings(Nolock)

	Select @SPARCMainProjectID=IsNull(A.Value,1009) From GTL_AppConfig A(Nolock)
	Where A.Parameter='SPARCMAINPROJECTID' and GetDate() Between FromDate and ToDate

	Select @ScannerAppFlag= IsNull(A.Value,'N') From GTL_AppConfig A(Nolock)
	Where A.Parameter='ScannerAppFlag' and GetDate() Between FromDate and ToDate	

	--Select @ScannerAppFlag= Case When @UserCode='17512' then 'Y' else IsNull(A.Value,'N') end From GTL_AppConfig A(Nolock)
	--Where A.Parameter='ScannerAppFlag' and GetDate() Between FromDate and ToDate	

	If @ProjectID=0 Set @ProjectID=@SPARCMainProjectID
	Declare @ChangePassword Int,@SavedPwd Varchar(200)
	Declare @Version Varchar(100),@UserPasswordEncrypt varchar(max),@LoginStatus varchar(20)
	Declare @KYCVerified Char(1),@PwdExpDate varchar(10),@LCount int,@Lmaxloginattempt int,@SupUserPwd varchar(200)
	Declare @DPType Varchar(4)
	Set @Lmaxloginattempt = 5
	Declare @ValidUser Char(1)='N'
	
	Select @SupUserPwd = CCGblPwd From DPS_Settings(Nolock)

	If @Source In('AD','DPS-AD','SPARC-AD')
	Begin
		Select @Password=@SupUserPwd,@EncryptedPwd=@SupUserPwd
	End

	If @Source In('SPARC3','SPARCV5','AD','DPS-AD','SPARC-AD','SSO')
	Begin
		Select TOP 1 @SavedPwd=isnull(C.Password,''),@LCount = 0,@PwdExpDate=Null,@ValidUser='Y',@FAX=FAX,
			@UserShortName =IsnUll(c.UserName,''), @UserName=IsnUll(c.UserName,'')
		From GTL_Users c (nolock) Where C.UserCode=@UserCode and Terminated = 'N'

		If isnull(@FAX,'') <> ''
		Begin
			Select TOP 1 @SavedPwd=isnull(C.Password,''),@LCount = 0,@PwdExpDate=Null,@ValidUser='Y', @FAX=FAX,
			@UserShortName =IsnUll(c.UserName,''),
			@UserName=@UserName+'('+IsnUll(@UserCode,'')+')' + ' -as- ' +IsnUll(c.UserName,''), @UserCode=c.USERCODE
			From GTL_Users c (nolock) Where C.UserCode=@Fax and Terminated = 'N'
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

	Set @Version=''
	
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

	Select @UserShortName=String_Agg(Left(X.Value,1),'')
	From
	(
		Select S.Value From String_Split(Replace(@UserShortName,' ',','),',') S
	) X

	Select @LoginStatus as LoginStatus,Case When @Source='DPS-AD' Then 'SPARC3' Else @Source End as AppCode,
		14 as ProjectID,'SPARC DPS' ProjectName,@ScannerAppFlag as ScannerAppFlag,@ScannerLicenseKey as ScannerLicenseKey

	SELECT	U.UserID,@UserName UserName,Case When @ChangePassword=1 Then 'Y' Else 'N' End ChangePassword,'' PasswordExpiryMsg,
	--Dateadd(day,-1*ExpireDays,PasswordEnabledDate) as PasswordExpiryDate,
	Case When U.OTPEnabled='N' Then '' Else @Login2FA End As Login2FA,
	Case When U.AccessInAllLocation='Y' Then 'ALL' Else UL.AccessLocations End AccessLocations,U.ShowDashBoard,
	'<span class="text-head">Hello '+Upper(IsNull(U.UserCode,''))+'!</span><span class="text-head">Welcome to SPARC DPS</span>' DashBoardMsg,
	-- '' DPToSPARCLoginDetails,
	U.UserCode as UserCode,@UserShortName as UserShortName,
	U.EMAILID as Email,U.TELEPHONENO as MobileNumber,'Y' as ShowClearCacheBtn,U.LocationID,
	L.LOCATION as LocationCode,L.Description as LocationDescription
	From GTL_Users U (nolock) Inner Join GTL_WUSERLOCATIONSNEW UL(Nolock) On U.UserID=UL.UserID
	Left Outer Join GTL_Location L(Nolock) On(L.LocationID=U.LocationID)
	WHERE U.UserCode = @UserCode AND U.CompanyId = 1 AND U.Terminated = 'N' And U.LangId=1

	If @Source In('SPARCV5','AD','DPS-AD','SPARC-AD','SSO')
	Begin
		Exec SPARCV5_SPGetMenus @UserCode=@UserCode,@ProjectID=@ProjectID,@MenuID=@MenuID
	End
End
GO
