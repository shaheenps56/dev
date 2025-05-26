SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Function [dbo].[SPARCV5_FnGetRptType](@UserCode Varchar(25),@Channel Int) Returns @Results Table 
(
	Code Int,
	Description Varchar(100),
	Icon Varchar(100),
	ToolTipLabel Varchar(100)
)   
As
/*****************************************************************************************************************
Created By	: Paul Mathew
Created on	: 15-05-2023
Project		: SPARC
Purpose		: For getting report type values
Test		: Select * From SPARCV5_FnGetRptType('GIT',1)
******************************************************************************************************************/
Begin
	Insert Into @Results(Code,Description,Icon,ToolTipLabel)
	--Select 1 as Code,'HTML' as Description,'' as Icon
	--Union All
	Select 2 as Code,'Pdf' as Description,'pi pi-file-pdf' as Icon,'Pdf File' as ToolTipLabel
	Union All
	Select 3 as Code,'Excel' as Description,'pi pi-file-excel' as Icon,'Excel File' as ToolTipLabel
	--Union All
	--Select 9 as Code,'Clear' as Description,'pi pi-times' as Icon
	Return
End
GO
