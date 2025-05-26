SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--FindSp 60
-- To find SpNames using its spid
CREATE Procedure [dbo].[FindSp](@spid int = 0)
As
Begin
	Declare @spname as varchar(250);

	Select @spname=isnull(SPNAME,'Sp Not Found!!!') from TBL_SP where SPID=@spid;
	Select isnull(@spname,'Sp Not Found!!!') as 'SP Name';

	If (@spname<>'Sp Not Found!!!')
	Exec Sp_HelpTextGtl @spname;

End
GO
