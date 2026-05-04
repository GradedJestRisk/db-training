# Transport data

## export

Set the identifier to export: it should be a text in database.

Here, we provide a UUID.
```shell
export IDENTIFIER=13c25760-004b-3c3f-ba16-830853d16680
```

Run the export.
```shell
./export.sh
```

Check the standard output, which indicate the number of exported rows, here 1 pour `booking`.
```terminaloutput
COPY (
  SELECT bk.*
  FROM booking bk
           INNER JOIN passenger psg ON bk.passenger_id = psg.id 
  WHERE psg.id = :IDENTIFIER
) TO STDOUT WITH CSV HEADER ENCODING 'UTF8' \g 'booking.csv'
COPY 1
```

Check the exported data
```shell
ls -ltrh *.csv
```

Transfer CSV files.

## import

### cleanup

The import will not remove existing data, so beware of unicity constraints.

You may have to do the cleanup yourself, in the proper order:
- dependencies (using foreign keys);
- main table.

```postgresql
DELETE FROM booking
WHERE passenger_id = '13c25760-004b-3c3f-ba16-830853d16680';

SELECT * FROM passenger
WHERE id = '13c25760-004b-3c3f-ba16-830853d16680';
```

### import

Run the import.
```shell
./import.sh
```

Check the standard output, which indicate the number of imported rows, here 1 pour `booking`.
```terminaloutput
\COPY booking FROM 'booking.csv' WITH CSV HEADER ENCODING 'UTF8';
COPY 1
```
