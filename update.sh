#!/usr/bin/bash

cat << "EOF"
SSPanel-UIM update script
Author: M1Screw
Github: https://github.com/sspanel-uim/SSPanel-Uim-Dev
Usage: 
./update.sh dev --> Upgrade to the latest development version
./update.sh release release_version db_version --> Upgrade to the specified release version
EOF

[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script!"; exit 1; }

do_update_sspanel_dev(){
    git pull
    git reset --hard origin/dev
    git fetch --prune --prune-tags
    rm -r storage/framework/smarty/compile/*
    php composer.phar update
    php composer.phar selfupdate
    php xcat Update
    php xcat Tool importAllSettings
    php xcat Migration latest
    wget https://cdn.jsdelivr.net/gh/sspanel-uim/qqwry.dat@latest/qqwry.dat -O storage/qqwry.dat 
}

do_update_sspanel_release(){
    tag=$1
    db_version=$2
    git pull
    git reset --hard $tag
    rm -r storage/framework/smarty/compile/*
    php composer.phar update
    php composer.phar selfupdate
    php xcat Update
    php xcat Tool importAllSettings
    php xcat Migration $db_version
    wget https://cdn.jsdelivr.net/gh/sspanel-uim/qqwry.dat@latest/qqwry.dat -O storage/qqwry.dat 
}

if [[ $1 == "dev" ]]; then
    do_update_sspanel_dev
    exit 0
fi

if [[ $1 == "release" ]]; then
    if [[ $2 == "" ]]; then
        echo "Error: The release version cannot be empty!"
        exit 1
    fi
    if [[ $3 == "" ]]; then
        echo "Error: The database version cannot be empty!"
        exit 1
    fi
    do_update_sspanel_release $2 $3
    exit 0
fi