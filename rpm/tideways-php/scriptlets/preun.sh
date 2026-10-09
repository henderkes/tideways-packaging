#!/bin/bash

case "$1" in
    0)
        if hash php-config 2>/dev/null; then
            # We need this hack because php-config is shipped in php5-dev pkg
            EXTENSION_DIR=`php -r 'echo ini_get("extension_dir");' 2> /dev/null`
        else
            echo "No PHP installation found.";
            exit 0
        fi

        if [ -h "$EXTENSION_DIR/tideways.so" ]; then
            rm "$EXTENSION_DIR/tideways.so"
            rm "$EXTENSION_DIR/Tideways.php"
        fi

        ;;

    1)
        # Nothing to do in case of upgrades
        ;;
esac