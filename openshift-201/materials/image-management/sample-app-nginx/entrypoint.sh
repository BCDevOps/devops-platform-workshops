#!/bin/sh

# Set default values for variables if they are not provided
: "${NAME:=unknown}"
: "${APP_MSG:= }"
: "${SECRET_APP_MSG:= }"

# Substitute the environment variables in the template file
envsubst '${NAME} ${APP_MSG} ${SECRET_APP_MSG}' \
    < /usr/share/nginx/html/index.html.template \
    > /usr/share/nginx/html/index.html

# Start Nginx
exec "$@"
