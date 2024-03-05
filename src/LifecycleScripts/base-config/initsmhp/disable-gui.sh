#!/bin/bash

set -exuo pipefail

## NOT WORKING. LEFT HERE FOR FYI BASIS ONLY.
## No effect until reboot, which we shouldn't do from LCC
#systemctl set-default multi-user.target
##
## When below tried manually, this will hang until ^C. Then soon after, cannot ssm to the instance.
#systemctl isolate multi-user.target

declare -a SVC=(
    gdm.service
    avahi-daemon.service
    switcheroo-control.service

    ## Do not disable this, otherwise sudo becomes slow.
    #dbus.service
    #network-manager.service
)
for i in "${SVC[@]}"; do
    systemctl disable --now $i
    systemctl mask $i
done
