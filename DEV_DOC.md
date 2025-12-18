# Developer Documentation - Inception Project

## Overview

This document is intended for developers who want to understand, modify, or extend the Inception infrastructure. It provides detailed technical information about the architecture, build process, configuration, and data persistence.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Prerequisites and Environment Setup](#prerequisites-and-environment-setup)
3. [Project Structure](#project-structure)
4. [Configuration Files](#configuration-files)
5. [Building and Launching](#building-and-launching)
6. [Container Management](#container-management)
7. [Volume and Data Persistence](#volume-and-data-persistence)
8. [Networking](#networking)
9. [Debugging and Development](#debugging-and-development)
10. [Customization Guide](#customization-guide)
11. [Technical Deep Dives](#technical-deep-dives)

---

## Architecture Overview

### High-Level Architecture

```
┌─────────────────────────────────────────────────────┐
│                    Host Machine                      │
│                                                      │
│  ┌────────────────────────────────────────────────┐ │
│  │         Docker Engine (Bridge Network)         │ │
│  │                                                 │ │
│  │  ┌──────────┐   ┌──────────┐   ┌──────────┐  │ │
│  │  │  NGINX   │   │WordPress │   │ MariaDB  │  │ │
│  │  │  :443    │──▶│  :9000   │──▶│  :3306   │  │ │
│  │  │ (TLS)    │   │(PHP-FPM) │   │ (MySQL)  │  │ │
│  │  └────┬─────┘   └────┬─────┘   └────┬─────┘  │ │
│  │       │              │              │         │ │
│  └───────┼──────────────┼──────────────┼─────────┘ │
│          │              │              │           │
│    ┌─────▼──────┐  ┌────▼─────┐  ┌────▼─────┐    │
│    │/data/      │  │/data/    │  │/data/    │    │
│    │wordpress   │  │wordpress │  │mariadb   │    │
│    │(static)    │  │(WP files)│  │(DB data) │    │
│    └────────────┘  └──────────┘  └──────────┘    │
└─────────────────────────────────────────────────────┘
```

### Service Communication Flow

1. **Client Request** → NGINX (port 443, HTTPS)
2. **NGINX** → WordPress PHP-FPM (port 9000, FastCGI)
3. **WordPress** → MariaDB (port 3306, MySQL protocol)
4. **Response Path**: MariaDB → WordPress → NGINX → Client

### Container Specifications

| Service   | Base Image      | Exposed Port | Internal Port | Restart Policy |
|-----------|-----------------|--------------|---------------|----------------|
| nginx     | debian:bullseye | 443          | 443           | always         |
| wordpress | debian:bullseye | -            | 9000          | always         |
| mariadb   | debian:bullseye | -            | 3306          | always         |

---

## Prerequisites and Environment Setup

### System Requirements

**Minimum:**
- CPU: 2 cores
- RAM: 2GB available
- Disk: 5GB free space
- OS: Linux, macOS, or Windows with WSL2

**Recommended:**
- CPU: 4+ cores
- RAM: 4GB+ available
- Disk: 10GB+ free space
- SSD storage

### Required Software

1. **Docker Engine** (20.10+)
   ```bash
   # Verify installation
   docker --version
   docker info
   ```

2. **Docker Compose** (v2.0+)
   ```bash
   # Verify installation
   docker compose version
   ```

3. **Make** (GNU Make)
   ```bash
   # Verify installation
   make --version
   ```

4. **Git** (for version control)
   ```bash
   git --version
   ```

### Installing Prerequisites

#### On Debian/Ubuntu:
```bash
# Update package list
sudo apt-get update

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose plugin
sudo apt-get install docker-compose-plugin

# Install Make
sudo apt-get install make

# Log out and back in for group changes
```

#### On macOS:
```bash
# Install Docker Desktop (includes Compose)
# Download from: https://www.docker.com/products/docker-desktop

# Install Make (via Xcode Command Line Tools)
xcode-select --install
```

### Setting Up the Development Environment

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd Inception_intra_retry_1
   ```

2. **Configure system hostname:**
   ```bash
   sudo sh -c 'echo "127.0.0.1 mlahrach.42.fr" >> /etc/hosts'
   ```

3. **Create and configure secrets:**
   ```bash
   # Secrets should already exist, but to recreate:
   echo "your_root_password" > secrets/mariadb_root_password.txt
   echo "your_wp_password" > secrets/mariadb_wordpress_password.txt
   echo "your_author_password" > secrets/wordpress_author_password.txt
   
   # Secure the files
   chmod 600 secrets/*
   ```

4. **Update environment variables:**
   Edit `srcs/.env` to match your configuration:
   ```bash
   nano srcs/.env
   ```

**Note:** Volume paths automatically use `$HOME` variable and `$(USER)` for permissions, making the project portable across any machine without modification.

---

## Project Structure

```
Inception_intra_retry_1/
│
├── Makefile                                # Build automation
├── README.md                               # Project documentation
├── USER_DOC.md                             # User guide
├── DEV_DOC.md                              # This file
│
├── secrets/                                # Docker secrets (not in git)
│   ├── mariadb_root_password.txt          # MariaDB root password
│   ├── mariadb_wordpress_password.txt     # WordPress DB user password
│   └── wordpress_author_password.txt      # WordPress author password
│
└── srcs/                                   # Source directory
    ├── .env                                # Environment variables
    ├── docker-compose.yml                  # Service orchestration
    │
    └── requirements/                       # Service definitions
        │
        ├── mariadb/                        # MariaDB service
        │   ├── Dockerfile                  # Image build instructions
        │   ├── conf/
        │   │   └── server.conf             # MariaDB server config
        │   └── tools/
        │       └── setupdb.sh              # Database initialization
        │
        ├── nginx/                          # NGINX service
        │   ├── Dockerfile                  # Image build instructions
        │   ├── conf/
        │   │   └── nginx.conf              # Server block configuration
        │   └── tools/
        │       └── setupssl.sh             # SSL certificate generation
        │
        └── wordpress/                      # WordPress service
            ├── Dockerfile                  # Image build instructions
            ├── conf/
            │   └── www.conf                # PHP-FPM pool configuration
            └── tools/
                └── setup.sh                # WordPress installation script
```

---

## Configuration Files

### 1. Makefile

**Location:** `./Makefile`

**Purpose:** Automates common development tasks

**Targets:**

- `make` or `make all`: Build and start all services
- `make down`: Stop containers (preserve data)
- `make clean`: Stop and remove containers, images, and volumes
- `make fclean`: Complete cleanup including data directories
- `make re`: Rebuild everything from scratch

**Key variables used:**
```makefile
# Automatically configured using system variables
$(HOME)   # User's home directory
$(USER)   # Current username
```
These variables make the Makefile portable across any system without hardcoded paths.

### 2. Docker Compose Configuration

**Location:** `srcs/docker-compose.yml`

**Key sections:**

#### Services Definition:
```yaml
services:
  nginx:
    build: ./requirements/nginx
    container_name: nginx
    image: nginx
    ports:
      - "443:443"              # Only HTTPS exposed
    restart: always
    depends_on:
      - wordpress              # Start after WordPress
    networks:
      - inception_network
    volumes:
      - volume_wordpress:/var/www/wordpress
```

#### Networks:
```yaml
networks:
  inception_network:
    driver: bridge              # Custom bridge network
```

#### Volumes:
```yaml
volumes:
  volume_mariadb:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${HOME}/data/mariadb
```

#### Secrets:
```yaml
secrets:
  mariadb_root_password:
    file: ../secrets/mariadb_root_password.txt
```

**Customization points:**
- Port mappings
- Volume mount paths
- Environment variables
- Dependency order
- Resource limits (add if needed)

### 3. Environment Variables

**Location:** `srcs/.env`

**Variables:**

```bash
# Database Configuration
WORDPRESS_DB_HOST=mariadb           # Container name for DB
WORDPRESS_DB_USER=mlahrach          # WordPress DB user
MARIADB_DATABASE=wordpress          # Database name

# WordPress Configuration
WORDPRESS_ADMIN_EMAIL=admin@example.com
WORDPRESS_SITE_URL=https://mlahrach.42.fr
WORDPRESS_SITE_TITLE=Inception
WORDPRESS_AUTHOR_USER=mohamed
WORDPRESS_AUTHOR_EMAIL=mohamed@gmail.com

# NGINX Configuration
NGINX_DOMAIN_NAME=mlahrach.42.fr    # Used in SSL cert generation
```

**Adding new variables:**
1. Add to `.env` file
2. Reference in docker-compose.yml with `env_file: .env`
3. Access in containers via `$VARIABLE_NAME`

### 4. Service-Specific Configurations

#### NGINX Configuration (`requirements/nginx/conf/nginx.conf`)

```nginx
server {
    listen 443 ssl;                          # HTTPS only
    server_name mlahrach.42.fr;
    
    # SSL Configuration
    ssl_certificate /etc/nginx/ssl/server.crt;
    ssl_certificate_key /etc/nginx/ssl/server.key;
    ssl_protocols TLSv1.2;                   # TLS 1.2 minimum
    
    # Document Root
    root /var/www/wordpress;
    index index.php index.html index.htm;
    
    # PHP-FPM Configuration
    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass wordpress:9000;          # Forward to WordPress container
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}
```

#### PHP-FPM Configuration (`requirements/wordpress/conf/www.conf`)

```ini
[www]
user = www-data
group = www-data

listen = 0.0.0.0:9000                        # Listen on all interfaces
listen.owner = www-data
listen.group = www-data

# Process Manager Settings
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
```

#### MariaDB Configuration (`requirements/mariadb/conf/server.conf`)

```ini
[mysqld]
user = mysql
port = 3306
bind-address = 0.0.0.0                       # Accept connections from any host
datadir = /var/lib/mysql
socket = /run/mysqld/mysqld.sock
```

---

## Building and Launching

### Build Process

**Step-by-step build:**

1. **Create data directories:**
   ```bash
   mkdir -p $HOME/data/mariadb
   mkdir -p $HOME/data/wordpress
   ```

2. **Set permissions:**
   ```bash
   sudo chown -R $USER:$USER $HOME/data/mariadb
   sudo chown -R $USER:$USER $HOME/data/wordpress
   ```

3. **Build images:**
   ```bash
   cd srcs
   docker compose build
   ```

4. **Start services:**
   ```bash
   docker compose up -d
   ```

**Or use Makefile (recommended):**
```bash
make
```

### Build Order and Dependencies

Docker Compose respects `depends_on` to start services in order:

1. **MariaDB** starts first (no dependencies)
2. **WordPress** starts after MariaDB
3. **NGINX** starts after WordPress

### Build Flags and Options

**Rebuild without cache:**
```bash
docker compose build --no-cache
```

**Build specific service:**
```bash
docker compose build nginx
```

**Pull latest base images:**
```bash
docker compose build --pull
```

**View build output:**
```bash
docker compose up --build
```

### Startup Sequence

1. **MariaDB container:**
   - Checks if database initialized
   - Runs `mysql_install_db` if needed
   - Starts MariaDB temporarily
   - Creates database and users
   - Shuts down and restarts in foreground

2. **WordPress container:**
   - Waits for MariaDB to accept connections
   - Downloads WordPress core (if not exists)
   - Creates `wp-config.php`
   - Installs WordPress
   - Creates author user
   - Starts PHP-FPM in foreground

3. **NGINX container:**
   - Generates self-signed SSL certificate
   - Starts NGINX in foreground

**Typical startup time:** 30-60 seconds (first run: 2-5 minutes)

---

## Container Management

### Essential Docker Commands

#### Listing Containers

```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# List with specific format
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

#### Starting and Stopping

```bash
# Start all services
docker compose -f srcs/docker-compose.yml up -d

# Stop all services
docker compose -f srcs/docker-compose.yml down

# Restart specific service
docker restart nginx

# Stop specific service
docker stop wordpress

# Start specific service
docker start wordpress
```

#### Inspecting Containers

```bash
# View container details
docker inspect nginx

# View container configuration
docker inspect --format='{{.Config.Env}}' nginx

# View container networks
docker inspect --format='{{.NetworkSettings.Networks}}' nginx

# View container mounts
docker inspect --format='{{.Mounts}}' mariadb
```

#### Executing Commands in Containers

```bash
# Interactive shell
docker exec -it nginx /bin/bash

# Single command
docker exec nginx ls -la /etc/nginx

# As specific user
docker exec -u www-data wordpress whoami

# Run database query
docker exec mariadb mysql -uroot -p$(cat secrets/mariadb_root_password.txt) -e "SHOW DATABASES;"
```

#### Viewing Logs

```bash
# View all logs
docker compose -f srcs/docker-compose.yml logs

# Follow logs in real-time
docker logs -f wordpress

# Last 50 lines
docker logs --tail 50 nginx

# Logs with timestamps
docker logs -t mariadb

# Logs since specific time
docker logs --since 1h nginx
```

#### Resource Monitoring

```bash
# Real-time stats
docker stats

# Single snapshot
docker stats --no-stream

# Specific containers
docker stats nginx wordpress mariadb
```

### Advanced Container Operations

#### Copying Files

```bash
# Copy from container to host
docker cp nginx:/etc/nginx/nginx.conf ./nginx-backup.conf

# Copy from host to container
docker cp custom.conf nginx:/etc/nginx/conf.d/
```

#### Creating Container Snapshots

```bash
# Commit container to image
docker commit nginx nginx-backup:latest

# Export container filesystem
docker export nginx > nginx-backup.tar
```

#### Network Operations

```bash
# List networks
docker network ls

# Inspect network
docker network inspect srcs_inception_network

# Connect container to network
docker network connect srcs_inception_network my-container
```

---

## Volume and Data Persistence

### Volume Architecture

```
Host Filesystem                Container Filesystem
───────────────                ──────────────────

$HOME/data/mariadb        →   /var/lib/mysql (mariadb)
$HOME/data/wordpress      →   /var/www/wordpress (wordpress, nginx)
```

### Volume Management Commands

#### List Volumes

```bash
# List all volumes
docker volume ls

# List volumes with filter
docker volume ls --filter "name=volume_wordpress"
```

#### Inspect Volumes

```bash
# View volume details
docker volume inspect srcs_volume_mariadb

# View mount points
docker inspect -f '{{ .Mounts }}' mariadb
```

#### Volume Operations

```bash
# Create volume manually
docker volume create --driver local \
  --opt type=none \
  --opt o=bind \
  --opt device=$HOME/data/test \
  test_volume

# Remove unused volumes
docker volume prune

# Remove specific volume (container must be stopped)
docker volume rm srcs_volume_mariadb
```

### Data Storage Locations

#### MariaDB Data

**Host path:** `$HOME/data/mariadb`  
**Container path:** `/var/lib/mysql`

**Contents:**
```
mariadb/
├── aria_log_control
├── ib_buffer_pool
├── ibdata1
├── ib_logfile0
├── mysql/                    # System database
├── performance_schema/       # Performance metrics
└── wordpress/                # WordPress database
    ├── wp_posts.frm
    ├── wp_users.frm
    ├── wp_options.frm
    └── ...
```

**Direct access:**
```bash
# View databases
ls -la $HOME/data/mariadb/

# View WordPress tables
ls -la $HOME/data/mariadb/wordpress/
```

#### WordPress Data

**Host path:** `$HOME/data/wordpress`  
**Container path:** `/var/www/wordpress`

**Contents:**
```
wordpress/
├── wp-config.php             # WordPress configuration
├── wp-content/
│   ├── plugins/              # Installed plugins
│   ├── themes/               # Installed themes
│   └── uploads/              # User-uploaded media
├── wp-admin/                 # Admin interface
├── wp-includes/              # WordPress core
└── index.php                 # Entry point
```

**Direct access:**
```bash
# View WordPress files
ls -la $HOME/data/wordpress/

# Check uploads
ls -la $HOME/data/wordpress/wp-content/uploads/
```

### Backup and Restore

#### Full Backup

```bash
#!/bin/bash
BACKUP_DIR="$HOME/backups/$(date +%Y%m%d_%H%M%S)"

# Stop services
make down

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup volumes
cp -rp $HOME/data/mariadb $BACKUP_DIR/
cp -rp $HOME/data/wordpress $BACKUP_DIR/

# Backup configuration
cp -rp srcs/ $BACKUP_DIR/
cp -rp secrets/ $BACKUP_DIR/

# Restart services
make

echo "Backup completed: $BACKUP_DIR"
```

#### Restore from Backup

```bash
#!/bin/bash
BACKUP_DIR="$HOME/backups/20231215_103000"

# Stop services
make down

# Remove current data
rm -rf $HOME/data/mariadb
rm -rf $HOME/data/wordpress

# Restore from backup
cp -rp $BACKUP_DIR/mariadb $HOME/data/
cp -rp $BACKUP_DIR/wordpress $HOME/data/

# Set permissions
sudo chown -R $USER:$USER $HOME/data/

# Restart services
make

echo "Restore completed from: $BACKUP_DIR"
```

#### Database-Only Backup

```bash
# Export database
docker exec mariadb mysqldump -uroot -p$(cat secrets/mariadb_root_password.txt) \
  --all-databases > backup_$(date +%Y%m%d).sql

# Import database
cat backup_20231215.sql | docker exec -i mariadb mysql -uroot -p$(cat secrets/mariadb_root_password.txt)
```

### Data Persistence Verification

**Test data persistence:**

1. Create test content in WordPress
2. Stop containers: `make down`
3. Start containers: `make`
4. Verify content still exists

**Check volume mounts:**
```bash
# Verify volumes are mounted
docker inspect -f '{{ .Mounts }}' mariadb | python3 -m json.tool

# Check data exists on host
ls -la $HOME/data/mariadb
ls -la $HOME/data/wordpress
```

---

## Networking

### Network Architecture

**Network name:** `srcs_inception_network`  
**Driver:** bridge  
**Subnet:** Assigned automatically by Docker

### Network Inspection

```bash
# List networks
docker network ls

# Inspect network details
docker network inspect srcs_inception_network

# View connected containers
docker network inspect srcs_inception_network \
  --format='{{range .Containers}}{{.Name}} {{end}}'
```

### Container Communication

Containers communicate using **container names as hostnames**:

- NGINX connects to WordPress: `fastcgi_pass wordpress:9000;`
- WordPress connects to MariaDB: `WORDPRESS_DB_HOST=mariadb`

**DNS resolution test:**
```bash
# From WordPress container
docker exec wordpress ping -c 3 mariadb
docker exec wordpress ping -c 3 nginx

# From NGINX container
docker exec nginx ping -c 3 wordpress
```

### Port Mapping

```
External (Host)  →  Internal (Container)  →  Service
──────────────────────────────────────────────────────
443              →  443 (nginx)           →  NGINX HTTPS
(none)           →  9000 (wordpress)      →  PHP-FPM
(none)           →  3306 (mariadb)        →  MariaDB
```

**Only port 443 is exposed to the host machine.**

### Firewall and Security

**Network isolation:**
- MariaDB and WordPress not accessible from host directly
- Only NGINX exposed via port 443
- Containers communicate on isolated bridge network

**Testing connectivity:**
```bash
# From host (should work)
curl -k https://mlahrach.42.fr

# From host (should fail)
curl http://localhost:9000
mysql -h localhost -P 3306
```

### Network Troubleshooting

**Container can't reach another service:**

1. Check container is running:
   ```bash
   docker ps
   ```

2. Verify network attachment:
   ```bash
   docker inspect wordpress --format='{{.NetworkSettings.Networks}}'
   ```

3. Test DNS resolution:
   ```bash
   docker exec wordpress nslookup mariadb
   ```

4. Test connectivity:
   ```bash
   docker exec wordpress nc -zv mariadb 3306
   ```

5. Check firewall rules:
   ```bash
   sudo iptables -L
   ```

---

## Debugging and Development

### Debugging Techniques

#### 1. Container Logs Analysis

```bash
# Follow all logs
docker compose -f srcs/docker-compose.yml logs -f

# Service-specific logs
docker logs -f nginx 2>&1 | grep -i error
docker logs -f wordpress 2>&1 | grep -i "fatal\|error"
docker logs -f mariadb 2>&1 | grep -i "error\|warning"
```

#### 2. Interactive Debugging

```bash
# Shell access
docker exec -it wordpress /bin/bash

# Check processes
docker exec wordpress ps aux

# Check network
docker exec wordpress netstat -tulpn

# Check filesystem
docker exec wordpress df -h
docker exec wordpress ls -la /var/www/wordpress
```

#### 3. Service Health Checks

```bash
# NGINX status
docker exec nginx nginx -t                    # Test config
docker exec nginx nginx -V                    # View version & modules

# PHP-FPM status
docker exec wordpress php-fpm7.4 -t          # Test config
docker exec wordpress php -v                  # View PHP version

# MariaDB status
docker exec mariadb mysqladmin -uroot -p$(cat secrets/mariadb_root_password.txt) status
docker exec mariadb mysqladmin -uroot -p$(cat secrets/mariadb_root_password.txt) ping
```

#### 4. Network Debugging

```bash
# Install tools in container (temporary)
docker exec -it wordpress apt-get update
docker exec -it wordpress apt-get install -y curl netcat-openbsd dnsutils

# Test connections
docker exec wordpress curl -v http://nginx
docker exec wordpress nc -zv mariadb 3306
docker exec wordpress nslookup mariadb
```

### Common Issues and Solutions

#### Issue 1: Container Exits Immediately

**Symptom:** Container status shows "Exited (1)"

**Debug:**
```bash
docker logs mariadb
docker inspect mariadb --format='{{.State}}'
```

**Common causes:**
- Script errors in entrypoint
- Missing permissions
- Process not running in foreground

#### Issue 2: WordPress Can't Connect to Database

**Symptom:** "Error establishing database connection"

**Debug:**
```bash
# Check MariaDB is running
docker exec mariadb mysqladmin ping

# Check WordPress can reach MariaDB
docker exec wordpress ping -c 3 mariadb

# Check database exists
docker exec mariadb mysql -uroot -p$(cat secrets/mariadb_root_password.txt) -e "SHOW DATABASES;"

# Check user permissions
docker exec mariadb mysql -uroot -p$(cat secrets/mariadb_root_password.txt) -e "SELECT user, host FROM mysql.user;"
```

#### Issue 3: NGINX 502 Bad Gateway

**Symptom:** NGINX returns 502 error

**Debug:**
```bash
# Check WordPress PHP-FPM is running
docker exec wordpress ps aux | grep php-fpm

# Check PHP-FPM is listening
docker exec wordpress netstat -tlnp | grep 9000

# Test PHP-FPM from NGINX container
docker exec nginx nc -zv wordpress 9000

# Check NGINX error logs
docker logs nginx 2>&1 | grep -i "upstream"
```

#### Issue 4: Permission Denied Errors

**Symptom:** Can't write files or access directories

**Debug:**
```bash
# Check file ownership
docker exec wordpress ls -la /var/www/wordpress

# Check process user
docker exec wordpress ps aux | grep php-fpm

# Fix permissions
docker exec wordpress chown -R www-data:www-data /var/www/wordpress
```

### Development Workflow

#### Making Changes to Services

**Workflow:**

1. **Modify configuration or code**
2. **Rebuild affected service:**
   ```bash
   docker compose -f srcs/docker-compose.yml build nginx
   ```
3. **Recreate container:**
   ```bash
   docker compose -f srcs/docker-compose.yml up -d --force-recreate nginx
   ```
4. **Test changes**
5. **View logs:**
   ```bash
   docker logs -f nginx
   ```

#### Testing Changes Without Rebuild

**For configuration files:**

```bash
# Copy new config to running container
docker cp srcs/requirements/nginx/conf/nginx.conf nginx:/etc/nginx/sites-available/default

# Reload NGINX
docker exec nginx nginx -s reload
```

#### Rapid Iteration

**Development mode docker-compose:**

Create `srcs/docker-compose.dev.yml`:
```yaml
services:
  wordpress:
    build:
      context: ./requirements/wordpress
      dockerfile: Dockerfile
    volumes:
      - ./requirements/wordpress/tools:/usr/local/bin:ro  # Mount scripts
    command: /bin/bash -c "while true; do php-fpm7.4 -F; done"
```

**Usage:**
```bash
docker compose -f srcs/docker-compose.dev.yml up
```

---

## Customization Guide

### Adding a New Service

**Example: Redis cache**

1. **Create service directory:**
   ```bash
   mkdir -p srcs/requirements/redis/{conf,tools}
   ```

2. **Create Dockerfile:**
   ```dockerfile
   FROM debian:bullseye
   RUN apt-get update && apt-get install -y redis-server
   COPY conf/redis.conf /etc/redis/redis.conf
   EXPOSE 6379
   CMD ["redis-server", "/etc/redis/redis.conf", "--daemonize no"]
   ```

3. **Add to docker-compose.yml:**
   ```yaml
   redis:
     build: ./requirements/redis
     container_name: redis
     restart: always
     networks:
       - inception_network
   ```

4. **Update WordPress to use Redis:**
   Install Redis PHP extension and configure.

### Modifying PHP-FPM Settings

**File:** `srcs/requirements/wordpress/conf/www.conf`

**Common modifications:**

```ini
# Increase max children for higher load
pm.max_children = 10

# Adjust memory limits
php_admin_value[memory_limit] = 256M

# Enable slow log
slowlog = /var/log/php-fpm/slow.log
request_slowlog_timeout = 5s
```

**Apply changes:**
```bash
docker compose -f srcs/docker-compose.yml build wordpress
docker compose -f srcs/docker-compose.yml up -d --force-recreate wordpress
```

### Customizing NGINX Configuration

**Add additional security headers:**

Edit `srcs/requirements/nginx/conf/nginx.conf`:
```nginx
server {
    listen 443 ssl;
    server_name mlahrach.42.fr;
    
    # ... existing config ...
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    
    # ... rest of config ...
}
```

### Adding Environment Variables

1. **Add to `srcs/.env`:**
   ```bash
   MY_NEW_VARIABLE=value
   ```

2. **Use in scripts:**
   ```bash
   echo "Variable value: $MY_NEW_VARIABLE"
   ```

3. **Use in WordPress:**
   Add to `wp-config.php`:
   ```php
   define('MY_CONSTANT', getenv('MY_NEW_VARIABLE'));
   ```

---

## Technical Deep Dives

### How WordPress Installation Works

**File:** `srcs/requirements/wordpress/tools/setup.sh`

**Process:**

1. **Check if already installed:**
   ```bash
   if [ ! -f "wp-config.php" ]; then
   ```

2. **Download WordPress core:**
   ```bash
   wp core download --allow-root
   ```

3. **Wait for database:**
   ```bash
   while ! mariadb -h mariadb -u"$WORDPRESS_DB_USER" -p"$MARIADB_WORDPRESS_PASSWORD"; do
       sleep 2
   done
   ```

4. **Create wp-config.php:**
   ```bash
   wp config create --allow-root \
     --dbname="$MARIADB_DATABASE" \
     --dbuser="$WORDPRESS_DB_USER" \
     --dbpass="$MARIADB_WORDPRESS_PASSWORD" \
     --dbhost="$WORDPRESS_DB_HOST"
   ```

5. **Install WordPress:**
   ```bash
   wp core install --allow-root \
     --url="$WORDPRESS_SITE_URL" \
     --title="$WORDPRESS_SITE_TITLE" \
     --admin_user="$WORDPRESS_DB_USER" \
     --admin_password="$MARIADB_WORDPRESS_PASSWORD" \
     --admin_email="$WORDPRESS_ADMIN_EMAIL"
   ```

6. **Create additional user:**
   ```bash
   wp user create --allow-root \
     "$WORDPRESS_AUTHOR_USER" "$WORDPRESS_AUTHOR_EMAIL" \
     --role=author \
     --user_pass="$WORDPRESS_AUTHOR_PASSWORD"
   ```

7. **Start PHP-FPM:**
   ```bash
   exec php-fpm7.4 -F
   ```

**Idempotency:** The script checks for `wp-config.php` existence, preventing reinstallation.

### How MariaDB Initialization Works

**File:** `srcs/requirements/mariadb/tools/setupdb.sh`

**Process:**

1. **Set ownership:**
   ```bash
   chown -R mysql:mysql /var/run/mysqld
   chown -R mysql:mysql /var/lib/mysql
   ```

2. **Check if first run:**
   ```bash
   if [ ! -f "/var/lib/mysql/.initialized" ]; then
       touch /var/lib/mysql/.initialized
       first_time=1
   fi
   ```

3. **Start MariaDB temporarily:**
   ```bash
   service mariadb start
   ```

4. **Wait for startup:**
   ```bash
   while ! mysqladmin ping ; do
       sleep 2
   done
   ```

5. **Configure on first run:**
   ```bash
   if [ "$first_time" = "1" ]; then
       mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';"
   fi
   ```

6. **Create database and user:**
   ```bash
   mysql -uroot -p"${MARIADB_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\`;"
   mysql -uroot -p"${MARIADB_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS '${WORDPRESS_DB_USER}'@'%' IDENTIFIED BY '${MARIADB_WORDPRESS_PASSWORD}';"
   mysql -uroot -p"${MARIADB_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO '${WORDPRESS_DB_USER}'@'%';"
   ```

7. **Restart in foreground:**
   ```bash
   mysqladmin -u root -p"${MARIADB_ROOT_PASSWORD}" shutdown
   exec mysqld
   ```

### SSL Certificate Generation

**File:** `srcs/requirements/nginx/tools/setupssl.sh`

**Process:**

```bash
# Create directory
mkdir -p /etc/nginx/ssl

# Generate self-signed certificate
openssl req -x509 -nodes \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/server.key \
    -out /etc/nginx/ssl/server.crt \
    -subj "/C=MA/ST=BG/L=1337/O=42/OU=42/CN=$NGINX_DOMAIN_NAME"

# Start NGINX in foreground
exec nginx -g "daemon off;"
```

**Certificate details:**
- **Type:** Self-signed X.509
- **Key size:** 2048-bit RSA
- **Subject:** Uses NGINX_DOMAIN_NAME from environment
- **Validity:** 30 days (OpenSSL default)

---

## Performance Optimization

### Resource Limits

Add to `docker-compose.yml`:

```yaml
services:
  wordpress:
    # ... existing config ...
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
```

### Caching Strategies

1. **OPcache** (PHP opcode cache) - already enabled in PHP 7.4
2. **Redis** - Add as separate service for object caching
3. **NGINX caching** - Add static file caching

**Example NGINX caching:**
```nginx
location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
    expires 30d;
    add_header Cache-Control "public, immutable";
}
```

### Database Optimization

Add to `srcs/requirements/mariadb/conf/server.conf`:

```ini
[mysqld]
# ... existing config ...

# Performance tuning
innodb_buffer_pool_size = 256M
innodb_log_file_size = 64M
query_cache_type = 1
query_cache_size = 32M
max_connections = 100
```

---

## CI/CD Integration

### Automated Testing Script

```bash
#!/bin/bash
# test.sh

set -e

echo "Building services..."
make

echo "Waiting for services to start..."
sleep 30

echo "Testing NGINX..."
curl -k -f https://mlahrach.42.fr || exit 1

echo "Testing database..."
docker exec mariadb mysqladmin ping || exit 1

echo "Testing WordPress..."
curl -k -f https://mlahrach.42.fr/wp-admin || exit 1

echo "All tests passed!"
make down
```

### GitHub Actions Example

```yaml
# .github/workflows/test.yml
name: Test Inception

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build and test
        run: |
          chmod +x test.sh
          ./test.sh
```

---

## Security Best Practices

### Production Checklist

- [ ] Change all default passwords
- [ ] Use real SSL certificates (Let's Encrypt)
- [ ] Implement proper firewall rules
- [ ] Regular security updates
- [ ] Enable fail2ban for brute-force protection
- [ ] Implement rate limiting
- [ ] Regular backups (automated)
- [ ] Monitor logs for suspicious activity
- [ ] Use Docker secrets (not env vars) for sensitive data
- [ ] Implement container security scanning
- [ ] Use read-only volumes where possible
- [ ] Run processes as non-root users
- [ ] Keep Docker and packages updated

---

## Conclusion

This developer documentation covers the essential aspects of building, deploying, and maintaining the Inception infrastructure. For user-facing operations, refer to `USER_DOC.md`. For project overview and requirements, see `README.md`.

**Additional Resources:**
- [Docker Documentation](https://docs.docker.com/)
- [WordPress Developer Handbook](https://developer.wordpress.org/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
- [NGINX Documentation](https://nginx.org/en/docs/)

---

**Last Updated:** December 2025  
**Maintainer:** mlahrach
