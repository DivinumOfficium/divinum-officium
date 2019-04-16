FROM        httpd:2.4-alpine
# FROM        perl:5.28
MAINTAINER  Ben Yanke <ben@benyanke.com>

###################
# Divinum Officium
###################

# Creates a fully running application server for Divinum 
# Officium, also enabling easy development without configuration
# or installing dependencies

# Last modified 4/12/2019 by Ben Yanke <ben@benyanke.com> 


# Set permission logs directory so PIDFILE can write before we drop root permissions
RUN chown www-data:www-data /usr/local/apache2/logs


# TODO: See if all these packages are needed
RUN apk add perl-cgi perl-cgi-session perl-utils && rm -rf /var/cache/apk/*

USER www-data
WORKDIR /var/www

# Copy App
COPY web /var/www/web

# Copy config files
copy docker/apache/httpd.conf /usr/local/apache2/conf/httpd.conf

# TODO: Add apache runner here

EXPOSE 8080

# TODO: Put dumb init here
# ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["httpd-foreground"]
