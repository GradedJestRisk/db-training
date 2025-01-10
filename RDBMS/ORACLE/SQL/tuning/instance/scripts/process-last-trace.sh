#!/usr/bin/env bash
TRACE_DIRECTORY=/opt/oracle/diag/rdbms/free/FREE/trace
TRACE_FILE_PATH=$(ls -rt $TRACE_DIRECTORY/FREE_ora_*.trc | tail -n 1)
REPORT_DIRECTORY=/tmp
REPORT_FILE_NAME=trace.txt
REPORT_FILE_PATH=$REPORT_DIRECTORY/$REPORT_FILE_NAME
rm $REPORT_FILE_PATH
tkprof $TRACE_FILE_PATH $REPORT_FILE_PATH sys=no sort=prsela,exeela,fchela