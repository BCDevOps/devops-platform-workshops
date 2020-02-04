#!/bin/bash

[ -z ${STUDENT+x} ] &&  echo "Environment Variable STUDENT has not been set or it is empty" && exit 1
[ -z ${NAMESPACE_TOOLS+x} ] && echo "Environment Variable NAMESPACE_TOOLS has not been set or it is empty" && exit 1
[ -z ${NAMESPACE_DEV+x} ] && echo "Environment Variable NAMESPACE_DEV has not been set or it is empty" && exit 1

set -x
rm -rf /opt/app-root/book/student
mkdir -p /opt/app-root/book/student
ln -s /opt/app-root/book "/opt/app-root/book/student/${STUDENT}"
{ set +x; } 2>/dev/null

find "/opt/app-root/book/openshift101" -type f -name '*.html' | xargs -I {} perl -p -i -e "s/\Q[username]\E/${STUDENT}/g" '{}'
find "/opt/app-root/book/openshift101" -type f -name '*.html' | xargs -I {} perl -p -i -e "s/\Q[-tools]\E/${NAMESPACE_TOOLS}/g" '{}'
find "/opt/app-root/book/openshift101" -type f -name '*.html' | xargs -I {} perl -p -i -e "s/\Q[-dev]\E/${NAMESPACE_DEV}/g" '{}'

exec "$@"
