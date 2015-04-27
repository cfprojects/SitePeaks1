<cfset myTable = structNew() />
<cfset myTable.SQL = "CREATE TABLE SitePeaks (
	[Ident] [int] IDENTITY(1,1) NOT NULL,
	[createdAt] [smalldatetime] NULL,
	[SessionID] [nvarchar](200) NULL,
	[ClientIP] [nvarchar](20) NULL,
	[Country] [nvarchar](5) NULL,
	[City] [nvarchar](200) NULL,
	[ISP] [nvarchar](200) NULL,
	[Organization] [nvarchar](200) NULL,
	[Latitude] [nvarchar](50) NULL,
	[Longitude] [nvarchar](50) NULL,
	[PageGroup] [nvarchar](250) NULL,
	[PageName] [nvarchar](250) NULL,
	[PageURL] [nvarchar](250) NULL
)
" />
<cfdump var="#myTable#" label="Datasource/Table=SitePeaks" expand="false">
