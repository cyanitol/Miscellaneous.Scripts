#!/bin/bash
# Copyright 2022 Justin Weeks <license@jmweeks.com>

function ResetFireWall(){
    yes | ufw reset
    ufw default deny incoming
    ufw default allow outgoing
}

function RestartCaddy(){
    systemctl restart caddy
}

function CreateFirewallRules(){
    ufw allow from any to any port 443
    ufw allow from any to any port 80
}

function DeleteFirewallRules(){
    ufw delete allow from any to any port 443
    ufw detele allow from any to any port 80
}

CreateFirewallRules
RestartCaddy
sleep 30
DeleteFirewallRules