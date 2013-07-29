On error resume Next

Set objShell = CreateObject("WScript.Shell")

'GET EXE OUTPUT
Function GetExecOutput(strExe, ByRef strStd, Timeout, ByRef DidTimeout)
On Error Resume Next

	'RESULT
	GetExecOutput = False
	DidTimeout = False
	strStd = ""
	
	'ERR CLEAR
	Err.Clear
	
	Set objExec = objShell.Exec(strExe)
	
	'ERR CHECK
	If (Err.Number = 0) Then
		'SLEEP TO ALLOW PIPES TO CONNECT
		Call WScript.Sleep(100)		
	
		Call objExec.StdIn.Close
		Call objExec.StdErr.Close
		StartDate = Now
		
		'WAIT FOR IT TO FINISH OR TIMEOUT
		Do Until ((objExec.Status = 1) And (objExec.StdOut.AtEndOfStream)) Or (DateDiff("s", StartDate, Now) > TimeOut)
			'STDOUT
			If (Not objExec.StdOut.AtEndOfStream) Then
				strRead = objExec.StdOut.ReadLine
				If (Len(strRead) > 0) Then 
					'#DEBUG
					'Call WScript.Echo(strRead)				
					strStd = strStd & strRead & vbCrLf
				End If
			End If
		Loop
			
		'TIMEOUT
		If (DateDiff("s", StartDate, Now) > TimeOut) Then		
			'TERMINATE PROCESS
			Call objExec.Terminate
			'TIMED OUT
			DidTimeout = True			
		'SUCCESS
		Else
			'RESULT
			GetExecOutput = True		
		End If
	End If
End Function

Function GetPsqlOutput(strDatabase, strQuery, ByRef strStd, Timeout, ByRef DidTimeout)
	strExe = strPgsqlPath & "psql -h localhost -U postgres -t -c """ & strQuery & """ " & strDatabase
	GetPsqlOutput = GetExecOutput(strExe, strStd, Timeout, DidTimeout)
End Function

Function GetDatabaseName()
	If (WScript.Arguments.Count < 3) Then
		'ERROR
		Call WScript.echo("Not enough arguments. Should add psql bin path, command and database name.")
		
		'QUIT
		Call PrintUsage
	End If
	GetDatabaseName = WScript.Arguments(2)
End Function

Sub PrintUsage()
	strScriptName = Wscript.ScriptName
	Call WScript.Echo("usage:")
	Call WScript.Echo("     " & strScriptName & " totalsize                   -- Check the total databases size.")
	Call WScript.Echo("     " & strScriptName & " db_cache <dbname>           -- Check the database cache hit ratio (percentage).")
	Call WScript.Echo("     " & strScriptName & " db_success <dbname>         -- Check the database success rate (percentage).")
	Call WScript.Echo("     " & strScriptName & " server_processes            -- Check the total number of Server Processes that are active.")
	Call WScript.Echo("     " & strScriptName & " tx_commited                 -- Check the total number of commited transactions.")
	Call WScript.Echo("     " & strScriptName & " tx_rolledback               -- Check the total number of rolled back transactions.")
	Call WScript.Echo("     " & strScriptName & " db_size <dbname>            -- Check the size of a Database (in bytes).")
	Call WScript.Echo("     " & strScriptName & " db_connections <dbname>     -- Check the number of active connections for a specified database.")
	Call WScript.Echo("     " & strScriptName & " db_returned <dbname>        -- Check the number of tuples returned for a specified database.")
	Call WScript.Echo("     " & strScriptName & " db_fetched <dbname>         -- Check the number of tuples fetched for a specified database.")
	Call WScript.Echo("     " & strScriptName & " db_inserted <dbname>        -- Check the number of tuples inserted for a specified database.")
	Call WScript.Echo("     " & strScriptName & " db_updated <dbname>         -- Check the number of tuples updated for a specified database.")
	Call WScript.Echo("     " & strScriptName & " db_deleted <dbname>         -- Check the number of tuples deleted for a specified database.")
	Call WScript.Echo("     " & strScriptName & " db_commited <dbname>        -- Check the number of commited back transactions for a specified database.")
	Call WScript.Echo("     " & strScriptName & " db_rolled <dbname>          -- Check the number of rolled back transactions for a specified database.")
	Call WScript.Echo("     " & strScriptName & " version                     -- The PostgreSQL version.")
	WScript.Quit
End Sub

'check arguments
count = WScript.Arguments.Count
If (WScript.Arguments.Count < 2) Then
	'ERROR
	Call WScript.echo("Not enough arguments. Should add psql bin path and command.")
	
	Call PrintUsage
End If

' prepare sql
strPgsqlPath = WScript.Arguments(0)
If Right(strPgsqlPath, 1) <> "\" Then
	strPgsqlPath = strPgsqlPath & "\"
End If
strOption = WScript.Arguments(1)

Select Case strOption
	Case "detect"
		strSql = "select datname from pg_stat_database where datname not like 'template%'"
	Case "totalsize"
		strSql = "select sum(pg_database_size(datid)) as total_size from pg_stat_database"
	Case "db_cache"
		strDbName = GetDatabaseName()
		strSql = "select cast(blks_hit/(blks_read+blks_hit+0.000001)*100.0 as numeric(5,2)) as cache from pg_stat_database where datname = '" & strDbName & "'"
    Case "db_success"
		strDbName = GetDatabaseName()
		strSql = "select cast(xact_commit/(xact_rollback+xact_commit+0.000001)*100.0 as numeric(5,2)) as success from pg_stat_database where datname = '" & strDbName & "'"

    Case "server_processes"
        strSql = "select sum(numbackends) from pg_stat_database"

    Case "tx_commited"
        strSql = "select sum(xact_commit) from pg_stat_database"

    Case "tx_rolledback"
        strSql = "select sum(xact_rollback) from pg_stat_database"

    Case "db_size"
		strDbName = GetDatabaseName()
        strSql = "select pg_database_size('" & strDbName & "')"

    Case "db_connections"
		strDbName = GetDatabaseName()
        strSql = "select numbackends from pg_stat_database where datname = '" & strDbName & "'"

    Case "db_returned"
		strDbName = GetDatabaseName()
        strSql = "select tup_returned from pg_stat_database where datname = '" & strDbName & "'"

    Case "db_fetched"
		strDbName = GetDatabaseName()
        strSql = "select tup_fetched from pg_stat_database where datname = '" & strDbName & "'"

    Case "db_inserted"
		strDbName = GetDatabaseName()
        strSql = "select tup_inserted from pg_stat_database where datname = '" & strDbName & "'"

    Case "db_updated"
		strDbName = GetDatabaseName()
        strSql = "select tup_updated from pg_stat_database where datname = '" & strDbName & "'"

    Case "db_deleted"
		strDbName = GetDatabaseName()
        strSql = "select tup_deleted from pg_stat_database where datname = '" & strDbName & "'"

    Case "db_commited"
		strDbName = GetDatabaseName()
        strSql = "select xact_commit from pg_stat_database where datname = '" & strDbName & "'"

    Case "db_rolled"
		strDbName = GetDatabaseName()
        strSql = "select xact_rollback from pg_stat_database where datname = '" & strDbName & "'"

    Case "version"
    	If Not GetExecOutput(strPgsqlPath & "psql --version", strStd, 3, DidTimeout) Then
		    WScript.StrOut.Write "ZBX_NOTSUPPORTED"
			WScript.Quit
    	End If
		Call WScript.StrOut.Write(strStd)
		WScript.Quit
	Case Else
		Call WScript.Echo("Unknown command " & strOption)
		Call PrintUsage()
End Select

' run
If Not GetPsqlOutput("postgres", strSql, strStd, 3, DidTimeout) Then
    WScript.StrOut.Write "ZBX_NOTSUPPORTED"
	WScript.Quit
End If

'WScript.Echo strStd
If strOption = "detect" Then
	' special output for detect
	strSplit = Split(strStd, vbCrLf)
	
	WScript.StdOut.Write "{"
	WScript.StdOut.Write """data"":["
	
	For x = 0 To UBound(strSplit)
		If Trim(strSplit(x)) <> "" Then
			If x > 0 Then
	        	WScript.StdOut.Write ","
			End If
	        WScript.StdOut.Write "{"
	        WScript.StdOut.Write """{#DBNAME}"":""" & Trim(strSplit(x)) & """"
	        WScript.StdOut.Write "}"
		End if
	Next
	
	WScript.StdOut.Write "]"
	WScript.StdOut.Write "}"
Else
	' regular output otherwise
	Call WScript.StdOut.Write(Trim(strStd))
End If
