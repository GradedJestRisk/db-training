SET search_path = "$user", $SCHEMA;

\COPY passenger FROM 'passenger.csv' WITH CSV HEADER ENCODING 'UTF8';

-- Foreign key on passenger
\COPY booking FROM 'booking.csv' WITH CSV HEADER ENCODING 'UTF8';
