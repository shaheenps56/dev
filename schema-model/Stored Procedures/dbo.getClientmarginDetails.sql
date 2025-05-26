SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--CREATE OR ALTER PROCEDURE dbo.InsertUsers 
--    @UserCode varchar(20), 
--	@EmailID varchar(200), 
--	@MOBILENUMBER varchar(30),
--	@RMSMAILANDSMS varchar(50), 
--	@POPUPSETTINGS varchar(50), 
--	@BRANCHEMAILID varchar(200),
--	@USERNAME varchar(200), 
--	@LOCATION varchar(50), 
--	@REGION varchar(50),
--	@PARENTUSERS varchar(2000)
--AS
--BEGIN
--SET NOCOUNT ON
--	INSERT INTO users(UserCode, EmailID, MOBILENUMBER, RMSMAILANDSMS, POPUPSETTINGS, BRANCHEMAILID, USERNAME, LOCATION, REGION,PARENTUSERS)
--	VALUES(@UserCode, @EmailID, @MOBILENUMBER, @RMSMAILANDSMS, @POPUPSETTINGS, @BRANCHEMAILID, @USERNAME, @LOCATION, @REGION,@PARENTUSERS)

--END

--GO

CREATE   PROCEDURE [dbo].[getClientmarginDetails]
    @UserCode varchar(20)
AS
BEGIN
SET NOCOUNT ON
insert into rmstestlog(spname,remarks)
	values('getClientmarginDetails','start')
	select  * from clientmargin(nolock) where usercode=@UserCode
END

GO
