#!/bin/sh -xe

# validate opencode config at container build time
jq . < .config/opencode/opencode.json > /dev/null

for f in $(find .config/opencode -name package.json); do
	npm install --prefix $(dirname $f)
done

# referenced by opencode.json
#npm install @opencode/ai

curl -fsSL https://bun.sh/install | bash
bun add github:zed-0xff/operator-memory
bun add --minimum-release-age 0 @aerovato/operator-helper@latest
operator-helper install opencode

# externally mounted session storage
mkdir -p .local/share
rm -rf .local/share/opencode
ln -sf /workspace/projects/.opencode .local/share/opencode
