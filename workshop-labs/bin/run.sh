#!/bin/bash
if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    echo "${USER_NAME:-default}:x:$(id -u):0:${USER_NAME:-default} user:${HOME}:/sbin/nologin" >> /etc/passwd
  fi
fi
exec "$@"

## Set github ssh config
cp /opt/app-root/bin/ssh_config /opt/app-root/.ssh/config

git clone $GIT_URL
cd devops-platform-workshops/workshop-labs/docs
gitbook install
#cd ${APP_ROOT}/docs

# Create PDF
gitbook pdf ./ ./download.pdf

gitbook serve