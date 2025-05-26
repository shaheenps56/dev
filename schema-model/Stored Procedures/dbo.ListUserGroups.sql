SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[ListUserGroups]
    @CompanyID INT = 1 -- Default to COMPANYID = 1; modify as needed
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        GROUPID,
        DESCRIPTION
    FROM 
        GTL_UserGroups
    WHERE 
        COMPANYID = @CompanyID -- Specify the company ID
    ORDER BY 
        DESCRIPTION;
END
GO
