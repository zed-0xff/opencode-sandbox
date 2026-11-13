#!/bin/sh -e
if [ -f policy.json.local ]; then
	jq -s 'reduce .[] as $item ({}; . * $item)' policy.json policy.json.local > policy.tmp
	export OPENSHELL_SANDBOX_POLICY=policy.tmp
else
	export OPENSHELL_SANDBOX_POLICY=policy.json
fi

openshell policy set opencode --policy policy.tmp

rm policy.tmp
