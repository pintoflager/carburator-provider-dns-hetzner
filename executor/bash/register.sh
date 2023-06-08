#!/usr/bin/env bash

# ATTENTION: Supports only client nodes, pointless to read role from $1


# We know we have secrets but this is a good practice anyways.
if carburator has json dns_provider.secrets -p '.exec.json'; then

    # Read secrets from json exec environment line by line
    while read -r secret; do
        # Prompt secret if it doesn't exist yet.
        if ! carburator has secret "$secret" --user root; then
            # ATTENTION: We know only one secret is present. Otherwise
            # prompt texts should be adjusted accordingly.
            carburator print terminal warn \
                "Could not find secret containing Hetzner DNS API token."
            
            carburator prompt secret "Hetzner DNS API key" \
            --name "$secret" \
            --user root || exit 120
        fi
    done < <(carburator get json dns_provider.secrets array -p '.exec.json')
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
    apt-get -y update
    apt-get -y install curl

elif carburator has program pacman; then
    pacman update
    pacman -Sy curl

elif carburator has program yum; then
    yum makecache --refresh
    yum install curl

elif carburator has program dnf; then
    dnf makecache --refresh
    dnf -y install curl

else
    carburator print terminal error \
        "Unable to detect package manager from client node linux"
    exit 120
fi

