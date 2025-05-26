SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [dbo].[getPopupSettings] 
     @UserCode varchar(20) 
AS
BEGIN
SET NOCOUNT ON

insert into rmstestlog(spname,remarks)
	values('getPopupSettings','start')

	SELECT USERCODE,EMAILID,MOBILENUMBER,RMSMAILANDSMS,POPUPSETTINGS  FROM USERS(nolock) where USERCODE = @UserCode

END

GO
