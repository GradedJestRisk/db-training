#!/usr/bin/env bash
trap 'exit 130' INT

CLIENT_IDENTIFIER="CALL dbms_session.set_identifier('parsing');"
SQL_ID="SELECT prev_sql_id FROM v\$session WHERE sid=sys_context('userenv','sid');"

for i in {1..20}
do
#  SELECT="SELECT MAX(id) FROM simple_table WHERE id > ${i};"
  # 30 seconds
  SELECT="SELECT MAX(id) FROM simple_table WHERE id > ${i} AND id > dbms_random.value(1,100000);"
#  echo $SELECT
#  echo -n "."
#  sqlplus $CONNECTION_STRING <<< $QUERY #1>/dev/null
  sqlplus -S $CONNECTION_STRING <<EOF
    SET head OFF
    SET feedback OFF
    $CLIENT_IDENTIFIER
    SET timing ON
    $SELECT
    SET timing OFF
    $SQL_ID
  EXIT;
EOF
done