SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--Exec RBAC_SPPortUsers @Server='',@UserCode='SYS'
CREATE   Proc [dbo].[RBAC_SPPortUsers](@Server Varchar(100)='',@UserCode varchar(25)='Job-1501') 
as
Begin
	Set Nocount On

	Declare @UserID Int=0,@SQL Varchar(4000)='',@AccessLocations Varchar(Max),
	@DepartmentID Int,@AccessProjectID Varchar(Max)='',@GroupID Int=0,@FullAccessUsers Varchar(Max)=''
	
	Select @Server='GFSL2025.dbo.' Where IsNull(@Server,'')=''

	Select @FullAccessUsers=IsNull(Value,'') From GTL_AppConfig A(Nolock)
	Where A.Parameter='FULLACCESSUSERS' and GetDate() Between FromDate and ToDate

	Select @AccessLocations=String_Agg(Cast(LocationID as Varchar(Max)),',') From GTL_Location L(Nolock)
	Select @AccessProjectID=String_Agg(Cast(ProjecTID as Varchar(Max)),',') From GTL_Projects P(Nolock)
	
	Select @DepartmentID=Isnull(Max(DepartmentID),999)From GTL_Department D(Nolock)
	
	Select @UserID=Isnull(Max(UserID),999) From GTL_Users(Nolock) Where UserID>999
	Select @GroupID=Isnull(Max(GroupID),999) From GTL_UserGroups(Nolock) Where GroupID>999

	Select Top 0 *,Cast('' as Varchar(200)) as DepartmentDesc,Cast(0 as Int) as DepartmentID,
	Cast('' as Varchar(200)) as FunctionalDesignation,Cast('N' as Varchar(1)) as BranchUser,
	Cast('N' as Varchar(1)) as ChangeInDesignation,Cast('N' as Varchar(1)) as ChangeInDepartment
	Into #Temp_Users From GTL_Users U(Nolock)

	Set @SQL='Insert Into #Temp_Users
	(
		CompanyID,LangID,UserID,UserCode,USERNAME,PASSWORD,LocationID,EmailID,EUSER,LASTUPDATEDON,
		PayrollAccessRights,Region,Terminated,GroupID,ToLocation,FAX,TelephoneNo,Department,IsWebUser,
		ChangePassword,PasswordExpire,ExpireDays,PasswordEnabledDate,Signature,MachineWiseLogin,MachineName,
		EnablePasswordCount,PasswordCount,LoginProjectID,CorpUser,RegionID,TerminatedDate,TerminatedReason,
		AccessInAllLocation,UserType,BranchGroupId,MaxQueryLevel,CRMIsProcessed,IPAddress,OTP,OTPTime,OTPEnabled,
		ShowDashBoard,RoleIds,DOB,CompanyState,DepartmentDesc,FunctionalDesignation,OfficialMobileNo
	)
	Select 1 CompanyID,1 as LangID,0 as UserID,
	EmpCode as UserCode,EmpName as USERNAME,'''' as PASSWORD,L.LocationID,E.EmailID,''SYS'' as EUSER,
	GetDate() LASTUPDATEDON,''N'' as PayrollAccessRights,Region,E.Terminated,0 as GroupID,
	Null as ToLocation,Null as FAX,Permanent_MobileNo as TelephoneNo,Department,
	Case When DepartMent=''BRANCH'' Then ''Y'' Else ''N'' End as IsWebUser,
	''N'' as ChangePassword,''N'' as PasswordExpire,0 as ExpireDays,Null as PasswordEnabledDate,
	Null as Signature,''N'' as MachineWiseLogin,Null as MachineName,
	''N'' as EnablePasswordCount,0 as PasswordCount,1111 as LoginProjectID,
	Case When DepartMent=''BRANCH'' Then ''N'' Else ''Y'' End as CorpUser,
	L.RegionID,Null as TerminatedDate,Null as TerminatedReason,
	Case When E.Location=''HO'' Then ''Y'' Else ''N'' End as AccessInAllLocation,
	''CO-Normal'' UserType,Null as BranchGroupId,''CORP'' as MaxQueryLevel,
	''N'' as CRMIsProcessed,Null as IPAddress,Null as OTP,Null as OTPTime,
	''N'' as OTPEnabled,''Y'' as ShowDashBoard,Null as RoleIds,DateofBirth as DOB,
	E.GeojitState as CompanyState,E.DepartmentDesc,E.FunctionalDesignation,E.Official_MobileNo
	From '+@Server+'EmployeeDetailsFromRamco E Inner Join GTL_Location L(Nolock)
	On(L.Location=E.Location)'
	Exec(@SQL)

	Insert Into #Temp_Users
	(
		CompanyID,LangID,UserID,UserCode,USERNAME,PASSWORD,LocationID,EmailID,EUSER,LASTUPDATEDON,
		PayrollAccessRights,Region,Terminated,GroupID,ToLocation,FAX,TelephoneNo,Department,IsWebUser,
		ChangePassword,PasswordExpire,ExpireDays,PasswordEnabledDate,Signature,MachineWiseLogin,MachineName,
		EnablePasswordCount,PasswordCount,LoginProjectID,CorpUser,RegionID,TerminatedDate,TerminatedReason,
		AccessInAllLocation,UserType,BranchGroupId,MaxQueryLevel,CRMIsProcessed,IPAddress,OTP,OTPTime,OTPEnabled,
		ShowDashBoard,RoleIds,DOB,CompanyState,DepartmentDesc,FunctionalDesignation
	)
	Select 1 CompanyID,1 as LangID,0 as UserID,
	E.UserCode,E.UserName,'' as PASSWORD,L.LocationID,E.Email as EmailID,'SYS' as EUSER,
	GetDate() LASTUPDATEDON,'N' as PayrollAccessRights,E.CurRegion,
	Case When E.Terminated=1 Then 'Y' Else 'N' End as Terminated,0 as GroupID,
	Null as ToLocation,Null as FAX,Null as TelephoneNo,
	Case When IsNull(Department,'')='' Then 'NODEP' Else Department End Department,
	Case When DepartMent='BRANCH' Then 'Y' Else 'N' End as IsWebUser,
	'N' as ChangePassword,'N' as PasswordExpire,0 as ExpireDays,Null as PasswordEnabledDate,
	Null as Signature,'N' as MachineWiseLogin,Null as MachineName,
	'N' as EnablePasswordCount,0 as PasswordCount,1111 as LoginProjectID,
	Case When DepartMent='BRANCH' Then 'N' Else 'Y' End as CorpUser,
	L.RegionID,Null as TerminatedDate,Null as TerminatedReason,
	Case When E.CurLocation='HO' Then 'Y' Else 'N' End as AccessInAllLocation,
	'CO-Normal' UserType,Null as BranchGroupId,'CORP' as MaxQueryLevel,
	'N' as CRMIsProcessed,Null as IPAddress,Null as OTP,Null as OTPTime,
	'N' as OTPEnabled,'Y' as ShowDashBoard,Null as RoleIds,Null as DOB,
	Null as CompanyState,
	Case When IsNull(Department,'')='' Then 'NO DEPARTMENT' Else Department End as Department,
	'OTHERS' as FunctionalDesignation
	From Passport..PassportUsers E Inner Join GTL_LOCATION L(Nolock)
	On(L.Location=E.CurLocation)
	Where Not Exists(Select Top 1 Null from #Temp_Users U(Nolock) Where U.UserCode=E.UserCode)
	and E.Terminated=0

	Insert Into GTL_Department
	(
		DepartmentID,DepartmentCode,DepartmentDesc,Active,EUser,LastUpdatedOn 
	)
	Select @DepartmentID+Row_Number() Over(Order By DepartMent) as DepartmentID,Department,
	DepartmentDesc,'Y' as Active,@UserCode as EUser,GetDate() as LastUpdatedOn 
	From 
	(
		Select Department,Max(DepartmentDesc) as DepartmentDesc From #Temp_Users T Group By Department
	) X
	Where Not Exists(Select Top 1 Null From GTL_Department D(Nolock) Where D.DepartmentCode=X.Department)
	and IsNull(Department,'')<>''

	Update T Set T.DepartmentID=D.DepartmentID 
	From #Temp_Users T Inner Join GTL_Department D On(D.DepartmentCode=T.Department)

	--Removing users without department
	Delete T From #Temp_Users T Where IsNull(T.DepartmentID,0)=0
	
	Update T Set T.GroupID=G.GroupID 
	From #Temp_Users T Inner Join GTL_UserGroups G On(G.Description=T.FunctionalDesignation)	

	
	/*#######################Designation/Department Change Processing begins#################################*/
	Update T Set T.BranchUser='Y' From #Temp_Users T Inner Join
	(	
		Select Distinct Designation From GTL_Users(Nolock) 
		Where Department In(Select Distinct DepartmentID From GTL_Department(Nolock) Where DepartmentCode='branch')
	) B
	On(T.FunctionalDesignation=B.Designation)

	Update T Set T.ChangeInDepartment=Case When T.DepartmentID<>U.Department Then 'Y' Else 'N' End, 
	T.ChangeInDesignation=Case When T.FunctionalDesignation<>U.Designation Then 'Y' Else 'N' End
	From #Temp_Users T Inner Join GTL_Users U(Nolock) On(T.UserCode=U.UserCode)

	--Update will happen on existing users only
	Update T Set T.GroupID=Case When (T.ChangeInDepartment='Y' Or T.ChangeInDesignation='Y') and 
		T.BranchUser='Y' Then T.GroupID Else 0 End 
	From #Temp_Users T 
	Where (T.ChangeInDesignation='Y' Or T.ChangeInDepartment='Y')
	/*#######################Designation/Department Change Processing ends#################################*/
	  
	/*
	Insert Into GTL_UserGroups
	(
		CompanyID,GroupID,IsWebUser,Description,LangID,EUser,LastUPdatedOn,AccessProjectID,LevelID,Remarks
	)
	Select 1 as CompanyID,@GroupID+Row_Number() Over(Order By FunctionalDesignation) as  GroupID,
	IsWebUser,FunctionalDesignation as Description,1 as LangID,@UserCode as EUser,GetDate() as LASTUPdatedOn,
	@AccessProjectID as AccessProjectID,Null as LevelID,Null as Remarks
	From 
	(
		Select FunctionalDesignation,Max(IsWebUser) as IsWebUser 
		From #Temp_Users T Where Terminated='N' and Department<>'SOFTWARE' Group By FunctionalDesignation
	) X
	Where Not Exists(Select Top 1 Null From GTL_UserGroups D Where D.Description=X.FunctionalDesignation)
	 */

	 --Mapping Role for Franchisee users
	 Update T Set T.GroupID=1235,T.BranchUser='Y' 
	 From #Temp_Users T Inner Join GFSL2025..FranchiseeStaff_Master F On(T.UserCode=F.EmpCode)


	 --Logging user details
	 Insert Into GTL_Users_Log
	 (
		COMPANYID,USERID,LANGID,USERCODE,USERNAME,PASSWORD,LOCATIONID,EMAILID,EUSER,LASTUPDATEDON,
		PAYROLLACCESSRIGHTS,REGION,TERMINATED,GROUPID,TOLOCATION,FAX,TELEPHONENO,DEPARTMENT,ISWEBUSER,
		CHANGEPASSWORD,PASSWORDEXPIRE,EXPIREDAYS,PASSWORDENABLEDDATE,SIGNATURE,MACHINEWISELOGIN,MACHINENAME,
		ENABLEPASSWORDCOUNT,PASSWORDCOUNT,LOGINPROJECTID,CORPUSER,REGIONID,TerminatedDate,TerminatedReason,
		AccessInAllLocation,UserType,BranchGroupId,MaxQueryLevel,CRMIsProcessed,IPAddress,OTP,OTPTime,
		OTPEnabled,ShowDashBoard,RoleIds,SkipDataMasking,DOB,CompanyState,Designation,OfficialMobileNo,DeletedUser,DeletedTime
	)
	Select U.COMPANYID,U.USERID,U.LANGID,U.USERCODE,U.USERNAME,U.PASSWORD,U.LOCATIONID,U.EMAILID,U.EUSER,U.LASTUPDATEDON,
	U.PAYROLLACCESSRIGHTS,U.REGION,U.TERMINATED,U.GROUPID,U.TOLOCATION,U.FAX,U.TELEPHONENO,U.DEPARTMENT,U.ISWEBUSER,
	U.CHANGEPASSWORD,U.PASSWORDEXPIRE,U.EXPIREDAYS,U.PASSWORDENABLEDDATE,U.SIGNATURE,U.MACHINEWISELOGIN,U.MACHINENAME,
	U.ENABLEPASSWORDCOUNT,U.PASSWORDCOUNT,U.LOGINPROJECTID,U.CORPUSER,U.REGIONID,U.TerminatedDate,U.TerminatedReason,
	U.AccessInAllLocation,U.UserType,U.BranchGroupId,U.MaxQueryLevel,U.CRMIsProcessed,U.IPAddress,U.OTP,U.OTPTime,
	U.OTPEnabled,U.ShowDashBoard,U.RoleIds,U.SkipDataMasking,U.DOB,U.CompanyState,U.Designation,U.OfficialMobileNo,
	@UserCode as DeletedUser,GetDate() as DeletedTime
	From GTL_Users U(Nolock) Inner Join #Temp_Users T On(U.UserCode=T.UserCode)
	Where 
	(
		(U.Terminated<>T.Terminated) Or (IsNull(U.LocationID,0)<>IsNull(T.LocationID,0)) Or 
		(IsNull(U.Region,'')<>IsNull(T.Region,'')) Or 
		(IsNull(U.RegionID,0)<>IsNull(T.RegionID,0)) Or (IsNull(U.EmailID,'')<>IsNull(T.EmailID,'')) Or
		(IsNull(U.TelephoneNo,'')<>IsNull(T.TelephoneNo,'')) Or 
		(IsNull(U.TerminatedDate,'')<>IsNull(T.TerminatedDate,'')) Or (IsNull(U.RoleIds,'')<>IsNull(T.RoleIds,'')) Or
		(IsNull(U.DOB,'')<>IsNull(T.DOB,'')) Or (IsNull(U.Department,'')<>IsNull(T.DepartmentID,'')) Or 
		(U.GroupID<>T.GroupID) Or (IsNull(U.CompanyState,'')<>IsNull(T.CompanyState,'')) Or
		(IsNull(U.AccessInAllLocation,'')<>IsNull(T.AccessInAllLocation,'')) Or 
		(IsNull(U.Designation,'')<>IsNull(T.FunctionalDesignation,''))
	)

	Insert Into GTL_Users
	(
		CompanyID,UserID,LangID,UserCode,USERNAME,PASSWORD,LocationID,EmailID,EUSER,LASTUPDATEDON,
		PayrollAccessRights,Region,Terminated,GroupID,ToLocation,FAX,TelephoneNo,Department,IsWebUser,
		ChangePassword,PasswordExpire,ExpireDays,PasswordEnabledDate,Signature,MachineWiseLogin,MachineName,
		EnablePasswordCount,PasswordCount,LoginProjectID,CorpUser,RegionID,TerminatedDate,TerminatedReason,
		AccessInAllLocation,UserType,BranchGroupId,MaxQueryLevel,CRMIsProcessed,IPAddress,OTP,OTPTime,OTPEnabled,
		ShowDashBoard,RoleIds,DOB,CompanyState,Designation,OfficialMobileNo
	)
	Select CompanyID,@UserID+Row_Number() Over(Order By UserCode) as UserID,
	LangID,UserCode,USERNAME,PASSWORD,LocationID,EmailID,EUSER,LASTUPDATEDON,
	PayrollAccessRights,Region,Terminated,
	Case When T.BranchUser='Y' Then T.GroupID Else 0 End as GroupID,ToLocation,FAX,TelephoneNo,
	DepartmentID as Department,IsWebUser,ChangePassword,PasswordExpire,ExpireDays,
	PasswordEnabledDate,Signature,MachineWiseLogin,MachineName,EnablePasswordCount,
	PasswordCount,LoginProjectID,CorpUser,RegionID,TerminatedDate,TerminatedReason,
	AccessInAllLocation,UserType,BranchGroupId,MaxQueryLevel,CRMIsProcessed,IPAddress,
	OTP,OTPTime,OTPEnabled,ShowDashBoard,RoleIds,DOB,CompanyState,FunctionalDesignation,OfficialMobileNo
	From #Temp_Users T
	where IsNull(T.Terminated,'N')='N' and Not Exists(Select Top 1 Null From GTL_Users U(Nolock) Where U.UserCode=T.UserCode)

	Update U Set U.Terminated=T.Terminated,U.LocationID=T.LocationID,
	U.Region=T.Region,U.RegionID=T.RegionID,U.EmailID=T.EmailID,
	U.TelephoneNo=T.TelephoneNo,U.TerminatedDate=T.TerminatedDate,
	U.RoleIds=T.RoleIds,U.DOB=T.DOB,U.Department=T.DepartmentID,
	U.CompanyState=T.CompanyState,U.AccessInAllLocation=T.AccessInAllLocation,
	U.Designation=T.FunctionalDesignation,U.OfficialMobileNo=T.OfficialMobileNo,
	U.GroupID=Case When U.UserCode In(Select Value From String_Split(@FullAccessUsers,',')) Then 1 
	When U.CorpUser='Y' Then U.GroupID Else T.GroupID End --Making no chnages for HO user roles
	From GTL_Users U Inner Join #Temp_Users T On(U.UserCode=T.UserCode)

	Delete L From GTL_WUserLocationsNew L Where L.UserCode Not In('SYS')

	Insert Into GTL_WUserLocationsNew
	(
		UserID,CompanyID,UserCode,LocationID,RegionID,LangID,AccessLocations,UserProjects,ToLocation
	)
	Select U.UserID,1 as CompanyID,U.UserCode,U.LocationID,U.RegionID,1 as LangID,
	Case When D.DepartmentCode='SOFTWARE' Then @AccessLocations Else LTrim(U.LocationID) End as AccessLocations,
	Null as UserProjects,Null ToLocation
	From GTL_Users U(Nolock) Inner Join GTL_DepartMent D(Nolock) On(U.Department=D.DepartmentID)
	Where U.UserCode Not In('SYS')

	Insert Into GTL_FunctionalDesignation
	(
		DepartmentID,FunctionalDesignation,RoleIDs,Euser,LastUpdatedOn
	)
	Select Distinct U.Department,U.Designation,U.GroupID as RoleIDs,@UserCode as Euser,
	GetDate() as LastUpdatedOn
	From GTL_Users U  Where IsNull(U.Designation,'')<>'' and IsNull(U.Department,'') Not In('','0')
	and Not Exists
	(
		Select Top 1 Null From GTL_FunctionalDesignation D(Nolock)
		Where U.Department=D.DepartmentID and D.FunctionalDesignation=U.Designation
	)

	
	Select @UserID=Isnull(Max(UserID),999) From GTL_Users(Nolock)

	Update T Set T.NewKey=@UserID From GTL_KeyTable T Where T.KeyName='UserID'

	Select @DepartmentID=Isnull(Max(DepartmentID),999) From GTL_Department(Nolock)

	Update T Set T.NewKey=@DepartmentID From GTL_KeyTable T Where T.KeyName='DepartmentID'

	Update GTL_KeyTable Set NewKey=(Select Max(G.GroupID) From GTL_UserGroups G(Nolock)) Where KeyName='UserGroupId'

	Set Nocount Off
End

GO
