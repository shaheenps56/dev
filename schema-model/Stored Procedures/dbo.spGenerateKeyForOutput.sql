SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Proc [dbo].[spGenerateKeyForOutput] 
(
	@KeyName		Varchar(50),
	@CompanyId		Integer,
	@Euser			Varchar(12),
	@NewKey			Varchar(25)output
) 
As
Begin
	set nocount on    
   	set ansi_warnings off
	Declare @NewId Numeric(15,0)
	/* To generate new keyvalue depends on the 
	parameter passed */
	
	Update GTL_KeyTable  set @NewId=NewKey = NewKey + 1,Euser=@Euser,LastUpdatedon=getDate()
	where keyname = @KeyName and CompanyId = @CompanyId
	
	If (@@rowcount=0) 
	Begin
		/* We may have to add setting table parameter here  --- ABK*/
		Set @NewId = 1000
		Insert GTL_KeyTable(KeyName,NewKey,LastUpdatedon,Euser,CompanyId) 
		values(@KeyName,@NewId,getdate(),@Euser,@CompanyId)
		Set @NewKey=Ltrim(Cast (@NewId as Int))
	End
	Else
	Begin
		Set @NewKey=Ltrim(Cast (@NewId as Int))
	End   
End
GO
