FROM node:8.12-alpine

ENV REVEAL_VERSION 3.7.0
ENV WORKSHOP_NAME=default

# python, make and g++ are build dependencies fpr reveal.js and grunt-cli
RUN apk add --no-cache --virtual .build-deps python make g++ wget gzip \
    && wget --no-check-certificate https://github.com/hakimel/reveal.js/archive/$REVEAL_VERSION.tar.gz \
    && tar xzf $REVEAL_VERSION.tar.gz \
    && rm -f $REVEAL_VERSION.tar.gz \
    && mv reveal.js-$REVEAL_VERSION revealjs \
    && mkdir -p /revealjs/node_modules \
    && npm install -g grunt-cli \
    && npm install --prefix /revealjs \
    && npm install -g bower \
    && apk del .build-deps 

WORKDIR /revealjs

# Install plugins
RUN npm install --save reveal.js-menu \
    && npm install --save reveal.js-toolbar


COPY plugin/reveal.js-plugins/ /revealjs/plugin/
COPY bin/run.sh /
COPY slides/ /revealjs

EXPOSE 8000
    
CMD ["/bin/sh", "/run.sh"]