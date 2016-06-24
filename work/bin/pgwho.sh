#!/bin/sh
exec psql -U pgsql postgres -c 'select * from pg_stat_activity;'
