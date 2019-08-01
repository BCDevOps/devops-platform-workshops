#!/bin/bash
if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    echo "${USER_NAME:-default}:x:$(id -u):0:${USER_NAME:-default} user:${HOME}:/sbin/nologin" >> /etc/passwd
  fi
fi
exec "$@"

## Set github ssh config
mkdir -p .ssh
cp bin/ssh_config .ssh/config

git clone $GIT_URL -b ${WORKSHOP_BRANCH:-master}
cd $WORKSHOP_FOLDER/docs
cp summaries/SUMMARY-$WORKSHOP_NAME.md SUMMARY.md
gitbook install
#cd ${APP_ROOT}/docs

# Create PDF
gitbook pdf ./ ./download.pdf

gitbook serve
