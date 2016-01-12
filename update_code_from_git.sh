#!/bin/bash
# update current (code) folder from git
set -x # echo on
cd /var/www/egrixcalcapp/egrixcalc
passenger stop
git fetch origin
git reset --hard origin/master
cd ..
chmod -R 777 egrixcalc/
cd egrixcalc
passenger start
