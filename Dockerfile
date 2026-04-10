# --- STAGE 1: Build Info (Adopted from Master) ---
FROM public.ecr.aws/docker/library/alpine:latest AS gitinfo
RUN apk add git
COPY .git /build/
WORKDIR /build

# Write build info to be available at $url/buildinfo
RUN echo "{" > /build/buildinfo && \
    echo "  \"build-date\": \"$(date +%s)\"," >> /build/buildinfo && \
    echo "  \"build-date-human\": \"$(date)\"," >> /build/buildinfo && \
    echo "  \"commit\": \"$(git rev-parse HEAD)\"," >> /build/buildinfo && \
    echo "  \"branch\": \"$(git rev-parse --abbrev-ref HEAD)\"" >> /build/buildinfo && \
    echo "}" >> /build/buildinfo

# --- STAGE 2: Final Container (Optimized Plack Stack) ---
FROM public.ecr.aws/docker/library/perl:5.42-slim AS final
LABEL maintainer="Thomas Randall <thomas.james.randall@gmail.com>"

# 1. System dependencies 
# build-essential and libperl-dev are CRITICAL for Starman/XS compilation on slim images
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libperl-dev \
    libssl-dev \
    zlib1g-dev \
    libcgi-pm-perl \
    perl-modules \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# 2. Plack Stack
RUN cpanm --notest \
    Plack Starman Plack::App::CGIBin CGI::Compile CGI::Emulate::PSGI CGI CGI::Session

# 3. Process management
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64 && \
    chmod +x /usr/local/bin/dumb-init

# 4. Set Workdir
WORKDIR /var/www

# 5. Copy code and FORCE PERMISSIONS
COPY web /var/www/web
COPY app.psgi /var/www/app.psgi

# Copy build info from Stage 1
COPY --from=gitinfo /build/buildinfo /var/www/web/buildinfo

# Ensure directories are accessible (755) and files are readable (644)
RUN find /var/www/web -type d -exec chmod 755 {} + && \
    find /var/www/web -type f -exec chmod 644 {} + && \
    find /var/www/web/cgi-bin -type f -name "*.pl" -exec chmod +x {} + && \
    chown -R www-data:www-data /var/www

# 6. Internalize URLs (Sledgehammer fix)
RUN grep -rl 'divinumofficium.com' /var/www/web | xargs sed -i 's|http[s]*://divinumofficium.com/|/|g'

USER www-data
EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
CMD ["starman", "--port", "8080", "--workers", "5", "/var/www/app.psgi"]