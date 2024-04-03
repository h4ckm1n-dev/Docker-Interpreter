#!/bin/bash
# keepalive.sh

# Trap SIGTERM (docker stop) and SIGINT (Ctrl+C) signals and gracefully exit
trap 'exit 0' SIGTERM SIGINT

# Wait indefinitely
while true; do
  sleep 1
done
