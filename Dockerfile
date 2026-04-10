FROM        perl:5.38
LABEL       maintainer="Thomas Randall <thomas.james.randall@gmail.com>"

# 1. System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libssl-dev \
    zlib1g-dev \
    libcgi-pm-perl \
    perl-modules \
    && rm -rf /var/lib/apt/lists/*

# 2. Plack Stack
RUN cpanm --notest \
    Plack Starman Plack::App::CGIBin CGI::Compile CGI::Emulate::PSGI CGI CGI::Session

# 3. dumb-init
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64 && \
    chmod +x /usr/local/bin/dumb-init

# 4. Set Workdir
WORKDIR /var/www

# 5. Copy and FORCE PERMISSIONS
# We do this as root first to ensure find/chmod works perfectly
COPY web /var/www/web
COPY app.psgi /var/www/app.psgi

# Ensure directories are accessible (755) and files are readable (644)
RUN find /var/www/web -type d -exec chmod 755 {} + && \
    find /var/www/web -type f -exec chmod 644 {} + && \
    find /var/www/web/cgi-bin -type f -name "*.pl" -exec chmod +x {} + && \
    chown -R www-data:www-data /var/www

# 6. Final setup
RUN grep -rl 'divinumofficium.com' /var/www/web | xargs sed -i 's|http[s]*://divinumofficium.com/|/|g'
USER www-data
EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
CMD ["starman", "--port", "8080", "--workers", "5", "/var/www/app.psgi"]