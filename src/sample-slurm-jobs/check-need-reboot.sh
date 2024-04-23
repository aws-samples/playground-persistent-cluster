#!/bin/bash

################################################################################
# Usage:
#
#     $ ./check-need-reboot.sh
#     $ srun -N<xx> -l ./check-need-reboot.sh
#
# Then, reboot Slurm nodes:
#
#    $ sudo /opt/slurm/bin/scontrol reboot host-01,host-02
#
################################################################################

[[ -e /var/run/reboot-required.pkgs ]] \
    && {
    echo "Need reboot: $(hostname) / $(cat /sys/devices/virtual/dmi/id/board_asset_tag) / $(cat /sys/devices/virtual/dmi/id/product_name)"
        cat /var/run/reboot-required.pkgs
    } \
    || true
