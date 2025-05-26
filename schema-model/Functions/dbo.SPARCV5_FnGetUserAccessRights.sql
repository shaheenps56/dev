SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE Function [dbo].[SPARCV5_FnGetUserAccessRights]
(
	@UserCode	Varchar(25),
	@AccessLevel Varchar(10)
) 
Returns @Results Table 
(
	GroupID			Int,
	ProjectID		Int,
	ModuleID		Int,
	AddRight		Varchar(1),
	ModifyRight		Varchar(1),
	DeleteRight		Varchar(1),
	PreviewRight	Varchar(1),
	PrintRight		Varchar(1),
	ShowMenu		Varchar(1),
	ExportRight		Varchar(1),
	SpecialRight	Varchar(1),
	ModuleName		Varchar(100)
)   
As
/* ***************************************************************************************************
Created By	: Paul Mathew
Created on	: 08-11-2024
Project		: SPARC
Purpose		: For getting user module access based on assigned roles(Primary & Secondary)
Test		: Select * From SPARCV5_FnGetUserAccessRights('02108','N')
	MOD:001 : On 07052025 By Dipu - Adding the special rights items along wth the menues if project if is given
**************************************************************************************************** */
Begin
	Insert Into @Results
	(
		GroupID,ProjectID,ModuleID,AddRight,ModifyRight,DeleteRight,PreviewRight,
		PrintRight,ShowMenu,ExportRight,SpecialRight,ModuleName
	)
	Select R.GroupID,R.ProjectID,R.ModuleID,Max(IsNull(R.AddRight,'N')) as AddRight,
		Max(IsNull(R.ModifyRight,'N')) as ModifyRight,Max(IsNull(R.DeleteRight,'N')) as DeleteRight,
		Max(IsNull(R.PreviewRight,'N')) as PreviewRight,Max(IsNull(R.PrintRight,'N')) as PrintRight,
		Max(IsNull(R.ShowMenu,'N')) as ShowMenu,Max(IsNull(R.ExportRight,'N')) as ExportRight,
		Max(IsNull(R.SpecialRight,'N')) as SpecialRight, max(r.MENUNAME) -- MOD:001
	From GTL_UserRights R(Nolock)
	Where Exists
	(
		Select Top 1 Null From GTL_Users U(Nolock) 
		Cross Apply 
		String_Split
		(
			LTrim(IsNull(U.GroupID,0))+
			Case When IsNull(U.RoleIDs,'')<>'' Then ','+U.RoleIDs Else IsNull(U.RoleIDs,'') End,','
		) X
		Where U.UserCode=@UserCode and R.GroupID=X.Value
	)
	and Exists
	(
		Select Top 1 Null From GTL_ModuleMaster M(Nolock) 
		Where M.ModuleID=R.ModuleID and 1=Case When 
		((@AccessLevel In('N','S') and M.AccessLevelID In(1)) Or 
		(@AccessLevel In('Y') and M.AccessLevelID In(2)))
		Then 0 Else 1 End
	)

	Group By R.GroupID,R.ProjectID,R.ModuleID

	Return
End
GO
