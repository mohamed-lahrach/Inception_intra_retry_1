# Inception

*This project has been created as part of the 42 curriculum by mlahrach.*

## Description

**Inception** is a system administration and DevOps project that focuses on containerization using Docker. The goal is to set up a complete web infrastructure composed of multiple Docker containers, each running a specific service. This project demonstrates the ability to architect, deploy, and manage a multi-service application stack using Docker Compose, with a focus on security, isolation, and best practices.

**What is a Daemon?**
​A daemon is a background process in an operating system that runs continuously, usually without direct interaction from a user. Its main job is to wait for requests, respond to them, or monitor and manage system resources.
​what makes a daemon special is that it starts automatically, keeps running even when no user is logged in, and provides services to other programs not humans directly.
​In MariaDB, the daemon is mysqld. It keeps running in the background, listening for SQL requests from clients (like wordpress, phpMyAdmin, or the sql CLI).
​when a client sends a query (like SELECT, CREATE, or INSERT), the daemon receives it, processes it, and returns the result.
​In Docker, the daemon is dockerd. It stays running in the background and responsible for creating, running, stopping, and managing containers. When you type commands like docker run or docker ps, you're not directly touching containers. Instead, you are sending a request to the Docker daemon, which does the real work.

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

- **Website**: https://mlahrach.42.fr - Regular users can access this. Think of it like going to any blog website (like Medium or WordPress.com); you just read content.
- **WordPress Admin Panel**: https://mlahrach.42.fr/wp-admin - Special area for site administration. Administrators can log in here to manage the site, create posts, and change settings. They can read, write, and modify content.
  - Username: `mlahrach`
  - Password: stored in `secrets/mariadb_wordpress_password.txt`

- **WordPress Author Panel**: https://mlahrach.42.fr/wp-admin - Area for authors to log in and create/edit their own posts.
  - Username: `mohamed`
  - Password: stored in `secrets/wordpress_author_password.txt`

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
### Youtube Videos
- [Docker Tutorial Full Video in Arabic for 10 hours](https://youtu.be/PrusdhS2lmo)

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
- **No Alpine**: While Alpine is smaller, Debian provides better compatibility with all required packages and I am more familiar with .deb distributions.
- **PID 1 Compliance**: All services run their main process with `exec` to ensure proper signal handling
- **Idempotent Scripts**: Setup scripts check for existing installations to avoid duplication
- **Custom Network**: Bridge network allows container-to-container communication by name

---

## Understanding MariaDB Setup (Database Initialization)

This section explains the database initialization process to demonstrate understanding of SQL operations and security practices.

### **The Initialization Script**

The MariaDB container uses a setup script that configures the database on first run. Here's the core SQL commands with detailed explanations:

```bash
# Read passwords from Docker secrets
MARIADB_ROOT_PASSWORD="$(cat /run/secrets/mariadb_root_password)"
MARIADB_WORDPRESS_PASSWORD="$(cat /run/secrets/mariadb_wordpress_password)"

# Wait for MariaDB to be ready
while ! mysqladmin ping ; do
    sleep 2
done

# Set root password (only on first run)
if [ "$first_time" = "1" ]; then
  mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';"
fi

# Create database and user
mysql -uroot -p"${MARIADB_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\`;"
mysql -uroot -p"${MARIADB_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS '${WORDPRESS_DB_USER}'@'%' IDENTIFIED BY '${MARIADB_WORDPRESS_PASSWORD}';"
mysql -uroot -p"${MARIADB_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO '${WORDPRESS_DB_USER}'@'%';"
mysql -uroot -p"${MARIADB_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"
```

### **Command Breakdown:**

#### **1. Reading Docker Secrets**
```bash
MARIADB_ROOT_PASSWORD="$(cat /run/secrets/mariadb_root_password)"
MARIADB_WORDPRESS_PASSWORD="$(cat /run/secrets/mariadb_wordpress_password)"
```

| Component                          | Explanation                                                    |
|------------------------------------|----------------------------------------------------------------|
| `MARIADB_ROOT_PASSWORD=`           | Bash variable assignment                                       |
| `"$(...)"`                         | Command substitution - runs command and stores output          |
| `cat /run/secrets/mariadb_root_password` | Reads the Docker secret file                         |

**What it does**: Reads passwords from Docker secrets (mounted as files) and stores them in bash variables.

**Why needed**: Makes passwords available to subsequent commands while keeping them secure (not hardcoded).

#### **2. Wait for MariaDB to be Ready**
```bash
while ! mysqladmin ping ; do
    sleep 2
done
```

| Component          | Explanation                                                    |
|--------------------|----------------------------------------------------------------|
| `while ! ... do`   | Loop that continues while condition is false                   |
| `mysqladmin ping`  | Tests if MariaDB server is responding                          |
| `!`                | Negation operator (true when ping fails)                       |
| `sleep 2`          | Wait 2 seconds before trying again                             |

**What it does**: Waits until MariaDB is fully started and accepting connections before running SQL commands.

**Why needed**: MariaDB takes a few seconds to start. Without this, SQL commands would fail with "connection refused" errors.

#### **3. The -e Flag (Execute Single Command)**
```bash
mysql -uroot -p"${MARIADB_ROOT_PASSWORD}" -e "SQL_COMMAND_HERE"
```

| Component                       | Explanation                                                    |
|---------------------------------|----------------------------------------------------------------|
| `mysql`                         | MySQL/MariaDB command-line client                              |
| `-uroot`                        | Connect as 'root' user (no space after -u)                     |
| `-p"${MARIADB_ROOT_PASSWORD}"`  | Password flag with variable (no space after -p)                |
| `-e "SQL_COMMAND"`              | Execute a single SQL command and exit                          |

**What it does**: Executes one SQL command non-interactively and exits.

**Why use `-e` instead of heredoc**: Simpler for single commands, easier to debug individual steps, clearer error messages.

#### **4. Idempotent First-Time Check**
```bash
if [ "$first_time" = "1" ]; then
  mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';"
fi
```

| Component                          | Explanation                                      |
|------------------------------------|--------------------------------------------------|
| `if [ "$first_time" = "1" ]`       | Checks if this is the first initialization       |
| `ALTER USER 'root'@'localhost'`    | SQL command to modify root user                  |
| `IDENTIFIED BY '...'`              | Sets/changes the password                        |

**What it does**: On first run only, changes root password from empty to the secure password from Docker secrets.

**Why check first_time**: MariaDB starts with no root password. After first run, root already has a password, so this command is skipped on subsequent runs.

**Idempotent design**: The `.initialized` marker file (created at start) ensures root password is only set once.

#### **5. CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\`;**

| Part                  | Explanation                                                                         |
|-----------------------|-------------------------------------------------------------------------------------|
| `CREATE DATABASE`     | SQL command to create a new database                                                |
| `IF NOT EXISTS`       | **Idempotent check**: Only create if doesn't exist (prevents errors on re-run)      |
| `\`${MARIADB_DATABASE}\`` | Database name from environment variable (backticks escape special chars)        |
| `;`                   | SQL statement terminator                                                            |

**What it does**: Creates a database (typically named "wordpress") to store all WordPress tables (posts, users, comments, etc.).

**Why backticks**: Protects database name from SQL injection and allows special characters.

**Why needed**: WordPress requires a dedicated database to function. This separates WordPress data from MariaDB system tables.

**Idempotent design**: Running this multiple times won't cause errors or duplicate databases.

#### **6. CREATE USER IF NOT EXISTS '${WORDPRESS_DB_USER}'@'%' IDENTIFIED BY '${MARIADB_WORDPRESS_PASSWORD}';**

| Part                              | Explanation                                                              |
|-----------------------------------|--------------------------------------------------------------------------|
| `CREATE USER`                     | SQL command to create a new database user account                        |
| `IF NOT EXISTS`                   | Idempotent check (skip if user already exists)                           |
| `'${WORDPRESS_DB_USER}'`          | Username from environment variable (typically "wordpress")               |
| `@'%'`                            | **Host specification**: `%` = wildcard (any host can connect)            |
| `IDENTIFIED BY`                   | Sets the password for this user                                          |
| `'${MARIADB_WORDPRESS_PASSWORD}'` | Password read from Docker secret file                                    |

**What it does**: Creates a database user that can connect from any container in the Docker network.

**Security consideration**: `@'%'` allows connections from any host. This is safe because:
- The database is isolated in a Docker network (not exposed to internet)
- Only containers in `inception_network` can reach it
- NGINX doesn't have access (only WordPress container does)

**Why not `@'localhost'`**: WordPress container connects remotely (different container), not from localhost.

#### **7. GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO '${WORDPRESS_DB_USER}'@'%';**

| Part                                | Explanation                                                                        |
|-------------------------------------|------------------------------------------------------------------------------------|
| `GRANT`                             | SQL command to assign permissions                                                  |
| `ALL PRIVILEGES`                    | Full permissions (SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, etc.)              |
| `ON \`${MARIADB_DATABASE}\`.*`      | Apply to specified database and all tables (`*`) inside it                         |
| `TO '${WORDPRESS_DB_USER}'@'%'`     | Grant permissions to this specific user                                            |

**What it does**: Gives the WordPress database user complete control over the WordPress database only.

**Permission scope**:
- ✅ Can read/write/delete data in `wordpress` database
- ✅ Can create/drop tables in `wordpress` database
- ❌ Cannot access other databases (like `mysql` system database)
- ❌ Cannot create new users or modify global settings

**Principle of least privilege**: WordPress user only has access to what it needs, not the entire MariaDB server.

#### **8. FLUSH PRIVILEGES;**

**What it does**: Tells MariaDB to reload the grant tables from the `mysql.user` and `mysql.db` tables into memory.

**Why needed**: Changes to user privileges are cached. This command forces MariaDB to apply the changes immediately without restart.

**Without this**: New permissions might not take effect until MariaDB restarts.

---

### **Additional Script Components**

#### **9. Graceful Shutdown Before Production Mode**
```bash
mysqladmin -u root -p"${MARIADB_ROOT_PASSWORD}" shutdown
```

**What it does**: Shuts down the temporary MariaDB instance that was started with `service mariadb start`.

**Why needed**: The script starts MariaDB temporarily to run initialization commands. After setup is complete, it needs to shut down cleanly before starting in production mode.

**Prevents**: Data corruption, lock file conflicts, and ensures a clean state.

#### **10. Start MariaDB in Foreground (PID 1)**
```bash
exec mysqld
```

| Component | Explanation                                                    |
|-----------|----------------------------------------------------------------|
| `exec`    | Replaces the shell process with `mysqld` (becomes PID 1)       |
| `mysqld`  | MariaDB server daemon in foreground mode                       |

**What it does**: Starts MariaDB as the main container process.

**Why `exec`**: 
- Makes `mysqld` PID 1 (required by Docker)
- Allows proper signal handling (SIGTERM for graceful shutdown)
- Container stops when `mysqld` stops

**PID 1 requirement**: Docker sends signals to PID 1. Without `exec`, signals would go to the bash script instead of MariaDB.

#### **11. Set -e (Error Handling)**
```bash
#!/bin/bash
set -e
```

**What it does**: Exit immediately if any command fails (returns non-zero exit code).

**Why critical**: Prevents the script from continuing with partial initialization if something fails (e.g., can't read secrets, MariaDB won't start).

**Safety measure**: Ensures container fails visibly rather than running in broken state.

#### **12. Ownership and Permissions**
```bash
chown -R mysql:mysql /var/run/mysqld
chown -R mysql:mysql /var/lib/mysql
```

**What it does**: Sets correct ownership for MariaDB directories.

**Why needed**: 
- MariaDB runs as `mysql` user (not root) for security
- The `mysql` user needs write permissions to create socket files and database files
- Docker volumes may have wrong ownership initially

---

### **Security Architecture Explained**

This setup implements a **two-tier security model**:

```
┌─────────────────────────────────────────┐
│         MariaDB Container               │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │   root@localhost (full access)  │   │  ← Only accessible inside container
│  │   Password: MARIADB_ROOT_PASSWORD│  │     Used for: admin tasks, backups
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │   wordpress@% (limited access)  │   │  ← Accessible from WordPress container
│  │   Password: MARIADB_WORDPRESS_  │   │     Used for: normal WordPress operations
│  │             PASSWORD            │   │     Access: wordpress DB only
│  └─────────────────────────────────┘   │
│                                         │
└─────────────────────────────────────────┘
         ↑
         │ Only WordPress container can connect
         │ (via Docker network inception_network)
```

**Benefits:**
1. **Separation of concerns**: Root password different from WordPress password
2. **Blast radius limitation**: If WordPress is compromised, attacker only has access to `wordpress` database
3. **Network isolation**: Database not exposed to host or internet
4. **Password management**: Both passwords stored as Docker secrets (not in code)

---

### **Why This Approach (Not Copy-Paste)**

**Understanding demonstrated:**
1. **Idempotent design**: `IF NOT EXISTS` prevents errors on re-runs (professional practice)
2. **Security layers**: Separate users with different privileges (defense in depth)
3. **Network security**: Understanding `@'%'` is safe in Docker networks
4. **Secret management**: Using Docker secrets instead of hardcoded passwords
5. **Principle of least privilege**: WordPress user can't access system tables

**Alternative approaches considered and rejected:**
- ❌ Single root user for everything: Too dangerous, WordPress doesn't need root
- ❌ Using environment variables: Less secure than Docker secrets
- ❌ Manual initialization: Not reproducible, not idempotent
- ✅ Automated, secure, idempotent script: Professional approach

---

## Technical Comparisons

### 1. Virtual Machines vs Docker

| Aspect             | Virtual Machines                         | Docker Containers                          |
|--------------------|------------------------------------------|--------------------------------------------|
| **Architecture**   | Full OS with kernel, runs on hypervisor  | Shares host kernel, isolated user space    |
| **Size**           | GBs (includes entire OS)                 | MBs (only application + dependencies)      |
| **Startup Time**   | Minutes (boot entire OS)                 | Seconds (start process only)               |
| **Resource Usage** | High overhead (CPU, RAM, storage)        | Lightweight, minimal overhead              |
| **Isolation**      | Complete isolation (hardware-level)      | Process-level isolation                    |
| **Portability**    | Less portable (hypervisor-dependent)     | Highly portable (runs anywhere with Docker)|
| **Performance**    | Native hardware performance              | Near-native (slight container overhead)    |
| **Use Case**       | Multiple OS types, strong isolation needs| Microservices, consistent environments     |

**Why Docker for this project?**
- Faster deployment and iteration during development
- Efficient resource usage (multiple services on single machine)
- Easier to version control infrastructure as code
- Better suited for microservices architecture

---

### 2. Secrets vs Environment Variables

| Aspect           | Docker Secrets                                | Environment Variables                              |
|------------------|-----------------------------------------------|----------------------------------------------------|
| **Storage**      | Encrypted at rest, in-memory in container     | Plain text in container environment                |
| **Visibility**   | Only accessible to authorized services        | Visible in `docker inspect`, logs, child processes |
| **Security**     | Designed for sensitive data (passwords, keys) | Not secure for sensitive information               |
| **Access**       | Mounted as files in `/run/secrets/`           | Available as env vars system-wide                  |
| **Rotation**     | Can be rotated without rebuilding             | Requires container restart to update               |
| **Best For**     | Passwords, API keys, certificates             | Non-sensitive configuration data                   |

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

| Aspect              | Docker Bridge Network                      | Host Network                                |
|---------------------|--------------------------------------------|---------------------------------------------|
| **Isolation**       | Containers isolated from host network      | Containers share host network stack         |
| **IP Address**      | Each container gets own IP                 | Containers use host IP directly             |
| **Port Mapping**    | Requires port publishing (-p flag)         | Ports directly bound to host                |
| **Security**        | Better isolation, controlled exposure      | Less isolation, all ports exposed           |
| **DNS Resolution**  | Automatic service discovery by name        | Must use host IP or external DNS            |
| **Performance**     | Slight NAT overhead                        | No overhead (direct access)                 |
| **Use Case**        | Multi-container apps, isolation needed     | Performance-critical apps, network tools    |

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

| Aspect           | Docker Volumes                                   | Bind Mounts                         |
|------------------|--------------------------------------------------|-------------------------------------|
| **Management**   | Managed by Docker                                | User manages directory structure    |
| **Location**     | Docker-managed path (`/var/lib/docker/volumes/`) | User-specified host path            |
| **Portability**  | More portable across systems                     | Dependent on host filesystem        |
| **Permissions**  | Docker handles permissions                       | Manual permission management needed |
| **Backup**       | Use Docker volume commands                       | Standard filesystem tools           |
| **Performance**  | Optimized by Docker                              | Direct filesystem access            |
| **Use Case**     | Persistent data, production                      | Development, direct file access     |

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
volumes:                           # "I'm defining storage"
  volume_mariadb:                  # "Name it 'volume_mariadb'"
    driver: local                  # "Store on this computer"
    driver_opts:                   # "Here's how to do it:"
      type: none                   # "No special filesystem type"
      o: bind                      # "Use bind mount (direct folder connection)"
      device: ${HOME}/data/mariadb # "Connect to this folder on my computer"
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

| System            | Home Directory      | Works?                             |
|-------------------|---------------------|------------------------------------|
| Linux (42 School) | `/home/username/`   | ✅ Yes                             |
| Ubuntu/Debian     | `/home/username/`   | ✅ Yes                             |
| macOS             | `/Users/username/`  | ✅ Yes (after Docker file sharing) |
| WSL2              | `/home/username/`   | ✅ Yes                             |

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
