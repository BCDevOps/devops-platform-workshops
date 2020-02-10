#!/usr/bin/env bash

# Pause Rollouts
oc -n ${DEV_NS} patch "dc/mongodb-${STUDENT_ID}" -p '{"spec":{"paused": true}}'
oc -n ${DEV_NS} patch "dc/rocketchat-${STUDENT_ID}" -p '{"spec":{"paused": true}}'

