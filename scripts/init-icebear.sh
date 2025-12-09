#!/bin/bash
set -e

MYSQL_HOST=${MYSQL_HOST:-mysql}
MYSQL_DATABASE=${MYSQL_DATABASE:-icebear}
MYSQL_USER=${MYSQL_USER:-icebear_user}
MYSQL_PASSWORD=${MYSQL_PASSWORD}
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
ICEBEAR_SOURCE_PATH=${ICEBEAR_SOURCE_PATH:-/var/www/icebear}
ICEBEAR_STORAGE_PATH=${ICEBEAR_STORAGE_PATH:-/icebearstore}
ICEBEAR_BACKUP_PATH=${ICEBEAR_BACKUP_PATH:-/icebear_backup}

echo "IceBear Initialization Script"
echo "Waiting for MySQL to be ready..."

# Wait for MySQL to be ready
until mysqladmin ping -h "$MYSQL_HOST" -u root -p"$MYSQL_ROOT_PASSWORD" --silent 2>/dev/null; do
    echo "Waiting for MySQL..."
    sleep 2
done

echo "MySQL is ready!"

# Wait a bit more to ensure MySQL is fully initialized
sleep 3

# Create storage directories if they don't exist
echo "Setting up storage directories..."
mkdir -p "$ICEBEAR_STORAGE_PATH" "$ICEBEAR_BACKUP_PATH"
chown -R www-data:www-data "$ICEBEAR_STORAGE_PATH" "$ICEBEAR_BACKUP_PATH"
chmod -R 755 "$ICEBEAR_STORAGE_PATH" "$ICEBEAR_BACKUP_PATH"

# Verify database connection
echo "Verifying database connection..."
mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" -e "SELECT 1;" > /dev/null 2>&1 || {
    echo "Warning: Could not connect to database with provided credentials"
    echo "Database may need to be initialized by IceBear installation process"
}

# Check if IceBear source is present
if [ ! -d "$ICEBEAR_SOURCE_PATH" ] || [ ! -f "$ICEBEAR_SOURCE_PATH/index.php" ]; then
    echo "Warning: IceBear source not found at $ICEBEAR_SOURCE_PATH"
    echo "Please ensure the source is downloaded or mounted"
    exit 1
fi

# Set permissions on IceBear source
echo "Setting permissions on IceBear source..."
chown -R www-data:www-data "$ICEBEAR_SOURCE_PATH"
find "$ICEBEAR_SOURCE_PATH" -type d -exec chmod 755 {} \;
find "$ICEBEAR_SOURCE_PATH" -type f -exec chmod 644 {} \;

# Make writable directories writable (IceBear may need these)
if [ -d "$ICEBEAR_SOURCE_PATH/config" ]; then
    chmod -R 775 "$ICEBEAR_SOURCE_PATH/config"
fi
if [ -d "$ICEBEAR_SOURCE_PATH/uploads" ]; then
    chmod -R 775 "$ICEBEAR_SOURCE_PATH/uploads"
fi

echo "IceBear initialization completed!"
echo "IceBear should be accessible at http://localhost/"
echo "Please complete the installation through the web interface if this is the first run."

