#!/usr/bin/env bash

if [ "$(psql -Aqtc "select count(pid) from pg_stat_activity where query ilike 'refresh materialized view concurrently user_statistics%' and state='active'" $DATABASE_URL 2> /dev/null)" == "0" ]; then
  echo "$(date --iso-8601=seconds): Refreshing user statistics"
  # refresh in the background to return immediately
  psql -Aqt \
    -c "REFRESH MATERIALIZED VIEW CONCURRENTLY user_statistics" \
    -c "UPDATE refreshments SET updated_at=now() where mat_view='user_statistics'" \
    $DATABASE_URL &
fi

if [ "$(psql -Aqtc "select count(pid) from pg_stat_activity where query ilike 'refresh materialized view concurrently hashtag_statistics%' and state='active'" $DATABASE_URL 2> /dev/null)" == "0" ]; then
  echo "$(date --iso-8601=seconds): Refreshing hashtag statistics"
  # refresh in the background to return immediately
  psql -Aqt \
    -c "REFRESH MATERIALIZED VIEW CONCURRENTLY hashtag_statistics" \
    -c "UPDATE refreshments SET updated_at=now() where mat_view='hashtag_statistics'" \
    $DATABASE_URL &
fi

if [ "$(psql -Aqtc "select count(pid) from pg_stat_activity where query ilike 'refresh materialized view concurrently country_statistics%' and state='active'" $DATABASE_URL 2> /dev/null)" == "0" ]; then
  # refresh in the background to return immediately
  echo "$(date --iso-8601=seconds): Refreshing country statistics"
  psql -Aqt \
    -c "REFRESH MATERIALIZED VIEW CONCURRENTLY country_statistics" \
    -c "UPDATE refreshments SET updated_at=now() where mat_view='country_statistics'" \
    $DATABASE_URL &
fi

wait
echo "$(date --iso-8601=seconds): Completed"
