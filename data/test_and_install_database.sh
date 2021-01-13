#!/usr/bin/env bash

service postgresql start
sudo -u postgres psql -f /tmp/postgresql.sql
/var/www/totum-mit/bin/totum install --pgdump=PGDUMP --psql=PSQL -e -- ru no-milti ${postgres_schema} ${email} ${domain} ${totum_user} ${totum_password} ${totum_database} localhost ${postgres_user} ${postgres_password}
if [ -e /tmp/totum_dump.sql ]; then
	echo "DROP SCHEMA main CASCADE;" > /tmp/drop.sql
	sudo -u postgres psql --dbname='totum_db' -f /tmp/drop.sql 
	sudo -u postgres PGPASSWORD=${postgres_password} psql -v ON_ERROR_STOP=1 --username=${postgres_user} --password --host='localhost' --dbname=${totum_database} --no-readline < /tmp/totum_dump.sql;
fi
