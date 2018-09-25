FROM arctiqteam/gitbook-base:3.2.3
MAINTAINER stewartshea <shea.stewart@arctiq.ca>

# Set paths, permissions, and add content
ENV APP_ROOT=/opt/app-root
ENV PATH=${APP_ROOT}/bin:${PATH} HOME=${APP_ROOT}
COPY bin/ ${APP_ROOT}/bin/
COPY docs/ ${APP_ROOT}/docs/
RUN chmod -R u+x ${APP_ROOT}/bin && \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} /etc/passwd 

# Install gitbook plugins
# RUN cd ${APP_ROOT}/docs && \
#     gitbook install

WORKDIR ${APP_ROOT}

EXPOSE 4000

# Do the thing
CMD ["/bin/bash", "-c", "${APP_ROOT}/bin/run.sh"]
