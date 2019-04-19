FROM        perl:5.28
MAINTAINER  Ben Yanke <ben@benyanke.com>

# Set envs
ENV APACHE_RUN_USER www-data \
    APACHE_RUN_GROUP www-data \
    APACHE_LOCK_DIR /var/lock/apache2 \
    APACHE_LOG_DIR /var/log/apache2 \
    APACHE_PID_FILE /var/run/apache2/apache2.pid \
    APACHE_SERVER_NAME localhost

# Get dumb-init to use a proper init system
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64 && \
    chmod +x /usr/local/bin/dumb-init

# Install packages
RUN apt-get update && apt-get install -y \
    apache2 \
    libcgi-session-perl \
    && rm -rf /var/lib/apt/lists/*

# Load config files
COPY docker/apache/ports.conf /etc/apache2/ports.conf
COPY docker/apache/apache2.conf /etc/apache2/apache2.conf

# Set permissionsso apache can write to logs without root
RUN mkdir -p /var/run/apache2 /var/lock/apache2 /var/log/apache2 ; chown -R www-data:www-data /var/lock/apache2 /var/log/apache2 /var/run/apache2

# Drop permissions - everything below here done without root
USER www-data

# Copy in code
WORKDIR /var/www
COPY --chown=www-data:www-data web /var/www/web

# Expose default port
EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
CMD ["/usr/sbin/apache2ctl", "-DFOREGROUND"]
