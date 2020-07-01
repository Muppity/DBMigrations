
set termout OFF
set long 100000
set linesize 500
set headsep on
set trimspool on
set pagesize 10000
set echo off
set feedback off

column owner format a17

column FileName new_value new_filename
select '/tmp/'||INSTANCE_NAME||'_'||to_char(sysdate,'YYYYMMDD_HH24MISS')||'.txt' FileName from v$INSTANCE;

spool &new_filename

PROMPT 
PROMPT ' ##########################################';
PROMPT ' ####   BASIC DATABASE INFORMATION   ######';
PROMPT ' ##########################################';

SELECT to_char(SYSDATE,'dd-Mon-rrrr HH24:Mi:SS') "REPORT DATE",NAME,to_char(CREATED,'dd-Mon-rrrr HH24:Mi:SS') "DB CREATED",OPEN_MODE,LOG_MODE FROM v$DATABASE;

SELECT INSTANCE_NAME,HOST_NAME,VERSION,STATUS,to_char(STARTUP_TIME,'dd-Mon-rrrr HH24:Mi:SS') STARTUP_TIME FROM v$INSTANCE;

PROMPT 
PROMPT ' ###############################';
PROMPT ' ####      SHOW SGA        #####';
PROMPT ' ###############################';

SHOW SGA;

PROMPT 
PROMPT ' ###############################';
PROMPT ' ####   OBJECTS BY OWNER   #####';
PROMPT ' ###############################';
SELECT   owner, object_type, COUNT (1)
    FROM dba_objects
   WHERE owner NOT IN
                     ('SYS', 'SYSTEM', 'CTXSYS','DBSNMP', 
                     'DMSYS', 'MDSYS', 'OLAPSYS', 'ORDPLUGINS', 
                     'OUTLN',  'ORDSYS','PUBLIC',  'EXFSYS', 
                     'ORACLE_OCM', 'SI_INFORMTN_SCHEMA',
                     'SYSMAN', 'TSMSYS', 'WMSYS','XDB', 
					 'APEX_030200','BI','IX','HR','SH','OE','PM',
					 'FLOWS_FILES','ORDDATA','OWBSYS','OWBSYS_AUDIT',
					 'APPQOSSYS')
GROUP BY ROLLUP (owner, object_type)
ORDER BY 1;

PROMPT 
PROMPT ' ####################################';
PROMPT ' ####   DB LINKS ON DATABASE   ######';
PROMPT ' ####################################';
column DB_LINK format a80
column HOST format a100

select OWNER, DB_LINK, USERNAME, HOST, CREATED from dba_db_links;

PROMPT 
PROMPT ' #################################';
PROMPT ' ####   SCHEDULER BY OWNER  ######';
PROMPT ' #################################';
set linesize 2000
column OWNER         format a10
column JOB_CREATOR   format a10
column PROGRAM_OWNER format a10
column PROGRAM_NAME  format a50
column JOB_ACTION    format a100
column SCHEDULE_OWNER format a20
column SCHEDULE_NAME  format a30

select OWNER, JOB_NAME, JOB_CREATOR, PROGRAM_OWNER, PROGRAM_NAME, JOB_TYPE, JOB_ACTION, 
       SCHEDULE_OWNER, SCHEDULE_NAME, SCHEDULE_TYPE, ENABLED, STATE, RUN_COUNT, FAILURE_COUNT, LAST_START_DATE, NEXT_RUN_DATE 
from ALL_SCHEDULER_JOBS
--where owner not in ('EXFSYS','ORACLE_OCM')
order by owner;

PROMPT 
PROMPT ' #######################################';
PROMPT ' ####   DATABASE INIT PARAMETERS  ######';
PROMPT ' #######################################';

set linesize 500
column value format a70
column name  format a40

SELECT p.name, p.value value, p.description
FROM V$PARAMETER p
where name not like 'nls%'
 AND (p.isDefault = 'FALSE')
 order by p.name;

PROMPT 
PROMPT ' #############################';
PROMPT ' ####     DATA FILES    ######';
PROMPT ' #############################';
column TABLESPACE_NAME format a20
column FILE_NAME format a70

select TABLESPACE_NAME, FILE_NAME, BYTES, STATUS, AUTOEXTENSIBLE, MAXBYTES, 
       INCREMENT_BY, ONLINE_STATUS 
from dba_data_files
order by TABLESPACE_NAME,FILE_NAME;

PROMPT 
PROMPT ' #############################';
PROMPT ' ####    TEMP FILES     ######';
PROMPT ' #############################';


select TABLESPACE_NAME, FILE_NAME, (BYTES/1024/1024) MB, STATUS, AUTOEXTENSIBLE, 
      (MAXBYTES/1024/1024) MAX_MB, INCREMENT_BY
from dba_temp_files
order by TABLESPACE_NAME,FILE_NAME;

PROMPT 
PROMPT ' #############################';
PROMPT ' ####   REDO LOG FILES  ######';
PROMPT ' #############################';

column MEMBER format a70

select * from V$LOGFILE;

select GROUP#, THREAD#, SEQUENCE#, (BYTES/1024/1024) MB, BLOCKSIZE, 
       MEMBERS, ARCHIVED, STATUS, FIRST_CHANGE#, FIRST_TIME, NEXT_CHANGE#, NEXT_TIME 
from v$log;

PROMPT 

spool off






