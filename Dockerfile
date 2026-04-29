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
FROM public.ecr.aws/docker/library/perl:5.42-slim AS final
LABEL maintainer="Thomas Randall <thomas.james.randall@gmail.com>"

# 1. System dependencies (Removed libcap2-bin)
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
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# 2. Plack Stack
RUN cpanm --notest \
    Starman \
    Plack::App::CGIBin \
    CGI::Compile \
    CGI::Emulate::PSGI \
    CGI::Session

# 3. Process management
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64 && \
    chmod +x /usr/local/bin/dumb-init

WORKDIR /var/www

# 4. Copy code and FORCE PERMISSIONS
COPY web /var/www/web
COPY app.psgi /var/www/app.psgi
COPY --from=gitinfo /build/buildinfo /var/www/web/buildinfo

RUN find /var/www/web -type d -exec chmod 755 {} + && \
    find /var/www/web -type f -exec chmod 644 {} + && \
    find /var/www/web/cgi-bin -type f -name "*.pl" -exec chmod +x {} + && \
    chown -R www-data:www-data /var/www

# 5. Internalize URLs
RUN grep -rl 'divinumofficium.com' /var/www/web | xargs sed -i 's|http[s]*://divinumofficium.com/|/|g'

# Removed setcap block entirely as it is not supported in the serverless runtime.

USER www-data
COPY --chown=www-data:www-data web /var/www/web

# Updated to Port 8080 (Non-privileged)
EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
# Updated Starman to listen on 8080
CMD ["starman", "--port", "8080", "--workers", "5", "/var/www/app.psgi"]