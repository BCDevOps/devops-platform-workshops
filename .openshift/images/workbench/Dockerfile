# Reference: https://fedoramagazine.org/building-smaller-container-images/
FROM registry.fedoraproject.org/fedora-minimal:30
RUN \
    set -x && \
    echo -e "[nodejs]\nname=nodejs\nstream=12\nprofiles=\nstate=enabled\n" > /etc/dnf/modules.d/nodejs.module && \
    microdnf install vim tar unzip which curl rsync procps git findutils httpd-tools && \
    curl -fsSL https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz | \
    tar -xvz --file=- --strip-components=1 --directory=/usr/local/bin --no-selinux --wildcards '*/oc'  --wildcards '*/kubectl' && \
    curl -fsSL -o /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 && \
    chmod a+x /usr/local/bin/jq && \
    ln -s /usr/bin/vim /usr/bin/vi && \
    microdnf clean all && \
    mkdir /home/nobody && chmod g+w /home/nobody && \
    chmod g+w /etc/passwd && \
    echo '#!/usr/bin/env bash' > /usr/local/sbin/uid_entrypoint && \
    echo 'echo "root:x:0:0:root:/root:/sbin/nologin" > /etc/passwd' >> /usr/local/sbin/uid_entrypoint && \
    echo 'echo "nobody:x:$(id -u):0:nobody user:/home/nobody:/bin/bash" >> /etc/passwd' >> /usr/local/sbin/uid_entrypoint && \
    echo 'exec "$@"' >> /usr/local/sbin/uid_entrypoint && \
    echo 'PS1='"'"'\e[41;4;33mWORKBENCH $\[\e[m\] '"'" > /home/nobody/.bashrc && \
    chmod ug+x /usr/local/sbin/uid_entrypoint

ENV HOME=/home/nobody
WORKDIR /home/nobody
ENTRYPOINT [ "/usr/local/sbin/uid_entrypoint", "sleep", "172800"]
