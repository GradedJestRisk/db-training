SET search_path = "$user", $SCHEMA;

COPY (
  SELECT bk.*
  FROM booking bk
           INNER JOIN passenger psg ON bk.passenger_id = psg.id
  WHERE psg.id = :IDENTIFIER
) TO STDOUT WITH CSV HEADER ENCODING 'UTF8' \g 'booking.csv'

COPY (
    SELECT *
    FROM passenger psg
    WHERE psg.id = :IDENTIFIER
) TO STDOUT WITH CSV HEADER ENCODING 'UTF8' \g 'passenger.csv'

