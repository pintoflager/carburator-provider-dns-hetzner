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

# Curl is required.
if ! carburator has program curl; then
    carburator print terminal error \
        "Missing required program curl. Trying to install..."
else
    carburator print terminal success "Curl found from the client"
    exit 0
fi

# TODO: Untested below
if carburator has program apt; then
    carburator sudo apt update
    carburator sudo apt -y install curl

elif carburator has program pacman; then
    carburator sudo pacman update
    carburator sudo pacman -Suy curl

elif carburator has program yum; then
    carburator sudo yum makecache --refresh
    carburator sudo yum install curl

elif carburator has program dnf; then
    carburator sudo dnf makecache --refresh
    carburator sudo dnf -y install curl

else
    carburator print terminal error \
        "Unable to detect package manager from client node linux"
    exit 120
fi

