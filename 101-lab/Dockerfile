FROM arctiqteam/gitbook-base:3.2.3

# Set paths, permissions, and add content
ENV APP_ROOT=/opt/app-root
ENV PATH=${APP_ROOT}/bin:${PATH} HOME=${APP_ROOT}
# where caddyfile is mounted
RUN mkdir ${APP_ROOT}/config
RUN mkdir ${APP_ROOT}/content
COPY content/ ${APP_ROOT}/content
COPY Caddyfile ${APP_ROOT}/config
RUN echo "Installing Caddy V2 (Beta), this is based of a github release and should be checked periodically to ensure the latest version is being used"
RUN chmod -R u+x ${APP_ROOT}/bin && \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} /etc/passwd && \
    mkdir /usr/local/bin/caddy2 && \
    curl -sSL -o caddy_2.4.0-beta.1_linux_amd64.tar.gz -f https://github.com/caddyserver/caddy/releases/download/v2.4.0-beta.1/caddy_2.4.0-beta.1_linux_amd64.tar.gz && \
    tar -xzvf caddy_2.4.0-beta.1_linux_amd64.tar.gz -C /usr/local/bin/ && \
    chmod +x /usr/local/bin/caddy && rm caddy_2.4.0-beta.1_linux_amd64.tar.gz


# build md into html pages
RUN cd ${APP_ROOT}/content && \
    chgrp -R 0 ${APP_ROOT}/content && \
    chmod -R g=u ${APP_ROOT}/content && \
    gitbook install && \
    gitbook build && \
    # mv ${APP_ROOT}/_book ${APP_ROOT} && \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g+w ${APP_ROOT} && \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT}

RUN mv ${APP_ROOT}/content/_book/* ${APP_ROOT}

WORKDIR ${APP_ROOT}
EXPOSE 2015
CMD ["sh", "-c", "/usr/local/bin/caddy run --config ${APP_ROOT}/config/Caddyfile" ]


# TODO FIGUIRE OUT HOW TO BUILD OCP101 and 201 labs independantly!