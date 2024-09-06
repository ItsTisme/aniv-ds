#!/bin/bash
NOW=$( date '+%F_%H-%M-%S' )
echo "[ANIV] Checking for updates..."
./aniv-ds.sh validate anonymous
cd aniv-ds
./aniv_server.x86_64 -map nightmare -timestamps 2>&1 | tee ./logs/server_$NOW.log 
# ./aniv_server.x86_64 -map nightmare -timestamps