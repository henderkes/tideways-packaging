#!/bin/sh

use_systemctl="True"
if ! command -V systemctl >/dev/null 2>&1; then
  use_systemctl="False"
fi

prerm_systemd() {
    NAME=$1

    systemctl stop $NAME >/dev/null || true
    systemctl disable $NAME >/dev/null || true
    systemctl --system daemon-reload >/dev/null || true
}

if [ "$1" = "1" ];
then
    # skipping uninstall on upgrade for rpm, since prerm of the old package
    # is executed after new package's installation on CentOS8/RHEL 8
    exit
fi

if [ "${use_systemctl}" = "True" ];
then
  prerm_systemd tideways-daemon
fi

