#!/usr/bin/env bash

sed -i -e \"s/^Stable tag: .*$/Stable tag: $PLUGIN_VERSION/g\" ./readme.txt
sed -i -e \"s/^Version: .*$/Version: $PLUGIN_VERSION/g\" ./wp-cowsay.php
