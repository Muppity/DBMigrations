USE MASTER
GO
SELECT TOP 100
	@@SERVERNAME as ServerName,
	s.database_name as DatabaseName,
	m.physical_device_name,
	CAST(CAST(s.backup_size / 1000000 AS INT) AS VARCHAR(14)) + ' ' + 'MB' as BackupSize,
	CAST(DATEDIFF(second, s.backup_start_date,s.backup_finish_date) AS VARCHAR(4)) + ' ' + 'Seconds' TimeTaken,
	s.backup_start_date BackupStartDate,
	s.backup_finish_date BackupEndDate,
	CAST(s.first_lsn AS VARCHAR(50)) AS First_lsn,
	CAST(s.last_lsn AS VARCHAR(50)) AS Last_sn,
	CASE s.[type]
	WHEN 'D' THEN 'Full'
	WHEN 'I' THEN 'Differential'
	WHEN 'L' THEN 'Transaction Log'
	END AS BackupType,
	s.recovery_model
FROM 
	msdb.dbo.backupset s
	INNER JOIN msdb.dbo.backupmediafamily m ON s.media_set_id = m.media_set_id
--Local Backups
WHERE 
	physical_device_name LIKE '%:\%'

--NetBackup
WHERE
	physical_device_name LIKE 'VNBU%'


--External backups
WHERE
	physical_device_name LIKE '%\\%'

--SnapManager backups 
WHERE 
	physical_device_name LIKE '%SnapInfo%'


--RedGated backups 
WHERE 
	physical_device_name LIKE '%{%'

AND s.type = 'D'
ORDER BY backup_start_date DESC
GO