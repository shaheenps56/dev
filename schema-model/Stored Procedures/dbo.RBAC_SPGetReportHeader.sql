SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [dbo].[RBAC_SPGetReportHeader]
(
	@ReportCaption Varchar(Max),
	@UserCode Varchar(25),
	@Region Varchar(100)='ALL',
	@Location Varchar(100)='ALL',
	@SBBranch Varchar(100)='ALL',
	@Exchange Varchar(100)='ALL',
	@ShowCompanyAddress Varchar(10)='Y',
	@ShowSubBrokerAddress Varchar(10)='N'
)as
/*
Exec RBAC_SPGetReportHeader @ReportCaption='Test',@UserCode='GIT',
@ShowCompanyAddress='Y',@ShowSubBrokerAddress='N'
*/
begin
	Declare @CompanyAddress Varchar(Max)='',@SubbrokerAddress Varchar(Max)='',@Filter Varchar(Max)=''
	
	Select @Exchange='ALL' Where isNull(@Exchange,'0')='0'

	Select @Filter=Case When @Exchange='' Then '' Else 'Exchange : '+Ltrim(IsNull(@Exchange,''))+' &nbsp;&nbsp;' End+
	Case When @Region='' Then '' Else 'Region : '+Ltrim(IsNull(@Region,''))+' &nbsp;&nbsp;' End+
	Case When @Location='' Then '' Else 'Location : '+Ltrim(IsNull(@Location,''))+' &nbsp;&nbsp;' End+
	Case When @SBBranch='' Then '' Else 'SBBranch : '+Ltrim(IsNull(@SBBranch,'')) End	

	Select @CompanyAddress=
	'<b><span  style="color:black; font-size:11px;"> '+ IsNull(CompanyName,'') +' </span></b><br/>'+	
	IsNull(CompanyAdd1,'')+'<br/>'+IsNull(CompanyAdd2,'')+'<br/>'+
	IsNull(CompanyAdd3,'')+'<br/>'+IsNull(Email,'')+'<br/>'+IsNull(CIN,'') From GTL_CompanyMaster (Nolock)

	Select '<table border="0" bordercolor="#e9ecef" cellpadding="1px" cellspacing="0" width="100%" style="font-family:Verdana,Arial,Helvetica,sans-serif;font-size:11px;">
	<tr><td height="1px" colspan="4"></td></tr><tr>
	<td style="width: 25%;color:#333333; font-family: Verdana,Arial,Helvetica,sans-serif; font-size:8px; padding-left:3px;" valign="top" align="left">'+
	Case When @ShowCompanyAddress='Y' Then @CompanyAddress Else Replicate('&nbsp;',90) End+
	'</td>
	<td style="width: 50%;color:#333333; font-family: Verdana,Arial,Helvetica,sans-serif; font-size: 11px;" valign="bottom" align="center" ><b>'+
	IsNull(@ReportCaption,'')
	+'</b></td>
	<td style="width: 25%;color:#333333; font-family: Verdana,Arial,Helvetica,sans-serif; font-size:8px; padding-right:3px;" valign="top" align="right">'+
	Case When @ShowSubBrokerAddress='Y' Then @SubbrokerAddress Else '&nbsp;' End+
	' </td></tr>
	<tr height="19" style="color:black; font-family: Verdana,Arial,Helvetica,sans-serif; font-size:11px;">'
	+Case When IsNull(@Filter,'')<>'' Then '<td colspan="3"  align="left">'+LTrim(@Filter)+
	'</td>' Else '' End+'
	<td  colspan="3" align="right" valign="top"> User : '+LTrim(@UserCode)+' &nbsp;&nbsp;Report Time : '+Format(GetDate(), 'dd-MM-yyyy hh:mm:ss tt')+'
	</td>
	</tr>
	</table>' as HTMLContent
End
GO
