SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Function [dbo].[fnGetMLAccessLocation]
(
	@UserCode VARCHAR(40)
)
RETURNS @AccessLocation TABLE
(
	[AllLocationID] VARCHAR(100)
)
AS 
BEGIN
	Declare @NEWUSERRIGHTS Varchar(10)='N'
	Select @NEWUSERRIGHTS=Value From GTL_AppConfig Where parameter='NEWUSERRIGHTS'
	If IsNull(@NEWUSERRIGHTS,'N')='Y'
	Begin
		Insert Into @AccessLocation
		Select * From dbo.fnGetMLAccessLocation_V1 (@UserCode)
		Return
	End
	DECLARE @QueryLevel CHAR(16)
	SET @QueryLevel = ''
	DECLARE @AccessAll CHAR(1)
	SET @AccessAll = ''

	SELECT  @QueryLevel = MaxQueryLevel ,
			@AccessAll = AccessInAllLocation
	FROM    GTL_Users (nolock)
	WHERE   USERCODE = @UserCode
			AND COMPANYID = 1

	DECLARE @Access VARCHAR(MAX)
	SET @Access = ''
	IF ( UPPER(@QueryLevel) IN ('SBMULTI','SBBRANCH','SBREGION') ) 
		BEGIN

			IF ( @AccessAll = 'Y' ) 
				BEGIN
					INSERT  INTO @AccessLocation
							SELECT  BranchId
							FROM    viewbranchdetails
					RETURN 
				END

			SELECT  @Access = AccessLocations + ','
			FROM    GTL_BranchWUserLocations W (nolock),
					GTL_Users U (nolock)
			WHERE   U.USERCODE = @UserCode
					AND W.UserId = U.UserId
					AND U.AccessInAllLocation = 'N'
					AND isnull(AccessLocations,'') <> ''
	END
	ELSE 
		BEGIN
			IF ( @AccessAll = 'Y' ) 
				BEGIN
					INSERT  INTO @AccessLocation
							SELECT  LOCATIONID
							FROM    dbo.GTL_LOCATION (nolock)
					RETURN 
				END
			SELECT  @Access = AccessLocations + ','
			FROM    GTL_WuserLocationsNew W (nolock),
					GTL_Users U (nolock)
			WHERE   U.USERCODE = @UserCode
					AND W.UserId = U.UserId
					AND U.AccessInAllLocation = 'N'
					AND isnull(AccessLocations,'') <> ''
		END

	INSERT  INTO @AccessLocation
	SELECT Distinct Items FROM dbo.Split(@Access, ',')

	RETURN
END
GO
