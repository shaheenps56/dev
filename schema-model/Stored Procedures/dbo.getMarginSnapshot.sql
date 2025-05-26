SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [dbo].[getMarginSnapshot]
    @rmsDbNo INT,
    @orderingUserCode VARCHAR(30),
    @location VARCHAR(20),
    @clientType VARCHAR(20),
    @region VARCHAR(20),
    @percentage DECIMAL(20, 4),
    @eodMvPercentage DECIMAL(18, 4),
    @peakMvPercentage DECIMAL(18, 4),
    @mtfPercentage DECIMAL(18, 4),
    @boClientType VARCHAR(20),
    @debtVal DECIMAL(20, 6),
    @productType INT,
    @segment INT,
    @getEnableMtmViolation INT
AS
/*
 exec getMarginSnapshot 2,'','','','',0,0,0,0,'',0,0,0,0
*/
BEGIN
    SET NOCOUNT ON;

    DECLARE @sql NVARCHAR(MAX) = N'
    SELECT CM.REGION,
        CM.LOCATION,
        CM.USERCODE,
        CM.TOTALMTMPER,
        CM.NEWTOTALMTM,
        CM.RTCOLLATERAL,
        CM.EODMVPERC,
        CM.EODMARGIN,
        CM.EODCOLLATERAL,
        CM.PEAKMVPERC,
        CM.PEAKMARGIN,
        CM.PEAKCOLLATERAL,
        CM.MTFPERC,
        CM.MTFMARGIN,
        CM.MTFCOLLATERAL,
        CM.SQUAREOFFENABLE,
        CM.REMARKS AS REMARK,
        CM.RTDEBIT,
        MARGINREQ,
        OPTMRKTVAL
    FROM CLIENTMARGINSNAPSHOT CM(nolock) '; 

    DECLARE @whereClause NVARCHAR(MAX) = N'WHERE 1=1 ';

    IF @rmsDbNo > 1
        SET @whereClause += N'AND CM.RMSDBNUMBER = @rmsDbNoParam ';

    IF @orderingUserCode <> ''
        SET @whereClause += N'AND CM.USERCODE = @orderingUserCodeParam ';

    IF @location <> ''
        SET @whereClause += N'AND CM.LOCATION = @locationParam ';

    IF @clientType <> ''
        SET @whereClause += N'AND CM.CLIENTTYPE = @clientTypeParam ';

    IF @region <> ''
        SET @whereClause += N'AND CM.REGION = @regionParam ';

    IF @percentage <> 0
        SET @whereClause += N'AND CM.TOTALMTMPER >= @percentageParam ';

    IF @eodMvPercentage <> 0
        SET @whereClause += N'AND CM.EODMVPERC >= @eodMvPercentageParam ';

    IF @peakMvPercentage <> 0
        SET @whereClause += N'AND CM.EODMVPERC >= @peakMvPercentageParam ';

    IF @mtfPercentage <> 0
        SET @whereClause += N'AND CM.MTFPERC >= @mtfPercentageParam ';

    IF @boClientType <> ''
        SET @whereClause += N'AND CM.BOCLIENTTYPE = @boClientTypeParam ';

    IF @debtVal <> 0
        SET @whereClause += N'AND CM.RTDEBIT <= @debtValParam * (-1) ';

    IF @productType <> 0
    BEGIN
        SET @whereClause += N'AND CM.USERCODE IN (SELECT DISTINCT USERCODE FROM PORTFOLIO WHERE PORTFOLIOTYPE = @productTypeParam ';

        IF @productType IN (1, 7, 9)
        BEGIN
            IF @productType = 1
                SET @whereClause += N'AND VENUECODE IN (''NSE'',''BSE'',''NSEMF'',''BSEMFD'') ';
            ELSE IF @productType = 7
                SET @whereClause += N'AND VENUECODE IN (''NSEFO'',''NSECD'') ';
            ELSE IF @productType = 9
                SET @whereClause += N'AND VENUECODE IN (''MCX'',''NCDEX'',''NSECOM'',''BSECOM'') ';
        END

        SET @whereClause += N') ';
    END

    IF @segment <> 0
        SET @whereClause += N'AND RISKMANAGEMENT = @segmentParam ';

    SET @sql += @whereClause;

    IF @getEnableMtmViolation = 0
        SET @sql += N'ORDER BY CM.TOTALMVPER DESC ';
    ELSE
        SET @sql += N'ORDER BY CM.TOTALMVPER DESC ';


    EXEC sp_executesql @sql,
        N'@rmsDbNoParam INT, @orderingUserCodeParam VARCHAR(30), @locationParam VARCHAR(20), @clientTypeParam VARCHAR(20), @regionParam VARCHAR(20), @percentageParam DECIMAL(20,4), @eodMvPercentageParam DECIMAL(18,4), @peakMvPercentageParam DECIMAL(18,4), @mtfPercentageParam DECIMAL(18,4), @boClientTypeParam VARCHAR(20), @debtValParam DECIMAL(20,6), @productTypeParam INT, @segmentParam INT',
        @rmsDbNo, @orderingUserCode, @location, @clientType, @region, @percentage, @eodMvPercentage, @peakMvPercentage, @mtfPercentage, @boClientType, @debtVal, @productType, @segment;

END;
GO
