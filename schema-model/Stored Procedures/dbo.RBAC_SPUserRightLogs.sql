SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Proc [dbo].[RBAC_SPUserRightLogs]
(
    @FromDate		Datetime,
    @ToDate			Datetime,
    @UserCode		Varchar(25),
	@Debug			Varchar(1)= 'N'
)
/**********************************************************************************************************************************************************
	Created By	:	
	Created On	:	27-06-2024
	Purprose	:	Generating Multiple resultsets for Creating Excel files
	Project		:	SPARCIM
	Test		:	Exec RBAC_SPUserRightLogs 
					@FromDate='2024-07-30',@ToDate='2024-08-01'	,@UserCode='GIT',@Debug='N'		
**********************************************************************************************************************************************************/
As
Begin

    Set NoCount On
	Set Transaction Isolation Level Read UnCommitted
	
	Select USERCODE,USERNAME,CONVERT(Varchar(10),DOB,23) DOB,U.EMAILID,U.TELEPHONENO,U.FAX,L.LOCATION,REGION,CompanyState,
	G.DESCRIPTION [Group],D.DepartmentCode,U.ISWEBUSER,U.CORPUSER,U.IPAddress,U.TERMINATED,U.TerminatedDate,U.TerminatedReason,
	Format(U.LASTUPDATEDON, 'dd-MM-yyyy hh:mm:ss tt') [CreatedTime]
	From GTL_USERS (Nolock) U Left Join GTL_LOCATION (Nolock) L
	On(U.LOCATIONID=L.LOCATIONID)
	Left Join GTL_USERGROUPS (Nolock) G On(U.GROUPID=G.GROUPID)
	Left Join GTL_Department (Nolock) D On(U.DEPARTMENT=D.DepartmentID)
	Where Convert(Varchar(10),U.LASTUPDATEDON,23)>=@FromDate and Convert(Varchar(10),U.LASTUPDATEDON,23)<=@ToDate
	
	Select '' USERCODE,'' USERNAME,'' DOB,'' EMAILID,'' TELEPHONENO,'' FAX,'' LOCATION,'' REGION,'' CompanyState,
	'' [Group],'' DepartmentCode,'' ISWEBUSER,'' CORPUSER,'' IPAddress,'' TERMINATED,'' TerminatedDate,'' TerminatedReason,
	'' [CreatedTime]

	Select '' as HiddenCols,'' as RightAlignCols,'N' as HTMLOutput

	Select G.DESCRIPTION [GroupName],P.DESCRIPTION [ProjectName],M.MODULENAME [ModuleName],U.MENUNAME [MenuName],
	U.ADDRIGHT [ADD],U.MODIFYRIGHT [MODIFY],U.DELETERIGHT [DELETE],U.PREVIEWRIGHT [PREVIEW],U.PRINTRIGHT [PRINT],
	U.EXPORTRIGHT [EXPORT],U.SPECIALRIGHT [SPECIALRIGHT],Format(U.LASTUPDATEDON, 'dd-MM-yyyy hh:mm:ss tt') [CreatedTime]
	From GTL_USERRIGHTS (Nolock) U Left Join GTL_USERGROUPS (Nolock) G
	On(U.GROUPID=G.GROUPID)
	Left Join GTL_PROJECTS (Nolock) P On(U.PROJECTID=P.PROJECTID)
	Left Join GTL_MODULEMASTER (Nolock) M On(U.MODULEID=M.MODULEID)
	Where Convert(Varchar(10),U.LASTUPDATEDON,23)>=@FromDate 
	and Convert(Varchar(10),U.LASTUPDATEDON,23)<=@ToDate

	Select '' [GroupName],'' [ProjectName],'' [ModuleName],'' [MenuName],
	'' [ADD], '' [MODIFY],'' [DELETE],'' [PREVIEW],'' [PRINT],
	'' [EXPORT],'' [SPECIALRIGHT],'' [CreatedTime]

	Select '' as HiddenCols,'' as RightAlignCols,'N' as HTMLOutput

	Select G.DESCRIPTION [GroupName],IsNull(G.Remarks,'') [GroupDescription],
	Format(G.LASTUPDATEDON, 'dd-MM-yyyy hh:mm:ss tt') [CreatedTime]
	From GTL_USERGROUPS (Nolock) G
	Where Convert(Varchar(10),G.LASTUPDATEDON,23)>=@FromDate
	and Convert(Varchar(10),G.LASTUPDATEDON,23)<=@ToDate

	Select '' [GroupName],''[GroupDescription],'' [CreatedTime]
	
	Select '' as HiddenCols,'' as RightAlignCols,'N' as HTMLOutput
	

	Select '<html><header><img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTh5dX8hbusCfKkLhQFasGj5Ro1P2gVV-FGcQ&s">'+
	+'Geojit Financial Services Limited (GFSL)</header></html>' as HTMLHeader,
	'AuditTrial.xlsx' as FileName,'1|UsersDetails','4|UserRights','7|UserGroups';

	Set Transaction Isolation Level Read Committed 
	Set NoCount Off
End
GO
