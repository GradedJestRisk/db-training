https://ubuntu.com/server/docs/install-and-configure-postgresql

Install postgres
```shell
sudo apt install postgres
```

```shell
sudo systemctl start postgresql.service
sudo -u postgres psql template1
```

```postgresql
ALTER USER postgres with encrypted password 'password123';
```

```shell
sudo vi /etc/postgresql/*/main/pg_hba.conf
```

Add
```text
hostssl template1       postgres        192.168.122.1/24        scram-sha-256
```

```shell
sudo systemctl restart postgresql.service
psql --host localhost --username postgres --password --dbname template1
```

```shell
sudo systemctl stop postgresql
sudo systemctl disable postgresql
```