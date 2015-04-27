<!--- Application.Scope --->
<cfapplication sessionmanagement="true">

<cfif NOT isDefined("server.sitePeaks") OR isDefined("url.reInit")>
	<!--- load SitePeaks in Server.Scope 4 all Applications --->
	<cfset server.sitePeaks = createObject('component','SitePeaks').init(AccountID='pnCqAL23FqlC',Datasource="SitePeaks") />
</cfif>

<!--- <cfdump var="#server.sitePeaks#" expand="false"> --->
