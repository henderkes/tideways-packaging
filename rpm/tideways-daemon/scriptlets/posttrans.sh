#!/bin/sh

use_systemctl="True"
if ! command -V systemctl >/dev/null 2>&1; then
  use_systemctl="False"
fi

activateAndStart() {
  if [ "${use_systemctl}" = "True" ]; then
    systemctl --system daemon-reload >/dev/null || true
    if ! systemctl is-enabled tideways-daemon >/dev/null; then
      systemctl enable tideways-daemon >/dev/null || true
      systemctl start tideways-daemon >/dev/null || true
    fi
    systemctl restart tideways-daemon >/dev/null || true
  fi
}

activateAndStart
