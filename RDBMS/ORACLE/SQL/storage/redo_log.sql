/*
V$LOG	         Displays the redo log file information from the control file
V$LOGFILE	   Identifies redo log groups and members and member status
V$LOG_HISTORY	Contains log history information
*/

SELECT * FROM v$log
;

SELECT * FROM v$logfile
;

SELECT * FROM v$log_history
;