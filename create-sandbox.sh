#!/bin/bash -e

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

openshell sandbox delete opencode
openshell sandbox create \
	--name opencode \
	--from opencode-sandbox:latest \
        --forward 0.0.0.0:4096 \
	--driver-config-json "$(envsubst < driver-config.json | jq -c .)" \
        --env-from PROJECT_NAME \
        --env-from OPENCODE_SERVER_PASSWORD \
        --env-from IDA_MCP_HOST \
        --env-from IDA_MCP_CODE \
        --env OPENCODE_MAX_IMAGES=1 \
	--detach \
	-- ./ep.sh opencode serve --print-logs

if [ -f policy.tmp ]; then
	rm policy.tmp
fi
