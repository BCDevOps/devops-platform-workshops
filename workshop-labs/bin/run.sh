#!/bin/bash

exec caddy2 file-server -root "${APP_ROOT}/book-${WORKSHOP_NAME}" --listen ':4000'