Select name as base_datos,
log_reuse_wait, log_reuse_wait_desc,
case
log_reuse_wait
when 0 then 'There are currently one or
more reusable virtual log files.'
when 1 then 'Not produced
no checkpoint since the last warning! Finally truncation
or the log header has not moved beyond a log file
virtual (all recovery models). This is a common reason for
delaying truncation.'
when 2 then 'You need a copy
up the registry to move the log header
(full recovery model or bulk-logged only). when
is complete registry backup, is advanced header
registration and some log space might become reusable.'
when 3 then 'There is a recovery
or data backup in progress (all recovery models).
The backup
data functions as an active transaction and, when executed, the copy of
security prevents truncation.'
when 4 then 'There may be a
long running transaction at the start of the backup
registration. In this case, to free space may require another copy of
safety record.
It differs from one
transaction. A deferred transaction is effectively an active transaction
whose rollback is blocked due to some unavailable resource.'
when 5 then 'It pauses
mirroring data base or, in the high performance mode,
the mirror database is significantly behind the database
principal (for the full recovery model).'
when 6 then 'during the
transactional replication, transactions relevant to the
publications are still undelivered to the distribution database (only
for the full recovery model).'
when 7 then 'It is creating a
snapshot database (all recovery models). This is a
routine, and typically brief, to delay the truncation
registration.'
when 8 then 'It is producing a
log scan (all recovery models). This is one reason
regular, usually brief, to delay log truncation.'
when 9 then 'Not used this
present value.'
end as columna,
recovery_model_desc as
modo_recuperacion_log, page_verify_option_desc as page_verify_bbdd,
user_access_desc as user_access,
state_desc as estado_bbdd from sys.databases
