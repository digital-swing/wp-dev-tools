#!/bin/bash

curl --header "Authorization: token $1" \
  --header 'Accept: application/vnd.github.v3.raw' \
  --output /tmp/main.yml \
  --location https://raw.githubusercontent.com/digital-swing/$2/$3/trellis/group_vars/all/main.yml

PHP_VERSION=$(cat /tmp/main.yml | grep php_version | cut -d'"' -f 2)

current_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

sed -i "s/##repo##/$2/" $current_path/continue-config.yml
sed -i "s/##branch##/$3/" $current_path/continue-config.yml
sed -i "s/##php-version##/$PHP_VERSION/" $current_path/continue-config.yml