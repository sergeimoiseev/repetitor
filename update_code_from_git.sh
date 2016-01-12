#!/bin/bash
# update current folder from git
# should be run with 'sudo bash <update_...sh'
set -x # echo on
cd /var/www/repetitorapp/code
passenger stop
git fetch origin
git reset --hard origin/master
cd ..
chmod -R 777 code/
cd code
passenger start
