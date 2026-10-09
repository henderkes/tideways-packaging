#!/bin/bash

INSTALL_DIR="/usr/lib/tideways"

if hash php 2>/dev/null; then
    # We need this hack because php-config is shipped in php5-dev pkg
    EXTENSION_DIR=`php -r 'echo ini_get("extension_dir");' 2> /dev/null`
    PHP_MAJOR_VERSION=`php -r 'echo PHP_MAJOR_VERSION;' 2> /dev/null`
    PHP_MINOR_VERSION=`php -r 'echo PHP_MINOR_VERSION;' 2> /dev/null`
    PHP_VERSION="${PHP_MAJOR_VERSION}.${PHP_MINOR_VERSION}";

    echo "Detected PHP ${PHP_VERSION} and extension directory: ${EXTENSION_DIR}"
else
    echo "No PHP installation found.";
    echo
    echo "MANUAL INSTALLATION REQUIRED"
    echo "Symlink the tideways-php-{phpversion}.so file";
    echo "for your PHP version into your extension directory."
    echo "Files have been installed to:"
    echo ""
    echo "  $INSTALL_DIR"
    echo ""
    echo "The tideways.so PHP extension file should be linked"
    echo "or copied to the PHP extension directory. An example for PHP 8.3:"
    echo ""
    echo "   ln -sf $INSTALL_DIR/tideways-php-8.3.so /my/php/ext/tideways.so"
    echo ""
    echo "To find the extension dir you can call: php -r 'echo ini_get(\"extension_dir\");'"
    echo ""
    echo "Enable the extension by adding the following line to your"
    echo "php.ini file and then reload your webserver or php-fpm:"
    echo ""
    echo "  extension=tideways.so"
    echo ""
    exit 0
fi

restartWebserver() {
    echo ""
    echo "To finalize the setup and start collecting performance data:"
    echo ""
    echo "1. Edit your php.ini, setting the \"tideways.api_key\" for your application."
    echo "2. Reload your php-fpm or apache webserver."
    echo ""
    echo "See also:"
    echo "https://support.tideways.com/documentation/setup/configuration/configure-tideways-globally-via-php-ini.html"
    echo ""
}

EXTENSION_FILE="$INSTALL_DIR/tideways-php-${PHP_VERSION}.so"
CONFIG_FILES=( )

echo "Checking for PHP versions and extension directories:"
if [ -f "$EXTENSION_FILE" ]; then
    ln -sf "$EXTENSION_FILE" "$EXTENSION_DIR/tideways.so"

    CONFIG_DIR="/etc/php.d"

    if [ -d "$CONFIG_DIR" ]; then
        if [ ! -f "$CONFIG_DIR/tideways.ini" ]; then
            cp $INSTALL_DIR/tideways.ini $CONFIG_DIR/tideways.ini
            CONFIG_FILES+=("$CONFIG_DIR/tideways.ini")
        fi
    fi

    echo "- Detected PHP ${PHP_VERSION} and extension directory: ${EXTENSION_DIR}"
fi
echo ""

if [ -d "/opt/plesk/php" ]; then
    echo "Detected Plesk PHP and installing Tideways for Plesk"

    VERSIONS=( "5.3" "5.4" "5.5" "7.0" "7.1" "7.2" "7.3" "7.4" "8.0" "8.1" "8.2" "8.3" "8.4" "8.5" "8.6" )
    EXTS=( "lib" "lib64" )

    for VERSION in "${VERSIONS[@]}"
    do
        for EXT in "${EXTS[@]}"
        do
            if [ -d "/opt/plesk/php/${VERSION}/${EXT}/php/modules" ]; then
                EXTENSION_DIR="/opt/plesk/php/${VERSION}/${EXT}/php/modules"
                CONFIG_DIR="/opt/plesk/php/${VERSION}/etc/php.d"

                ln -sf "$INSTALL_DIR/tideways-php-${VERSION}.so" "${EXTENSION_DIR}/tideways.so"

                echo "- Detected PHP ${VERSION} and extension directory: ${EXTENSION_DIR}"

                if [ ! -f "${CONFIG_DIR}/tideways.ini" ]; then
                    cp $INSTALL_DIR/tideways.ini $CONFIG_DIR/tideways.ini
                    CONFIG_FILES+=("$CONFIG_DIR/tideways.ini")
                fi
            fi
        done
    done

    echo ""
fi

echo "The following tideways.ini files have been created:"
for CONFIG_FILE in "${CONFIG_FILES[@]}"
do
    echo "- ${CONFIG_FILE}"
done

restartWebserver

exit 0