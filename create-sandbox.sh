#!/bin/bash -e

OPT="--detach"
if [ "$1" = "-d" -o "$1" = "--debug" ]; then
    OPT=""
fi

set -a
[ -f .env ] && . .env
set +a

docker build -t opencode-sandbox .
docker image ls opencode-sandbox

if [ -f policy.json.local ]; then
	jq -s 'reduce .[] as $item ({}; . * $item)' policy.json policy.json.local > policy.tmp
	export OPENSHELL_SANDBOX_POLICY=policy.tmp
else
	export OPENSHELL_SANDBOX_POLICY=policy.json
fi

#export IDA_MCP_URL=$(openshell service list ida -o json | jq -r '.services[0].url')

openshell sandbox delete opencode
openshell sandbox create \
	--name opencode \
	--from opencode-sandbox:latest \
	--driver-config-json "$(envsubst < driver-config.json | jq -c .)" \
    --env-from PROJECT_NAME \
    --env-from IDA_MCP_URL \
    --env-from OPENCODE_PASSWORD \
    --env OPENCODE_MAX_IMAGES=1 \
    $OPT \
	-- ./ep.sh opencode serve --print-logs

openshell service expose opencode 4096 web

if [ -f policy.tmp ]; then
	rm policy.tmp
fi

if [ "$1" = "-c" -o "$1" = "--connect" ]; then
    openshell sandbox connect opencode
fi
