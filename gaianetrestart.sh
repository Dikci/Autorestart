#!/bin/bash

# Найти и убить процессы на порту 8080
PIDS=$(lsof -ti :8080)
if [ -n "$PIDS" ]; then
  echo "Killing process(es) on port 8080: $PIDS"
  kill -9 $PIDS
else
  echo "No process found on port 8080."
fi

# Выполнить команды gaianet stop и start
/root/gaianet/bin/gaianet stop
/root/gaianet/bin/gaianet start
