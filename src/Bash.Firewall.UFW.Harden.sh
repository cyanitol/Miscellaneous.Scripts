#!/bin/bash
# Copyright 2022 Justin Weeks <license@jmweeks.com>

# SCRIPT FUNCTION:
# The purpose of this script is to use ufw to deny access to all IP addresses 
# and all ports running on a particular system except for those explicitly 
# allowed.
# 
# SCRIPT CONFIGURATION:
# DNS_record: A and/or AAAA records(s) that contain the IP addresses of systems
#            allowed to access allowed_ports.
#  allowed_ports: Ports that are allowed access from the IP addresses in 
#                  DNS_record
#  allowed_ports_unrestricted: Ports that are allowed access from ANY IP address 
#                              regardless of what is set in DNS_record (DANGER!)
#  DNS_server_address: DNS Server to use for DNS Record Lookup

# Path is set here if running from cron doesn't include necessary paths
export PATH=$PATH:/usr/sbin:/usr/bin

# ** CHANGE THESE VARIABLES **
DNS_record="hostname.domain.com";
allowed_ports=("22" "443" "80")
DNS_server_address = "1.1.1.1"

# Uncomment if Needed (DANGER!)
#allowed_ports_unrestricted=("443" "80")

# ** DO NOT EDIT ANYTHING BELOW THIS LINE **
allowedIP=();

function get_IP_address(){
    for i in $(dig +short $DNS_record @$DNS_server_address); do
    allowedIP+=("$i");
    done;

    for i in $(dig +short $DNS_record AAAA @$DNS_server_address); do
    allowedIP+=("$i");
    done;
}

function reset_firewall_rules(){
    yes | ufw reset
    ufw default deny incoming
    ufw default allow outgoing
}

function create_rule_allow_ports(){
    for IP in ${allowedIP[@]}; do
        ufw allow from $IP to any port $PORT;
    done;
}

function create_rule_allow_ports_unrestricted(){
    for IP in ${allowed_ports_unrestricted[@]}; do
        ufw allow $PORT;
    done;
}

function enable_firewall(){
    yes | ufw enable
}

get_IP_address
reset_firewall_rules

for PORT in ${allowed_ports[@]}; do
    create_rule_allow_ports
done;

for PORT in ${allowed_ports_unrestricted[@]}; do
    create_rule_allow_ports_unrestricted
done;

enable_firewall