#!/bin/bash
REMOTE_HOST="192.168.1.36"

sudo apt-get install bsd-utils

REMOTE_PORT="514"

LOG_COUNT=10

SLEEP_INTERVAL=1

if ! command -v logger &> /dev/null
then
    echo "Polecenie 'logger' nie zostało znalezione. Zainstaluj pakiet 'bsd-utils'."
    exit 1
fi

echo "Rozpoczynam wysyłanie $LOG_COUNT logów testowych do $REMOTE_HOST:$REMOTE_PORT..."

for i in $(seq 1 $LOG_COUNT)
do
  LOG_MESSAGE="To jest testowy log numer $i z serwera $(hostname)"

  logger -n "$REMOTE_HOST" -P "$REMOTE_PORT" --protocol=udp -t "TestowySkrypt" -p user.info "$LOG_MESSAGE"

  echo "Wysłano log: \"$LOG_MESSAGE\""
  sleep "$SLEEP_INTERVAL"
done

echo "Zakończono wysyłanie logów."