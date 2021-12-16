#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Configure the example service
# s6-overlay docs: https://github.com/just-containers/s6-overlay
# ==============================================================================

declare cf_tunnel_name
declare cf_certificate
declare cf_subdomain
declare cf_domain

cf_tunnel_name=$(bashio::config 'cf_tunnel_name')
cf_certificate=$(bashio::config 'cf_certificate')
cf_subdomain=$(bashio::config 'cf_subdomain')
cf_domain=$(bashio::config 'cf_domain')

if ! bashio::fs.file_exists "/config/cloudflare/${cf_tunnel_name}.json"; then
    bashio::log.info "Creating Cloudflare Tunnel"

    ./opt/cloudflare/cloudflared --origincert "${cf_certificate}" --cred-file /config/cloudflare/"${cf_tunnel_name}".json tunnel create "${cf_tunnel_name}"
fi

if ! bashio::fs.file_exists "/config/cloudflare/config-${cf_tunnel_name}.yaml"; then
    bashio::log.info "Creating Cloudflare configuration file"

    echo -e "tunnel: ${cf_tunnel_name}" > /config/cloudflare/config-"${cf_tunnel_name}".yaml
    echo -e "credentials-file: /config/cloudflare/${cf_tunnel_name}.json" >> /config/cloudflare/config-"${cf_tunnel_name}".yaml
    echo -e "url: http://localhost:7123" >> /config/cloudflare/config-"${cf_tunnel_name}".yaml

    bashio::log.info "Creating Cloudflare DNS entry"

    ./opt/cloudflare/cloudflared --origincert "${cf_certificate}" tunnel route dns "${cf_tunnel_name}" "${cf_subdomain}"."${cf_domain}"
fi