FROM arctiqteam/gitbook-base:3.2.3
MAINTAINER stewartshea <shea.stewart@arctiq.ca>

# Set paths, permissions, and add content
ENV APP_ROOT=/opt/app-root
ENV PATH=${APP_ROOT}/bin:${PATH} HOME=${APP_ROOT}
COPY bin/ ${APP_ROOT}/bin/
COPY support/ ${APP_ROOT}/support/

RUN rm -rf  ${APP_ROOT}/docs/*
COPY docs/ ${APP_ROOT}/docs/
RUN chmod -R u+x ${APP_ROOT}/bin && \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} /etc/passwd && \
#    curl -fsSL https://github.com/caddyserver/caddy/releases/download/v1.0.4/caddy_v1.0.4_linux_amd64.tar.gz | \
#    tar -xvz --file=- --directory=/usr/local/bin --no-selinux caddy && \
    curl -sSL -o /usr/local/bin/caddy2 -f https://github.com/caddyserver/caddy/releases/download/v2.0.0-beta.13/caddy2_beta13_linux_amd64 && \
    chmod +x /usr/local/bin/caddy2 && \
    mkdir /home/nobody && chmod g+w /home/nobody && \
    echo '#!/bin/sh' > /usr/local/sbin/uid_entrypoint && \
    echo 'echo "root:x:0:0:root:/root:/sbin/nologin" > /etc/passwd' >> /usr/local/sbin/uid_entrypoint && \
    echo 'echo "nobody:x:$(id -u):0:nobody user:/home/nobody:/sbin/nologin" >> /etc/passwd' >> /usr/local/sbin/uid_entrypoint && \
    echo 'exec "$@"' >> /usr/local/sbin/uid_entrypoint \
    chmod 764 /usr/local/sbin/uid_entrypoint

# Install gitbook plugins
RUN cd ${APP_ROOT}/docs && \
    ../support/toc.sh ./openshift101 > SUMMARY.md && \
    chgrp -R 0 ${APP_ROOT}/docs && \
    chmod -R g=u ${APP_ROOT}/docs && \
    gitbook install && \
    gitbook build && \
    mv ${APP_ROOT}/docs/_book ${APP_ROOT}/book && \
    chgrp -R 0 ${APP_ROOT}/book && \
    chmod -R g+w ${APP_ROOT}/book && \
#    gitbook pdf ./ ./download.pdf && \
    chgrp -R 0 ${APP_ROOT}/docs && \
    chmod -R g=u ${APP_ROOT}/docs

WORKDIR ${APP_ROOT}

EXPOSE 4000

# Do the thing
CMD ["/usr/local/sbin/uid_entrypoint", "${APP_ROOT}/bin/run.sh"]
