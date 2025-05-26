SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE Proc [dbo].[SpCommonSpCall](@SpID INT)as
Begin
	Set NoCount On

	Select T.SPID,T.SPNAME,T.TransactionRequired,T.Readonly_Connection,
	Cast(T.TTL as Varchar(20)),T.CacheMechanism 
	From Tbl_SP T(Nolock) Where SpId=@SpID
End
GO
