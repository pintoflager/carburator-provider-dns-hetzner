#!/usr/bin/env bash

# ATTENTION: Supports only client nodes, pointless to read role from $1

secret_name="$PACKAGE_SECRET_NAME"

# Prompt secret if it doesn't exist yet.
if ! carburator has secret "$secret_name" --user root; then
    carburator print terminal warn \
		"Could not find secret containing Hetzner DNS API token."
	
    carburator prompt secret "Hetzner DNS API key" \
      --name "$secret_name" \
      --user root || exit 120
fi
