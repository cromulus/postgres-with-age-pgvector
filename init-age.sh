#!/bin/bash
set -e

# The PostgreSQL configuration file is in $PGDATA/postgresql.conf.
# Append the Apache AGE extension to shared_preload_libraries if it’s not already set.
CONFIG_FILE="$PGDATA/postgresql.conf"

if grep -q "^shared_preload_libraries" "$CONFIG_FILE"; then
  # If a shared_preload_libraries line already exists but doesn't include 'age', append it.
  if ! grep -q "age" "$CONFIG_FILE"; then
    sed -ri "s/^(shared_preload_libraries\s*=\s*)'?([^']*)'?/\1'age, \2'/" "$CONFIG_FILE"
  fi
else
  # Otherwise, just add the line.
  echo "shared_preload_libraries = 'age'" >> "$CONFIG_FILE"
fi

