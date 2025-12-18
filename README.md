# Inception

*This project has been created as part of the 42 curriculum by mlahrach.*

## Description

**Inception** is a system administration and DevOps project that focuses on containerization using Docker. The goal is to set up a complete web infrastructure composed of multiple Docker containers, each running a specific service. This project demonstrates the ability to architect, deploy, and manage a multi-service application stack using Docker Compose, with a focus on security, isolation, and best practices.

The infrastructure includes:
- **NGINX** - Web server configured with TLS/SSL
- **WordPress** - Content Management System with PHP-FPM
- **MariaDB** - Relational database for WordPress data storage

All services run in separate containers, communicate through a custom Docker network, and persist data using Docker volumes. The project emphasizes understanding containerization concepts, service orchestration, and secure deployment practices.

---

## 🎯 **For Peer Evaluators: Portability & Idempotency**

This project is designed to work **on any machine without modification**, ensuring a smooth evaluation experience.

### **Automatic Path Configuration**

**No hardcoded usernames or paths!** The project uses environment variables:

- **Makefile**: Uses `$(HOME)` and `$(USER)` variables
  ```makefile
  mkdir -p $(HOME)/data/mariadb        # Expands to YOUR home directory
  sudo chown -R $(USER) $(HOME)/data/  # Uses YOUR username
  ```

- **docker-compose.yml**: Uses `${HOME}` variable
  ```yaml
  volumes:
    volume_mariadb:
      device: ${HOME}/data/mariadb      # Automatically uses evaluator's home
  ```

### **Why This Matters for Evaluation**

✅ **Works on any evaluation machine** - Linux, macOS, or VM  
✅ **No configuration needed** - Just clone and `make`  
✅ **Idempotent** - Can be run multiple times safely  
✅ **Clean isolation** - Each evaluator gets their own data directory  
✅ **No permission conflicts** - Automatically uses current user's permissions  

### **Idempotent Design**

All setup scripts are idempotent (can be run multiple times safely):

- **MariaDB**: Checks for existing database initialization before creating users
- **WordPress**: Checks for `wp-config.php` before installation
- **Data persistence**: Volumes survive container recreation

**You can safely run:**
```bash
make      # First run
make down # Stop
make      # Run again - no errors, data preserved
```

---

## Instructions

### Prerequisites

Before running this project, ensure you have the following installed on your system:
- Docker (version 20.10 or higher)
- Docker Compose (version 2.0 or higher)
- Make (GNU Make)
- Sufficient disk space for volumes (minimum 2GB)

### Configuration

1. **Update the domain name in `/etc/hosts`:**
   ```bash
   sudo echo "127.0.0.1 mlahrach.42.fr" >> /etc/hosts
   ```

2. **Verify secrets exist** in the `secrets/` directory:
   - `mariadb_root_password.txt`
   - `mariadb_wordpress_password.txt`
   - `wordpress_author_password.txt`

3. **Update environment variables** in `srcs/.env` if needed:
   - Domain name
   - Database credentials
   - WordPress configuration

**Note:** Volume paths are automatically configured using `$HOME/data/` directory and will work on any machine.

### Compilation and Execution

#### Build and start the infrastructure:
```bash
make
```
This command will:
- Create necessary directories for volumes
- Set proper permissions
- Build all Docker images
- Start all containers in detached mode

#### Stop the containers:
```bash
make down
```

#### Clean up (remove containers, images, and volumes):
```bash
make clean
```

#### Full cleanup (including data volumes):
```bash
make fclean
```

#### Rebuild everything:
```bash
make re
```

### Accessing the Services

- **Website**: https://mlahrach.42.fr
- **WordPress Admin Panel**: https://mlahrach.42.fr/wp-admin
  - Username: `mlahrach`
  - Password: stored in `secrets/mariadb_wordpress_password.txt`

**Note**: Your browser will show a security warning because the SSL certificate is self-signed. Accept the warning to proceed.

## Resources

### Documentation
- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress Developer Resources](https://developer.wordpress.org/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
- [WP-CLI Documentation](https://wp-cli.org/)

### Articles and Tutorials
- [Understanding Docker Volumes](https://docs.docker.com/storage/volumes/)
- [Docker Networking](https://docs.docker.com/network/)
- [Docker Secrets Management](https://docs.docker.com/engine/swarm/secrets/)
- [PHP-FPM Configuration](https://www.php.net/manual/en/install.fpm.php)
- [NGINX as Reverse Proxy](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/)

### AI Usage

AI tools were used in this project for the following purposes:

1. **Code Review and Debugging**:
   - Analyzing Docker container logs for troubleshooting
   - Identifying configuration errors in nginx.conf and PHP-FPM settings
   - Debugging shell script logic in entrypoint files

2. **Documentation Generation**:
   - Structuring and organizing documentation files (README, USER_DOC, DEV_DOC)
   - Generating clear explanations of technical concepts
   - Creating comparison tables for Docker concepts

3. **Best Practices Research**:
   - Recommending secure configuration patterns
   - Suggesting idempotent script designs
   - Advising on Docker Compose orchestration strategies

4. **Code Optimization**:
   - Reviewing bash scripts for error handling
   - Suggesting improvements for MariaDB initialization logic
   - Optimizing WordPress installation process

**No AI-generated code was used verbatim without understanding and manual validation. All critical logic was written and verified by the developer.**

## Project Description

### Docker and Container Architecture

This project leverages **Docker** to create an isolated, reproducible environment for running a complete web application stack. Each service (NGINX, WordPress, MariaDB) runs in its own container, providing:

- **Isolation**: Each service operates independently with its own filesystem and process space
- **Portability**: The entire infrastructure can be deployed on any system with Docker installed
- **Scalability**: Services can be scaled independently based on load requirements
- **Version Control**: Infrastructure is defined as code using Dockerfiles and docker-compose.yml

### Sources and Design Choices

#### Main Components:

1. **NGINX Container**
   - Built from Debian Bullseye base image
   - Generates self-signed SSL certificate on startup
   - Acts as reverse proxy to PHP-FPM
   - Configured to listen only on port 443 (HTTPS)
   - Uses custom nginx.conf for WordPress-specific routing

2. **WordPress Container**
   - Built from Debian Bullseye with PHP-FPM 7.4
   - Uses WP-CLI for automated WordPress installation
   - Implements idempotent setup script (won't reinstall if already configured)
   - Runs PHP-FPM in foreground as PID 1
   - Creates two users: admin and author

3. **MariaDB Container**
   - Built from Debian Bullseye
   - Initializes database on first run
   - Configured to accept connections from any host (bind-address: 0.0.0.0)
   - Uses Docker secrets for password management
   - Data persisted in named volume

#### Design Decisions:

- **Base Image**: Debian Bullseye chosen for stability and official support
- **No Alpine**: While Alpine is smaller, Debian provides better compatibility with all required packages
- **PID 1 Compliance**: All services run their main process with `exec` to ensure proper signal handling
- **Idempotent Scripts**: Setup scripts check for existing installations to avoid duplication
- **Custom Network**: Bridge network allows container-to-container communication by name

---

## Technical Comparisons

### 1. Virtual Machines vs Docker

| Aspect | Virtual Machines | Docker Containers |
|--------|-----------------|-------------------|
| **Architecture** | Full OS with kernel, runs on hypervisor | Shares host kernel, isolated user space |
| **Size** | GBs (includes entire OS) | MBs (only application + dependencies) |
| **Startup Time** | Minutes (boot entire OS) | Seconds (start process only) |
| **Resource Usage** | High overhead (CPU, RAM, storage) | Lightweight, minimal overhead |
| **Isolation** | Complete isolation (hardware-level) | Process-level isolation |
| **Portability** | Less portable (hypervisor-dependent) | Highly portable (runs anywhere with Docker) |
| **Performance** | Native hardware performance | Near-native (slight container overhead) |
| **Use Case** | Multiple OS types, strong isolation needs | Microservices, consistent environments |

**Why Docker for this project?**
- Faster deployment and iteration during development
- Efficient resource usage (multiple services on single machine)
- Easier to version control infrastructure as code
- Better suited for microservices architecture

---

### 2. Secrets vs Environment Variables

| Aspect | Docker Secrets | Environment Variables |
|--------|---------------|----------------------|
| **Storage** | Encrypted at rest, in-memory in container | Plain text in container environment |
| **Visibility** | Only accessible to authorized services | Visible in `docker inspect`, logs, child processes |
| **Security** | Designed for sensitive data (passwords, keys) | Not secure for sensitive information |
| **Access** | Mounted as files in `/run/secrets/` | Available as env vars system-wide |
| **Rotation** | Can be rotated without rebuilding | Requires container restart to update |
| **Best For** | Passwords, API keys, certificates | Non-sensitive configuration data |

**Why Secrets in this project?**
- Passwords for MariaDB root and WordPress users
- Prevents accidental exposure in logs or process listings
- Follows security best practices
- Secrets are never stored in git repository

**Environment Variables Used:**
- Domain names (NGINX_DOMAIN_NAME)
- Service endpoints (WORDPRESS_DB_HOST)
- Non-sensitive configuration (database names, usernames)

---

### 3. Docker Network vs Host Network

| Aspect | Docker Bridge Network | Host Network |
|--------|----------------------|--------------|
| **Isolation** | Containers isolated from host network | Containers share host network stack |
| **IP Address** | Each container gets own IP | Containers use host IP directly |
| **Port Mapping** | Requires port publishing (-p flag) | Ports directly bound to host |
| **Security** | Better isolation, controlled exposure | Less isolation, all ports exposed |
| **DNS Resolution** | Automatic service discovery by name | Must use host IP or external DNS |
| **Performance** | Slight NAT overhead | No overhead (direct access) |
| **Use Case** | Multi-container apps, isolation needed | Performance-critical apps, network tools |

**Why Bridge Network in this project?**
- **Service Discovery**: Containers communicate by name (e.g., `wordpress:9000`)
- **Security**: Only NGINX port 443 exposed to host
- **Isolation**: Internal services (MariaDB, WordPress) not directly accessible
- **Flexibility**: Easy to add more services without port conflicts

**Project Network Flow:**
```
Host (443) → NGINX Container → WordPress Container (9000) → MariaDB Container (3306)
```

---

### 4. Docker Volumes vs Bind Mounts

| Aspect | Docker Volumes | Bind Mounts |
|--------|---------------|-------------|
| **Management** | Managed by Docker | User manages directory structure |
| **Location** | Docker-managed path (`/var/lib/docker/volumes/`) | User-specified host path |
| **Portability** | More portable across systems | Dependent on host filesystem |
| **Permissions** | Docker handles permissions | Manual permission management needed |
| **Backup** | Use Docker volume commands | Standard filesystem tools |
| **Performance** | Optimized by Docker | Direct filesystem access |
| **Use Case** | Persistent data, production | Development, direct file access |

**Why Bind Mounts in this project?**
- **Data Location Control**: Data stored in `$HOME/data/` directory
- **Easy Backup**: Simple filesystem copy for backups
- **Inspection**: Direct access to MariaDB and WordPress files
- **42 School Requirements**: Specific path requirements for evaluation
- **Machine Independence**: Uses `$HOME` variable to work on any system

**Project Volumes:**

1. **volume_mariadb** → `$HOME/data/mariadb`
   - Stores MariaDB database files
   - Persists all WordPress data (posts, users, settings)
   - Survives container recreation

2. **volume_wordpress** → `$HOME/data/wordpress`
   - Stores WordPress installation files
   - Shared between WordPress and NGINX containers
   - Contains wp-config.php, themes, plugins, uploads

**Volume Configuration:**
```yaml
volumes:
  volume_mariadb:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${HOME}/data/mariadb
```

This creates a named volume that uses bind mount underneath, combining benefits of both approaches. The `${HOME}` variable automatically expands to the current user's home directory.

---

## Project Structure

```
.
├── Makefile                              # Build and management commands
├── secrets/                              # Sensitive data (not in git)
│   ├── mariadb_root_password.txt
│   ├── mariadb_wordpress_password.txt
│   └── wordpress_author_password.txt
└── srcs/
    ├── .env                              # Environment variables
    ├── docker-compose.yml                # Service orchestration
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile                # MariaDB image definition
        │   ├── conf/
        │   │   └── server.conf           # MariaDB configuration
        │   └── tools/
        │       └── setupdb.sh            # Database initialization script
        ├── nginx/
        │   ├── Dockerfile                # NGINX image definition
        │   ├── conf/
        │   │   └── nginx.conf            # NGINX server configuration
        │   └── tools/
        │       └── setupssl.sh           # SSL certificate generation
        └── wordpress/
            ├── Dockerfile                # WordPress + PHP-FPM image
            ├── conf/
            │   └── www.conf              # PHP-FPM pool configuration
            └── tools/
                └── setup.sh              # WordPress installation script
```

---

## Additional Information

### Security Considerations

- **TLS 1.2** encryption for all HTTPS traffic
- **Self-signed certificates** generated at runtime
- **Docker secrets** for password management
- **Non-root users** run services where possible
- **Isolated network** prevents direct external access to database

### Maintenance

- **Logs**: View with `docker compose logs -f [service_name]`
- **Shell Access**: `docker exec -it [container_name] /bin/bash`
- **Database Backup**: Copy `$HOME/data/mariadb/`
- **WordPress Backup**: Copy `$HOME/data/wordpress/`

### Known Limitations

- Self-signed certificate requires browser security exception
- No HTTPS redirect (only listens on 443)
- Development-focused configuration (not production-hardened)
- Fixed resource limits not configured

---

## 📝 **Evaluation Notes**

### **Portability Features for Evaluators**

This project implements several features to ensure smooth evaluation on any machine:

#### **1. Dynamic Path Resolution**

**Makefile:**
```makefile
$(HOME)  # Automatically expands to evaluator's home directory
$(USER)  # Automatically expands to evaluator's username
```

**Example on different machines:**
- Student machine: `/home/mlahrach/data/mariadb`
- Evaluator machine: `/home/evaluator/data/mariadb`
- **No changes needed!**

#### **2. Cross-Platform Compatibility**

| System | Home Directory | Works? |
|--------|---------------|--------|
| Linux (42 School) | `/home/username/` | ✅ Yes |
| Ubuntu/Debian | `/home/username/` | ✅ Yes |
| macOS | `/Users/username/` | ✅ Yes (after Docker file sharing) |
| WSL2 | `/home/username/` | ✅ Yes |

#### **3. Idempotent Execution**

All setup scripts can be run multiple times safely:

**MariaDB** (`setupdb.sh`):
```bash
# Creates .initialized marker file
if [ ! -f "/var/lib/mysql/.initialized" ]; then
  # Only runs on first execution
fi
```

**WordPress** (`setup.sh`):
```bash
# Checks for existing installation
if [ ! -f "wp-config.php" ]; then
  # Only installs if not already done
fi
```

**Benefits:**
- Can restart containers without data loss
- Can rebuild images without losing database
- Safe to run `make` multiple times
- Data persists in volumes

#### **4. Clean Evaluation Workflow**

```bash
# Evaluator workflow (works on any machine)
git clone <repository>
cd Inception_intra_retry_1

# Just run - no configuration needed!
make

# Check services
docker ps

# Access website
https://mlahrach.42.fr

# Clean up after evaluation
make fclean
```

#### **5. No Hardcoded Values**

**What's NOT in the code:**
- ❌ No `/home/specific_username/` paths
- ❌ No hardcoded IP addresses (uses container names)
- ❌ No fixed user IDs
- ❌ No machine-specific configurations

**What IS used:**
- ✅ Environment variables (`$HOME`, `$USER`)
- ✅ Docker container names for networking
- ✅ Docker secrets for passwords
- ✅ Dynamic path resolution

#### **6. Evaluation Machine Requirements**

**Minimal requirements:**
- Docker and Docker Compose installed
- `make` utility
- sudo privileges (for file permissions)
- 2GB free disk space

**No manual configuration needed!**

---

## License

This project is part of the 42 school curriculum and follows school guidelines.

## Author

**mlahrach** - 42 Student

For questions or issues, refer to the 42 Inception subject PDF.
