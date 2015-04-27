<cfcomponent hint="Usertracking auf Basis der IP und den GEO-Daten von MaxMind">

<cffunction name="init" returntype="SitePeaks" access="remote" output="false" hint="stellt die initialen Werte zur Verfügung">
	<cfargument name="AccountID"	type="string" required="true"		hint="Muss bei MaxMind beantragt werden" />
	<cfargument name="Datasource"	type="string" required="true"		hint="Name der Datenbankverbindung" />

	<cfset variables.instance = structNew() />
	<cfset variables.instance.AccountID = arguments.AccountID />
	<cfset variables.instance.AccountFields	= 'Country,Region,City,Postal,Latitude,Longitude,Metropolitan,Area,ISP,Organization,ErrorCode' />
	<cfset variables.instance.Datasource	= arguments.Datasource />
	<cfset variables.instance.Robots = structNew() />
	<cfset variables.instance.Robots.Google.URL			= 'http://www.iplists.com/nw/google.txt' />
	<cfset variables.instance.Robots.Yahoo.URL			= 'http://www.iplists.com/nw/inktomi.txt' />
	<cfset variables.instance.Robots.Lycos.URL			= 'http://www.iplists.com/nw/lycos.txt' />
	<cfset variables.instance.Robots.MSN.URL				= 'http://www.iplists.com/nw/msn.txt' />
	<cfset variables.instance.Robots.AltaVista.URL	= 'http://www.iplists.com/nw/altavista.txt' />
	<cfset variables.instance.Robots.WiseNut.URL		= 'http://www.iplists.com/nw/wisenut.txt' />
	<cfset variables.instance.Robots.Ask.URL				= 'http://www.iplists.com/nw/askjeeves.txt' />
	<cfset variables.instance.Robots.Misc.URL				= 'http://www.iplists.com/nw/misc.txt' />
	<cfset variables.instance.Robots.NonSpiders.URL	= 'http://www.iplists.com/nw/non_engines.txt' />

	<cfloop collection="#variables.instance.Robots#" item="myRobots">
		<cfhttp url="#variables.instance.Robots[myRobots].URL#" result="myResult" />
		<cfset variables.instance.Robots[myRobots].IPList = myResult.fileContent />
	</cfloop>

	<cfreturn this />
</cffunction>


<cffunction name="CSV2Array" returntype="array" access="private" output="false" hint="liefert ein Array aufgrund einer CSV-Liste, inklusive Anfuerungszeichen bei Stringwerten">
	<cfargument name="myList" type="string" required="true" hint="die CSV-Zeile in Anfuerungszeichen wenn zb ein Komma in einem Stringwert enthalten sein könnte" />

	<cfset var myArray		= ArrayNew(1) />
	<cfset var myElements	= ListToArray(replace(arguments.myList,',,',',-,','all')) />
	<cfset var myString		= "" />
	<cfset var doAppend		= false />
	<cfset var myField		= "" />

	<cfloop from="1" to="#ArrayLen(myElements)#" index="myField">
		<cfif left(myElements[myField],1) EQ chr(34) OR doAppend>
			<cfset myString = listAppend(myString,myElements[myField]) />
			<cfset doAppend = true />

			<cfif right(myElements[myField],1) EQ chr(34)>
				<cfset ArrayAppend(myArray,removeChars(removeChars(myString,len(myString),2),1,1)) />
				<cfset myString = "" />
				<cfset doAppend = false />
			</cfif>

		<cfelseif NOT doAppend>
			<cfset ArrayAppend(myArray,myElements[myField]) />
		</cfif>
	</cfloop>

	<cfreturn myArray />
</cffunction>


<cffunction name="WriteToDatabase" returntype="void" access="private" output="false" hint="schreibt die GEO-Daten in ein LogFile">
	<cfargument name="GEObean" type="struct" required="true" hint="Die GEO-Daten als Struktur (TransferObjekt)" />

	<cfset var myQuery = queryNew('emtpy,query') />
	<cfquery name="myQuery" datasource="#variables.instance.Datasource#">
		INSERT INTO #variables.instance.Datasource# (SessionID, createdAt,ClientIP,Country,City,ISP,Organization,Latitude,Longitude,PageGroup,Pagename,PageURL)
			VALUES ('#arguments.GEObean['SessionID']#',#now()#,'#arguments.GEObean['ClientIP']#','#arguments.GEObean['Country']#','#arguments.GEObean['City']#','#arguments.GEObean['ISP']#','#arguments.GEObean['Organization']#','#arguments.GEObean['Latitude']#','#arguments.GEObean['Longitude']#','#arguments.GEObean['PageGroup']#','#arguments.GEObean['PageName']#','#arguments.GEObean['PageURL']#')
	</cfquery>
</cffunction>


<cffunction name="isARobotIP" returntype="struct" access="remote" output="false" hint="prueft ob die IP von einem Robot ist">
	<cfargument name="ClientIP" type="string" required="true" hint="Die zu ueberpruefende IP" />

	<cfset var myIPcheck = structNew() />
	<cfset myIPcheck.IP2Check	= arguments.ClientIP />
	<cfset myIPcheck.IPFound	= false />
	<cfset myIPcheck.Robot		= "" />

	<cfif listLen(arguments.ClientIP,'.') GT 3>
		<cfset myIPcheck.IP2Check = listDeleteAt(arguments.ClientIP,listLen(arguments.ClientIP,'.'),'.')>
		<cfloop collection="#variables.instance.Robots#" item="myName">
			<cfif findNoCase(myIPcheck.IP2Check,variables.instance.Robots[myName].IPList)>
				<cfset myIPcheck.IPFound	= true />
				<cfset myIPcheck.Robot		= myName />
			</cfif>
		</cfloop>
	<cfelse>
		<cfset myIPcheck.IPFound	= true />
		<cfset myIPcheck.Robot		= "localhost" />
	</cfif>

	<cfreturn myIPcheck />
</cffunction>


<cffunction name="setSitePeak" returntype="struct" access="remote" output="false" hint="konvertiert das Array in eine Struktur, um namentlich darauf zugreifen zu koennen">
	<cfargument name="ClientIP"		type="string"	required="true"		hint="IP-Adresse, welche ausgewertet werden soll" />
	<cfargument name="SessionID"	type="string"	required="false"	hint="SessionID zum UserTracking" />
	<cfargument name="PageName"		type="string"	required="false"	hint="Name der Seite" />
	<cfargument name="PageGroup"	type="string"	required="false"	hint="Gruppenzuordnung" />
	<cfargument name="PageURL"		type="string"	required="false"	hint="Link zur Seite" />

	<cfset var myArray		= arrayNew(1) />
	<cfset var myStruct		= structNew() />
	<cfset var myMMGEOs		= "" />

	<cfif isARobotIP(arguments.ClientIP).IPFound><cfabort></cfif>

	<cfhttp url="http://maxmind.com:8010/f?l=#variables.instance.AccountID#&i=#arguments.ClientIP#" columns="#variables.instance.AccountFields#" result="myMMGEOs" />

	<cfset myArray = CSV2Array(myMMGEOs.fileContent) />
	<cfloop from="1" to="#ArrayLen(myArray)#" index="myField">
		<cfset myStruct[listGetAt(variables.instance.AccountFields,myField)] = myArray[myField] />
	</cfloop>
	<cfset myStruct['ClientIP']		= arguments.ClientIP />
	<cfset myStruct['SessionID']	= arguments.SessionID />
	<cfset myStruct['PageName']		= arguments.PageName />
	<cfset myStruct['PageGroup']	= arguments.PageGroup />
	<cfset myStruct['PageURL']		= arguments.PageURL />

	<cfset WriteToDatabase(myStruct) />

	<cfreturn myStruct />
</cffunction>


<cffunction name="getSitePeaks" returntype="query" access="remote" output="false" hint="Liest alle SitePeaks aus der Datenbank">
	<cfargument name="Records" type="numeric" required="true" hint="Anzahl der anzuzeigenden Datensätze">

	<cfset var myQuery = queryNew('emtpy,query') />
	<cfquery name="myQuery" datasource="#variables.instance.Datasource#">
		SELECT TOP #arguments.Records# * FROM #variables.instance.Datasource# ORDER BY Ident DESC
	</cfquery>

	<cfreturn myQuery />
</cffunction>

</cfcomponent>