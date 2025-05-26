SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [dbo].[getUserDetails] 
AS
BEGIN
SET NOCOUNT ON
	insert into rmstestlog(spname,remarks)
	values('getUserDetails','start')

	SELECT u.UserCode, u.UserName, u.MOBILENUMBER, u.EmailID, u.Rmspopupsettings, u.Rmsmailandsms, u.Location, u.Region,
       loc.emailid AS branchmailid,u.PARENTUSERS
	FROM users(nolock) u, LOCATION(nolock) loc
	WHERE u.location=loc.location
END

GO
