# Docker file for using the standalone generator
FROM        perl:5.28-slim as final
LABEL maintainer="Stepan Srubar <breviarium@srubarovi.cz>"

# Install packages
RUN apt-get update && apt-get install -y \
    libcgi-session-perl \
    bsdmainutils \
    zip \
    libwww-perl \
    dos2unix

# Copy kindlegen for Linux from another docker image (for MOBI conversions).
COPY --from=wiltonsr/kindlegen /kindlegen /usr/local/bin/kindlegen

# Copy in code
COPY web /var/www/web
COPY standalone/tools/epubgen2 /var/www/standalone/tools/epubgen2

# Ensure the files have linux endings (and purge packages not required at runtime)
RUN find /var/www/web -xdev -type f \( -name "*.pl" -o -name "*.sh" -o -name "*.txt" -o -name "*.ini" \) -exec dos2unix {} \; \
    && find /var/www/standalone/tools/epubgen2/ -xdev -type f \( -name "*.pl" -o -name "*.sh" -o -name "*.txt" -o -name "*.ini" \) -exec dos2unix {} \; \
    && apt-get --purge remove -y dos2unix \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/standalone/tools/epubgen2/
CMD ["/bin/bash", "/var/www/standalone/tools/epubgen2/epubgen2.sh"]
