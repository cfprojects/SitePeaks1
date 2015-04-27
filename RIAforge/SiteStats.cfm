<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="de">
<head>

	<cfparam name="url.pageRefresh"	default="0"			type="numeric">
	<cfparam name="url.pagePeaks"		default="100"		type="numeric">
	<cfparam name="url.pageURL"			default="false"	type="boolean">

	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<cfif url.pageRefresh GT 0><cfoutput><meta http-equiv="refresh" content="#url.pageRefresh#; URL=#listLast(cgi.PATH_INFO,'/')#?pageRefresh=#url.pageRefresh#&pagePeaks=#url.pagePeaks#"></cfoutput></cfif>
	<title>Site-Peaks - [Statistik]</title>
	<link rel="stylesheet" type="text/css" media="screen" href="styles/screen.css">
</head>

<body>

<cfoutput>
<form name="showStats" action="#listLast(cgi.PATH_INFO,'/')#" method="get">
	&nbsp;<a href="#listLast(cgi.PATH_INFO,'/')#">[reStart]</a>&nbsp;&nbsp;&nbsp;
	pageRefresh <input type="text" name="pageRefresh" value="#url.pageRefresh#" size="4" />&nbsp;&nbsp;&nbsp;
	pagePeaks <input type="text" name="pagePeaks" value="#url.pagePeaks#" size="4" />
	<input type="submit" value="show">
</form>
</cfoutput>

<cfset myStats = server.sitePeaks.getSitePeaks(url.pagePeaks) />	<!--- Records each Page --->

<table>
<tr id="head">
	<td>TimeStamp</td>
	<td>ClientIP</td>
	<td>World</td>
	<td>City</td>
	<td>ISP</td>
	<td>Organisation</td>
	<td>PageGroup</td>
	<td>PageName</td>
	<cfif url.pageURL><td>PageURL</td></cfif>
	<td>SessionID</td>
</tr>

<cfoutput query="MyStats">
	<tr <cfif CurrentRow Mod 2>class="smaller low"<cfelse>class="smaller def"</cfif> onMouseOver="this.className='smaller high';" <cfif CurrentRow Mod 2>onMouseOut="this.className='smaller low';"<cfelse> onMouseOut="this.className='smaller def';"</cfif>>
		<td nowrap>#lsDateFormat(createdAt,"dd.mm.yy")# - #lsTimeFormat(createdAt,"HH:MM:SS")#</td>
		<td nowrap><a href="http://networking.ringofsaturn.com/Tools/whois.php?domain=#ClientIP#">#ClientIP#</a></td>
		<td nowrap style="cursor:help;"><a href="http://maps.google.com/maps?f=q&hl=#Country#&q=#Country#,+#City#&ie=UTF8&z=12&iwloc=addr">#Country#</a></td>
		<td nowrap><a href="http://www.multimap.com/map/home.cgi?client=public&amp;db=#Country#&amp;overviewmap=#Country#&amp;addr3=#City#&amp;search_result=#City#">#City#</a></td>
		<td nowrap><a href="http://www.google.ch/search?q=#ISP#">#ISP#</a></td>
		<td nowrap><a href="http://www.google.ch/search?q=#Organization#">#Organization#</a></td>
		<td nowrap>#pageGroup#</td>
		<td nowrap><a href="#pageURL#" title="#pageGroup#-#pageName#">#pageName#</a></td>
		<cfif url.pageURL><td nowrap><a href="#pageURL#" title="#pageGroup#-#pageName#">#pageURL#</a></td></cfif>
		<td nowrap>#SessionID#</td>
	</tr>
</cfoutput>

<tr>
	<td id="footer" colspan="10">total <cfoutput>#MyStats.RecordCount#</cfoutput></td>
</tr>
</table>

</body>
</html>