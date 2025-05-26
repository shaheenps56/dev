SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Function [dbo].[SPARCV5_FnGetAppControlsColor](@Type Varchar(500)='') Returns Varchar(500) As
/********************************************************************************
Created By	: Paul
Created on	: 10.06.2023
Project		: SPARCV5
Purpose		: For getting front end controls colors 
Test		: Select dbo.SPARCV5_FnGetAppControlsColor('SELECTEDROW')
**********************************************************************************/
Begin
	Declare @Color Varchar(500)
	If @Type='SELECTEDROW' --Table selected row color
	Begin
		Select @Color='#f0f1f2'
	End

	Return @Color
End
GO
