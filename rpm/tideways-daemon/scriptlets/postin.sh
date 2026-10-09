#!/bin/sh

# Step 1, decide if we should use systemd or init/upstart
use_systemctl="True"
if ! command -V systemctl >/dev/null 2>&1; then
  use_systemctl="False"
fi

commonInstallUpgrade() {
  mkdir -p /var/log/tideways
  chown tideways:tideways /var/log/tideways

  mkdir -p /var/run/tideways
  chown tideways:tideways /var/run/tideways

  chmod 0644 /etc/logrotate.d/tideways-daemon

  chmod a+x /usr/bin/tideways-daemon

  if command -v selinuxenabled >/dev/null 2>&1 && selinuxenabled; then
    semodule -i /usr/share/selinux/packages/tideways_daemon.pp || return 1
    restorecon -RF /usr/bin/tideways-daemon /run/tideways || return 1
  fi
}

cleanInstall() {
  commonInstallUpgrade || return 1

  # Step 3 (clean install), enable the service in the proper way for this platform
  if [ "${use_systemctl}" = "True" ]; then
    systemctl daemon-reload || :
    systemctl unmask tideways-daemon || :
    systemctl preset tideways-daemon || :
    systemctl enable tideways-daemon || :
    systemctl restart tideways-daemon || :
  fi
}

upgrade() {
  # Step 3(upgrade), do what you need
  commonInstallUpgrade || return 1

  if [ "${use_systemctl}" = "True" ]; then
    systemctl --system daemon-reload >/dev/null || true
    if ! systemctl is-enabled tideways-daemon >/dev/null; then
      systemctl enable tideways-daemon >/dev/null || true
      systemctl start tideways-daemon >/dev/null || true
    fi
    systemctl restart tideways-daemon >/dev/null || true
  fi
}

# Step 2, check if this is a clean install or an upgrade
action="$1"
if [ "$1" = "configure" ] && [ -z "$2" ]; then
  # Alpine linux does not pass args, and deb passes $1=configure
  action="install"
elif [ "$1" = "configure" ] && [ -n "$2" ]; then
  # deb passes $1=configure $2=<current version>
  action="upgrade"
fi

case "$action" in
"1" | "install")
  cleanInstall
  ;;
"2" | "upgrade")
  upgrade
  ;;
*)
  # $1 == version being installed
  cleanInstall
  ;;
esac
