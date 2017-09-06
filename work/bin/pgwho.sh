#!/bin/sh
exec psql --expanded -U pgsql postgres -c 'select * from pg_stat_activity;'
