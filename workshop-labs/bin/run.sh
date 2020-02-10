#!/bin/bash

exec caddy2 file-server -root "${APP_ROOT}/book" --listen ':4000'