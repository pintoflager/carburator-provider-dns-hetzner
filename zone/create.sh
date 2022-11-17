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
    --provisioner "$PROVISIONER_NAME"; exitcode=$?


###
# Extract required values from provisioner output and save it to service provider.
#
if [[ $exitcode -eq 0 ]]; then
    carburator fn echo info "Updating Hetzner service provider environment..."

    if [[ $PROVISIONER_NAME == 'terraform' ]]; then
        # TODO: zone is per domain.
        output="$PROVISIONER_PROVIDER_PATH/zone.json"

        
    fi

    # ... test other provisioners with else if [[  ]]...

    carburator fn echo success "Hetzner service provider updated."

###
# Fallback to API call.
#
else
    curl -X "POST" "https://dns.hetzner.com/api/v1/zones" \
        -s \
        -H 'Content-Type: application/json' \
        -H "Auth-API-Token: $dns_token" \
        -d $'{
    "name": "'"$domain"'",
    "ttl": 86400
    }' > "$zonefile"

    # TODO: same as with provider but extract from response json
    # If file size is zero, dns zone setup went to shit. Try again
    if [[ ! -s "$zonefile" ]]; then
        rm -f "$zonefile"
        echo-error "Dns zone create failed, trying again in 10 seconds..."
        sleep 10 && dns-zone
    fi

    if [[ -z $(jq -rc ".zone.id" "$zonefile") ]]; then
        echo-warn "DNS zone id came back empty, try searching for duplicate.."

        existing_zone=$(curl "https://dns.hetzner.com/api/v1/zones?name=$domain" \
            -s \
            -H "Auth-API-Token: $dns_token" | \
            jq -rc '.zones[].id')

        # Existing DNS zone was found from hetzner, delete it and try again.                                                                                                                
        if [[ -n $existing_zone ]]; then
            echo-success "Duplicate DNS zone found, delete it and try again..."

            curl -X "DELETE" "https://dns.hetzner.com/api/v1/zones/$existing_zone" \
            -s \
            -H "Auth-API-Token: $dns_token" &> /dev/null
            
            # Try again
            dns-zone
        else
            die "We had problems with creating new DNS zone. Please debug"
        fi
    fi
fi
