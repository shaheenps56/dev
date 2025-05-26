SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [dbo].[InsertToClientRtPledge] 
    @USERCODE varchar(20),
	@ISIN varchar(20),
	@PortfolioType int,
	@PledgeQty decimal(18,6)
AS
BEGIN
SET NOCOUNT ON
insert into rmstestlog(spname,remarks)
	values('InsertToClientRtPledge','start')

	INSERT INTO CLIENTRTPLEDGE(USERCODE,ISIN,PortfolioType,PledgeQty)
	values(@USERCODE,@ISIN,@PortfolioType,@PledgeQty)
END

GO
