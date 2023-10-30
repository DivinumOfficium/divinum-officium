#!/bin/bash

# Copy in correct apache config
if [[ "$HTTPS_REDIRECT" == "" ]] ; then

fi


# Startup the app
/usr/sbin/apache2ctl -DFOREGROUND
