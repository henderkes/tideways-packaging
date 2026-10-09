#!/bin/sh
if id -u "tideways" >/dev/null 2>&1; then
    echo "User tideways already exists, skipping.."
else
    useradd -r --shell /bin/false -U -M -d /nonexistant tideways
fi
