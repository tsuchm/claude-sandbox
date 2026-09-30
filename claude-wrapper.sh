#!/bin/bash
exec docker compose -f $(dirname "$(readlink -f ${0})")/docker-compose.yml \
     exec claude-sandbox claude
