SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [dbo].[getSecurityDetails] 
    @pfCol decimal(20,4),
    @pfColval decimal(20,4)
AS
/*
	exec getSecurityDetails '1','1'
*/
BEGIN
SET NOCOUNT ON
insert into rmstestlog(spname,remarks)
	values('getSecurityDetails','start')

	SELECT s.VENUECODE ,s.VENUESCRIPCODE from security(nolock)s  where CONCAT_WS('.', s.VENUECODE , s.VENUESCRIPCODE ) 
	in (select CONCAT_WS('.', p.VENUECODE , p.VENUESCRIPCODE ) from PORTFOLIO(nolock) p where @pfCol= @pfColval or 1=1);

	--DECLARE @sql NVARCHAR(MAX);
    
	--SET @sql =N'SELECT s.VENUECODE ,s.VENUESCRIPCODE from security(nolock)s  where CONCAT_WS(''.'', s.VENUECODE , s.VENUESCRIPCODE ) 
	--in (select CONCAT_WS(''.'', p.VENUECODE , p.VENUESCRIPCODE ) from PORTFOLIO(nolock) p where ' + QUOTENAME(@pfCol) + '= @pfColval or 1=1)';


 --   EXEC sp_executesql @sql,  
 --   N'@pfColval VARCHAR(100)',  
 --   @pfColval;
END


GO
