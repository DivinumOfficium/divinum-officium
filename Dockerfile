# --- STAGE 1: Build Info (Adopted from Master) ---
# This stage extracts git metadata to keep the final image clean.
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

# --- STAGE 2: Final Container (The Plack/Starman Stack) ---
FROM public.ecr.aws/docker/library/perl:5.42-slim AS final
LABEL maintainer="Thomas Randall <thomas.james.randall@gmail.com>"

# 1. System dependencies 
# We use 'apt' to pre-install heavy dependencies like Plack and URI.
# This makes the build 10x faster and avoids compilation timeouts.
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
# Since 'libplack-perl' is now handled by the OS, we only use cpanm 
# for the specific app-server and specialized wrappers.
RUN cpanm --notest \
    Starman \
    Plack::App::CGIBin \
    CGI::Compile \
    CGI::Emulate::PSGI \
    CGI::Session

# 3. Process management (init system)
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64 && \
    chmod +x /usr/local/bin/dumb-init

# 4. Set Workdir
WORKDIR /var/www

# 5. Copy code and FORCE PERMISSIONS
COPY web /var/www/web
COPY app.psgi /var/www/app.psgi

# Integrate the buildinfo metadata from Stage 1
COPY --from=gitinfo /build/buildinfo /var/www/web/buildinfo

# Ensure directories are accessible and scripts are executable
RUN find /var/www/web -type d -exec chmod 755 {} + && \
    find /var/www/web -type f -exec chmod 644 {} + && \
    find /var/www/web/cgi-bin -type f -name "*.pl" -exec chmod +x {} + && \
    chown -R www-data:www-data /var/www

# 6. Sledgehammer: Convert hardcoded URLs to relative paths
RUN grep -rl 'divinumofficium.com' /var/www/web | xargs sed -i 's|http[s]*://divinumofficium.com/|/|g'

# Run as non-root user for security
USER www-data
EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
CMD ["starman", "--port", "8080", "--workers", "5", "/var/www/app.psgi"]