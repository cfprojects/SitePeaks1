<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Site-Peaks - [Home]</title>

	<cfparam name="url.event" type="string" default="FirstCall">

	<!--- Each PageRequest: must be a public IP --->
	<cfinvoke component="#server.sitePeaks#" method="setSitePeak" returnvariable="myMaxMindData">
		<cfinvokeargument name="SessionID"	value="#session.SessionID#" />
		<cfinvokeargument name="ClientIP"		value="80.190.147.233" />	<!--- #cgi.REMOTE_ADDR# --->
		<cfinvokeargument name="PageGroup"	value="index" />	<!--- Gruppenzuordnung --->
		<cfinvokeargument name="PageName"		value="#url.event#" />	<!--- Name der Seite --->
		<cfinvokeargument name="PageURL"		value="http#iif(cgi.HTTPS IS 'ON',de('s'),de(''))#://#cgi.HTTP_HOST##cgi.PATH_INFO#?#cgi.QUERY_STRING#" />	<!--- http://www.myDomain.ch/myPage.cfm --->
	</cfinvoke>

</head>

<body>

<a href="index.cfm?event=home">Home</a>&nbsp;&nbsp;<a href="index.cfm?event=login">Login</a>&nbsp;&nbsp;<a href="index.cfm?event=shop">Shop</a><br /><br />

<a href="index.cfm">index</a><br /><a href="SiteStats.cfm">Statistik</a><br />

You are here: <cfoutput>#url.event#</cfoutput><br /><br />

<cfdump var="#myMaxMindData#" label="myMaxMindData" expand="false"><br />

<cfinclude template="createSQL.cfm">

</body>
</html>
