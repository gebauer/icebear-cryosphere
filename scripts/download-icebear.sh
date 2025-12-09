#!/bin/bash
set -e

ICEBEAR_VERSION=${ICEBEAR_VERSION:-1.10.2}
ICEBEAR_SOURCE_TYPE=${ICEBEAR_SOURCE_TYPE:-official}
ICEBEAR_SOURCE_PATH=${ICEBEAR_SOURCE_PATH:-/var/www/icebear}
ICEBEAR_GITHUB_REPO=${ICEBEAR_GITHUB_REPO:-}

echo "IceBear Source Download Script"
echo "Version: $ICEBEAR_VERSION"
echo "Source Type: $ICEBEAR_SOURCE_TYPE"
echo "Target Path: $ICEBEAR_SOURCE_PATH"

# Create target directory if it doesn't exist
mkdir -p "$ICEBEAR_SOURCE_PATH"

cd "$ICEBEAR_SOURCE_PATH"

case "$ICEBEAR_SOURCE_TYPE" in
    official)
        echo "Downloading IceBear from official releases..."
        DOWNLOAD_URL="https://www.icebear.fi/releases/icebear_v${ICEBEAR_VERSION//./_}.tar"
        
        # Download the tarball
        echo "Downloading from: $DOWNLOAD_URL"
        if ! wget -O icebear.tar "$DOWNLOAD_URL"; then
            echo "Error: Failed to download IceBear from: $DOWNLOAD_URL"
            echo "Please verify the version number and that the URL is accessible"
            exit 1
        fi
        
        # Extract the tarball
        echo "Extracting IceBear source..."
        tar -xf icebear.tar
        
        # Find the extracted directory and move contents to target
        EXTRACTED_DIR=$(find . -maxdepth 1 -type d -name "icebear*" | head -n 1)
        if [ -n "$EXTRACTED_DIR" ] && [ "$EXTRACTED_DIR" != "." ]; then
            echo "Moving contents from $EXTRACTED_DIR to $ICEBEAR_SOURCE_PATH"
            mv "$EXTRACTED_DIR"/* . 2>/dev/null || true
            mv "$EXTRACTED_DIR"/.[!.]* . 2>/dev/null || true
            rmdir "$EXTRACTED_DIR" 2>/dev/null || true
        fi
        
        # Clean up
        rm -f icebear.tar
        
        echo "IceBear source downloaded and extracted successfully"
        ;;
        
    github)
        if [ -z "$ICEBEAR_GITHUB_REPO" ]; then
            echo "Error: ICEBEAR_GITHUB_REPO must be set when using github source type"
            exit 1
        fi
        
        echo "Cloning IceBear from GitHub repository..."
        echo "Repository: $ICEBEAR_GITHUB_REPO"
        
        # Clone or update repository
        if [ -d ".git" ]; then
            echo "Updating existing repository..."
            git pull origin main || git pull origin master
        else
            echo "Cloning repository..."
            git clone "$ICEBEAR_GITHUB_REPO" .
        fi
        
        # Checkout specific version if provided and different from default
        if [ -n "$ICEBEAR_VERSION" ] && [ "$ICEBEAR_VERSION" != "latest" ]; then
            echo "Checking out version: $ICEBEAR_VERSION"
            git checkout "$ICEBEAR_VERSION" 2>/dev/null || git checkout "v$ICEBEAR_VERSION" 2>/dev/null || echo "Warning: Could not checkout version $ICEBEAR_VERSION, using default branch"
        fi
        
        echo "IceBear source cloned/updated successfully"
        ;;
        
    volume)
        echo "Source type is 'volume' - skipping download"
        echo "Assuming IceBear source is already mounted at $ICEBEAR_SOURCE_PATH"
        if [ ! -f "index.php" ] && [ ! -f "config.php" ]; then
            echo "Warning: No IceBear files detected in $ICEBEAR_SOURCE_PATH"
            echo "Please ensure the source is mounted correctly"
        fi
        ;;
        
    *)
        echo "Error: Unknown source type: $ICEBEAR_SOURCE_TYPE"
        echo "Supported types: official, github, volume"
        exit 1
        ;;
esac

# Set correct permissions
echo "Setting permissions..."
chown -R www-data:www-data "$ICEBEAR_SOURCE_PATH"
find "$ICEBEAR_SOURCE_PATH" -type d -exec chmod 755 {} \;
find "$ICEBEAR_SOURCE_PATH" -type f -exec chmod 644 {} \;

# Mark as installed
touch "$ICEBEAR_SOURCE_PATH/.icebear-installed"
echo "IceBear source setup completed"

