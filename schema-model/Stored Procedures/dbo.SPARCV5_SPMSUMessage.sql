SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE Proc [dbo].[SPARCV5_SPMSUMessage]
(
	@Usercode		Varchar(25),
	@Version		Varchar(100),
	@ProjectID		Int=-1,
	@XMLFilters		Varchar(Max)=''
)
As
/************************************************************************************************
Created By	:	Paul Mathew
Created On	:	30-09-2022
Purpose		:	MSU Message
Test		:	Exec SPARCV5_SPMSUMessage @Usercode='GIT',@Version=''
*************************************************************************************************/
Begin
	Set Nocount On
	Declare @UserName Varchar(500)='',@DashboardContent Varchar(Max)='',@DashboardHeader Varchar(200)=''

	Select @UserName=IsNull(U.UserName,'') From GTL_Users U(Nolock) Where U.UserCode=@Usercode

	Exec spSparc_MSUMessage @User=@Usercode

	Select @DashboardContent=DashboardContent,@DashboardHeader=DashboardHeader
	From dbo.SPARCV5_FnGetDashboardContent(@ProjectID,@Usercode)

	If IsNull(@DashboardContent,'')=''
	Begin
		Select Top 0 @DashboardContent as DashboardContent,@DashboardHeader as DashboardHeader,
		'N' ShowGreeting,'' GreetingHeader,'' as GreetingContent
	End
	Else
	Begin
		Select @DashboardContent as DashboardContent,@DashboardHeader as DashboardHeader,
		'Y' ShowGreeting,'' GreetingHeader,@DashboardContent as GreetingContent
	End

	--Profile Photo
	Select ProfileImgUrl=IsNull(CAST('' AS XML).value('xs:base64Binary(sql:column("FileImage"))','VARCHAR(MAX)'),'')
	From 
	(
		Select FileImage=Cast(P.FileImage as Varbinary(Max)) From GTL_UserProfileImage P(Nolock) Where P.UserCode=@UserCode
	) D

	Set Nocount Off
End
GO
