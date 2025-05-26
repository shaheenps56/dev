SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

 
CREATE Proc [dbo].[GTL_SPUserCreation] 
(  
	@UserCode			Varchar(25),  
	@UserName			Varchar(100),  
	@XMLFilters			Varchar(8000),  
	@XMLString          Varchar(8000),  
	@UserRegions		Varchar(8000),   
	@UserLocations		Varchar(Max),  
	@Purpose            Varchar(10),  
	@Channel            Int,  
	@Version			Varchar(100),  
	@Euser				Varchar(25)  
)as  
/************************************************************************************************************************************************ 
	Created By	:	Paul Mathew  
	Created On	:	13.12.2023  
	Purpose		:	To create user   
	Project		:	SPARCIM  
	Test		:	Exec GTL_SPUserCreation @XMLFilters='<XMLDetails><XMLData><UserID>1000</UserID></XMLData></XMLDetails>',  
					@XMLString='',@UserRegions='',@UserLocations='',@UserCode='',@UserName='',@Channel= 5,@Version='',@Purpose='F',  
					@Euser= 'GIT'  
************************************************************************************************************************************************/  
Begin  
	Set NoCount On  
  
	Declare @Msg Varchar(8000), @GroupName Varchar(100),@UserType Varchar(20),@QueryLevel Varchar(30),@CompanyID Int=1,  
	@CorpUser Char(1)='N',@AccessInAllLocation Char(1)='N',@XMLDetails XML,@LoginLocationID Int,  
	@Password Varchar(200),@ApplyToAllUsers Char(1)='N',@GroupID Int,@ChangePassWord Char(1),  
	@PasswordExpire Char(1),@ExpireDays Int,@MachineWiseLogin Char(1),@MachineName Varchar(100),  
	@EnablePasswordCount Char(1),@PasswordCount Int,@UserID Int,@SUserID Int=0,  
	@UserMangementLevel Varchar(10)='1',@FilePath Varchar(4000)
  
	Create Table #TempV5_UserMaster  
	(  
	UserID						Int,  
	[Password]					Varchar(200),
	Department					Varchar(100) Not Null Default '',  
	TerminatedDate				Datetime,  
	CurrentRegion				Varchar(20),  
	Region						Int Not Null Default 0, 
	AccessInAllLocation			Char(1) Not Null Default 'N', 
	IPAddress					Varchar(100),
	ConfirmPassword				Varchar(200),
	Reason						Varchar(400),
	Telephone					Varchar(100),  
	Email						Varchar(256),  
	Fax							Varchar(100),  
	UserGroup					Int,
	UserManagementLevel			Varchar(20),
	WebAccess					Char(1) Not Null Default 'N',
	Terminated					Char(1) Not Null Default 'N',
	PasswordExpire				Char(1) Not Null Default 'N',  
	MachineWiseLogin			Char(1) Not Null Default 'N',  
	DontAllowPreviousPwd		Char(1) Not Null Default 'N',
	ChangePasswordNextLogin		Char(1) Not Null Default 'N',
	ApplyToAllUser				Char(1) Not Null Default 'N',
	ExpireDays					Int Not Null Default 0,  
	MacAddress					Varchar(100),
	ApplyPwdPolicy				Char(1) Not Null Default 'N',  
	MaximumPasswordLength		Varchar(20),
	PasswordCount				Int Not Null Default 0,
	PasswordPolicies			Varchar(100),  
	LowerCase					Varchar(1) Not Null Default 'N',  
	UpperCase					Varchar(1) Not Null Default 'N',  
	[Numeric]					Varchar(1) Not Null Default 'N',  
	NonAlphaNumeric				Varchar(1) Not Null Default 'N',  
	RoleIds                     Varchar(Max) 
	)  
  
	Create Table #TempV5_AccessRegions  
	(  
	RegionID			Int  
	)  
    
	Create Table #TempV5_AccessLocations  
	(  
	LocationID			Int  
	)  
  
	Create Table #Region  
	(  
	SlNo				Int,  
	Checked				Char(1),  
	Region				Varchar(20),  
	RegionName			Varchar(200),  
	RegionID			Int  
	)  
	
	Create Table #Location  
	(  
	SlNo				Int,  
	Checked				Char(1),  
	Location			Varchar(20),  
	LocationName		Varchar(200),  
	LocationID			Int,  
	RegionID			Int,  
	BranchOrFranchisee	Varchar(50)  
	)  
 
	Create Table #TempV5_UserRoles
	(
	PrimaryFlag		Char(1) Not Null Default 'N',
	GroupID			Int
	)

	Select 
		@UserID=Case When ColName='UserID' Then ColValue Else IsNull(@UserID,0) End,  
		@LoginLocationID=Case When ColName='LocationID' Then ColValue Else IsNull(@LoginLocationID,0) End,  
		@UserMangementLevel=Case When ColName='UserMangementLevel' Then ColValue Else IsNull(@UserMangementLevel,0) End,  
		@GroupID=Case When @Purpose='SRLS' and ColName='GroupID' Then ColValue Else IsNull(@GroupID,0) End,  
		@FilePath=Case When @Purpose='ACU' and ColName='FilePath' Then ColValue Else IsNull(@FilePath,'') End  
	From SPARCV5_FnGetRptFilters(@XMLFilters)  
  
	If IsNull(@UserCode,'')=''  
	Begin  
		Select @UserCode=IsNull(U.UserCode,''),@UserName=IsNull(U.UserName,'')   
		From GTL_Users U (Nolock) Where U.UserID=@UserID  
	End  
 
	If @Purpose='UMLC'			--User Mangament Level dropdown change  
	Begin  
		--Selecting Accessible Regions  

		If @UserMangementLevel In('N','S')  
		Begin  
			Select Row_Number() Over(Order By R.Description) as SlNo,'Y' as Checked,R.Region,  
			R.Description as [Region Name],R.RegionID
			From GTL_REGION (Nolock) R  Inner Join GTL_LOCATION (Nolock) L
			On(R.REGIONID=L.REGIONID)
			Where L.LOCATIONID=Case When @LoginLocationID<>'' Then @LoginLocationID Else LOCATIONID End  
		End  
		Else  
		Begin  
			Select Row_Number() Over(Order By R.Description) as SlNo,'Y' as Checked,R.Region,  
			R.Description as [Region Name],R.RegionID From GTL_Region R(Nolock)  
		End  
  
		--Selecting Accessible Locations  
		If @UserMangementLevel In('N','S')  
		Begin  
			Select Row_Number() Over(Order By L.Description) as SlNo,'Y' as Checked,L.BranchCode as Location,  
			L.Description as [Location Name],L.BranchID as LocationID,L.SBRegionID as RegionID   
			From SPARC_SBBranch L (Nolock)   
			Where L.LocationID=Case When @LoginLocationID<>0 Then @LoginLocationID Else L.LocationID End   
		End  
		Else  
		Begin  
			Select Row_Number() Over(Order By L.Description) as SlNo,'Y' as Checked,L.Location,  
			L.Description as [Location Name],L.LocationID,L.RegionID From GTL_Location L (Nolock)   
		End 
		
	End  
	Else If @Purpose In('F','SRLS')			--Main search,Secondary Role add  
	Begin    
	
		If @Purpose='F'  
		Begin  
			Select U.UserCode,U.UserName,U.TerminatedDate,U.TerminatedReason,L.LOCATIONID,L.Location,  
			L.Description as LocationName,R.Region,U.TelephoneNo,U.EmailID,U.Fax,U.IPAddress,  
			Ltrim(RTrim(U.Terminated)) as Terminated,U.IsWebUser,U.GroupID,G.Description as GroupName,  
			U.EUser,U.PayrollAccessRights,U.CompanyID,U.Department,U.IsWebUser,  
			U.Signature,U.PasswordExpire,U.ExpireDays,U.MachineWiseLogin,U.MachineName,U.EnablePasswordCount,  
			U.PasswordCount,U.PasswordEnabledDate,U.ChangePassword,U.CorpUser,  
			Case When LOCATION='HO' Then 'Y' Else IsNull(U.AccessInAllLocation,'N') End as AccessInAllLocation,  
			U.CompanyState as GeojitState  
			From GTL_Users U(Nolock) Left Outer Join GTL_Location (Nolock) L On(U.LocationID=L.LocationID)  
			Left Outer Join GTL_Region R(Nolock) On(U.RegionID=R.RegionID)  
			Left Outer Join GTL_UserGroups G(Nolock) On(U.GroupID=G.GroupID)  
			Where U.UserID=@UserID   

			Insert Into #Region  
			(  
			SlNo,Checked,Region,RegionName,RegionID  
			)  
			Exec GTL_SPGetUserAccessRegions @CompanyID=@CompanyID,@LangID=1,@UserCode=@UserCode   
			 
			Select SlNo,Checked,Region,RegionName [Region Name],RegionID From #Region T    
  
			Insert Into #Location  
			(  
			SlNo,Checked,Location,LocationName,LocationID,RegionID  
			)  
			Exec GTL_SPGetUserAccessLocations @CompanyID=@CompanyID,@LangID=1,@UserCode=@UserCode  
    
			Update T Set   
				T.BranchOrFranchisee=Case When L.BRANCH='N' Then 'Franchisee' Else 'Branch' End  
			From #Location T Inner Join GTL_LOCATION (Nolock) L  
			On(T.LocationID=L.LOCATIONID)  
  
			Select SlNo,Checked,Location,LocationName as [Location Name],LocationID,RegionID,BranchOrFranchisee  
			[Branch Or Franchisee]  
			From #Location  
  
			Select P.Length,P.LowerCase,P.UpperCase,P.Numeric,  
			P.NonAlphaNumeric,P.ApplyPwdPolicy From GTL_PasswordPolicy P(Nolock)  
			Where P.CompanyID=@CompanyID  
		End  
  
		If @Purpose='SRLS'  
		Begin  
			Select G.Description [Role],'N' as [Primary],IsNull(G.Remarks,'') Description,'' Button,G.GROUPID as GroupID  
			From GTL_USERGROUPS G(Nolock)    
			Where GroupID=@GroupID    
		End  
		Else  
		Begin  
			Select G.Description [Role],'Y' as [Primary],IsNull(G.Remarks,'') Description,'' Button,G.GROUPID as GroupID    
			From GTL_UserGroups G(Nolock)  Inner Join GTL_USERS (Nolock) U  
			On(G.GROUPID=U.GROUPID) Where U.USERID=@UserID  
			Union All  
			Select G.Description [Role],'N' as [Primary],IsNull(G.Remarks,'') Description,'' Button,G.GROUPID as GroupID   
			From GTL_USERGROUPS G(Nolock)    
			Where GroupID In (Select Cast(value as Int)   
			From GTL_Users (Nolock) U Cross Apply String_Split(U.RoleIds,',')  
			Where U.USERID=@UserID)  
		End  
  
		Select ''RightAlignCols,''LinkCols,'N' HTMLOutput, 'SlNo,LocationID,RegionID,GroupID' HiddenCols,'' SelectedRowColor  
	End  
	Else If @Purpose='S'  
	Begin  
	
		If IsNull(@UserRegions,'')=''  
		Begin  
			Raiserror('Select atleast one User Region',16,1)  
			Return  
		End  
    
		Select @XMLDetails=Cast(@XMLString as Xml)  
  
		Insert Into #TempV5_UserMaster  
		(
		Password,TerminatedDate,CurrentRegion,AccessInAllLocation,IPAddress,ConfirmPassword,Reason,Telephone,Email,Fax,
		UserGroup,UserManagementLevel,WebAccess,Terminated,PasswordExpire,MachineWiseLogin,DontAllowPreviousPwd,
		ChangePasswordNextLogin,ApplyToAllUser,ExpireDays,MacAddress,PasswordCount,ApplyPwdPolicy,MaximumPasswordLength,  
		LowerCase,UpperCase,Numeric,NonAlphaNumeric,Department
		)   
		Select Cast(colx.query('data(Password)') as Varchar(Max)) as Password,
		Cast(colx.query('data(TerminatedDate)') as Varchar(Max)) as TerminatedDate,  
		Cast(colx.query('data(CurrentRegion)') as Varchar(Max)) as CurrentRegion,  
		Cast(colx.query('data(AccessInAllLocation)') as Varchar(Max)) as AccessInAllLocation,
		Cast(colx.query('data(IPAddress)') as Varchar(Max)) as IPAddress,
		Cast(colx.query('data(ConfirmPassword)') as Varchar(Max)) as ConfirmPassword,  
		Cast(colx.query('data(Reason)') as Varchar(Max)) as Reason,  
		Cast(colx.query('data(Telephone)') as Varchar(Max)) as Telephone, 
		Cast(colx.query('data(Email)') as Varchar(Max)) as Email,
		Cast(colx.query('data(Fax)') as Varchar(Max)) as Fax,  
		Cast(colx.query('data(UserGroup)') as Varchar(Max)) as UserGroup,  
		Cast(colx.query('data(UserManagementLevel)') as Varchar(Max)) as UserManagementLevel, 
		Cast(colx.query('data(WebAccess)') as Varchar(Max)) as WebAccess,
		Cast(colx.query('data(Terminated)') as Varchar(Max)) as Terminated,  
		Cast(colx.query('data(PasswordExpire)') as Varchar(Max)) as PasswordExpire,  
		Cast(colx.query('data(MachineWiseLogin)') as Varchar(Max)) as MachineWiseLogin,
		Cast(colx.query('data(DontAllowPreviousPwd)') as Varchar(Max)) as DontAllowPreviousPwd,  
		Cast(colx.query('data(ChangePasswordNextLogin)') as Varchar(Max)) as ChangePasswordNextLogin,  
		Cast(colx.query('data(ApplyToAllUser)') as Varchar(Max)) as ApplyToAllUser,
		Cast(colx.query('data(ExpireDays)') as Varchar(Max)) as ExpireDays,  
		LTrim(RTrim(Cast(colx.query('data(MacAddress)') as Varchar(Max)))) as MacAddress,  
		Cast(colx.query('data(PasswordCount)') as Varchar(Max)) as PasswordCount,  
		Cast(colx.query('data(ApplyPwdPolicy)') as Varchar(Max)) as ApplyPwdPolicy,
		Cast(colx.query('data(MaximumPasswordLength)') as Varchar(Max)) as MaximumPasswordLength,  
		Cast(colx.query('data(LowerCase)') as Varchar(Max)) as LowerCase,  
		Cast(colx.query('data(UpperCase)') as Varchar(Max)) as UpperCase,  
		Cast(colx.query('data(Numeric)') as Varchar(Max)) as Numeric,  
		Cast(colx.query('data(NonAlphaNumeric)') as Varchar(Max)) as NonAlphaNumeric,  
		Cast(colx.query('data(Department)') as Varchar(Max)) as Department 
		From @XMLDetails.nodes('XMLDetails/XMLData') as Tabx(colx)    
  
		Insert Into #TempV5_UserRoles
		(
			PrimaryFlag,GroupID
		)
		Select PrimaryFlag,GroupID
		From
		(
			Select Cast(colx.query('data(Primary)') as Varchar(Max)) as PrimaryFlag,
			Cast(colx.query('data(GroupID)') as Varchar(256)) as GroupID
			From @XMLDetails.nodes('XMLDetails/XMLData/SecondaryGroup/XMLDetails/XMLData') as Tabx(colx)  
		)T

		If Not Exists(Select Top 1 Null From #TempV5_UserRoles Where PrimaryFlag='Y')  
		Begin  
			Raiserror('Select at least one primary role',16,1)  
			Return  
		End  
 
		Update T Set 
			T.UserID=@UserID 
		From #TempV5_UserMaster T  
  
		Update T Set 
			T.Region=R.RegionID 
		From #TempV5_UserMaster T Inner Join GTL_Region (Nolock) R  
		On(Ltrim(RTrim(T.CurrentRegion))=Ltrim(RTrim(R.Region)))  
  
		Select @AccessInAllLocation=AccessInAllLocation,@GroupID=UserGroup,@ApplyToAllUsers=ApplyToAllUser,  
		@ChangePassWord=ChangePasswordNextLogin,@PasswordExpire=PasswordExpire,@ExpireDays=ExpireDays,  
		@MachineWiseLogin=MachineWiseLogin,@MachineName=MacAddress,@EnablePasswordCount=DontAllowPreviousPwd,  
		@PasswordCount=PasswordCount,@CorpUser=UserManagementLevel  
		From #TempV5_UserMaster 
		
		Select @GroupID=R.GroupID From #TempV5_UserRoles R Where R.PrimaryFlag='Y' 
  
		If @GroupID Is Null
		Begin  
			Raiserror('Please select User Role.',16,1)  
			Return  
		End  
 
		Select @GroupName=G.Description From GTL_UserGroups G(Nolock) 
		Where G.GroupID=@GroupID and G.CompanyID=@CompanyID  
    
		Select @XMLDetails = Cast(@UserRegions as XML)    
  
		Insert Into #TempV5_AccessRegions(RegionID)  
		Select RegionID  
		From  
		(    
			Select Cast(colx.query('data(RegionID)') as Varchar(100)) as RegionID    
			From @XMLDetails.nodes('XMLDetails/XMLData') as Tabx(colx)    
		)T    
  
		Select @XMLDetails = Cast(@UserLocations as XML)    
  
		Insert Into #TempV5_AccessLocations(LocationID)  
		Select LocationID From  
		(    
			Select Cast(colx.query('data(LocationID)') as Varchar(100)) as LocationID    
			From @XMLDetails.nodes('XMLDetails/XMLData') as Tabx(colx)    
		)T    
  
		If @CorpUser='N' and Exists  
		(  
			Select Top 1 Null From #TempV5_AccessLocations T Inner Join SPARC_SBBranch SB(Nolock) 
			On(T.LocationID=SB.BranchID)  
			Where SB.LocationID<>@LoginLocationID  
		)  
		Begin  
			RAISERROR('Multiple branch access does not permitted for specified user.',16,1)  
			Return  
		End  
  
		If @CorpUser='N' and Exists  
		(  
			Select Top 1 Null From #TempV5_AccessRegions T Inner Join SPARC_SBRegion SB (Nolock) On (T.RegionID=SB.RegionID)  
			Inner Join GTL_Location (Nolock) L On(L.Location=SB.SubBrokerCode)  
			Where L.LocationID<>@LoginLocationID  
		)  
		Begin  
			RAISERROR('Multiple branch access does not permitted for specified user.',16,1)  
			Return  
		End  
  
		Set @UserRegions=''  
		Select @UserRegions=@UserRegions+','+Ltrim(RegionID) From #TempV5_AccessRegions(Nolock)  
    
		If IsNull(@UserRegions,'')<>''   
		Begin  
			Set @UserRegions=Substring(@UserRegions,2,Len(@UserRegions))  
		End  

		Set @UserLocations=''  

		Select @UserLocations=@UserLocations+','+Ltrim(LocationID) 
		From  #TempV5_AccessLocations(Nolock)  
    
		If IsNull(@UserLocations,'')<>''  
		Begin  
			Set @UserLocations=Substring(@UserLocations,2,Len(@UserLocations))  
		End  
   
		If @GroupName='Administrators' Or @GroupName='Management' and @CorpUser='Y'   
		Begin    
			Set @UserType='CO-CO'    
			Set @QueryLevel='CORP'    
		End    

		Else If @GroupName='Regional Managers'  and @CorpUser='Y'   
		Begin      
			
			Set @UserType='CO-RM'    
			
			If @AccessInAllLocation='Y'    
				Set @QueryLevel='CORP'    
			Else If charIndex(',',@UserRegions)>0     
				Set @QueryLevel='CORPMULTI'    
			Else    
				Set @QueryLevel='CORPREGION' 
				
		End    	
		Else If @GroupName='Branch Managers' and @CorpUser='Y'  
		Begin  
		
			Set @UserType='CO-BM'    
    
			If @AccessInAllLocation='Y'    
			 Set @QueryLevel='CORP'    
			Else If charIndex(',',@UserLocations)>0     
			 Set @QueryLevel='CORPMULTI'    
			Else    
			 Set @QueryLevel='SB'   
			 
		End    
		Else If @GroupName='Subbroker' and @CorpUser='Y'   
		Begin    
			Set @UserType='SB-SB'    
			Set @QueryLevel='SB'    
		End    
		Else     
		Begin    
			If @CorpUser='N'  
			Begin  
				Set @UserType='SB-BM'    
				Set @QueryLevel='SBMULTI'  
			End  
			Else  
			Begin  
				Set @UserType='CO-NORMAL'   
    
				If @AccessInAllLocation='Y'    
					Set @QueryLevel='CORP'    
				Else If CharIndex(',',@UserLocations)>0    
					Set @QueryLevel='CORPMULTI'    
				Else    
					Set @QueryLevel='SB'   
			End   
		End     
  
	Begin Try  
	Begin Tran  
		
		If Exists(Select Top 1 Null From GTL_Users U(Nolock) Where U.UserID=@UserID and U.CompanyID=@CompanyID)  
		Begin       
			If IsNull(@Password,'')=''  
			Begin  
				Select @Password=U.Password From GTL_Users U(Nolock) Where U.UserID=@UserID  
			End  
			Else  
			Begin  
				Select @Password= Cast(N'' as xml).value('xs:base64Binary(xs:hexBinary(sql:column("UserPwd")))','nvarchar(4000)')  
				From (Select HashBytes('SHA1',Password) UserPwd From #TempV5_UserMaster) X  
			End  


			Update G Set 
				G.Region=T.CurrentRegion,G.RegionID=T.Region,G.LocationID=@LoginLocationID,G.EmailID=T.Email,    
				G.Terminated=T.Terminated,Password=Ltrim(RTrim(@Password)),G.IsWebUser=T.WebAccess,
				G.Lastupdatedon=GETDATE(),G.EUser=@Euser,G.TelephoneNo=T.Telephone,
				G.Fax=T.Fax,				
				G.Department=T.Department,    
				G.PasswordExpire=T.PasswordExpire,G.ExpireDays= T.ExpireDays,G.MachineWiseLogin=T.MachineWiseLogin,  
				G.MachineName=T.MacAddress,G.EnablePasswordCount=T.DontAllowPreviousPwd,G.PasswordCount=T.PasswordCount,  
				G.CORPUSER=@CorpUser,G.TerminatedDate=Case When T.TerminatedDate='' Then Null Else T.TerminatedDate End,  
				G.TerminatedReason=T.Reason,G.AccessInAllLocation=T.AccessInAllLocation,G.UserType=@UserType,
				G.MaxQueryLevel=@QueryLevel
			From GTL_Users G Inner Join #TempV5_UserMaster T 
			On(G.UserID=T.UserID)  
			Where G.UserID=@UserID  and CompanyID=@CompanyID     
    
			Update G Set
				G.GROUPID=R.GroupID
			From GTL_Users G,#TempV5_UserRoles R 
			Where  G.UserID= @UserID and R.PrimaryFlag='Y' and G.CompanyID=@CompanyID and G.LangID=1  

			Update G Set 
				G.UserName=Ltrim(RTrim(@UserName)),   
				G.RoleIds= (
							Select String_Agg(R.GroupID,',') From #TempV5_UserRoles R
							Where IsNull(R.PrimaryFlag,'N')='N'
							)
			From GTL_Users G
			Where G.USERID=@UserID and G.COMPANYID=@CompanyID and G.LANGID=1    
		End  
		Else  
		Begin   
			Select @Password= Cast(N'' as xml).value('xs:base64Binary(xs:hexBinary(sql:column("UserPwd")))','nvarchar(4000)')  
			From (Select HashBytes('SHA1',Password) UserPwd From #TempV5_UserMaster) X     
  
			If Exists(Select Top 1 Null From GTL_Users U(Nolock) Where U.UserCode=@UserCode and U.CompanyID=@CompanyID )  
			Begin  
				Set @Msg='User Code '+ @UserCode +' already exists.'    
				RAISERROR (@Msg,16,24)    
				Rollback Tran  
				Return    
			End    
		
			Exec spGenerateKeyForOutput 'UserID',1,@Euser,@UserID OutPut  
     
			Insert Into GTL_Users  
			(  
			CompanyID,LangID,UserID,UserCode,UserName,Password,LocationID,EmailID,EUser,LastUpdatedOn,    
			Region,RegionID,Terminated,GroupID,Fax,TelephoneNo,Department,IsWebUser,PasswordExpire,ExpireDays,    
			MachineWiseLogin,MachineName,EnablePasswordCount,PasswordCount,PasswordEnabledDate,CorpUser,  
			TerminatedDate,TerminatedReason,AccessInAllLocation,UserType,MaxQueryLevel,IPAddress  
			)    
			Select @CompanyID,1,@UserID,Ltrim(RTrim(@UserCode)),Ltrim(RTrim(@UserName)),Ltrim(RTrim(@Password)),  
			@LoginLocationID,T.Email,@Euser as UserCode,GetDate() as LastUpdatedOn,T.CurrentRegion,T.Region,T.Terminated,  
			T.UserGroup,T.Fax,T.Telephone,T.Department,T.WebAccess,T.PasswordExpire,T.ExpireDays,T.MachineWiseLogin,  
			T.MacAddress,T.DontAllowPreviousPwd,T.PasswordCount,GetDate() as PasswordEnabledDate,@CorpUser,  
			Case When T.TerminatedDate='' Then Null Else T.TerminatedDate End,T.Reason,T.AccessInAllLocation,  
			@UserType,@QueryLevel,T.IPAddress From #TempV5_UserMaster T  
		End  
    
		Select @SUserID=Case When @ApplyToAllUsers='Y' Then 0 Else @UserID End  
  
		Exec SPUpdateUserSecurity @PasswordExpire=@PasswordExpire,@ExpireDays=@ExpireDays,@MachineWiseLogin=@MachineWiseLogin,    
		@MachineName=@MachineName,@EnablePasswordCount=@EnablePasswordCount,@PasswordCount=@PasswordCount,@UserID=@SUserID,    
		@CompanyID=@CompanyID,@ChangePassword=@ChangePassword,@Euser=@Euser,@Channel=5     
    
		If Not Exists(Select Top 1 Null From GTL_WUserLocationsnew L(Nolock) Where UserID=@UserID  and CompanyID=@CompanyID)   
		Begin   
			Insert GTL_WUserLocationsnew  
			(  
			LangID,UserID,UserCode,LocationID,RegionID,AccessLocations,CompanyID  
			)    
			Select 1 as LangID,@UserID,@UserCode,@UserLocations,@UserRegions,@UserLocations,@CompanyID     
		End    
		Else    
		Begin  
			Update G Set 
				G.UserCode=@UserCode,G.LocationID=@UserLocations,G.RegionID=@UserRegions,  
				G.AccessLocations=@UserLocations 
			From GTL_WUserLocationsNew G  
			Where G.UserID=@UserID and G.CompanyID=@CompanyID  
		End   
     
		Delete P From GTL_PasswordPolicy P Where P.CompanyID=@CompanyID;  
  
		Insert Into GTL_PasswordPolicy  
		(  
		CompanyID,Length,ApplyPwdPolicy,LowerCase,UpperCase,Numeric,NonAlphaNumeric,EUser,LastUpdatedOn     
		)  
		Select @CompanyID,T.MaximumPasswordLength,IsNull(T.ApplyPwdPolicy,'N') as ApplyPwdPolicy,  
		IsNull(T.LowerCase,'N') as LowerCase,IsNull(T.UpperCase,'N') as UpperCase,  
		IsNull(T.Numeric,'N') as Numeric,IsNull(T.NonAlphaNumeric,'N') as NonAlphaNumeric,     
		@Euser as Euser,GetDate() as LastUpdatedOn  
		From #TempV5_UserMaster T  
     
		Insert Into GTL_WUserViewLogin  
		(  
		ModuleID,UserCode,LocationId,WDate,Time,ComputerID,CompanyId  
		)      
		Select 13,@Euser,@LoginLocationID,Cast(Year(GETDATE()) as Varchar(4)) + '/' +   
		Cast(Month(GETDATE()) as Varchar(2)) +'/' + Cast(Day(GETDATE()) as Varchar(2))  as WDate,  
		Cast(DatePart(hh,GETDATE())as Varchar(3)) + ':' + Cast(DatePart(mi,GETDATE()) as Varchar(3)) +   
		':' + Cast(DatePart(ss,GETDATE()) as Varchar(3))  as Time,T.IPAddress,@CompanyID  
		From #TempV5_UserMaster T  
  
		Select 'Data saved successfully.' as ResponseMsg  
		Commit Tran  
	
	End Try  
	Begin Catch  
		If @@Trancount <> 0  
		Begin  
		 Rollback Tran  
		End  
		Select @Msg=Error_Message()  
		RAISERROR(@Msg,16,1)  
		Return  
	End Catch  
	End  
	Else If @Purpose In('ACU')			--Additional Client Upload  
	Begin  
		
		Declare @SQL Varchar(4000)  
		
		Create Table #Temp_UserClientMapping  
		(  
		UserCode	Varchar(25),  
		CIN			Varchar(25),  
		UCC			Varchar(15) 
		)  
	
		Begin Try    

			Set @SQL ='Bulk Insert #Temp_UserClientMapping From '''+@FilePath+  
			''' With(FieldTerminator='','',RowTerminator=''0x0a'',FirstRow=2)'   
			Exec(@SQL) 
			
		End Try  
		Begin Catch  

			Select @Msg=Case When @UserCode='GIT' Then Error_Message()   
			Else 'Failed to upload the file due to invalid file format.' End  
			RAISERROR(@FilePath,16,1)  
			Return  

		End Catch  
  
		Begin Try  
		Begin Tran  
			
			Delete M From GTL_UserClientMapping M   
			Inner Join #Temp_UserClientMapping T On(M.UserCode=T.UserCode and M.CIN=T.CIN)  
  
			Insert Into GTL_UserClientMapping  
			(  
			UserCode,CIN,UCC,Euser,LastUpdatedOn  
			)  
			Select T.UserCode,T.CIN,T.UCC,@Euser as Euser,GetDate() LastUpdatedOn  
			From #Temp_UserClientMapping T  
  
			Select 'File uploaded successfully.' as ResponseMsg  
			Commit Tran  
		End Try  
		Begin Catch  
			If @@Trancount <> 0  
			Begin  
			 Rollback Tran  
			End  
			Select @Msg=Error_Message()  
			RAISERROR(@Msg,16,1)  
			Return  
		End Catch  
	End  
	
	Drop Table #TempV5_UserRoles
	Drop Table #Region
	Drop Table #Location
	Drop Table #TempV5_AccessRegions  
	Drop Table #TempV5_AccessLocations  
	Drop Table #TempV5_UserMaster 
	
	Set Nocount Off  

End



GO
