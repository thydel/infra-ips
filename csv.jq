#!/usr/local/bin/jq -rf

([ "IP", "Mounted on", "MAC", "UP", "Comment"] | @csv),
(.ips[] | [ .id, .is_on, .mac, .ip_up, .cmnt ] | @csv)
