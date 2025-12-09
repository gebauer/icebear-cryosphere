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

## Getting Started (Outline)

Here’s a rough outline of how to get started with IceBear-Cryosphere:

1. Clone this repository  
2. Copy or template a configuration file (e.g. `.env` or `config.yml`) — specify:  
   - Storage path(s) (for IceBear store, backups)  
   - MySQL database credentials / settings  
   - (Optional) Imaging integration details (if using Formulatrix)  
   - Hostname / domain, HTTPS settings  
3. Run `docker-compose up -d` (or equivalent) to start services: Apache/PHP, MySQL, IceBear web app, volume mounts  
4. On first start, run IceBear’s equivalent of the install script: initialize database, configure storage, set permissions.  
5. Access IceBear in browser via your configured domain (e.g. `https://icebear.example.org`) — finish setup (storage, admin user, optional imaging configuration).  
6. (Optional) Configure automatic backups (via host-mounted volume, external backup service, etc.).  

## Configuration Variables (suggested)

Here are some configuration variables you might want to expose / template:

```
ICEBEAR_STORAGE_PATH=/icebearstore
ICEBEAR_BACKUP_PATH=/icebear_backup
MYSQL_ROOT_PASSWORD=your_root_password
MYSQL_DATABASE=icebear
MYSQL_USER=icebear_user
MYSQL_PASSWORD=secure_password
SERVER_HOSTNAME=icebear.example.org
ENABLE_HTTPS=true
LETSENCRYPT_EMAIL=admin@example.org
… (imager integration vars if needed) …
```

## Notes / Warnings

- IceBear can handle large amounts of image data — ensure you allocate sufficient disk space and configure regular backups.  
- For production deployment — configure HTTPS properly, secure database credentials, and restrict access appropriately.  
- If integrating imaging devices, ensure secure network connectivity and correct credentials.  
- Monitor your server’s resource usage (disk, CPU, memory, network) — especially when dealing with many images or multiple users.  

## License & Contribution

*(Add license information here: MIT / GPL / whatever is appropriate)*  

Contributions are welcome: if you add support for extra configuration (e.g. Kubernetes), better backup strategies, or automations — please send a pull request.  

