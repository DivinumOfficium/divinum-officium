# --- STAGE 1: Build Info ---
FROM public.ecr.aws/docker/library/alpine:latest AS gitinfo
RUN apk add git
COPY .git /build/
WORKDIR /build

RUN echo "{" > /build/buildinfo && \
    echo "  \"build-date\": \"$(date +%s)\", " >> /build/buildinfo && \
    echo "  \"build-date-human\": \"$(date)\", " >> /build/buildinfo && \
    echo "  \"commit\": \"$(git rev-parse HEAD)\", " >> /build/buildinfo && \
    echo "  \"branch\": \"$(git rev-parse --abbrev-ref HEAD)\"" >> /build/buildinfo && \
    echo "}" >> /build/buildinfo

# --- STAGE 2: Final Container ---
FROM public.ecr.aws/docker/library/perl:5.40-slim AS final
LABEL maintainer="Thomas Randall <thomas.james.randall@gmail.com>"

# 1. System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libperl-dev \
    libssl-dev \
    zlib1g-dev \
    libcgi-pm-perl \
    libcgi-session-perl \
    libhttp-message-perl \
    liburi-perl \
    libwww-perl \
    libplack-perl \
    perl-modules \
    wget \
    && rm -rf /var/lib/apt/lists/*

# 2. Plack Stack — pin Plack to 1.0050 which reverts the breaking return_405 change
RUN cpanm --notest \
    MIYAGAWA/Plack-1.0050.tar.gz \
    Starman \
    Plack::App::CGIBin \
    CGI::Compile \
    CGI::Emulate::PSGI \
    CGI::Session

# 3. Process management — detect arch so this works on both x86_64 and ARM
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        DUMB_INIT_ARCH="x86_64"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        DUMB_INIT_ARCH="aarch64"; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    wget -O /usr/local/bin/dumb-init \
        "https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_${DUMB_INIT_ARCH}" && \
    chmod +x /usr/local/bin/dumb-init

WORKDIR /var/www

# 4. Copy code and set permissions
COPY web /var/www/web
COPY app.psgi /var/www/app.psgi
COPY --from=gitinfo /build/buildinfo /var/www/web/buildinfo

RUN find /var/www/web -type d -exec chmod 755 {} + && \
    find /var/www/web -type f -exec chmod 644 {} + && \
    find /var/www/web/cgi-bin -type f -name "*.pl" -exec chmod +x {} + && \
    chown -R www-data:www-data /var/www

# 5. Internalize URLs
RUN grep -rl 'divinumofficium.com' /var/www/web | xargs sed -i 's|https\?://divinumofficium\.com/|/|g'

# 6. Clear any debug environment that might have leaked in
ENV PERL5OPT=""
ENV PERL5DB=""
ENV PERLDB_OPTS=""

USER www-data
EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]

CMD ["starman", "--port", "8080", "--host", "0.0.0.0", "--workers", "10", "--preload-app", "/var/www/app.psgi"]
