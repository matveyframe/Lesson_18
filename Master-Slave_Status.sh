#!/bin/bash

NOTES_APP="http://10.127.17.30:8001"
OUTPUT=$(curl -s "$NOTES_APP/health")
STATUS_CLUSTER=$( sudo -u postgres repmgr -f /etc/repmgr.conf cluster show)

  if echo "${OUTPUT}" | grep -q '"primary":"up"' && echo "${OUTPUT}" | grep -q '"replica":"up"'; then
     echo "$STATUS_CLUSTER" && echo -e "\n\nMaster and Slave is working!"
  else
     echo "$STATUS_CLUSTER" && echo -e "\n\nMaster or Slave not a working!"
  fi




