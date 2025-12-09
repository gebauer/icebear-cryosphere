FROM php:8.1-apache

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    git \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libxml2-dev \
    libmagickwand-dev \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions required by IceBear
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    mysqli \
    pdo \
    pdo_mysql \
    gd \
    zip \
    xml \
    mbstring \
    opcache

# Install Imagick extension
RUN pecl install imagick && docker-php-ext-enable imagick

# Enable Apache modules
RUN a2enmod rewrite headers

# Copy Apache configuration
COPY docker/apache/icebear.conf /etc/apache2/sites-available/000-default.conf

# Copy PHP configuration
COPY docker/php/php.ini /usr/local/etc/php/conf.d/icebear.ini

# Copy initialization scripts
COPY scripts/download-icebear.sh /usr/local/bin/download-icebear.sh
COPY scripts/init-icebear.sh /usr/local/bin/init-icebear.sh

# Make scripts executable
RUN chmod +x /usr/local/bin/download-icebear.sh /usr/local/bin/init-icebear.sh

# Create IceBear source directory
RUN mkdir -p /var/www/icebear && chown -R www-data:www-data /var/www

# Create storage directories
RUN mkdir -p /icebearstore /icebear_backup && \
    chown -R www-data:www-data /icebearstore /icebear_backup

# Set working directory
WORKDIR /var/www/icebear

# Create entrypoint script
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
# Download IceBear source if needed\n\
if [ "$ICEBEAR_SOURCE_TYPE" != "volume" ]; then\n\
    if [ "$ICEBEAR_UPDATE_ON_START" = "true" ] || [ ! -f /var/www/icebear/.icebear-installed ]; then\n\
        echo "Downloading/updating IceBear source..."\n\
        /usr/local/bin/download-icebear.sh\n\
    fi\n\
fi\n\
\n\
# Initialize IceBear\n\
/usr/local/bin/init-icebear.sh\n\
\n\
# Start Apache\n\
exec apache2-foreground\n\
' > /usr/local/bin/docker-entrypoint.sh && \
    chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

EXPOSE 80

