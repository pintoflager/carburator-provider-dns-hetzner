#!/usr/bin/env bash

carburator fn echo info "Invoking Hetzner DNS provider..."

# ATTENTION: --preserve-env (or -k) flag forwards domain env from here to provisioner.
# Check if provisioner exists and gives OK response.
carburator provisioner request \
    create \
    zone \
    --provider "$PROVIDER_NAME" \
    --provisioner "$PROVISIONER_NAME" \
    --preserve-env || exit 120

carburator fn echo success "Hetzner DNS zone for $DOMAIN_FQDN created."
