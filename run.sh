#!/bin/sh

#export ISUBATA_DB_HOST=127.0.0.1
export ISUBATA_DB_HOST=10.146.15.201
export ISUBATA_DB_USER=isucon
export ISUBATA_DB_PASSWORD=isucon
export GOGC=50
cd /home/isucon/isubata/webapp/go
exec ./isubata > /tmp/isubata.log 2>/tmp/isubata-err.log

