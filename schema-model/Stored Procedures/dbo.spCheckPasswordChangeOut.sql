SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Exec spCheckPasswordChangeOut 'GIT',1
--Return 0 for no change of password, 1 for change password, 2 for Password expired
Create Proc [dbo].[spCheckPasswordChangeOut]
(
	@UserCode nvarchar(10),
	@CompanyId Int,
	@Out Int Output
) AS 
BEGIN
	Declare @PassDate dateTime,@ExpireDay Int,@PasswordExpire Char(1)
	Select @ExpireDay=0, @PasswordExpire='N'
	If (Select Top 1 ChangePassword From GTL_Users Where UserCode=@UserCode and CompanyID=@CompanyId)='Y'
		Set @Out= 1
	Else
	Begin
		Select	@PassDate=PasswordEnabledDate,@ExpireDay=ExpireDays,
				@PasswordExpire=PasswordExpire 
		From	GTL_Users 
		Where	UserCode=@UserCode and CompanyID=@CompanyId
		If @PasswordExpire='N'
			Set @Out= 0
		Else
			If (Dateadd(day,@ExpireDay,@PassDate))<GetDate() 
				Set @Out= 2
			Else
				Set @Out= 0
	End
	Return @Out
END
GO
