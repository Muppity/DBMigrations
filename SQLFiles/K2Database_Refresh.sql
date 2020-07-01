USE MASTER
GO
DECLARE @DBNAME SYSNAME

SET @DBNAME = 'K2Database'

DECLARE @SPID INT
	SELECT @SPID = MIN(SPID) FROM MASTER.DBO.SYSPROCESSES WHERE DBID = DB_ID(@DBNAME)
WHILE @SPID IS NOT NULL
BEGIN
	EXECUTE ('KILL ' + @SPID)
	SELECT @SPID = MIN(SPID) FROM MASTER.DBO.SYSPROCESSES WHERE DBID = DB_ID(@DBNAME) AND SPID > @SPID
END
GO

RESTORE DATABASE [K2Database] FROM  DISK = N'F:\K2Database_20140315.bak' 
WITH  FILE = 1,  
MOVE N'Primary_1' TO N'E:\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\K2Database_Primary_1.ndf',
MOVE N'FG_log_1' TO N'E:\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\K2Database_log_1.ldf',  
MOVE N'FG_Server_1' TO N'E:\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\K2Database_FG_Server_1.ndf',  
MOVE N'FG_HostServer_1' TO N'E:\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\K2Database_FG_HostServer_1.ndf',  
MOVE N'FG_Identity_1' TO N'E:\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\K2Database_FG_Identity_1.ndf',  
MOVE N'FG_SmartBroker_1' TO N'E:\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\K2Database_FG_SmartBroker_1.ndf',  
MOVE N'FG_ServerLog_1' TO N'E:\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\K2Database_FG_ServerLog_1.ndf',  

NOUNLOAD,  REPLACE,  STATS = 5
GO

-- Generated on 14 Mar 2014 16:07:28 by ONE\s.mssql on PHLSQL08CLT
USE K2Database
GO
-- Add Database Users
--------------------------------------------------------------------------------------------------------------------------------------------------------
EXEC sp_grantdbaccess 'nimbus.monitor'
EXEC sp_grantdbaccess 'ONE\NSharma'
EXEC sp_grantdbaccess 'ONE\s.K2Test'

-- Create Roles
-------------------------------------------------------------------------------------------------------------------------------------------------------
EXEC sp_addrole 'aspnet_Membership_BasicAccess',dbo 
EXEC sp_addrole 'aspnet_Membership_FullAccess',dbo 
EXEC sp_addrole 'aspnet_Membership_ReportingAccess',dbo 
EXEC sp_addrole 'aspnet_Personalization_BasicAccess',dbo 
EXEC sp_addrole 'aspnet_Personalization_FullAccess',dbo 
EXEC sp_addrole 'aspnet_Personalization_ReportingAccess',dbo 
EXEC sp_addrole 'aspnet_Profile_BasicAccess',dbo 
EXEC sp_addrole 'aspnet_Profile_FullAccess',dbo 
EXEC sp_addrole 'aspnet_Profile_ReportingAccess',dbo 
EXEC sp_addrole 'aspnet_Roles_BasicAccess',dbo 
EXEC sp_addrole 'aspnet_Roles_FullAccess',dbo 
EXEC sp_addrole 'aspnet_Roles_ReportingAccess',dbo 
EXEC sp_addrole 'aspnet_WebEvent_FullAccess',dbo 
EXEC sp_addrole 'db_accessadmin',dbo 
EXEC sp_addrole 'db_backupoperator',dbo 
EXEC sp_addrole 'db_datareader',dbo 
EXEC sp_addrole 'db_datawriter',dbo 
EXEC sp_addrole 'db_ddladmin',dbo 
EXEC sp_addrole 'db_denydatareader',dbo 
EXEC sp_addrole 'db_denydatawriter',dbo 
EXEC sp_addrole 'db_owner',dbo 
EXEC sp_addrole 'db_securityadmin',dbo 

-- Add Role Users
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
EXEC sp_addrolemember 'db_datareader','ONE\s.K2Test'
EXEC sp_addrolemember 'db_datawriter','ONE\s.K2Test'
EXEC sp_addrolemember 'db_owner','ONE\s.K2Test'

-- Setup Object privileges
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Setup Column privileges
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- End of script





DECLARE @autoFix bit; 
SET @autoFix = 'TRUE';  -- FALSE = Report only those user who could be auto fixed. 
                         -- TRUE  = Report and fix !!! 
 
DECLARE @user sysname, @principal sysname, @sql nvarchar(500), @found int, @fixed int; 
 
DECLARE orphans CURSOR LOCAL FOR 
    SELECT QUOTENAME(SU.[name]) AS UserName 
          ,QUOTENAME(SP.[name]) AS PrincipalName 
    FROM sys.sysusers AS SU 
         LEFT JOIN sys.server_principals AS SP 
             ON SU.[name] = SP.[name] collate SQL_Latin1_General_CP1_CI_AS 
                AND SP.[type] = 'S' 
    WHERE SU.issqluser = 1          -- Only SQL logins 
          AND NOT SU.[sid] IS NULL  -- Exclude system user 
          AND SU.[sid] <> 0x0       -- Exclude guest account 
          AND LEN(SU.[sid]) <= 16   -- Exclude Windows accounts & roles 
          AND SUSER_SNAME(SU.[sid]) IS NULL  -- Login for SID is null 
    ORDER BY SU.[name]; 
 
SET @found = 0; 
SET @fixed = 0; 
OPEN orphans; 
FETCH NEXT FROM orphans 
    INTO @user, @principal; 
WHILE @@FETCH_STATUS = 0 
BEGIN 
    IF @principal IS NULL 
        PRINT N'Orphan: ' + @user; 
    ELSE 
    BEGIN 
        PRINT N'Orphan: ' + @user + N' => Autofix possible, principal with same name found!'; 
        IF @autoFix = 'TRUE' 
        BEGIN 
            -- Build the DDL statement dynamically. 
            SET @sql = N'ALTER USER ' + @user + N' WITH LOGIN = ' + @principal + N';'; 
            EXEC sp_executesql @sql; 
            PRINT N'        ' + @user + N' is auto fixed.'; 
            SET @fixed = @fixed + 1; 
        END 
    END 
    SET @found = @found + 1; 
     
    FETCH NEXT FROM orphans 
        INTO @user, @principal; 
END; 
 
CLOSE orphans; 
DEALLOCATE orphans; 
 
PRINT ''; 
PRINT CONVERT(nvarchar(15), @found) + N' orphan(s) found, ' 
    + CONVERT(nvarchar(15), @fixed) + N' orphan(s) fixed.';



