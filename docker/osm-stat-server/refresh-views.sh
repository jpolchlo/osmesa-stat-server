#!/usr/bin/env bash

if [ "$(psql -Aqtc "select count(pid) from pg_stat_activity where query ilike 'refresh materialized view concurrently user_statistics%' and state='active'" $DATABASE_URL 2> /dev/null)" == "0" ]; then
  # refresh in the background to return immediately
  psql -Aqtc "REFRESH MATERIALIZED VIEW CONCURRENTLY user_statistics" $DATABASE_URL &
fi

if [ "$(psql -Aqtc "select count(pid) from pg_stat_activity where query ilike 'refresh materialized view concurrently hashtag_statistics%' and state='active'" $DATABASE_URL 2> /dev/null)" == "0" ]; then
  # refresh in the background to return immediately
  psql -Aqtc "REFRESH MATERIALIZED VIEW CONCURRENTLY hashtag_statistics" $DATABASE_URL &
fi