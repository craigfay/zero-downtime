#!/bin/bash
CONFIG_FROM=127.0.0.1:9923
CONFOG_TO=127.0.0.1:9924
NGINX_FROM=http://webapp_9923
NGINX_TO=http://webapp_9924

# read our existing configuration file
# and see if we should swap our to <-> from
if grep --quiet 127.0.0.1:9924 /opt/webapp/config.json; then
  CONFIG_FROM=127.0.0.1:9924
  CONFIG_TO=127.0.0.1:9923
  NGINX_FROM=http://webapp_9924
  NGINX_TO=http://webapp_9923
fi

function rollback {
  sed -i "s#$CONFIG_TO#$CONFIG_FROM#g" /opt/webapp/config.json
}

sed -i "s#$CONFIG_FROM#$CONFIG_TO#g" /opt/webapp/config.json
if [ $? -ne 0 ]; then
  exit 1
fi

sed -i "s#$NGINX_FROM#$NGINX_TO#g" /opt/nginx/sites-available/webapp
if [ $? -ne 0 ]; then
  rollback
  exit 2
fi

## TODO: start a new web app

# wait for it to start
sleep 5

# reload nginx to use the now running & listening app
/etc/init.d/nginx reload

## TODO: stop the existing web app