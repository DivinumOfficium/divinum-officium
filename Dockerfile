###################
# Divinum Officium
###################

# Creates a fully running application server for Divinum
# Officium, also enabling easy development without configuration
# or installing dependencies

FROM minidocks/perl AS dev
LABEL maintainer="Martin Hasoň <martin.hason@gmail.com>"

RUN apk add apache2 perl-cgi && clean

RUN sed -i 's/logs\/access.log/\/dev\/stdout.pipe/g' /etc/apache2/httpd.conf \
    && sed -i 's/logs\/error.log/\/dev\/stderr.pipe/g' /etc/apache2/httpd.conf \
    && sed -i 's/localhost\/cgi-bin/divinum-officium\/cgi-bin/g' /etc/apache2/httpd.conf

# Copy config files into container
COPY ./docker /

EXPOSE 8080
WORKDIR /var/www

HEALTHCHECK CMD wget -S -q --spider -O/dev/null http://localhost:8080 2>&1 | grep -q 'HTTP/1.1 200'

CMD ["httpd", "-DFOREGROUND"]

FROM dev AS prod

# Copy web with correct permission
COPY --chown=apache:apache ./web /var/www/divinum-officium
