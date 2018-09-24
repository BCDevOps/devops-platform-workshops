#!/bin/bash
if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    echo "${USER_NAME:-default}:x:$(id -u):0:${USER_NAME:-default} user:${HOME}:/sbin/nologin" >> /etc/passwd
  fi
fi
exec "$@"


#git clone -b  $BRANCH $GIT_URL data
#cd data/docs
cd ${APP_ROOT}/docs

# Create PDF
gitbook pdf ./ ./download.pdf

gitbook serve