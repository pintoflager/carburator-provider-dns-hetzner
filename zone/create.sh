#!/usr/bin/env bash

# ATTENTION: Scripts run from carburator project's public root directory:
# echo "$PWD"

# ATTENTION: to check the environment variables uncomment:
# env

carburator fn paint green "Invoking Hetzner DNS provider..."

# Check if provisioner exists and gives OK response.
carburator provisioner request \
    create \
    zone \
    --provider "$PROVIDER_NAME" \
    --provisioner "$PROVISIONER_NAME" || exit 120

carburator fn echo success "Hetzner DNS zone for $DOMAIN_FQDN created."
