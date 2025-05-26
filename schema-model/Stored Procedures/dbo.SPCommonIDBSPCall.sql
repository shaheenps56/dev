SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
 
CREATE Proc [dbo].[SPCommonIDBSPCall](@SpCode Varchar(100))
/*
 Exec SPCommonIDBSPCall  'GetUserRights'
*/

as
Begin
	Set NoCount On

	Select T.SPID,T.SPNAME
	From Tbl_IDBSP T(Nolock) Where SPCode=@SpCode
End



GO
