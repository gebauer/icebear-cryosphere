# IceBear-Cryosphere 🚀

This project aims to dockerize IceBear — a research data management platform for structural biology / crystallography — to simplify deployment and maintenance in a containerized environment.

## What is IceBear

IceBear is a browser-based LIMS (Laboratory Information Management System) for structural biology / macromolecular crystallography: it helps manage crystallization experiments, metadata, imaging, and storage of results. :contentReference[oaicite:2]{index=2}  
With IceBear-Cryosphere, we aim to wrap IceBear and its dependencies into Docker containers (or a Docker Compose / Kubernetes stack) for easier deployment, portability, and reproducibility.

## System Requirements (as per upstream IceBear)

According to the official installation guide of IceBear: :contentReference[oaicite:3]{index=3}

- A Linux server (Ubuntu 18.04 LTS is assumed) :contentReference[oaicite:4]{index=4}  
- A functional LAMP stack (Apache, MySQL, PHP) — PHP 7.2 or later :contentReference[oaicite:5]{index=5}  
- Several terabytes of disk space (especially if storing significant image data) and a good network connection :contentReference[oaicite:6]{index=6}  
- Writable storage location for IceBear store (default is `/icebearstore`) and optional backup storage location :contentReference[oaicite:7]{index=7}  
- (Optional) If integrating with imaging devices (e.g. Formulatrix imagers / Rock Maker), connection details (hostname, port, database names, credentials) will be needed. :contentReference[oaicite:9]{index=9}  
- Proper secure-HTTP (HTTPS) configuration: SSL certificate, ideally from your IT department or via Let’s Encrypt / CertBot. :contentReference[oaicite:11]{index=11}  

## What IceBear-Cryosphere Will Provide

- A Docker (or Docker Compose / Helm / K8s) based setup to run IceBear + its dependencies (Apache, MySQL, PHP) in containers.  
- Configuration of storage volumes (for IceBear data, image storage, backups).  
- Easy initialization of the database and IceBear config, mapping to container volumes.  
- (Optionally) A way to integrate imaging-device imports (e.g. Formulatrix imagers) via environment variables / configuration files.  
- HTTPS support via built-in or easy-to-configure mechanism (Let’s Encrypt or external certs).  
- (Optional) Backup/restore support, e.g. mounting an external storage for backups, or scheduled exports.  

## Quick Start with Docker Compose

### Prerequisites

- Docker Engine 20.10+ and Docker Compose 2.0+
- At least 4GB RAM (8GB+ recommended for production)
- Sufficient disk space for your data (IceBear can handle terabytes of image data)

### Installation Steps

1. **Clone this repository:**
   ```bash
   git clone <repository-url>
   cd icebear-cryosphere
   ```

2. **Configure environment variables:**
   ```bash
   cp .env.example .env
   # Edit .env and set your database passwords and configuration
   ```

3. **Start the services:**
   ```bash
   docker-compose up -d
   ```

4. **Wait for initialization:**
   - The containers will automatically download IceBear source (if using `official` source type)
   - MySQL will initialize on first run
   - IceBear will be available once containers are healthy

5. **Access IceBear:**
   - Open your browser to `http://localhost` (or your configured `SERVER_HOSTNAME`)
   - Complete the IceBear installation wizard through the web interface
   - Configure storage paths, admin user, and optional imaging device integration

6. **Verify health:**
   ```bash
   docker-compose ps
   # All services should show as "healthy"
   ```

### Updating IceBear Source

The setup is designed to make updating IceBear easy:

**Option 1: Update via environment variable (recommended)**
1. Edit `.env` and set `ICEBEAR_VERSION` to the new version (e.g., `1.10.3`)
2. Set `ICEBEAR_UPDATE_ON_START=true` (or run download script manually)
3. Restart the web container:
   ```bash
   docker-compose restart web
   ```

**Option 2: Manual update script**
```bash
docker-compose exec web /usr/local/bin/download-icebear.sh
docker-compose restart web
```

**Option 3: Use GitHub source**
1. Set `ICEBEAR_SOURCE_TYPE=github` in `.env`
2. Set `ICEBEAR_GITHUB_REPO` to your repository URL
3. Restart the web container

**Option 4: Volume mount (for development)**
1. Set `ICEBEAR_SOURCE_TYPE=volume` in `.env`
2. Mount your local IceBear source directory in `docker-compose.yml`

## Configuration Variables

See `.env.example` for all available configuration options. Key variables:

**Database:**
- `MYSQL_ROOT_PASSWORD` - MySQL root password (required)
- `MYSQL_DATABASE` - Database name (default: `icebear`)
- `MYSQL_USER` - Database user (default: `icebear_user`)
- `MYSQL_PASSWORD` - Database user password (required)

**IceBear Source:**
- `ICEBEAR_VERSION` - Version to download (default: `1.10.2`)
- `ICEBEAR_SOURCE_TYPE` - Source type: `official`, `github`, or `volume` (default: `official`)
- `ICEBEAR_GITHUB_REPO` - GitHub repository URL (if using GitHub source)
- `ICEBEAR_UPDATE_ON_START` - Auto-update on container start (default: `false`)

**Storage:**
- `ICEBEAR_STORAGE_PATH` - Main storage path (default: `/icebearstore`)
- `ICEBEAR_BACKUP_PATH` - Backup storage path (default: `/icebear_backup`)

**Application:**
- `SERVER_HOSTNAME` - Server hostname for Apache config (default: `localhost`)
- `PHP_MEMORY_LIMIT` - PHP memory limit (default: `512M`)

## Deployment with Coolify

This Docker Compose setup is fully compatible with [Coolify](https://coolify.io), a self-hosted PaaS platform.

### Deploying to Coolify

1. **Install Coolify** (if not already installed):
   ```bash
   curl -fsSL https://cdn.coollabs.io/coolify/install.sh | sudo bash
   ```

2. **Create a new project** in Coolify dashboard

3. **Add a new resource** using Docker Compose:
   - Click "Create New Resource"
   - Select "Docker Compose" build pack
   - Connect your Git repository or upload the `docker-compose.yml` file
   - Specify the path to `docker-compose.yml` (root if at repository root)

4. **Configure environment variables** in Coolify:
   - Navigate to your resource's "Environment Variables" section
   - Add all variables from `.env.example`
   - Set secure passwords and configuration values

5. **Deploy:**
   - Click "Deploy" in Coolify
   - Monitor the deployment logs
   - Health checks will automatically verify service status

### Coolify-Specific Notes

- Health checks are automatically configured and monitored by Coolify
- Volumes are managed by Coolify's volume system
- Ports are automatically exposed through Coolify's reverse proxy
- HTTPS is handled by Coolify's Traefik instance (no additional configuration needed)
- Updates can be triggered through Coolify's interface or by pushing to your repository

## Volume Management and Backups

### Persistent Volumes

The setup creates the following named volumes:
- `icebear_source` - IceBear application source code
- `icebear_data` - Main data storage (`/icebearstore`)
- `icebear_backup` - Backup storage (`/icebear_backup`)
- `mysql_data` - MySQL database files

### Backup Strategy

**Database backup:**
```bash
docker-compose exec mysql mysqldump -u root -p${MYSQL_ROOT_PASSWORD} icebear > backup.sql
```

**Volume backup:**
```bash
docker run --rm -v icebear_data:/data -v $(pwd):/backup alpine tar czf /backup/icebear_data_backup.tar.gz -C /data .
```

**Restore:**
```bash
# Database restore
docker-compose exec -T mysql mysql -u root -p${MYSQL_ROOT_PASSWORD} icebear < backup.sql

# Volume restore
docker run --rm -v icebear_data:/data -v $(pwd):/backup alpine tar xzf /backup/icebear_data_backup.tar.gz -C /data
```

### Using Host Directories (Optional)

To use host directories instead of named volumes, modify `docker-compose.yml`:

```yaml
volumes:
  - ./icebear_source:/var/www/icebear
  - ./data/icebearstore:/icebearstore
  - ./data/backup:/icebear_backup
```

## Troubleshooting

### Container won't start

- Check logs: `docker-compose logs web` or `docker-compose logs mysql`
- Verify environment variables are set correctly
- Ensure ports 80 and 3306 are not already in use

### IceBear source not downloading

- Check internet connectivity from container: `docker-compose exec web curl -I https://www.icebear.fi`
- Verify `ICEBEAR_VERSION` is correct (format: `1.10.2`)
- Check download script logs: `docker-compose exec web cat /var/log/apache2/error.log`

### Database connection errors

- Verify MySQL is healthy: `docker-compose ps mysql`
- Check database credentials in `.env`
- Wait for MySQL to fully initialize (may take 30-60 seconds on first run)

### Permission issues

- Ensure storage directories are writable: `docker-compose exec web ls -la /icebearstore`
- Check file ownership: `docker-compose exec web ls -la /var/www/icebear`

### Health check failures

- Verify web service is responding: `curl http://localhost`
- Check Apache error logs: `docker-compose exec web tail -f /var/log/apache2/error.log`
- Increase health check start period if initialization takes longer

## Notes / Warnings

- **IceBear can handle large amounts of image data** — ensure you allocate sufficient disk space and configure regular backups
- **For production deployment** — configure HTTPS properly (use Coolify's built-in HTTPS or configure SSL certificates), secure database credentials, and restrict access appropriately
- **If integrating imaging devices** — ensure secure network connectivity and correct credentials
- **Monitor resource usage** — disk, CPU, memory, network — especially when dealing with many images or multiple users
- **PHP version requirement** — IceBear 1.10.2 requires PHP 8.1.0+ (included in this setup)
- **Storage planning** — Plan for several terabytes if storing significant image data  

## License & Contribution

*(Add license information here: MIT / GPL / whatever is appropriate)*  

Contributions are welcome: if you add support for extra configuration (e.g. Kubernetes), better backup strategies, or automations — please send a pull request.  

