FROM arctiqteam/gitbook-base:3.2.3

# Set paths, permissions, and add content
ENV APP_ROOT=/opt/app-root
ENV PATH=${APP_ROOT}/bin:${PATH} HOME=${APP_ROOT}
COPY bin/ ${APP_ROOT}/bin/
COPY support/ ${APP_ROOT}/support/
# where caddyfile is mounted
RUN mkdir ${APP_ROOT}/config
RUN rm -rf  ${APP_ROOT}/docs/*

COPY docs/ ${APP_ROOT}/docs/

RUN echo "Installing Caddy V2 (Beta), this is based of a github release and should be checked periodically to ensure the latest version is being used"
RUN chmod -R u+x ${APP_ROOT}/bin && \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} /etc/passwd && \
    curl -sSL -o /usr/local/bin/caddy2 -f https://github.com/caddyserver/caddy/releases/download/v2.0.0-beta.20/caddy2_beta20_linux_amd64 && \
    chmod +x /usr/local/bin/caddy2 && \
    mkdir /home/nobody && chmod g+w /home/nobody && \
    echo '#!/bin/sh' > /usr/local/sbin/uid_entrypoint && \
    echo 'echo "root:x:0:0:root:/root:/sbin/nologin" > /etc/passwd' >> /usr/local/sbin/uid_entrypoint && \
    echo 'echo "nobody:x:$(id -u):0:nobody user:/home/nobody:/sbin/nologin" >> /etc/passwd' >> /usr/local/sbin/uid_entrypoint && \
    echo 'exec "$@"' >> /usr/local/sbin/uid_entrypoint
    
RUN chmod 764 /usr/local/sbin/uid_entrypoint

ENV BOOK_NAME_101=book-openshift101
ENV BOOK_NAME_201=book-openshift201

# Install gitbook plugins for 101:
RUN cd ${APP_ROOT}/docs && \
    ../support/toc.sh ./openshift101 > SUMMARY.md && \
    chgrp -R 0 ${APP_ROOT}/docs && \
    chmod -R g=u ${APP_ROOT}/docs && \
    gitbook install && \
    gitbook build && \
    mv ${APP_ROOT}/docs/_book ${APP_ROOT}/${BOOK_NAME_101} && \
    chgrp -R 0 ${APP_ROOT}/${BOOK_NAME_101} && \
    chmod -R g+w ${APP_ROOT}/${BOOK_NAME_101} && \
#    gitbook pdf ./ ./download.pdf && \
    chgrp -R 0 ${APP_ROOT}/docs && \
    chmod -R g=u ${APP_ROOT}/docs

# Install gitbook plugins for 201:
RUN cd ${APP_ROOT}/docs && \
    ../support/toc.sh ./openshift201 > SUMMARY.md && \
    chgrp -R 0 ${APP_ROOT}/docs && \
    chmod -R g=u ${APP_ROOT}/docs && \
    rm -rf ${APP_ROOT}/docs/_book && \
    gitbook build && \
    mv ${APP_ROOT}/docs/_book ${APP_ROOT}/${BOOK_NAME_201} && \
    chgrp -R 0 ${APP_ROOT}/${BOOK_NAME_201} && \
    chmod -R g+w ${APP_ROOT}/${BOOK_NAME_201} && \
#    gitbook pdf ./ ./download.pdf && \
    chgrp -R 0 ${APP_ROOT}/docs && \
    chmod -R g=u ${APP_ROOT}/docs

WORKDIR ${APP_ROOT}

EXPOSE 4000

# Do the thing
CMD ["sh", "-c", "$APP_ROOT/bin/run.sh"]
